import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// Stelle di valutazione 1-5. Senza `onRatingUpdate` è di sola lettura
/// (usata per mostrare una media); con `onRatingUpdate` diventa interattiva
/// (usata per lasciare una recensione).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.onRatingUpdate,
  });

  final double rating;
  final double size;
  final ValueChanged<double>? onRatingUpdate;

  @override
  Widget build(BuildContext context) {
    if (onRatingUpdate == null) {
      return RatingBarIndicator(
        rating: rating,
        itemCount: 5,
        itemSize: size,
        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
      );
    }

    return RatingBar.builder(
      initialRating: rating,
      itemCount: 5,
      itemSize: size,
      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: onRatingUpdate!,
    );
  }
}
