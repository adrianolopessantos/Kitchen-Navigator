import '../../models/monthly_meal_plan.dart';
import '../../models/household_profile.dart';
import '../../models/nutrition_summary.dart';
import '../../models/recipe.dart';

abstract final class NutritionIntelligenceService {
  static NutritionSummary summarizeDay({
    required DateTime date,
    required List<MonthlyMealEntry> entries,
    required List<Recipe> recipes,
  }) {
    final key = dateKeyFor(date);
    final dayEntries =
        entries.where((entry) => entry.dateKey == key).toList();

    var calories = 0.0;
    var protein = 0.0;
    var carbohydrates = 0.0;
    var fat = 0.0;
    final categories = <String>{};

    for (final entry in dayEntries) {
      if (entry.recipeId == null) {
        final estimate = _simpleFoodEstimate(entry.name);
        calories += estimate.calories;
        protein += estimate.protein;
        carbohydrates += estimate.carbohydrates;
        fat += estimate.fat;
        categories.add('simple');
        continue;
      }

      Recipe? recipe;
      for (final value in recipes) {
        if (value.id == entry.recipeId) {
          recipe = value;
          break;
        }
      }

      if (recipe == null) continue;

      final scale = entry.servings / recipe.servings;
      calories += _estimateCalories(recipe) * scale;
      protein += _estimateProtein(recipe) * scale;
      carbohydrates += _estimateCarbs(recipe) * scale;
      fat += _estimateFat(recipe) * scale;
      categories.add(recipe.category);
    }

    final variety = (categories.length * 20).clamp(0, 100);

    return NutritionSummary(
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      mealCount: dayEntries.length,
      varietyScore: variety,
    );
  }


  static bool hasUsefulData(NutritionSummary summary) {
    return summary.mealCount > 0 &&
        (summary.calories > 0 ||
            summary.protein > 0 ||
            summary.carbohydrates > 0 ||
            summary.fat > 0);
  }

  static List<FamilyMemberNutritionEstimate> allocateToFamily({
    required NutritionSummary household,
    required HouseholdProfile profile,
  }) {
    if (!hasUsefulData(household) || profile.members.isEmpty) {
      return const [];
    }

    final weights = <String, double>{};
    var totalWeight = 0.0;

    for (final member in profile.members) {
      final weight = _memberServingWeight(member);
      weights[member.id] = weight;
      totalWeight += weight;
    }

    if (totalWeight <= 0) return const [];

    return profile.members.map((member) {
      final share = weights[member.id]! / totalWeight;
      return FamilyMemberNutritionEstimate(
        memberId: member.id,
        memberName: member.name,
        calories: household.calories * share,
        protein: household.protein * share,
        carbohydrates: household.carbohydrates * share,
        fat: household.fat * share,
        share: share,
      );
    }).toList();
  }

  static double _memberServingWeight(FamilyMember member) {
    if (member.type == FamilyMemberType.adult) {
      return 1.0;
    }

    if (member.age <= 3) return .4;
    if (member.age <= 7) return .55;
    if (member.age <= 12) return .7;
    if (member.age <= 16) return .85;
    return 1.0;
  }

  static NutritionSummary _simpleFoodEstimate(String name) {
    final key = name.toLowerCase();

    if (key.contains('fruit') ||
        key.contains('apple') ||
        key.contains('banana')) {
      return const NutritionSummary(
        calories: 95,
        protein: 1,
        carbohydrates: 24,
        fat: 0.3,
        mealCount: 1,
        varietyScore: 0,
      );
    }
    if (key.contains('yogurt')) {
      return const NutritionSummary(
        calories: 120,
        protein: 8,
        carbohydrates: 14,
        fat: 4,
        mealCount: 1,
        varietyScore: 0,
      );
    }
    if (key.contains('toast')) {
      return const NutritionSummary(
        calories: 180,
        protein: 6,
        carbohydrates: 30,
        fat: 4,
        mealCount: 1,
        varietyScore: 0,
      );
    }
    if (key.contains('leftover')) {
      return const NutritionSummary(
        calories: 450,
        protein: 20,
        carbohydrates: 50,
        fat: 18,
        mealCount: 1,
        varietyScore: 0,
      );
    }

    return const NutritionSummary(
      calories: 200,
      protein: 6,
      carbohydrates: 28,
      fat: 7,
      mealCount: 1,
      varietyScore: 0,
    );
  }

  static double _estimateCalories(Recipe recipe) {
    return 180 + recipe.ingredients.length * 55;
  }

  static double _estimateProtein(Recipe recipe) {
    final searchable =
        '${recipe.name} ${recipe.ingredients.join(' ')}'.toLowerCase();
    final highProtein = [
      'chicken',
      'beef',
      'fish',
      'salmon',
      'egg',
      'tuna',
      'shrimp',
      'lentil',
      'chickpea',
      'beans',
    ].any(searchable.contains);
    return highProtein ? 30 : 12;
  }

  static double _estimateCarbs(Recipe recipe) {
    final searchable =
        '${recipe.name} ${recipe.ingredients.join(' ')}'.toLowerCase();
    return [
      'rice',
      'pasta',
      'bread',
      'potato',
      'oats',
      'flour',
      'tortilla',
    ].any(searchable.contains)
        ? 55
        : 25;
  }

  static double _estimateFat(Recipe recipe) {
    final searchable =
        '${recipe.name} ${recipe.ingredients.join(' ')}'.toLowerCase();
    return [
      'butter',
      'cream',
      'cheese',
      'oil',
      'avocado',
    ].any(searchable.contains)
        ? 22
        : 10;
  }
}
