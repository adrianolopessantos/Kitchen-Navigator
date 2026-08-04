import '../../models/nutrition.dart';
import '../../models/recipe.dart';

abstract final class NutritionService {
  static NutritionTotals forRecipe(
    Recipe recipe, {
    int? servings,
  }) {
    var total = NutritionTotals.zero;

    for (final ingredient in recipe.ingredients) {
      total += _ingredientNutrition(ingredient);
    }

    final requestedServings = servings ?? recipe.servings;
    final scale = requestedServings / recipe.servings;
    return total.scale(scale);
  }

  static NutritionTotals perServing(Recipe recipe) {
    final total = forRecipe(recipe);
    return total.scale(1 / recipe.servings);
  }

  static NutritionTargets targetsFor(NutritionGoal goal) {
    switch (goal) {
      case NutritionGoal.loseWeight:
        return const NutritionTargets(
          calories: 1800,
          protein: 110,
          carbohydrates: 180,
          fat: 55,
          fibre: 30,
          sugar: 45,
          salt: 6,
        );
      case NutritionGoal.gainMuscle:
        return const NutritionTargets(
          calories: 2700,
          protein: 160,
          carbohydrates: 320,
          fat: 80,
          fibre: 35,
          sugar: 55,
          salt: 6,
        );
      case NutritionGoal.highProtein:
        return const NutritionTargets(
          calories: 2200,
          protein: 150,
          carbohydrates: 220,
          fat: 70,
          fibre: 30,
          sugar: 50,
          salt: 6,
        );
      case NutritionGoal.lowCarb:
        return const NutritionTargets(
          calories: 2100,
          protein: 135,
          carbohydrates: 110,
          fat: 105,
          fibre: 28,
          sugar: 35,
          salt: 6,
        );
      case NutritionGoal.vegetarian:
      case NutritionGoal.mediterranean:
      case NutritionGoal.maintainWeight:
      case NutritionGoal.balanced:
        return const NutritionTargets(
          calories: 2200,
          protein: 100,
          carbohydrates: 260,
          fat: 70,
          fibre: 30,
          sugar: 50,
          salt: 6,
        );
    }
  }

  static List<String> advice(
    NutritionTotals totals,
    NutritionTargets targets,
  ) {
    final messages = <String>[];

    if (totals.calories < targets.calories * .65) {
      messages.add(
        'Planned meals are quite light in calories. Consider adding a balanced snack.',
      );
    } else if (totals.calories > targets.calories * 1.15) {
      messages.add(
        'Planned calories are above your target. Review portions or side dishes.',
      );
    }

    if (totals.protein < targets.protein * .75) {
      messages.add(
        'Protein is low. Add eggs, Greek yogurt, beans, fish, tofu, or lean meat.',
      );
    }

    if (totals.fibre < targets.fibre * .7) {
      messages.add(
        'Fibre is low. Add vegetables, fruit, beans, or whole grains.',
      );
    }

    if (totals.sugar > targets.sugar) {
      messages.add(
        'Sugar is above the daily target. Check drinks, sauces, and desserts.',
      );
    }

    if (totals.salt > targets.salt) {
      messages.add(
        'Salt is above the daily target. Use herbs, lemon, or spices instead.',
      );
    }

    if (messages.isEmpty) {
      messages.add(
        'Today’s plan looks reasonably balanced for your selected goal.',
      );
    }

    return messages;
  }

  static NutritionTotals _ingredientNutrition(String ingredient) {
    final key = ingredient.trim().toLowerCase();

    if (key.contains('chicken')) {
      return const NutritionTotals(
        calories: 410,
        protein: 77,
        carbohydrates: 0,
        fat: 9,
        fibre: 0,
        sugar: 0,
        salt: 0.3,
      );
    }
    if (key.contains('salmon')) {
      return const NutritionTotals(
        calories: 520,
        protein: 55,
        carbohydrates: 0,
        fat: 32,
        fibre: 0,
        sugar: 0,
        salt: 0.2,
      );
    }
    if (key.contains('egg')) {
      return const NutritionTotals(
        calories: 280,
        protein: 24,
        carbohydrates: 2,
        fat: 20,
        fibre: 0,
        sugar: 1,
        salt: 0.7,
      );
    }
    if (key.contains('milk')) {
      return const NutritionTotals(
        calories: 230,
        protein: 17,
        carbohydrates: 24,
        fat: 9,
        fibre: 0,
        sugar: 24,
        salt: 0.5,
      );
    }
    if (key.contains('butter')) {
      return const NutritionTotals(
        calories: 215,
        protein: 0,
        carbohydrates: 0,
        fat: 24,
        fibre: 0,
        sugar: 0,
        salt: 0.2,
      );
    }
    if (key.contains('pasta')) {
      return const NutritionTotals(
        calories: 890,
        protein: 31,
        carbohydrates: 180,
        fat: 4,
        fibre: 8,
        sugar: 4,
        salt: 0.1,
      );
    }
    if (key.contains('potato')) {
      return const NutritionTotals(
        calories: 385,
        protein: 10,
        carbohydrates: 85,
        fat: 1,
        fibre: 10,
        sugar: 4,
        salt: 0.1,
      );
    }
    if (key.contains('rice')) {
      return const NutritionTotals(
        calories: 720,
        protein: 14,
        carbohydrates: 160,
        fat: 2,
        fibre: 2,
        sugar: 0,
        salt: 0.1,
      );
    }
    if (key.contains('cheese') ||
        key.contains('parmesan') ||
        key.contains('feta')) {
      return const NutritionTotals(
        calories: 300,
        protein: 20,
        carbohydrates: 4,
        fat: 24,
        fibre: 0,
        sugar: 2,
        salt: 1.5,
      );
    }
    if (key.contains('tomato') ||
        key.contains('cucumber') ||
        key.contains('onion') ||
        key.contains('lemon')) {
      return const NutritionTotals(
        calories: 70,
        protein: 3,
        carbohydrates: 16,
        fat: 1,
        fibre: 4,
        sugar: 9,
        salt: 0.1,
      );
    }
    if (key.contains('pesto')) {
      return const NutritionTotals(
        calories: 520,
        protein: 8,
        carbohydrates: 12,
        fat: 48,
        fibre: 3,
        sugar: 3,
        salt: 1.2,
      );
    }
    if (key.contains('coconut milk')) {
      return const NutritionTotals(
        calories: 450,
        protein: 5,
        carbohydrates: 10,
        fat: 45,
        fibre: 2,
        sugar: 4,
        salt: 0.2,
      );
    }

    return const NutritionTotals(
      calories: 40,
      protein: 1,
      carbohydrates: 8,
      fat: 1,
      fibre: 1,
      sugar: 1,
      salt: 0.1,
    );
  }
}
