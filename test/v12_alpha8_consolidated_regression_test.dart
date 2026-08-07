import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cook Together remains easy to discover', () {
    final recipes = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(recipes, contains("'Cook Together · 2–4 meals'"));
    expect(recipes, contains('cookTogetherMode'));
    expect(recipes, contains('Tap 2 to 4 recipe cards'));
    expect(recipes, contains('constraints.maxWidth < 390'));
  });

  test('Cook Together keeps audio and voice alerts', () {
    final cooking = File(
      'lib/features/cooking/cooking_assistant_screen.dart',
    ).readAsStringSync();

    expect(cooking, contains("'Timer alerts'"));
    expect(cooking, contains("'Voice guidance'"));
    expect(cooking, contains("'Repeat focus'"));
    expect(cooking, contains('timer finished.'));
    expect(cooking, contains('Focus now.'));
  });

  test('Receipt scanner remains responsive', () {
    final receipt = File(
      'lib/features/receipt/receipt_scanner_screen.dart',
    ).readAsStringSync();

    expect(receipt, contains('constraints.maxWidth < 370'));
    expect(receipt, contains('TextOverflow.ellipsis'));
  });

  test('Pantry health keeps final high contrast styling', () {
    final pantry = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();

    expect(pantry, contains('Color(0xFFA9D6A5)'));
    expect(pantry, contains('Color(0xFFFFF8E7)'));
    expect(pantry, contains('Color(0xFFD7E3D8)'));
  });

  test('Alpha 8 Insights is connected and uses correct nutrition field', () {
    final dashboard = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();
    final insights = File(
      'lib/features/insights/insights_screen.dart',
    ).readAsStringSync();

    expect(dashboard, contains('openInsights(context)'));
    expect(insights, contains("'Kitchen insights'"));
    expect(insights, contains('nutrition.carbohydrates'));
    expect(insights, isNot(contains('nutrition.carbs')));
    expect(insights, contains("'Budget'"));
    expect(insights, contains("'Pantry'"));
    expect(insights, contains("'Shopping'"));
    expect(insights, contains("'Nutrition'"));
  });
}
