import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Version 12 release baseline is present', () {
    final app = File('lib/app.dart').readAsStringSync();
    final dashboard = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();
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

    expect(app, contains('PlannerScreen'));

    expect(dashboard, contains('_scanFromDashboard'));
    expect(dashboard, contains("title: 'Kitchen overview'"));
    expect(dashboard, contains('openInsights(context)'));

    expect(shopping, contains('setShoppingPurchased'));
    expect(shopping, contains('setShoppingMonthView'));
    expect(shopping, contains('Still to buy'));
    expect(shopping, contains('Full list'));

    expect(pantry, contains('_CompactPantryRow'));
    expect(pantry, contains('_showPantryDetails'));
    expect(pantry, contains('_scanIntoPantry'));

    expect(recipes, contains('30 min or less'));
    expect(recipes, contains('Add missing'));
    expect(recipes, contains('Cook'));
    expect(recipes, contains('addCustomRecipe'));
    expect(recipes, contains('updateCustomRecipe'));
    expect(recipes, contains('Cook Together · 2–4 meals'));
    expect(recipes, contains('openCookingAssistant'));

    expect(planner, contains('shoppingItemsForWeek'));
    expect(planner, contains('openShopping'));
  });
}
