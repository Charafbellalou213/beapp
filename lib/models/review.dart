class Review {
  final String placeId;
  final int rating;
  final String? optionalComment;
  final DateTime createdAt;

  Review({
    required this.placeId,
    required this.rating,
    this.optionalComment,
    required this.createdAt,
  }) : assert(rating >= 1 && rating <= 5, 'rating deve essere tra 1 e 5');

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      placeId: json['placeId'] as String,
      rating: json['rating'] as int,
      optionalComment: json['optionalComment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'rating': rating,
      'optionalComment': optionalComment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
