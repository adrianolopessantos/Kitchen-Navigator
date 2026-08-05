import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/nutrition_intelligence_service.dart';
import 'package:kitchen_navigator/models/monthly_meal_plan.dart';
import 'package:kitchen_navigator/models/recipe.dart';

void main() {
  test('Nutrition summary combines simple foods and recipes', () {
    const recipes = [
      Recipe(
        id: 'r1',
        name: 'Chicken Rice',
        ingredients: ['Chicken', 'Rice'],
        steps: [RecipeStep(instruction: 'Cook', seconds: 600)],
        servings: 2,
        category: 'Dinner',
      ),
    ];

    final summary = NutritionIntelligenceService.summarizeDay(
      date: DateTime(2026, 8, 5),
      entries: const [
        MonthlyMealEntry(
          id: 'a',
          dateKey: '2026-08-05',
          slot: MealSlotType.morningSnack,
          name: 'Apple',
          servings: 1,
          simpleFood: true,
        ),
        MonthlyMealEntry(
          id: 'b',
          dateKey: '2026-08-05',
          slot: MealSlotType.dinner,
          name: 'Chicken Rice',
          servings: 2,
          recipeId: 'r1',
        ),
      ],
      recipes: recipes,
    );

    expect(summary.mealCount, 2);
    expect(summary.calories, greaterThan(200));
    expect(summary.protein, greaterThan(20));
  });
}
