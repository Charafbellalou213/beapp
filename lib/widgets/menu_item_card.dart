import 'package:flutter/material.dart';

import '../models/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({super.key, required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (item.isTypicalLocalProduct)
              Tooltip(
                message: 'Prodotto tipico locale',
                child: Icon(Icons.eco, size: 18, color: Theme.of(context).colorScheme.primary),
              ),
          ],
        ),
        subtitle: Text(item.description),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${item.calories} kcal', style: Theme.of(context).textTheme.bodySmall),
            if (item.price != null)
              Text(
                '€${item.price!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
