import 'review.dart';

class UserStats {
  final String username;
  final int totalPoints;
  final double totalCalories;
  final double totalDistanceKm;
  final int totalSteps;
  final List<String> visitedPlaceIds;
  final List<String> visitedRestaurantIds;
  final List<Review> reviews;
  final List<String> unlockedBadgeIds;
  final int completedRoutes;
  final DateTime? lastDataUpdateDate;

  const UserStats({
    required this.username,
    this.totalPoints = 0,
    this.totalCalories = 0,
    this.totalDistanceKm = 0,
    this.totalSteps = 0,
    this.visitedPlaceIds = const [],
    this.visitedRestaurantIds = const [],
    this.reviews = const [],
    this.unlockedBadgeIds = const [],
    this.completedRoutes = 0,
    this.lastDataUpdateDate,
  });

  factory UserStats.empty(String username) => UserStats(username: username);

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      username: json['username'] as String,
      totalPoints: json['totalPoints'] as int? ?? 0,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      totalSteps: json['totalSteps'] as int? ?? 0,
      visitedPlaceIds: (json['visitedPlaceIds'] as List<dynamic>? ?? [])
          .map((id) => id as String)
          .toList(),
      visitedRestaurantIds: (json['visitedRestaurantIds'] as List<dynamic>? ?? [])
          .map((id) => id as String)
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList(),
      unlockedBadgeIds: (json['unlockedBadgeIds'] as List<dynamic>? ?? [])
          .map((id) => id as String)
          .toList(),
      completedRoutes: json['completedRoutes'] as int? ?? 0,
      lastDataUpdateDate: json['lastDataUpdateDate'] == null
          ? null
          : DateTime.parse(json['lastDataUpdateDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'totalPoints': totalPoints,
      'totalCalories': totalCalories,
      'totalDistanceKm': totalDistanceKm,
      'totalSteps': totalSteps,
      'visitedPlaceIds': visitedPlaceIds,
      'visitedRestaurantIds': visitedRestaurantIds,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'unlockedBadgeIds': unlockedBadgeIds,
      'completedRoutes': completedRoutes,
      'lastDataUpdateDate': lastDataUpdateDate?.toIso8601String(),
    };
  }

  UserStats copyWith({
    int? totalPoints,
    double? totalCalories,
    double? totalDistanceKm,
    int? totalSteps,
    List<String>? visitedPlaceIds,
    List<String>? visitedRestaurantIds,
    List<Review>? reviews,
    List<String>? unlockedBadgeIds,
    int? completedRoutes,
    DateTime? lastDataUpdateDate,
  }) {
    return UserStats(
      username: username,
      totalPoints: totalPoints ?? this.totalPoints,
      totalCalories: totalCalories ?? this.totalCalories,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalSteps: totalSteps ?? this.totalSteps,
      visitedPlaceIds: visitedPlaceIds ?? this.visitedPlaceIds,
      visitedRestaurantIds: visitedRestaurantIds ?? this.visitedRestaurantIds,
      reviews: reviews ?? this.reviews,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      completedRoutes: completedRoutes ?? this.completedRoutes,
      lastDataUpdateDate: lastDataUpdateDate ?? this.lastDataUpdateDate,
    );
  }
}
