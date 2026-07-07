import 'package:flutter/material.dart';

import '../models/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: Center(child: Text('Restaurant Detail Screen: ${restaurant.name}')),
    );
  }
}
