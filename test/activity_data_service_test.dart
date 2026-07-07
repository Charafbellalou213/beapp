import 'package:flutter_test/flutter_test.dart';
import 'package:beapp/services/activity_data_service.dart';

void main() {
  test(
    'fetchSummaryForDate ripiega su isFromApi=false se il base URL non è raggiungibile',
    () async {
      final service = ActivityDataService();

      final summary = await service.fetchSummaryForDate('utente_demo', DateTime(2026, 7, 6));

      expect(summary.isFromApi, false);
      expect(summary.calories, 0);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
