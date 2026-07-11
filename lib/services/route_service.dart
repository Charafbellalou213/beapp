import '../models/place.dart';
import '../utils/calorie_calculator.dart';
import '../utils/constants.dart';
import '../utils/distance_calculator.dart';

enum RouteLength {
  short(targetDistanceKm: 1.5, maxDistanceKm: 2.1, label: 'Breve'),
  medium(targetDistanceKm: 3.0, maxDistanceKm: 3.0, label: 'Medio'),
  long(targetDistanceKm: double.infinity, maxDistanceKm: double.infinity, label: 'Lungo');

  final double targetDistanceKm;
  final double maxDistanceKm;
  final String label;
  const RouteLength({
    required this.targetDistanceKm,
    required this.maxDistanceKm,
    required this.label,
  });
}

class SuggestedRoute {
  final RouteLength length;
  final List<Place> places;
  final double distanceKm;
  final int estimatedMinutes;
  final double estimatedCalories;
  final int totalPoints;
  final double startLatitude;
  final double startLongitude;

  const SuggestedRoute({
    required this.length,
    required this.places,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.estimatedCalories,
    required this.totalPoints,
    required this.startLatitude,
    required this.startLongitude,
  });
}

// ordina i luoghi per vicinanza (nearest-neighbor) e si ferma alla prima
// soglia raggiunta tra distanza obiettivo e numero massimo di tappe
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
    var accumulatedDistance = 0.0;

    while (remaining.isNotEmpty) {
      remaining.sort(
        (a, b) => haversineDistanceKm(currentLat, currentLng, a.latitude, a.longitude)
            .compareTo(haversineDistanceKm(currentLat, currentLng, b.latitude, b.longitude)),
      );
      final next = remaining.first;
      final legDistance = haversineDistanceKm(currentLat, currentLng, next.latitude, next.longitude);

      // la prima tappa va sempre inclusa, il limite di distanza vale dalla seconda in poi
      if (ordered.isNotEmpty && accumulatedDistance + legDistance > length.maxDistanceKm) {
        break;
      }

      remaining.removeAt(0);
      ordered.add(next);
      accumulatedDistance += legDistance;
      currentLat = next.latitude;
      currentLng = next.longitude;
    }

    final walkingMinutes = (accumulatedDistance / AppConstants.walkingSpeedKmh * 60).round();
    final visitMinutes = ordered.fold<int>(0, (sum, p) => sum + p.averageVisitTimeMinutes);
    final totalPoints = ordered.fold<int>(0, (sum, p) => sum + p.points);

    return SuggestedRoute(
      length: length,
      places: ordered,
      distanceKm: accumulatedDistance,
      estimatedMinutes: walkingMinutes + visitMinutes,
      estimatedCalories: estimateCaloriesForDistance(accumulatedDistance, userWeightKg: userWeightKg),
      totalPoints: totalPoints,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
    );
  }
}