import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/user_stats.dart';
import '../services/local_data_service.dart';
import '../services/route_service.dart';
import '../services/storage_service.dart';

/// Punti assegnati per aver "visitato" (mangiato/bevuto qualcosa presso) un
/// locale tipico. I luoghi turistici hanno un valore `points` proprio nel
/// JSON; per i ristoranti usiamo un valore fisso più semplice da spiegare.
const int kRestaurantVisitPoints = 15;

/// Bonus assegnato per aver completato un intero percorso (oltre ai punti
/// dei singoli luoghi, assegnati separatamente da `markPlaceVisited`).
const int kRouteCompletionBonus = 20;

/// Soglie minime per sbloccare i badge di `kAllBadges` (vedi models/badge.dart).
class _BadgeThresholds {
  static const int localExplorerPlaces = 3;
  static const int padovaAmbassadorPlaces = 5;
  static const double sustainableTouristCalories = 1000;
  static const int reviewHelperReviews = 3;
  static const int walkingDaySteps = 6000;
}

/// Stato centrale dell'app: dati caricati dai JSON locali e progressi
/// dell'utente corrente, persistiti in shared_preferences tramite
/// `StorageService`. Le schermate leggono questo stato con
/// `Consumer<AppState>` o `context.watch<AppState>()`.
class AppState extends ChangeNotifier {
  AppState({
    LocalDataService? localDataService,
    StorageService? storageService,
    RouteService? routeService,
  })  : _localDataService = localDataService ?? LocalDataService(),
        _storageService = storageService ?? StorageService(),
        _routeService = routeService ?? RouteService();

  final LocalDataService _localDataService;
  final StorageService _storageService;
  final RouteService _routeService;

  bool isBootstrapping = true;

  String? username;
  UserStats? userStats;

  List<Place> places = [];
  List<Restaurant> restaurants = [];

  bool isLoadingData = false;
  String? loadError;

  /// Ultimo badge sbloccato durante l'ultima azione, utile per mostrare un
  /// piccolo messaggio di congratulazioni nella UI. La schermata che lo
  /// consuma dovrebbe azzerarlo con [clearLastUnlockedBadgeId].
  String? lastUnlockedBadgeId;

  RouteLength selectedRouteLength = RouteLength.medium;
  SuggestedRoute? currentRoute;

  bool get isLoggedIn => username != null && username!.isNotEmpty;

  void selectRoute(
    RouteLength length, {
    required double startLatitude,
    required double startLongitude,
  }) {
    selectedRouteLength = length;
    currentRoute = _routeService.buildRoute(
      availablePlaces: places,
      length: length,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
    );
    notifyListeners();
  }

  /// Segna come visitati tutti i luoghi del percorso corrente (i punti dei
  /// singoli luoghi arrivano da qui, tramite `markPlaceVisited`), poi
  /// aggiunge calorie/distanza stimate e un bonus fisso di completamento.
  Future<void> completeCurrentRoute() async {
    final route = currentRoute;
    if (route == null) return;

    for (final place in route.places) {
      await markPlaceVisited(place.id);
    }

    final stats = userStats;
    if (stats == null) return;

    final updated = stats.copyWith(
      totalPoints: stats.totalPoints + kRouteCompletionBonus,
      totalCalories: stats.totalCalories + route.estimatedCalories,
      totalDistanceKm: stats.totalDistanceKm + route.distanceKm,
      completedRoutes: stats.completedRoutes + 1,
    );
    await _applyStatsUpdate(updated);
    currentRoute = null;
  }

