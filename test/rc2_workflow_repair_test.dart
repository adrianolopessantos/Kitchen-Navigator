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

    expect(dashboard, contains('openTodayBrief'));
    expect(planner, contains('openShopping'));
    expect(planner, contains('shoppingItemsForWeek'));
    expect(shopping, contains("label: Text('Month')"));
    expect(shopping, contains('setShoppingPurchased'));
    expect(recipes, contains('30 min or less'));
    expect(recipes, contains('No recipes match'));
  });
}
