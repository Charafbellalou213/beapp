import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../providers/app_state.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../utils/constants.dart';
import '../widgets/place_card.dart';
import '../widgets/stats_card.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final _locationService = LocationService();
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _selectLength(RouteLength.medium));
  }

  Future<void> _selectLength(RouteLength length) async {
    setState(() => _isBuilding = true);

    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    final appState = context.read<AppState>();
    appState.selectRoute(
      length,
      startLatitude: position?.latitude ?? AppConstants.padovaCenterLat,
      startLongitude: position?.longitude ?? AppConstants.padovaCenterLng,
    );

    setState(() => _isBuilding = false);
  }

  Future<void> _completeRoute(AppState appState) async {
    await appState.completeCurrentRoute();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Percorso completato! Punti e calorie aggiornati.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final route = appState.currentRoute;

    if (appState.places.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Percorso')),
        body: const Center(child: Text('Nessun luogo disponibile per un percorso')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Percorso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<RouteLength>(
            segments: RouteLength.values
                .map((length) => ButtonSegment(value: length, label: Text(length.label)))
                .toList(),
            selected: {appState.selectedRouteLength},
            onSelectionChanged: (selection) => _selectLength(selection.first),
          ),
          const SizedBox(height: 20),
          if (_isBuilding) const Center(child: CircularProgressIndicator()),
          if (!_isBuilding && route != null) ...[
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: Icons.route,
                    label: 'Distanza',
                    value: '${route.distanceKm.toStringAsFixed(1)} km',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    icon: Icons.timer_outlined,
                    label: 'Tempo stimato',
                    value: '${route.estimatedMinutes} min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: Icons.local_fire_department,
                    label: 'Calorie stimate',
                    value: '${route.estimatedCalories.round()} kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    icon: Icons.stars,
                    label: 'Punti ottenibili',
                    value: '${route.totalPoints + kRouteCompletionBonus}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Tappe consigliate', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...route.places.map(
              (place) => Card(
                child: ListTile(
                  leading: Icon(placeCategoryIcon(place.category)),
                  title: Text(place.name),
                  subtitle: Text('${placeCategoryLabel(place.category)} · +${place.points} punti'),
                  trailing: place.isVisited
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _MotivationalBanner(
              route: route,
              dish: _suggestedDish(appState.restaurants, route.estimatedCalories),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _completeRoute(appState),
              icon: const Icon(Icons.flag_circle_outlined),
              label: const Text('Completa percorso'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sceglie un piatto tipico "alla portata" delle calorie stimate del
/// percorso: il più calorico tra quelli che rientrano nel budget, o il meno
/// calorico disponibile se nessuno rientra.
MenuItem? _suggestedDish(List<Restaurant> restaurants, double availableCalories) {
  final typicalItems = restaurants
      .expand((restaurant) => restaurant.menu)
      .where((item) => item.isTypicalLocalProduct)
      .toList()
    ..sort((a, b) => a.calories.compareTo(b.calories));

  if (typicalItems.isEmpty) return null;

  final affordable = typicalItems.where((item) => item.calories <= availableCalories).toList();
  return affordable.isNotEmpty ? affordable.last : typicalItems.first;
}

class _MotivationalBanner extends StatelessWidget {
  const _MotivationalBanner({required this.route, required this.dish});

  final SuggestedRoute route;
  final MenuItem? dish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final calories = route.estimatedCalories.round();
    final dishText = dish != null
        ? 'Con questo percorso puoi bruciare circa $calories kcal: ti puoi permettere '
            'un piatto tipico come "${dish!.itemName}" (~${dish!.calories} kcal).'
        : 'Con questo percorso puoi bruciare circa $calories kcal camminando.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: colorScheme.onTertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(dishText, style: TextStyle(color: colorScheme.onTertiaryContainer)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Scopri cultura locale, cammina in modo sostenibile e supporta le attività '
            'tipiche di Padova.',
            style: TextStyle(color: colorScheme.onTertiaryContainer, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
