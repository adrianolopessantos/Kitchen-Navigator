import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/nutrition_service.dart';
import 'package:kitchen_navigator/models/recipe.dart';

void main() {
  test('nutrition estimates are positive for a recipe', () {
    const recipe = Recipe(
      id: 'test',
      name: 'Test Pasta',
      ingredients: ['Pasta', 'Tomato', 'Parmesan'],
      steps: [],
      servings: 2,
    );

    final nutrition = NutritionService.forRecipe(recipe);

    expect(nutrition.calories, greaterThan(0));
    expect(nutrition.protein, greaterThan(0));
    expect(nutrition.carbohydrates, greaterThan(0));
  });
}
