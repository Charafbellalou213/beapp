import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beapp/services/impact_service.dart';
import 'package:beapp/services/storage_service.dart';

// flutter test blocca le richieste http reali, quindi qui si testa solo il fallback.
// per la connessione vera: dart run tool/check_impact_connection.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('resolveAvailableDate', () {
    test('senza data di riferimento usa "ieri" rispetto a oggi', () {
      final service = ImpactService();
      final today = DateTime.now();
      final expected = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));

      expect(service.resolveAvailableDate(), expected);
    });

    test('con una data di riferimento usa il giorno precedente a quella data', () {
      final service = ImpactService();
      final result = service.resolveAvailableDate(DateTime(2026, 7, 15));
      expect(result, DateTime(2026, 7, 14));
    });
  });

  group('fallback senza credenziali/rete', () {
    test('login() ritorna false se username/password sono vuoti, senza lanciare eccezioni', () async {
      final service = ImpactService();
      final success = await service.login();
      expect(success, false);
    });

    test('hasValidSession() è false se non è mai stato salvato nessun token', () async {
      final service = ImpactService();
      expect(await service.hasValidSession(), false);
    });

    test(
      'getDailyActivitySummary() torna un riepilogo "vuoto" (hasAnyData=false) se non si può autenticare',
      () async {
        final service = ImpactService();
        final summary = await service.getDailyActivitySummary();

        expect(summary.hasAnyData, false);
        expect(summary.hasCaloriesData, false);
        expect(summary.hasStepsData, false);
        expect(summary.hasDistanceData, false);
        expect(summary.totalCalories, 0);
        expect(summary.totalSteps, 0);
      },
    );
  });

  group('StorageService — token IMPACT', () {
    test('saveImpactTokens/loadImpactAccessToken/clearImpactTokens fanno un round trip corretto', () async {
      final storage = StorageService();

      expect(await storage.loadImpactAccessToken(), isNull);

      await storage.saveImpactTokens(accessToken: 'access123', refreshToken: 'refresh456');

      expect(await storage.loadImpactAccessToken(), 'access123');
      expect(await storage.loadImpactRefreshToken(), 'refresh456');

      await storage.clearImpactTokens();

      expect(await storage.loadImpactAccessToken(), isNull);
      expect(await storage.loadImpactRefreshToken(), isNull);
    });
  });
}