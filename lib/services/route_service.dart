import '../models/place.dart';
import '../utils/calorie_calculator.dart';
import '../utils/constants.dart';
import '../utils/distance_calculator.dart';

enum RouteLength {
  short(placeCount: 2, label: 'Breve'),
  medium(placeCount: 4, label: 'Medio'),
  long(placeCount: 6, label: 'Lungo');

  final int placeCount;
  final String label;
  const RouteLength({required this.placeCount, required this.label});
}

class SuggestedRoute {
  final RouteLength length;
  final List<Place> places;
  final double distanceKm;
  final int estimatedMinutes;
  final double estimatedCalories;
  final int totalPoints;

  const SuggestedRoute({
    required this.length,
    required this.places,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.estimatedCalories,
    required this.totalPoints,
  });
}

/// Costruisce un percorso a piedi semplice: ordina i luoghi per vicinanza
/// (nearest-neighbor, senza ottimizzazione TSP) a partire da un punto di
/// partenza, fino al numero di tappe previsto dalla lunghezza scelta.
class RouteService {
  SuggestedRoute buildRoute({
    required List<Place> availablePlaces,
    required RouteLength length,
    required double startLatitude,
    required double startLongitude,
    double userWeightKg = AppConstants.defaultUserWeightKg,
  }) {
    final remaining = List<Place>.from(availablePlaces);
    final ordered = <Place>[];

    var currentLat = startLatitude;
    var currentLng = startLongitude;

    while (ordered.length < length.placeCount && remaining.isNotEmpty) {
      remaining.sort(
        (a, b) => haversineDistanceKm(currentLat, currentLng, a.latitude, a.longitude)
            .compareTo(haversineDistanceKm(currentLat, currentLng, b.latitude, b.longitude)),
      );
      final next = remaining.removeAt(0);
      ordered.add(next);
      currentLat = next.latitude;
      currentLng = next.longitude;
    }

    var totalDistance = 0.0;
    var lat = startLatitude;
    var lng = startLongitude;
    for (final place in ordered) {
      totalDistance += haversineDistanceKm(lat, lng, place.latitude, place.longitude);
      lat = place.latitude;
      lng = place.longitude;
    }

    final walkingMinutes = (totalDistance / AppConstants.walkingSpeedKmh * 60).round();
    final visitMinutes = ordered.fold<int>(0, (sum, p) => sum + p.averageVisitTimeMinutes);
    final totalPoints = ordered.fold<int>(0, (sum, p) => sum + p.points);

    return SuggestedRoute(
      length: length,
      places: ordered,
      distanceKm: totalDistance,
      estimatedMinutes: walkingMinutes + visitMinutes,
      estimatedCalories: estimateCaloriesForDistance(totalDistance, userWeightKg: userWeightKg),
      totalPoints: totalPoints,
    );
  }
}
