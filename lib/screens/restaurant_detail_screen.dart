import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/app_state.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/restaurant_card.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isVisited = appState.userStats?.visitedRestaurantIds.contains(restaurant.id) ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(restaurantTypeIcon(restaurant.type)),
              const SizedBox(width: 8),
              Text(restaurantTypeLabel(restaurant.type)),
              const Spacer(),
              Text(
                restaurant.priceRange,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(restaurant.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.public, color: Theme.of(context).colorScheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    restaurant.localCultureConnection,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (restaurant.typicalDishes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: restaurant.typicalDishes
                  .map((dish) => Chip(avatar: const Icon(Icons.local_dining, size: 16), label: Text(dish)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: isVisited ? null : () => appState.markRestaurantVisited(restaurant.id),
            icon: Icon(isVisited ? Icons.check_circle : Icons.restaurant_menu),
            label: Text(isVisited ? 'Già segnato come visitato' : 'Ho mangiato qui (+15 punti)'),
          ),
          const Divider(height: 40),
          Text('Menu', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...restaurant.menu.map((item) => MenuItemCard(item: item)),
        ],
      ),
    );
  }
}
