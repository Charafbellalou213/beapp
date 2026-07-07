import 'package:flutter_test/flutter_test.dart';
import 'package:beapp/models/review.dart';
import 'package:beapp/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadInitialData popola places e restaurants dagli asset', () async {
    final appState = AppState();

    expect(appState.isLoadingData, false);

    await appState.loadInitialData();

    expect(appState.loadError, isNull);
    expect(appState.places, hasLength(2));
    expect(appState.restaurants, hasLength(2));
  });

  test('setUsername crea uno UserStats vuoto e imposta isLoggedIn', () {
    final appState = AppState();

    expect(appState.isLoggedIn, false);

    appState.setUsername('mario');

    expect(appState.isLoggedIn, true);
    expect(appState.userStats?.username, 'mario');
    expect(appState.userStats?.totalPoints, 0);
  });

  test('markPlaceVisited assegna punti una sola volta per luogo', () async {
    final appState = AppState();
    appState.setUsername('mario');
    await appState.loadInitialData();

    final place = appState.places.first;

    appState.markPlaceVisited(place.id);
    appState.markPlaceVisited(place.id); // seconda chiamata: non deve raddoppiare i punti

    expect(appState.userStats?.totalPoints, place.points);
    expect(appState.userStats?.visitedPlaceIds, [place.id]);
    expect(appState.places.first.isVisited, true);
  });

  test('addReview aggiunge la recensione alle statistiche utente', () {
    final appState = AppState();
    appState.setUsername('mario');

    appState.addReview(
      Review(placeId: 'place_001', rating: 5, createdAt: DateTime.now()),
    );

    expect(appState.userStats?.reviews, hasLength(1));
  });

  test('notifyListeners viene chiamato durante loadInitialData', () async {
    final appState = AppState();
    var notifications = 0;
    appState.addListener(() => notifications++);

    await appState.loadInitialData();

    expect(notifications, greaterThanOrEqualTo(2)); // inizio caricamento + fine caricamento
  });
}
