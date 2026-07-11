import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:beapp/models/place.dart';
import 'package:beapp/models/restaurant.dart';

void main() {
  test('places.json contiene 20 luoghi validi con id univoci', () {
    final file = File('assets/data/places.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final places = (json['places'] as List<dynamic>)
        .map((item) => Place.fromJson(item as Map<String, dynamic>))
        .toList();

    expect(places, hasLength(20));
    expect(places.map((p) => p.id).toSet(), hasLength(20));
    expect(places.map((p) => p.id), containsAll(['place_001', 'place_002', 'place_020']));
  });

  test('restaurants.json contiene 6 locali validi con menu e id univoci', () {
    final file = File('assets/data/restaurants.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final restaurants = (json['restaurants'] as List<dynamic>)
        .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
        .toList();

    expect(restaurants, hasLength(6));
    expect(restaurants.map((r) => r.id).toSet(), hasLength(6));
    for (final restaurant in restaurants) {
      expect(restaurant.menu, isNotEmpty);
    }
  });
}