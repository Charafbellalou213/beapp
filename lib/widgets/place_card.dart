import 'package:flutter/material.dart';

import '../models/place.dart';
import 'rating_stars.dart';

IconData placeCategoryIcon(PlaceCategory category) {
  switch (category) {
    case PlaceCategory.history:
      return Icons.account_balance;
    case PlaceCategory.culture:
      return Icons.museum;
    case PlaceCategory.food:
      return Icons.restaurant;
    case PlaceCategory.nature:
      return Icons.park;
    case PlaceCategory.innovation:
      return Icons.lightbulb;
    case PlaceCategory.localProducts:
      return Icons.shopping_bag;
    case PlaceCategory.art:
      return Icons.palette;
  }
}

String placeCategoryLabel(PlaceCategory category) {
  switch (category) {
    case PlaceCategory.history:
      return 'Storia';
    case PlaceCategory.culture:
      return 'Cultura';
    case PlaceCategory.food:
      return 'Cibo';
    case PlaceCategory.nature:
      return 'Natura';
    case PlaceCategory.innovation:
      return 'Innovazione';
    case PlaceCategory.localProducts:
      return 'Prodotti locali';
    case PlaceCategory.art:
      return 'Arte';
  }
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            placeCategoryIcon(place.category),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            RatingStars(rating: place.averageRating, size: 14),
            const SizedBox(width: 6),
            Text(place.averageRating.toStringAsFixed(1)),
            const SizedBox(width: 12),
            Text('+${place.points} pt'),
          ],
        ),
        trailing: place.isVisited
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
