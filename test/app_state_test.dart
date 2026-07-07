import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beapp/models/review.dart';
import 'package:beapp/providers/app_state.dart';
import 'package:beapp/services/route_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadInitialData (via bootstrap) popola places e restaurants dagli asset', () async {
    final appState = AppState();

    await appState.bootstrap();

    expect(appState.isBootstrapping, false);
    expect(appState.loadError, isNull);
    expect(appState.places, hasLength(2));
    expect(appState.restaurants, hasLength(2));
  });

  test('login crea uno UserStats vuoto e imposta isLoggedIn', () async {
    final appState = AppState();
    await appState.bootstrap();

    expect(appState.isLoggedIn, false);

    await appState.login('mario');

    expect(appState.isLoggedIn, true);
    expect(appState.userStats?.username, 'mario');
    expect(appState.userStats?.totalPoints, 0);
  });

  test('bootstrap ripristina username e statistiche salvate in precedenza', () async {
    final first = AppState();
    await first.bootstrap();
    await first.login('mario');
    await first.markPlaceVisited(first.places.first.id);

    final second = AppState();
    await second.bootstrap();

    expect(second.username, 'mario');
    expect(second.userStats?.totalPoints, first.userStats?.totalPoints);
  });

  test('markPlaceVisited assegna punti una sola volta per luogo', () async {
    final appState = AppState();
    await appState.bootstrap();
    await appState.login('mario');

    final place = appState.places.first;

    await appState.markPlaceVisited(place.id);
    await appState.markPlaceVisited(place.id); // seconda chiamata: non deve raddoppiare i punti

    expect(appState.userStats?.totalPoints, place.points);
    expect(appState.userStats?.visitedPlaceIds, [place.id]);
    expect(appState.places.first.isVisited, true);
  });

  test('markPlaceVisited sblocca il badge first_step', () async {
    final appState = AppState();
    await appState.bootstrap();
    await appState.login('mario');

    await appState.markPlaceVisited(appState.places.first.id);

    expect(appState.userStats?.unlockedBadgeIds, contains('first_step'));
    expect(appState.lastUnlockedBadgeId, 'first_step');
  });

  test('markRestaurantVisited assegna punti fissi una sola volta', () async {
    final appState = AppState();
    await appState.bootstrap();
    await appState.login('mario');

    final restaurant = appState.restaurants.first;

    await appState.markRestaurantVisited(restaurant.id);
    await appState.markRestaurantVisited(restaurant.id);

    expect(appState.userStats?.totalPoints, kRestaurantVisitPoints);
    expect(appState.userStats?.visitedRestaurantIds, [restaurant.id]);
  });

  test('addReview aggiunge la recensione alle statistiche utente', () async {
    final appState = AppState();
    await appState.bootstrap();
    await appState.login('mario');

    await appState.addReview(
      Review(placeId: 'place_001', rating: 5, createdAt: DateTime.now()),
    );

    expect(appState.userStats?.reviews, hasLength(1));
  });

  test('review_helper si sblocca dopo 3 recensioni', () async {
    final appState = AppState();
    await appState.bootstrap();
    await appState.login('mario');

    for (var i = 0; i < 3; i++) {
      await appState.addReview(
        Review(placeId: 'place_001', rating: 4, createdAt: DateTime.now()),
      );
    }

    expect(appState.userStats?.unlockedBadgeIds, contains('review_helper'));
  });

  test('notifyListeners viene chiamato durante bootstrap', () async {
    final appState = AppState();
    var notifications = 0;
    appState.addListener(() => notifications++);

    await appState.bootstrap();

    expect(notifications, greaterThanOrEqualTo(1));
  });

  test('selectRoute costruisce un percorso e completeCurrentRoute assegna punti/calorie', () async {
    final appState = AppState();
    await appState.bootstrap();
    await appState.login('mario');

    appState.selectRoute(RouteLength.long, startLatitude: 45.3987, startLongitude: 11.8767);

    expect(appState.currentRoute, isNotNull);
    final route = appState.currentRoute!;
    final expectedPlacePoints = route.places.fold<int>(0, (sum, p) => sum + p.points);

    await appState.completeCurrentRoute();

    expect(appState.currentRoute, isNull);
    expect(appState.userStats?.completedRoutes, 1);
    expect(appState.userStats?.totalPoints, expectedPlacePoints + kRouteCompletionBonus);
    expect(appState.userStats?.totalCalories, route.estimatedCalories);
    expect(appState.userStats?.totalDistanceKm, route.distanceKm);
    expect(appState.places.every((p) => !route.places.map((r) => r.id).contains(p.id) || p.isVisited), true);
  });
}
