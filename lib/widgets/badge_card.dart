import 'package:flutter/material.dart';

import '../models/badge.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.badge, required this.isUnlocked});

  final AppBadge badge;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: badge.description,
      child: Opacity(
        opacity: isUnlocked ? 1 : 0.4,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isUnlocked
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  child: Icon(
                    badge.icon,
                    size: 20,
                    color:
                        isUnlocked ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
