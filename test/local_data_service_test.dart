import 'package:flutter_test/flutter_test.dart';
import 'package:beapp/services/local_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = LocalDataService();

  test('loadPlaces legge i 2 luoghi da assets/data/places.json', () async {
    final places = await service.loadPlaces();

    expect(places, hasLength(2));
    expect(places.first.name, "Prato della Valle");
  });

  test('loadRestaurants legge i 2 locali da assets/data/restaurants.json', () async {
    final restaurants = await service.loadRestaurants();

    expect(restaurants, hasLength(2));
    expect(restaurants.every((r) => r.menu.isNotEmpty), true);
  });
}
