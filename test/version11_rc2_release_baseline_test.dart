import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Version 11 RC2 release baseline is present', () {
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

    expect(shopping, contains('setShoppingPurchased'));
    expect(shopping, contains('setShoppingMonthView'));
    expect(shopping, contains('Still to buy'));
    expect(shopping, contains('Full list'));

    expect(pantry, contains('_CompactPantryRow'));
    expect(pantry, contains('_showPantryDetails'));

    expect(recipes, contains('30 min or less'));
    expect(recipes, contains('Add missing'));
    expect(recipes, contains('Cook'));
    expect(recipes, contains('addManualShoppingItem'));

    expect(planner, contains('shoppingItemsForWeek'));
    expect(planner, contains('openShopping'));
  });
}
