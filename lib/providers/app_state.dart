import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/daily_activity_summary.dart';
import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/user_stats.dart';
import '../services/impact_service.dart';
import '../services/local_data_service.dart';
import '../services/route_service.dart';
import '../services/storage_service.dart';
import '../utils/calorie_calculator.dart';
import '../utils/distance_calculator.dart';

const int kRestaurantVisitPoints = 15;
const int kRouteCompletionBonus = 20;

class _BadgeThresholds {
  static const int localExplorerPlaces = 3;
  static const int padovaAmbassadorPlaces = 5;
  static const double sustainableTouristCalories = 1000;
  static const int reviewHelperReviews = 3;
  static const int routeCompletedRoutes = 1;
  static const double sustainableWalkerDistanceKm = 2;
  static const int activeTouristSteps = 5000;
}

class _RouteRecommendationThresholds {
  static const int shortMaxSteps = 3000;
  static const int mediumMaxSteps = 8000;
}

class _SimulationStep {
  final double latitude;
  final double longitude;
  final Place? reachedPlace;

  const _SimulationStep({
    required this.latitude,
    required this.longitude,
    this.reachedPlace,
  });
}

class AppState extends ChangeNotifier {
  AppState({
    LocalDataService? localDataService,
    StorageService? storageService,
    RouteService? routeService,
    ImpactService? impactService,
  }) : _localDataService = localDataService ?? LocalDataService(),
       _storageService = storageService ?? StorageService(),
       _routeService = routeService ?? RouteService(),
       _impactService = impactService ?? ImpactService();

  final LocalDataService _localDataService;
  final StorageService _storageService;
  final RouteService _routeService;
  final ImpactService _impactService;

  bool isBootstrapping = true;

  String? username;
  UserStats? userStats;

  List<Place> places = [];
  List<Restaurant> restaurants = [];

  bool isLoadingData = false;
  String? loadError;

  String? lastUnlockedBadgeId;

  RouteLength selectedRouteLength = RouteLength.medium;
  SuggestedRoute? currentRoute;

  bool isSimulationRunning = false;
  int simulationPlacesReached = 0;
  double simulatedDistanceKm = 0;
  double simulatedCalories = 0;
  double? simulatedLatitude;
  double? simulatedLongitude;
  Timer? _simulationTimer;

  DailyActivitySummary? impactActivitySummary;
  bool isLoadingImpactData = false;
  String? impactError;

  bool get isLoggedIn => username != null && username!.isNotEmpty;

  RouteLength get recommendedRouteLength {
    final summary = impactActivitySummary;
    if (summary == null || !summary.hasStepsData) return RouteLength.medium;

    if (summary.totalSteps < _RouteRecommendationThresholds.shortMaxSteps) {
      return RouteLength.short;
    }
    if (summary.totalSteps <= _RouteRecommendationThresholds.mediumMaxSteps) {
      return RouteLength.medium;
    }
    return RouteLength.long;
  }

  Future<bool> loginImpact() async {
    isLoadingImpactData = true;
    impactError = null;
    notifyListeners();

    final success = await _attemptImpactLogin();

    isLoadingImpactData = false;
    notifyListeners();
    return success;
  }

  Future<bool> _attemptImpactLogin() async {
    final reachable = await _impactService.ping();
    if (!reachable) {
      impactError =
          'Servizio IMPACT non raggiungibile: controlla la connessione a Internet.';
      return false;
    }

    final success = await _impactService.login();
    if (!success) {
      impactError =
          'Accesso a IMPACT non riuscito: verifica le credenziali configurate.';
    }
    return success;
  }

  Future<void> logoutImpact() async {
    await _impactService.logout();
    impactActivitySummary = null;
    impactError = null;
    notifyListeners();
  }

  Future<bool> hasValidImpactSession() => _impactService.hasValidSession();

  Future<void> loadYesterdayActivityData() => _loadImpactSummary(null);

  Future<void> loadActivityDataForDate(DateTime date) =>
      _loadImpactSummary(date);

  Future<void> _loadImpactSummary(DateTime? referenceDate) async {
    isLoadingImpactData = true;
    impactError = null;
    notifyListeners();

    var hasSession = await _impactService.hasValidSession();
    if (!hasSession) {
      hasSession = await _attemptImpactLogin();
    }

    if (hasSession) {
      final summary = await _impactService.getDailyActivitySummary(
        referenceDate,
      );
      impactActivitySummary = summary;

      if (!summary.hasAnyData) {
        impactError = 'Nessun dato disponibile dal paziente per questa data.';
      } else if (summary.hasStepsData &&
          summary.totalSteps > _BadgeThresholds.activeTouristSteps) {
        await _unlockBadgeManually('active_tourist');
      }
    } else {
      // se login/ping falliscono teniamo comunque un riepilogo vuoto invece di null
      impactActivitySummary = DailyActivitySummary.empty(
        _impactService.resolveAvailableDate(referenceDate),
      );
    }

    isLoadingImpactData = false;
    notifyListeners();
  }

