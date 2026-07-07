enum ActivityType { calories, distance, steps, exercise }

enum DataSource { api, estimated }

/// Un singolo punto dato restituito dall'API attività (es. calorie di un
/// giorno). Il parsing esatto dei campi verrà rifinito nella Fase 13,
/// quando integreremo le risposte reali dell'API.
class ActivityData {
  final DateTime date;
  final double value;
  final ActivityType type;
  final DataSource source;

  const ActivityData({
    required this.date,
    required this.value,
    required this.type,
    required this.source,
  });

  factory ActivityData.fromJson(
    Map<String, dynamic> json, {
    required ActivityType type,
  }) {
    return ActivityData(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      type: type,
      source: DataSource.api,
    );
  }
}
