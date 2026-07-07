import 'package:flutter_test/flutter_test.dart';
import 'package:beapp/models/place.dart';
import 'package:beapp/models/menu_item.dart';
import 'package:beapp/models/restaurant.dart';
import 'package:beapp/models/review.dart';
import 'package:beapp/models/user_stats.dart';

void main() {
  group('Place', () {
    test('fromJson/toJson round trip', () {
      final json = {
        'id': 'place_001',
        'name': 'Prato della Valle',
        'description': 'Piazza storica di Padova.',
        'category': 'history',
        'latitude': 45.3987,
        'longitude': 11.8767,
        'points': 10,
        'averageVisitTimeMinutes': 20,
        'imagePath': null,
        'isVisited': false,
        'averageRating': 4.6,
      };

      final place = Place.fromJson(json);

      expect(place.name, 'Prato della Valle');
      expect(place.category, PlaceCategory.history);
      expect(place.isVisited, false);
      expect(place.toJson()['category'], 'history');
    });

    test('copyWith aggiorna isVisited senza toccare gli altri campi', () {
      final place = Place.fromJson({
        'id': 'place_001',
        'name': 'Prato della Valle',
        'description': 'desc',
        'category': 'history',
        'latitude': 45.3987,
        'longitude': 11.8767,
        'points': 10,
        'averageVisitTimeMinutes': 20,
        'isVisited': false,
        'averageRating': 4.6,
      });

      final visited = place.copyWith(isVisited: true);

      expect(visited.isVisited, true);
      expect(visited.id, place.id);
      expect(visited.points, place.points);
    });
  });

  group('Restaurant', () {
    test('fromJson costruisce menu annidato', () {
      final json = {
        'id': 'rest_001',
        'name': 'Osteria del Borgo',
        'type': 'restaurant',
        'description': 'desc',
        'latitude': 45.4064,
        'longitude': 11.8768,
        'priceRange': '€€',
        'localCultureConnection': 'legame culturale',
        'typicalDishes': ['Bigoli in salsa'],
        'menu': [
          {
            'itemName': 'Bigoli in salsa',
            'description': 'Pasta tipica veneta',
            'calories': 420,
            'price': 9.5,
            'isTypicalLocalProduct': true,
            'category': 'food',
          },
        ],
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.type, RestaurantType.restaurant);
      expect(restaurant.menu, hasLength(1));
      expect(restaurant.menu.first, isA<MenuItem>());
      expect(restaurant.menu.first.isTypicalLocalProduct, true);
    });
  });

  group('Review', () {
    test('rating fuori range solleva un assertion error', () {
      expect(
        () => Review(placeId: 'place_001', rating: 6, createdAt: DateTime.now()),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('UserStats', () {
    test('empty ha tutti i contatori a zero', () {
      final stats = UserStats.empty('mario');

      expect(stats.totalPoints, 0);
      expect(stats.visitedPlaceIds, isEmpty);
    });

    test('fromJson/toJson round trip mantiene i valori', () {
      final stats = UserStats(
        username: 'mario',
        totalPoints: 25,
        visitedPlaceIds: const ['place_001'],
      );

      final restored = UserStats.fromJson(stats.toJson());

      expect(restored.username, 'mario');
      expect(restored.totalPoints, 25);
      expect(restored.visitedPlaceIds, ['place_001']);
    });
  });
}
