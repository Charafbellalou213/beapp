import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beapp/models/daily_activity_summary.dart';
import 'package:beapp/models/review.dart';
import 'package:beapp/providers/app_state.dart';
import 'package:beapp/services/route_service.dart';

DailyActivitySummary _summaryWithSteps(int steps) => DailyActivitySummary(
      date: DateTime(2026, 7, 8),
      totalCalories: 0,
      totalSteps: steps,
      totalDistanceKm: 0,
      hasCaloriesData: false,
      hasStepsData: true,
      hasDistanceData: false,
    );

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
    expect(appState.places, hasLength(20));
    expect(appState.restaurants, hasLength(6));
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

  test(
    'dopo un riavvio (nuova istanza di AppState) tutti i dati persistiti sono ripristinati',
    () async {
      final first = AppState();
      await first.bootstrap();
      await first.login('mario');
      await first.markPlaceVisited(first.places.first.id);
      await first.markRestaurantVisited(first.restaurants.first.id);
      await first.addReview(
        Review(placeId: first.places.first.id, rating: 5, createdAt: DateTime.now()),
      );
      first.selectRoute(RouteLength.short, startLatitude: 45.3987, startLongitude: 11.8767);

      final second = AppState();
      await second.bootstrap();

      expect(second.username, 'mario');
      expect(second.userStats?.totalPoints, first.userStats?.totalPoints);
      expect(second.userStats?.visitedPlaceIds, first.userStats?.visitedPlaceIds);
      expect(second.userStats?.visitedRestaurantIds, first.userStats?.visitedRestaurantIds);
      expect(second.userStats?.reviews, hasLength(1));
      expect(second.userStats?.unlockedBadgeIds, contains('first_step'));
      expect(second.selectedRouteLength, RouteLength.short);
    },
  );

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

  test(
    'IMPACT: se ping/login falliscono, loginImpact() fallisce in modo pulito (nessuna eccezione)',
    () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.login('mario');

      final success = await appState.loginImpact();

      expect(success, false);
      expect(appState.impactError, isNotNull);
      expect(appState.isLoadingImpactData, false);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  test(
    'IMPACT: loadYesterdayActivityData() non aggiorna mai le statistiche stimate di Beapp',
    () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.login('mario');
      final pointsBefore = appState.userStats?.totalPoints;

      await appState.loadYesterdayActivityData();

      expect(appState.impactActivitySummary, isNotNull);
      expect(appState.impactActivitySummary!.hasAnyData, false);
      expect(appState.userStats?.totalPoints, pointsBefore);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  group('recommendedRouteLength', () {
    test('senza dati IMPACT consiglia sempre il percorso medio', () {
      final appState = AppState();
      expect(appState.recommendedRouteLength, RouteLength.medium);
    });

    test('meno di 3000 passi -> percorso breve', () {
      final appState = AppState()..impactActivitySummary = _summaryWithSteps(2000);
      expect(appState.recommendedRouteLength, RouteLength.short);
    });

    test('tra 3000 e 8000 passi -> percorso medio', () {
      final appState = AppState()..impactActivitySummary = _summaryWithSteps(5000);
      expect(appState.recommendedRouteLength, RouteLength.medium);
    });

    test('più di 8000 passi -> percorso lungo', () {
      final appState = AppState()..impactActivitySummary = _summaryWithSteps(9000);
      expect(appState.recommendedRouteLength, RouteLength.long);
    });
  });

  group('simulatore di movimento (demo)', () {
    test(
      'startRouteSimulation avanza tra le tappe e completa il percorso automaticamente',
      () async {
        final appState = AppState();
        await appState.bootstrap();
        await appState.login('mario');
        appState.selectRoute(RouteLength.long, startLatitude: 45.3987, startLongitude: 11.8767);
        final totalPlaces = appState.currentRoute!.places.length;

        appState.startRouteSimulation(
          totalDuration: const Duration(milliseconds: 300),
          stepsPerSegment: 3,
        );
        expect(appState.isSimulationRunning, true);

        // il tick minimo è 50ms, quindi il tempo reale è totalPlaces * 3 step * 50ms
        await Future.delayed(Duration(milliseconds: totalPlaces * 3 * 50 + 500));

        expect(appState.isSimulationRunning, false);
        expect(appState.currentRoute, isNull);
        expect(appState.simulatedLatitude, isNull);
        expect(appState.userStats?.completedRoutes, 1);
        expect(appState.userStats?.visitedPlaceIds, hasLength(totalPlaces));
        expect(appState.userStats?.unlockedBadgeIds, contains('route_completed'));
      },
    );

    test('stopSimulation ferma la simulazione senza completare il percorso', () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.login('mario');
      appState.selectRoute(RouteLength.long, startLatitude: 45.3987, startLongitude: 11.8767);

      appState.startRouteSimulation(
        totalDuration: const Duration(milliseconds: 2000),
        stepsPerSegment: 3,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      appState.stopSimulation();

      expect(appState.isSimulationRunning, false);
      expect(appState.currentRoute, isNotNull);
      expect(appState.userStats?.completedRoutes, 0);
    });
  });

  group('account locali (username + password)', () {
    test('registerAccount crea l\'account e logga subito l\'utente', () async {
      final appState = AppState();
      await appState.bootstrap();

      final error = await appState.registerAccount('mario', 'segreta123');

      expect(error, isNull);
      expect(appState.isLoggedIn, true);
      expect(appState.username, 'mario');
    });

    test('registerAccount rifiuta uno username già in uso', () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.registerAccount('mario', 'segreta123');
      await appState.logout();

      final error = await appState.registerAccount('mario', 'altrapassword');

      expect(error, isNotNull);
      expect(appState.isLoggedIn, false);
    });

    test('registerAccount rifiuta campi vuoti', () async {
      final appState = AppState();
      await appState.bootstrap();

      expect(await appState.registerAccount('', 'segreta123'), isNotNull);
      expect(await appState.registerAccount('mario', ''), isNotNull);
    });

    test('loginWithPassword funziona con le credenziali corrette dopo un logout', () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.registerAccount('mario', 'segreta123');
      await appState.logout();

      final error = await appState.loginWithPassword('mario', 'segreta123');

      expect(error, isNull);
      expect(appState.isLoggedIn, true);
      expect(appState.username, 'mario');
    });

    test('loginWithPassword rifiuta una password sbagliata', () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.registerAccount('mario', 'segreta123');
      await appState.logout();

      final error = await appState.loginWithPassword('mario', 'password-sbagliata');

      expect(error, isNotNull);
      expect(appState.isLoggedIn, false);
    });

    test('logout preserva le statistiche per il prossimo accesso', () async {
      final appState = AppState();
      await appState.bootstrap();
      await appState.registerAccount('mario', 'segreta123');
      await appState.markPlaceVisited(appState.places.first.id);
      final pointsBeforeLogout = appState.userStats?.totalPoints;

      await appState.logout();
      expect(appState.isLoggedIn, false);

      await appState.loginWithPassword('mario', 'segreta123');
      expect(appState.userStats?.totalPoints, pointsBeforeLogout);
    });

    test('loginWithPassword rifiuta uno username mai registrato', () async {
      final appState = AppState();
      await appState.bootstrap();

      final error = await appState.loginWithPassword('utente_fantasma', 'qualsiasi');

      expect(error, isNotNull);
      expect(appState.isLoggedIn, false);
    });
  });
}