import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard uses Version 11 live planning values', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('state.todaysMonthlyMeals'));
    expect(source, contains('state.selectedWeeklyShoppingItems'));
    expect(
      source,
      contains('state.estimatedMonthlyPlanShoppingTotal'),
    );
    expect(source, contains('state.weeklyShoppingBudget'));
    expect(source, contains('state.householdProfile.monthlyBudget'));

    expect(source, isNot(contains('state.shoppingItems.length} to buy')));
    expect(
      source,
      isNot(
        contains(
          'state.estimatedShoppingTotal.toStringAsFixed(2)} weekly list',
        ),
      ),
    );
  });
}
