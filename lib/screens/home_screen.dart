import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/stats_card.dart';
import 'route_screen.dart';
import 'sdg_impact_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stats = appState.userStats;

    return Scaffold(
      appBar: AppBar(title: const Text('Beapp')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ciao, ${appState.username ?? 'esploratore'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Beapp ti aiuta a scoprire Padova a piedi: luoghi tipici, '
              'cultura locale e attività del territorio, un percorso alla volta.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _SdgBanner(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SdgImpactScreen()),
              ),
            ),
            const SizedBox(height: 24),
            Text('Le tue statistiche', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatsCard(
                  icon: Icons.stars,
                  label: 'Punti totali',
                  value: '${stats?.totalPoints ?? 0}',
                ),
                StatsCard(
                  icon: Icons.local_fire_department,
                  label: 'Calorie stimate',
                  value: '${(stats?.totalCalories ?? 0).round()} kcal',
                ),
                StatsCard(
                  icon: Icons.route,
                  label: 'Distanza percorsa',
                  value: '${(stats?.totalDistanceKm ?? 0).toStringAsFixed(1)} km',
                ),
                StatsCard(
                  icon: Icons.directions_walk,
                  label: 'Passi',
                  value: '${stats?.totalSteps ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RouteScreen()),
              ),
              icon: const Icon(Icons.directions_walk),
              label: const Text('Inizia percorso'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SdgBanner extends StatelessWidget {
  const _SdgBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.public, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Progetto legato a SDG 8.9 — turismo sostenibile. Tocca per saperne di più.',
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }
}
