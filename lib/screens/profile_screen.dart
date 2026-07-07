import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/daily_activity_summary.dart';
import '../models/badge.dart';
import '../models/place.dart';
import '../providers/app_state.dart';
import '../utils/date_utils.dart';
import '../widgets/badge_card.dart';
import '../widgets/place_card.dart';
import '../widgets/stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stats = appState.userStats;
    final unlockedIds = stats?.unlockedBadgeIds ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna dati attività',
            onPressed: appState.isLoadingActivityData ? null : () => appState.loadActivityData(),
            icon: appState.isLoadingActivityData
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: stats == null
          ? const Center(child: Text('Accedi per vedere le tue statistiche'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  appState.username ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatsCard(icon: Icons.stars, label: 'Punti totali', value: '${stats.totalPoints}'),
                    StatsCard(
                      icon: Icons.place,
                      label: 'Luoghi visitati',
                      value: '${stats.visitedPlaceIds.length}',
                    ),
                    StatsCard(
                      icon: Icons.local_fire_department,
                      label: 'Calorie',
                      value: '${stats.totalCalories.round()} kcal',
                    ),
                    StatsCard(
                      icon: Icons.route,
                      label: 'Distanza',
                      value: '${stats.totalDistanceKm.toStringAsFixed(1)} km',
                    ),
                    StatsCard(icon: Icons.directions_walk, label: 'Passi', value: '${stats.totalSteps}'),
                    StatsCard(
                      icon: Icons.rate_review,
                      label: 'Recensioni',
                      value: '${stats.reviews.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (appState.activitySummary != null) _ActivityDataBanner(summary: appState.activitySummary!),
                const SizedBox(height: 24),
                Text('Luoghi visitati per categoria', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _CategoryChart(places: appState.places, visitedIds: stats.visitedPlaceIds),
                const SizedBox(height: 24),
                Text('Badge', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: kAllBadges
                      .map((badge) => BadgeCard(badge: badge, isUnlocked: unlockedIds.contains(badge.id)))
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class _ActivityDataBanner extends StatelessWidget {
  const _ActivityDataBanner({required this.summary});

  final DailyActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateText = formatDisplayDate(summary.date);
    final text = summary.isFromApi
        ? 'Dati attività aggiornati al $dateText (fonte: API). Valori indicativi, non medici.'
        : 'Nessun dato reale disponibile per $dateText: l\'app usa stime locali.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            summary.isFromApi ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.places, required this.visitedIds});

  final List<Place> places;
  final List<String> visitedIds;

  @override
  Widget build(BuildContext context) {
    final counts = <PlaceCategory, int>{};
    for (final place in places) {
      if (visitedIds.contains(place.id)) {
        counts[place.category] = (counts[place.category] ?? 0) + 1;
      }
    }

    final categories = PlaceCategory.values;
    final maxCount = counts.values.isEmpty ? 0 : counts.values.reduce((a, b) => a > b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: (maxCount + 1).toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 24, interval: 1),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= categories.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      placeCategoryLabel(categories[index]),
                      style: const TextStyle(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < categories.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (counts[categories[i]] ?? 0).toDouble(),
                    color: colorScheme.primary,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