  Future<void> _unlockBadgeManually(String badgeId) async {
    final stats = userStats;
    if (stats == null || stats.unlockedBadgeIds.contains(badgeId)) return;

    userStats = stats.copyWith(
      unlockedBadgeIds: [...stats.unlockedBadgeIds, badgeId],
    );
    lastUnlockedBadgeId = badgeId;
    await _persistStats();
  }

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
    _storageService.savePreferredRouteLength(length.name);
    notifyListeners();
  }

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

  List<_SimulationStep> _simulationPath = [];
  int _simulationStepIndex = 0;

  // totalDuration è solo la durata dell'animazione, non è a velocità di camminata reale
  void startRouteSimulation({
    Duration totalDuration = const Duration(seconds: 45),
    int stepsPerSegment = 30,
  }) {
    final route = currentRoute;
    if (route == null || route.places.isEmpty || isSimulationRunning) return;

    _simulationPath = _buildSimulationPath(
      route,
      stepsPerSegment: stepsPerSegment,
    );
    _simulationStepIndex = 0;

    isSimulationRunning = true;
    simulationPlacesReached = 0;
    simulatedDistanceKm = 0;
    simulatedCalories = 0;
    simulatedLatitude = route.startLatitude;
    simulatedLongitude = route.startLongitude;
    notifyListeners();

    final tickMs = (totalDuration.inMilliseconds / _simulationPath.length)
        .round()
        .clamp(50, 2000);
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: tickMs),
      (_) => _advanceSimulationStep(),
    );
  }

  List<_SimulationStep> _buildSimulationPath(
    SuggestedRoute route, {
    required int stepsPerSegment,
  }) {
    final path = <_SimulationStep>[];
    var lat = route.startLatitude;
    var lng = route.startLongitude;

    for (final place in route.places) {
      for (var i = 1; i <= stepsPerSegment; i++) {
        final t = i / stepsPerSegment;
        path.add(
          _SimulationStep(
            latitude: lat + (place.latitude - lat) * t,
            longitude: lng + (place.longitude - lng) * t,
            reachedPlace: i == stepsPerSegment ? place : null,
          ),
        );
      }
      lat = place.latitude;
      lng = place.longitude;
    }
    return path;
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    isSimulationRunning = false;
    notifyListeners();
  }

  Future<void> _advanceSimulationStep() async {
    if (_simulationStepIndex >= _simulationPath.length) {
      await _finishSimulation();
      return;
    }

    final step = _simulationPath[_simulationStepIndex];
    final fromLat = simulatedLatitude ?? step.latitude;
    final fromLng = simulatedLongitude ?? step.longitude;

    simulatedDistanceKm += haversineDistanceKm(
      fromLat,
      fromLng,
      step.latitude,
      step.longitude,
    );
    simulatedCalories = estimateCaloriesForDistance(simulatedDistanceKm);
    simulatedLatitude = step.latitude;
    simulatedLongitude = step.longitude;
    _simulationStepIndex++;

    if (step.reachedPlace != null) {
      simulationPlacesReached++;
      await markPlaceVisited(step.reachedPlace!.id);
    }

    notifyListeners();

    if (_simulationStepIndex >= _simulationPath.length) {
      await _finishSimulation();
    }
  }

  Future<void> _finishSimulation() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    isSimulationRunning = false;
    _simulationPath = [];
    _simulationStepIndex = 0;

    await completeCurrentRoute();

    simulatedLatitude = null;
    simulatedLongitude = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
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
    final savedRouteLengthName = await _storageService
        .loadPreferredRouteLength();
    if (savedRouteLengthName != null) {
      selectedRouteLength = RouteLength.values.firstWhere(
        (length) => length.name == savedRouteLengthName,
        orElse: () => RouteLength.medium,
      );
    }

    final savedUsername = await _storageService.loadUsername();
    if (savedUsername == null || savedUsername.isEmpty) return;

    final savedStats = await _storageService.loadUserStats(savedUsername);
    username = savedUsername;
    userStats = savedStats ?? UserStats.empty(savedUsername);
  }

  Future<void> login(String name) async {
    username = name;
    userStats =
        await _storageService.loadUserStats(name) ?? UserStats.empty(name);
    await _storageService.saveUsername(name);
    await _persistStats();
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.clearActiveSession();
    username = null;
    userStats = null;
    notifyListeners();
  }

  Future<String?> registerAccount(String username, String password) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return 'Inserisci username e password.';
    }

    final alreadyExists = await _storageService.usernameExists(trimmedUsername);
    if (alreadyExists) {
      return 'Username già in uso: scegline un altro.';
    }

    await _storageService.registerCredentials(trimmedUsername, password);
    await login(trimmedUsername);
    return null;
  }

  Future<String?> loginWithPassword(String username, String password) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return 'Inserisci username e password.';
    }

    final valid = await _storageService.verifyCredentials(
      trimmedUsername,
      password,
    );
    if (!valid) {
      return 'Username o password non corretti.';
    }

    await login(trimmedUsername);
    return null;
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
    final exists = restaurants.any(
      (restaurant) => restaurant.id == restaurantId,
    );
    if (!exists) return;

    final stats = userStats;
    if (stats == null || stats.visitedRestaurantIds.contains(restaurantId))
      return;

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

  Future<void> _applyStatsUpdate(UserStats updated) async {
    final newlyUnlocked = _evaluateNewlyUnlockedBadges(updated);
    final withBadges = newlyUnlocked.isEmpty
        ? updated
        : updated.copyWith(
            unlockedBadgeIds: [...updated.unlockedBadgeIds, ...newlyUnlocked],
          );

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
    unlockIfNeeded(
      'route_completed',
      stats.completedRoutes >= _BadgeThresholds.routeCompletedRoutes,
    );
    unlockIfNeeded(
      'sustainable_walker',
      stats.completedRoutes >= _BadgeThresholds.routeCompletedRoutes &&
          stats.totalDistanceKm >= _BadgeThresholds.sustainableWalkerDistanceKm,
    );

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
          stats.visitedPlaceIds.contains(place.id) &&
          culturalCategories.contains(place.category),
    );
  }

  Future<void> _persistStats() async {
    final stats = userStats;
    if (stats == null) return;
    await _storageService.saveUserStats(stats);
  }
}
