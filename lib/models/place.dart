enum PlaceCategory {
  history('history'),
  culture('culture'),
  food('food'),
  nature('nature'),
  innovation('innovation'),
  localProducts('local_products'),
  art('art');

  final String jsonValue;
  const PlaceCategory(this.jsonValue);

  static PlaceCategory fromJson(String value) {
    return PlaceCategory.values.firstWhere(
      (category) => category.jsonValue == value,
      orElse: () => PlaceCategory.culture,
    );
  }
}

class Place {
  final String id;
  final String name;
  final String description;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final int points;
  final int averageVisitTimeMinutes;
  final String? imagePath;
  final bool isVisited;
  final double averageRating;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.points,
    required this.averageVisitTimeMinutes,
    this.imagePath,
    this.isVisited = false,
    required this.averageRating,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: PlaceCategory.fromJson(json['category'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      points: json['points'] as int,
      averageVisitTimeMinutes: json['averageVisitTimeMinutes'] as int,
      imagePath: json['imagePath'] as String?,
      isVisited: json['isVisited'] as bool? ?? false,
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.jsonValue,
      'latitude': latitude,
      'longitude': longitude,
      'points': points,
      'averageVisitTimeMinutes': averageVisitTimeMinutes,
      'imagePath': imagePath,
      'isVisited': isVisited,
      'averageRating': averageRating,
    };
  }

  Place copyWith({bool? isVisited, double? averageRating}) {
    return Place(
      id: id,
      name: name,
      description: description,
      category: category,
      latitude: latitude,
      longitude: longitude,
      points: points,
      averageVisitTimeMinutes: averageVisitTimeMinutes,
      imagePath: imagePath,
      isVisited: isVisited ?? this.isVisited,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}
