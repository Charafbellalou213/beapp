/// Riepilogo delle attività di un giorno, usato nella Profile/Stats screen.
/// Se `isFromApi` è false i valori sono stime locali (formula calorie/distanza),
/// non dati reali del dispositivo.
class DailyActivitySummary {
  final DateTime date;
  final double calories;
  final double distanceKm;
  final int steps;
  final int exerciseMinutes;
  final bool isFromApi;

  const DailyActivitySummary({
    required this.date,
    required this.calories,
    required this.distanceKm,
    required this.steps,
    required this.exerciseMinutes,
    required this.isFromApi,
  });

  factory DailyActivitySummary.estimated(DateTime date) {
    return DailyActivitySummary(
      date: date,
      calories: 0,
      distanceKm: 0,
      steps: 0,
      exerciseMinutes: 0,
      isFromApi: false,
    );
  }
}
