import 'package:flutter_test/flutter_test.dart';
import 'package:beapp/models/place.dart';
import 'package:beapp/services/route_service.dart';

void main() {
  final places = [
    const Place(
      id: 'a',
      name: 'A',
      description: 'desc',
      category: PlaceCategory.history,
      latitude: 45.40,
      longitude: 11.87,
      points: 10,
      averageVisitTimeMinutes: 20,
      averageRating: 4.5,
    ),
    const Place(
      id: 'b',
      name: 'B',
      description: 'desc',
      category: PlaceCategory.culture,
      latitude: 45.41,
      longitude: 11.90,
      points: 15,
      averageVisitTimeMinutes: 30,
      averageRating: 4.8,
    ),
  ];

  test('buildRoute ordina i luoghi per vicinanza e somma punti/tempo', () {
    final route = RouteService().buildRoute(
      availablePlaces: places,
      length: RouteLength.long,
      startLatitude: 45.40,
      startLongitude: 11.87,
    );

    expect(route.places, hasLength(2));
    expect(route.places.first.id, 'a'); // il più vicino al punto di partenza
    expect(route.totalPoints, 25);
    expect(route.distanceKm, greaterThan(0));
    expect(route.estimatedCalories, greaterThan(0));
  });

  test(
    'buildRoute breve esclude una tappa troppo lontana per l\'obiettivo di distanza',
    () {
      // 'b' dista circa 2.6 km da 'a', troppo per il "Breve" (max 2.1 km)
      final route = RouteService().buildRoute(
        availablePlaces: places,
        length: RouteLength.short,
        startLatitude: 45.40,
        startLongitude: 11.87,
      );

      expect(route.places, hasLength(1));
      expect(route.places.first.id, 'a');
      expect(route.distanceKm, lessThan(RouteLength.short.maxDistanceKm));
    },
  );

  test('un percorso lungo può includere una tappa che uno breve esclude', () {
    final shortRoute = RouteService().buildRoute(
      availablePlaces: places,
      length: RouteLength.short,
      startLatitude: 45.40,
      startLongitude: 11.87,
    );
    final longRoute = RouteService().buildRoute(
      availablePlaces: places,
      length: RouteLength.long,
      startLatitude: 45.40,
      startLongitude: 11.87,
    );

    expect(shortRoute.places.length, lessThan(longRoute.places.length));
    expect(shortRoute.distanceKm, lessThan(longRoute.distanceKm));
  });
}