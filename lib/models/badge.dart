import 'package:flutter/material.dart';

// si chiama AppBadge e non Badge per non confonderlo col widget Badge di material.dart
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
    description:
        'Hai bruciato (o stimato di bruciare) 1000 calorie camminando.',
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
    id: 'route_completed',
    name: 'Route Completed',
    description: 'Hai completato il tuo primo percorso BeLocal.',
    icon: Icons.flag_circle,
  ),
  AppBadge(
    id: 'sustainable_walker',
    name: 'Sustainable Walker',
    description: 'Hai percorso almeno 2 km completando percorsi BeLocal.',
    icon: Icons.hiking,
  ),
  AppBadge(
    id: 'active_tourist',
    name: 'Active Tourist',
    description: 'Ieri hai fatto più di 5000 passi (dati reali IMPACT).',
    icon: Icons.directions_walk,
  ),
];
