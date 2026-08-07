import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

String read(String path) => File(path).readAsStringSync();

void main() {
  test('V12 core screens remain present', () {
    for (final path in [
      'lib/features/dashboard/dashboard_screen.dart',
      'lib/features/shopping/shopping_screen.dart',
      'lib/features/pantry/pantry_screen.dart',
      'lib/features/recipes/recipes_screen.dart',
      'lib/features/planner/planner_screen.dart',
      'lib/features/cooking/cooking_assistant_screen.dart',
      'lib/features/receipt/receipt_scanner_screen.dart',
      'lib/features/insights/insights_screen.dart',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  test('Cook Together release features remain enabled', () {
    final recipes = read('lib/features/recipes/recipes_screen.dart');
    final cooking =
        read('lib/features/cooking/cooking_assistant_screen.dart');

    expect(recipes, contains('Cook Together · 2–4 meals'));
    expect(recipes, contains('cookTogetherMode'));
    expect(cooking, contains('MultiMealCookingAssistantScreen'));
    expect(cooking, contains('Timer alerts'));
    expect(cooking, contains('Voice guidance'));
    expect(cooking, contains('Repeat focus'));
    expect(cooking, contains('timer finished.'));
  });

  test('Known overflow repairs remain installed', () {
    final recipes = read('lib/features/recipes/recipes_screen.dart');
    final receipt =
        read('lib/features/receipt/receipt_scanner_screen.dart');

    expect(recipes, contains('constraints.maxWidth < 390'));
    expect(recipes, contains('WrapCrossAlignment.center'));
    expect(receipt, contains('constraints.maxWidth < 370'));
    expect(receipt, contains('TextOverflow.ellipsis'));
  });

  test('Pantry Health contrast regression guard', () {
    final pantry = read('lib/features/pantry/pantry_screen.dart');

    expect(pantry, contains('Color(0xFFFFF8E7)'));
    expect(pantry, contains('Color(0xFFD7E3D8)'));
    expect(pantry, contains('Color(0xFFA9D6A5)'));
  });

  test('Insights uses the real nutrition model field', () {
    final insights = read('lib/features/insights/insights_screen.dart');

    expect(insights, contains('nutrition.carbohydrates'));
    expect(insights, isNot(contains('nutrition.carbs')));
  });

  test('V12 brand and feature palette remain defined', () {
    final theme = read('lib/core/theme/app_theme.dart');

    expect(theme, contains('class AppColors'));
    expect(theme, contains('shopping'));
    expect(theme, contains('pantry'));
    expect(theme, contains('recipes'));
    expect(theme, contains('planner'));
    expect(theme, contains('cooking'));
    expect(theme, contains('nutrition'));
  });
}
