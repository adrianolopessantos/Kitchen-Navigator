import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

String read(String path) => File(path).readAsStringSync();

void main() {
  test('Final V12 feature set remains installed', () {
    final required = [
      'lib/features/dashboard/dashboard_screen.dart',
      'lib/features/shopping/shopping_screen.dart',
      'lib/features/pantry/pantry_screen.dart',
      'lib/features/recipes/recipes_screen.dart',
      'lib/features/planner/planner_screen.dart',
      'lib/features/cooking/cooking_assistant_screen.dart',
      'lib/features/receipt/receipt_scanner_screen.dart',
      'lib/features/insights/insights_screen.dart',
      'lib/data/essential_recipe_library.dart',
    ];

    for (final path in required) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  test('Recipe Builder remains structured', () {
    final recipes =
        read('lib/features/recipes/recipes_screen.dart');

    expect(recipes, contains("'Add ingredient'"));
    expect(recipes, contains("'Quantity'"));
    expect(recipes, contains("'Unit'"));
    expect(recipes, contains("'Add step'"));
    expect(recipes, contains("'Timer unit'"));
    expect(recipes, contains("'No timer'"));
    expect(recipes, contains('_secondsForStepDraft'));
  });

  test('Starter recipe collection remains structured', () {
    final library =
        read('lib/data/essential_recipe_library.dart');

    expect(library, contains("'500 g Chicken breast'"));
    expect(library, contains("'300 ml Milk'"));
    expect(library, contains("'2 tbsp Soy sauce'"));
    expect(library, contains("'2 can Tuna'"));
  });

  test('Cook Together remains visible and audible', () {
    final recipes =
        read('lib/features/recipes/recipes_screen.dart');
    final cooking =
        read('lib/features/cooking/cooking_assistant_screen.dart');

    expect(recipes, contains("'Cook Together · 2–4 meals'"));
    expect(recipes, contains('cookTogetherMode'));
    expect(cooking, contains('MultiMealCookingAssistantScreen'));
    expect(cooking, contains("'Timer alerts'"));
    expect(cooking, contains("'Voice guidance'"));
    expect(cooking, contains("'Repeat focus'"));
  });

  test('Known contrast and overflow fixes remain present', () {
    final pantry =
        read('lib/features/pantry/pantry_screen.dart');
    final recipes =
        read('lib/features/recipes/recipes_screen.dart');
    final receipt =
        read('lib/features/receipt/receipt_scanner_screen.dart');

    expect(pantry, contains('Color(0xFFFFF8E7)'));
    expect(pantry, contains('foregroundColor: Colors.white'));
    expect(recipes, contains('constraints.maxWidth < 390'));
    expect(receipt, contains('constraints.maxWidth < 370'));
  });

  test('Insights uses correct nutrition field', () {
    final insights =
        read('lib/features/insights/insights_screen.dart');

    expect(insights, contains('nutrition.carbohydrates'));
    expect(insights, isNot(contains('nutrition.carbs')));
  });
}
