import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../models/review.dart';
import '../providers/app_state.dart';
import '../widgets/place_card.dart';
import '../widgets/rating_stars.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  double _newRating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview(AppState appState, String placeId) {
    appState.addReview(
      Review(
        placeId: placeId,
        rating: _newRating.round(),
        optionalComment:
            _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recensione salvata, grazie!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final place = appState.places.firstWhere(
      (p) => p.id == widget.place.id,
      orElse: () => widget.place,
    );

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(placeCategoryIcon(place.category)),
              const SizedBox(width: 8),
              Text(placeCategoryLabel(place.category)),
              const Spacer(),
              RatingStars(rating: place.averageRating),
              const SizedBox(width: 4),
              Text(place.averageRating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(place.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Chip(
                avatar: const Icon(Icons.stars, size: 18),
                label: Text('${place.points} punti'),
              ),
              Chip(
                avatar: const Icon(Icons.timer_outlined, size: 18),
                label: Text('~${place.averageVisitTimeMinutes} min'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: place.isVisited ? null : () => appState.markPlaceVisited(place.id),
            icon: Icon(place.isVisited ? Icons.check_circle : Icons.flag_outlined),
            label: Text(place.isVisited ? 'Già visitato' : 'Segna come visitato'),
          ),
          const Divider(height: 40),
          Text('Lascia una recensione', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RatingStars(
            rating: _newRating,
            size: 32,
            onRatingUpdate: (value) => setState(() => _newRating = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Commento (opzionale)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _submitReview(appState, place.id),
            child: const Text('Invia recensione'),
          ),
        ],
      ),
    );
  }
}
