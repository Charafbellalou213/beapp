import 'package:flutter/material.dart';

/// Chiamato `AppBadge` (non `Badge`) per non entrare in conflitto con il
/// widget `Badge` già presente in `package:flutter/material.dart`.
class AppBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Catalogo statico di tutti i badge ottenibili nell'app.
/// `UserStats.unlockedBadgeIds` salva solo gli id: questa lista fornisce
/// nome, descrizione e icona da mostrare per ciascun id sbloccato.
const List<AppBadge> kAllBadges = [
  AppBadge(
    id: 'first_step',
    name: 'First Step',
    description: 'Hai visitato il tuo primo luogo a Padova.',
    icon: Icons.directions_walk,
  ),
  AppBadge(
    id: 'local_explorer',
    name: 'Local Explorer',
    description: 'Hai visitato 3 luoghi tipici.',
    icon: Icons.explore,
  ),
  AppBadge(
    id: 'padova_ambassador',
    name: 'Padova Ambassador',
    description: 'Hai visitato 5 luoghi tipici.',
    icon: Icons.emoji_events,
  ),
  AppBadge(
    id: 'sustainable_tourist',
    name: 'Sustainable Tourist',
    description: 'Hai bruciato/stimato 1000 calorie camminando.',
    icon: Icons.eco,
  ),
  AppBadge(
    id: 'culture_supporter',
    name: 'Culture Supporter',
    description: 'Hai visitato un luogo culturale e un locale tipico.',
    icon: Icons.museum,
  ),
  AppBadge(
    id: 'review_helper',
    name: 'Review Helper',
    description: 'Hai lasciato 3 recensioni.',
    icon: Icons.rate_review,
  ),
  AppBadge(
    id: 'walking_day',
    name: 'Walking Day',
    description: 'Hai raggiunto un buon numero di passi in un giorno.',
    icon: Icons.hiking,
  ),
];
