class DailyActivitySummary {
  final DateTime date;
  final double totalCalories;
  final int totalSteps;
  final double totalDistanceKm;
  final bool hasCaloriesData;
  final bool hasStepsData;
  final bool hasDistanceData;

  const DailyActivitySummary({
    required this.date,
    required this.totalCalories,
    required this.totalSteps,
    required this.totalDistanceKm,
    required this.hasCaloriesData,
    required this.hasStepsData,
    required this.hasDistanceData,
  });

  factory DailyActivitySummary.empty(DateTime date) {
    return DailyActivitySummary(
      date: date,
      totalCalories: 0,
      totalSteps: 0,
      totalDistanceKm: 0,
      hasCaloriesData: false,
      hasStepsData: false,
      hasDistanceData: false,
    );
  }

  bool get hasAnyData => hasCaloriesData || hasStepsData || hasDistanceData;
}
