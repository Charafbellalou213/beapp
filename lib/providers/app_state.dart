import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/user_stats.dart';
import '../services/local_data_service.dart';

/// Stato centrale dell'app: dati caricati dai JSON locali e progressi
/// dell'utente corrente. Le schermate leggono questo stato con
/// `Consumer<AppState>` o `context.watch<AppState>()`.
class AppState extends ChangeNotifier {
  AppState({LocalDataService? localDataService})
      : _localDataService = localDataService ?? LocalDataService();

  final LocalDataService _localDataService;

  String? username;
  UserStats? userStats;

  List<Place> places = [];
  List<Restaurant> restaurants = [];

  bool isLoadingData = false;
  String? loadError;

  bool get isLoggedIn => username != null && username!.isNotEmpty;

  Future<void> loadInitialData() async {
    isLoadingData = true;
    loadError = null;
    notifyListeners();

    try {
      final loadedPlaces = await _localDataService.loadPlaces();
      final loadedRestaurants = await _localDataService.loadRestaurants();
      places = loadedPlaces;
      restaurants = loadedRestaurants;
    } catch (_) {
      loadError = 'Impossibile caricare i dati locali di luoghi e ristoranti.';
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  void setUsername(String name) {
    username = name;
    userStats ??= UserStats.empty(name);
    notifyListeners();
  }

  void markPlaceVisited(String placeId) {
    final index = places.indexWhere((place) => place.id == placeId);
    if (index == -1) return;

    final place = places[index];
    if (place.isVisited) return;

    places[index] = place.copyWith(isVisited: true);

    final stats = userStats;
    if (stats != null) {
      userStats = stats.copyWith(
        totalPoints: stats.totalPoints + place.points,
        visitedPlaceIds: [...stats.visitedPlaceIds, placeId],
      );
    }

    notifyListeners();
  }

  void addReview(Review review) {
    final stats = userStats;
    if (stats == null) return;

    userStats = stats.copyWith(reviews: [...stats.reviews, review]);
    notifyListeners();
  }
}
