import '../models/daily_activity_summary.dart';
import '../utils/date_utils.dart';
import 'api_service.dart';

/// Recupera calorie/distanza/passi/esercizio dall'API per un utente e un
/// giorno specifico. Non richiede mai dati del giorno corrente: il
/// chiamante deve passare al massimo `latestAvailableActivityDate()`.
///
/// Se l'API non risponde (rete assente, username inesistente, dati non
/// disponibili per quel giorno) ritorna un riepilogo "stimato"
/// (`isFromApi = false`) invece di lanciare un errore: l'app deve
/// funzionare comunque.
class ActivityDataService {
  ActivityDataService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<DailyActivitySummary> fetchSummaryForDate(String username, DateTime date) async {
    final day = formatApiDate(date);

    final results = await Future.wait([
      _fetchValue('calories', username, day),
      _fetchValue('distance', username, day),
      _fetchValue('steps', username, day),
      _fetchValue('exercise', username, day),
    ]);

    final calories = results[0];
    final distance = results[1];
    final steps = results[2];
    final exercise = results[3];

    final hasAnyData = [calories, distance, steps, exercise].any((value) => value != null);
    if (!hasAnyData) {
      return DailyActivitySummary.estimated(date);
    }

    return DailyActivitySummary(
      date: date,
      calories: calories ?? 0,
      distanceKm: distance ?? 0,
      steps: (steps ?? 0).round(),
      exerciseMinutes: (exercise ?? 0).round(),
      isFromApi: true,
    );
  }

  Future<double?> _fetchValue(String metric, String username, String day) async {
    final json = await _api.getJson('/$metric/patients/$username/day/$day/');
    if (json == null) return null;

    // La forma esatta della risposta reale non è documentata: proviamo le
    // chiavi più comuni. Da adattare quando si conosce lo schema definitivo
    // dell'API fornita dal corso.
    final value = json['value'] ?? json['total'] ?? json['amount'];
    if (value is! num) return null;
    return value.toDouble();
  }
}
