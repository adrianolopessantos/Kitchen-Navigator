class NutritionSummary {
  const NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.mealCount,
    required this.varietyScore,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final int mealCount;
  final int varietyScore;

  NutritionSummary operator +(NutritionSummary other) {
    return NutritionSummary(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbohydrates: carbohydrates + other.carbohydrates,
      fat: fat + other.fat,
      mealCount: mealCount + other.mealCount,
      varietyScore: varietyScore,
    );
  }

  static const empty = NutritionSummary(
    calories: 0,
    protein: 0,
    carbohydrates: 0,
    fat: 0,
    mealCount: 0,
    varietyScore: 0,
  );
}


class FamilyMemberNutritionEstimate {
  const FamilyMemberNutritionEstimate({
    required this.memberId,
    required this.memberName,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.share,
  });

  final String memberId;
  final String memberName;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double share;
}
