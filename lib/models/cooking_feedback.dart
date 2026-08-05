class CookingFeedback {
  const CookingFeedback({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.rating,
    required this.createdAt,
    this.everyoneLikedIt = true,
    this.tooSpicy = false,
    this.tooSalty = false,
    this.portionFeedback = 'right',
    this.notes = '',
  });

  final String id;
  final String recipeId;
  final String recipeName;
  final int rating;
  final DateTime createdAt;
  final bool everyoneLikedIt;
  final bool tooSpicy;
  final bool tooSalty;
  final String portionFeedback;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'recipeName': recipeName,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
        'everyoneLikedIt': everyoneLikedIt,
        'tooSpicy': tooSpicy,
        'tooSalty': tooSalty,
        'portionFeedback': portionFeedback,
        'notes': notes,
      };

  factory CookingFeedback.fromJson(Map<String, dynamic> json) {
    return CookingFeedback(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      recipeId: json['recipeId'] as String? ?? '',
      recipeName: json['recipeName'] as String? ?? 'Recipe',
      rating: ((json['rating'] as num?)?.toInt() ?? 3).clamp(1, 5),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      everyoneLikedIt: json['everyoneLikedIt'] as bool? ?? true,
      tooSpicy: json['tooSpicy'] as bool? ?? false,
      tooSalty: json['tooSalty'] as bool? ?? false,
      portionFeedback:
          json['portionFeedback'] as String? ?? 'right',
      notes: json['notes'] as String? ?? '',
    );
  }
}
