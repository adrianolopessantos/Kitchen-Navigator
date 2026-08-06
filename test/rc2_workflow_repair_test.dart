import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RC2 workflow repair connects core screens', () {
    final dashboard = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();
    final planner = File(
      'lib/features/planner/planner_screen.dart',
    ).readAsStringSync();
    final shopping = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();
    final recipes = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(dashboard, isNot(contains('openTodayBrief')));
    expect(dashboard, contains('_scanFromDashboard'));

    expect(planner, contains('openShopping'));
    expect(planner, contains('shoppingItemsForWeek'));
    expect(planner, contains('selectShoppingWeek'));

    expect(shopping, contains('SegmentedButton<bool>'));
    expect(shopping, contains("'Month'"));
    expect(shopping, contains('setShoppingPurchased'));
    expect(shopping, contains('setShoppingMonthView'));

    expect(recipes, contains('30 min or less'));
    expect(recipes, contains('No recipes match'));
    expect(recipes, contains('Add missing'));
    expect(recipes, contains('Cook'));
  });
}
