import 'constants.dart';

/// Stima indicativa delle calorie bruciate camminando una certa distanza.
/// Non è un dato medico: formula semplice, spiegabile in sede d'esame.
double estimateCaloriesForDistance(
  double distanceKm, {
  double userWeightKg = AppConstants.defaultUserWeightKg,
}) {
  return distanceKm * userWeightKg * 0.75;
}
