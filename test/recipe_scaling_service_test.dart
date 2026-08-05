import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/recipe_scaling_service.dart';

void main() {
  test('Scales numeric ingredient quantities for household servings', () {
    expect(
      RecipeScalingService.scaleIngredientText(
        '200 g pasta',
        originalServings: 2,
        targetServings: 5,
      ),
      '500 g pasta',
    );

    expect(
      RecipeScalingService.scaleIngredientText(
        '2 eggs',
        originalServings: 2,
        targetServings: 5,
      ),
      '5 eggs',
    );
  });

  test('Leaves ingredients without leading quantities unchanged', () {
    expect(
      RecipeScalingService.scaleIngredientText(
        'Salt to taste',
        originalServings: 2,
        targetServings: 5,
      ),
      'Salt to taste',
    );
  });
}
