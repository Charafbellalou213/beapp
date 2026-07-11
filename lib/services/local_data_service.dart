import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/place.dart';
import '../models/restaurant.dart';

class LocalDataService {
  Future<List<Place>> loadPlaces() async {
    final raw = await rootBundle.loadString('assets/data/places.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['places'] as List<dynamic>)
        .map((item) => Place.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Restaurant>> loadRestaurants() async {
    final raw = await rootBundle.loadString('assets/data/restaurants.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['restaurants'] as List<dynamic>)
        .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
