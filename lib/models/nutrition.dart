class NutritionTotals {
  const NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fibre,
    required this.sugar,
    required this.salt,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fibre;
  final double sugar;
  final double salt;

  static const zero = NutritionTotals(
    calories: 0,
    protein: 0,
    carbohydrates: 0,
    fat: 0,
    fibre: 0,
    sugar: 0,
    salt: 0,
  );

  NutritionTotals operator +(NutritionTotals other) {
    return NutritionTotals(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbohydrates: carbohydrates + other.carbohydrates,
      fat: fat + other.fat,
      fibre: fibre + other.fibre,
      sugar: sugar + other.sugar,
      salt: salt + other.salt,
    );
  }

  NutritionTotals scale(double value) {
    return NutritionTotals(
      calories: calories * value,
      protein: protein * value,
      carbohydrates: carbohydrates * value,
      fat: fat * value,
      fibre: fibre * value,
      sugar: sugar * value,
      salt: salt * value,
    );
  }
}

enum NutritionGoal {
  balanced,
  loseWeight,
  maintainWeight,
  gainMuscle,
  highProtein,
  vegetarian,
  mediterranean,
  lowCarb,
}

extension NutritionGoalLabel on NutritionGoal {
  String get label {
    switch (this) {
      case NutritionGoal.balanced:
        return 'Balanced';
      case NutritionGoal.loseWeight:
        return 'Lose weight';
      case NutritionGoal.maintainWeight:
        return 'Maintain weight';
      case NutritionGoal.gainMuscle:
        return 'Gain muscle';
      case NutritionGoal.highProtein:
        return 'High protein';
      case NutritionGoal.vegetarian:
        return 'Vegetarian';
      case NutritionGoal.mediterranean:
        return 'Mediterranean';
      case NutritionGoal.lowCarb:
        return 'Low carb';
    }
  }
}

class NutritionTargets {
  const NutritionTargets({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fibre,
    required this.sugar,
    required this.salt,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fibre;
  final double sugar;
  final double salt;
}
