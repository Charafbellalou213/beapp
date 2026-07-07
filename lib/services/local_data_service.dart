import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/place.dart';
import '../models/restaurant.dart';

/// Carica i dati locali di luoghi e ristoranti/locali dai file JSON in
/// `assets/data/`. Aggiungere nuovi luoghi/locali nel JSON non richiede
/// nessuna modifica a questo service.
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
