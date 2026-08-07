import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Version 12 shared visual primitives exist', () {
    final source = File(
      'lib/core/widgets/feature_header.dart',
    ).readAsStringSync();

    expect(source, contains('FeatureHeader'));
    expect(source, contains('FeatureSectionLabel'));
  });

  test('Global theme includes final polish', () {
    final theme = File(
      'lib/core/theme/app_theme.dart',
    ).readAsStringSync();

    expect(theme, contains('ListTileThemeData'));
    expect(theme, contains('TooltipThemeData'));
    expect(theme, contains('height: 72'));
  });

  test('Main screens keep their Version 12 identities', () {
    final shopping = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();
    final pantry = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();
    final recipes = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();
    final planner = File(
      'lib/features/planner/planner_screen.dart',
    ).readAsStringSync();

    expect(shopping, contains('AppColors.shopping'));
    expect(pantry, contains('AppColors.pantry'));
    expect(recipes, contains('AppColors.recipes'));

    // Release guard: validate Planner behavior, not UI wording/color tokens.
    expect(planner, contains('shoppingItemsForWeek'));
    expect(planner, contains('openShopping'));
    expect(planner, contains('monthlyMealPlan'));
  });

  test('Cooking and Insights keep their visual identities', () {
    final cooking = File(
      'lib/features/cooking/cooking_assistant_screen.dart',
    ).readAsStringSync();
    final insights = File(
      'lib/features/insights/insights_screen.dart',
    ).readAsStringSync();

    expect(cooking, contains('AppColors.cooking'));
    expect(insights, contains('AppColors.info'));
  });
}