  Future<void> bootstrap() async {
    isBootstrapping = true;
    notifyListeners();

    await Future.wait([_loadLocalData(), _restoreSession()]);

    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> _loadLocalData() async {
    isLoadingData = true;
    loadError = null;

    try {
      final loadedPlaces = await _localDataService.loadPlaces();
      final loadedRestaurants = await _localDataService.loadRestaurants();
      places = loadedPlaces;
      restaurants = loadedRestaurants;
    } catch (_) {
      loadError = 'Impossibile caricare i dati locali di luoghi e ristoranti.';
    } finally {
      isLoadingData = false;
    }
  }

  Future<void> _restoreSession() async {
    final savedUsername = await _storageService.loadUsername();
    if (savedUsername == null || savedUsername.isEmpty) return;

    final savedStats = await _storageService.loadUserStats();
    username = savedUsername;
    userStats = savedStats ?? UserStats.empty(savedUsername);
  }

  Future<void> login(String name) async {
    username = name;
    userStats ??= UserStats.empty(name);
    await _storageService.saveUsername(name);
    await _persistStats();
    notifyListeners();
  }

  void clearLastUnlockedBadgeId() {
    lastUnlockedBadgeId = null;
  }

  Future<void> markPlaceVisited(String placeId) async {
    final index = places.indexWhere((place) => place.id == placeId);
    if (index == -1) return;

    final place = places[index];
    if (place.isVisited) return;

    places[index] = place.copyWith(isVisited: true);

    final stats = userStats;
    if (stats != null) {
      final updated = stats.copyWith(
        totalPoints: stats.totalPoints + place.points,
        visitedPlaceIds: [...stats.visitedPlaceIds, placeId],
      );
      await _applyStatsUpdate(updated);
    } else {
      notifyListeners();
    }
  }

  Future<void> markRestaurantVisited(String restaurantId) async {
    final exists = restaurants.any((restaurant) => restaurant.id == restaurantId);
    if (!exists) return;

    final stats = userStats;
    if (stats == null || stats.visitedRestaurantIds.contains(restaurantId)) return;

    final updated = stats.copyWith(
      totalPoints: stats.totalPoints + kRestaurantVisitPoints,
      visitedRestaurantIds: [...stats.visitedRestaurantIds, restaurantId],
    );
    await _applyStatsUpdate(updated);
  }

  Future<void> addReview(Review review) async {
    final stats = userStats;
    if (stats == null) return;

    final updated = stats.copyWith(reviews: [...stats.reviews, review]);
    await _applyStatsUpdate(updated);
  }

  /// Applica un aggiornamento a [userStats], verifica se sono stati
  /// sbloccati nuovi badge, salva tutto e notifica la UI.
  Future<void> _applyStatsUpdate(UserStats updated) async {
    final newlyUnlocked = _evaluateNewlyUnlockedBadges(updated);
    final withBadges = newlyUnlocked.isEmpty
        ? updated
        : updated.copyWith(unlockedBadgeIds: [...updated.unlockedBadgeIds, ...newlyUnlocked]);

    userStats = withBadges;
    lastUnlockedBadgeId = newlyUnlocked.isNotEmpty ? newlyUnlocked.last : null;

    await _persistStats();
    notifyListeners();
  }

  List<String> _evaluateNewlyUnlockedBadges(UserStats stats) {
    final alreadyUnlocked = stats.unlockedBadgeIds.toSet();
    final newlyUnlocked = <String>[];

    void unlockIfNeeded(String badgeId, bool condition) {
      if (condition && !alreadyUnlocked.contains(badgeId)) {
        newlyUnlocked.add(badgeId);
      }
    }

    unlockIfNeeded('first_step', stats.visitedPlaceIds.isNotEmpty);
    unlockIfNeeded(
      'local_explorer',
      stats.visitedPlaceIds.length >= _BadgeThresholds.localExplorerPlaces,
    );
    unlockIfNeeded(
      'padova_ambassador',
      stats.visitedPlaceIds.length >= _BadgeThresholds.padovaAmbassadorPlaces,
    );
    unlockIfNeeded(
      'sustainable_tourist',
      stats.totalCalories >= _BadgeThresholds.sustainableTouristCalories,
    );
    unlockIfNeeded(
      'culture_supporter',
      _hasVisitedCulturalPlace(stats) && stats.visitedRestaurantIds.isNotEmpty,
    );
    unlockIfNeeded(
      'review_helper',
      stats.reviews.length >= _BadgeThresholds.reviewHelperReviews,
    );
    unlockIfNeeded('walking_day', stats.totalSteps >= _BadgeThresholds.walkingDaySteps);

    return newlyUnlocked;
  }

  bool _hasVisitedCulturalPlace(UserStats stats) {
    const culturalCategories = {
      PlaceCategory.history,
      PlaceCategory.culture,
      PlaceCategory.art,
    };
    return places.any(
      (place) =>
          stats.visitedPlaceIds.contains(place.id) && culturalCategories.contains(place.category),
    );
  }

  Future<void> _persistStats() async {
    final stats = userStats;
    if (stats == null) return;
    await _storageService.saveUserStats(stats);
  }
}
