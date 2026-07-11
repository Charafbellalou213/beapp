import 'menu_item.dart';

enum RestaurantType {
  restaurant('restaurant'),
  kiosk('kiosk'),
  bar('bar'),
  bakery('bakery'),
  streetFood('street_food'),
  localShop('local_shop');

  final String jsonValue;
  const RestaurantType(this.jsonValue);

  static RestaurantType fromJson(String value) {
    return RestaurantType.values.firstWhere(
      (type) => type.jsonValue == value,
      orElse: () => RestaurantType.restaurant,
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final RestaurantType type;
  final String description;
  final double latitude;
  final double longitude;
  final String priceRange;
  final String? address;
  final String? localCultureConnection;
  final String? imagePath;
  final List<String> typicalDishes;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.priceRange,
    this.address,
    this.localCultureConnection,
    this.imagePath,
    this.typicalDishes = const [],
    required this.menu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      type: RestaurantType.fromJson(json['type'] as String),
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      priceRange: json['priceRange'] as String,
      address: json['address'] as String?,
      localCultureConnection: json['localCultureConnection'] as String?,
      imagePath: json['imagePath'] as String?,
      typicalDishes: (json['typicalDishes'] as List<dynamic>? ?? [])
          .map((dish) => dish as String)
          .toList(),
      menu: (json['menu'] as List<dynamic>)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.jsonValue,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'priceRange': priceRange,
      'address': address,
      'localCultureConnection': localCultureConnection,
      'imagePath': imagePath,
      'typicalDishes': typicalDishes,
      'menu': menu.map((item) => item.toJson()).toList(),
    };
  }
}
