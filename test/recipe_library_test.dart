import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/data/essential_recipe_library.dart';

void main() {
  test('Essential recipe library contains 50 unique recipes', () {
    expect(essentialRecipeLibrary.length, 50);

    final ids = essentialRecipeLibrary.map((recipe) => recipe.id).toSet();
    final names =
        essentialRecipeLibrary.map((recipe) => recipe.name).toSet();

    expect(ids.length, 50);
    expect(names.length, 50);

    for (final recipe in essentialRecipeLibrary) {
      expect(recipe.ingredients, isNotEmpty);
      expect(recipe.steps, isNotEmpty);
      expect(recipe.servings, greaterThan(0));
      expect(recipe.totalMinutes, greaterThan(0));
    }
  });
}
