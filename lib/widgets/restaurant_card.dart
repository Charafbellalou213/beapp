import 'package:flutter/material.dart';

import '../models/restaurant.dart';

IconData restaurantTypeIcon(RestaurantType type) {
  switch (type) {
    case RestaurantType.restaurant:
      return Icons.restaurant;
    case RestaurantType.kiosk:
      return Icons.storefront;
    case RestaurantType.bar:
      return Icons.local_bar;
    case RestaurantType.bakery:
      return Icons.bakery_dining;
    case RestaurantType.localShop:
      return Icons.shopping_bag;
    case RestaurantType.streetFood:
      return Icons.tapas;
  }
}

String restaurantTypeLabel(RestaurantType type) {
  switch (type) {
    case RestaurantType.restaurant:
      return 'Ristorante';
    case RestaurantType.kiosk:
      return 'Chiosco';
    case RestaurantType.bar:
      return 'Bar';
    case RestaurantType.bakery:
      return 'Panetteria';
    case RestaurantType.localShop:
      return 'Bottega locale';
    case RestaurantType.streetFood:
      return 'Street food';
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, required this.onTap, this.isVisited = false});

  final Restaurant restaurant;
  final VoidCallback onTap;
  final bool isVisited;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: Icon(
            restaurantTypeIcon(restaurant.type),
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        title: Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${restaurantTypeLabel(restaurant.type)} · ${restaurant.priceRange}'),
        trailing: isVisited
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
