import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard uses current Version 12 live planning values', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('state.todaysMonthlyMeals'));
    expect(source, contains('state.selectedWeeklyShoppingItems'));
    expect(source, contains('state.estimatedShoppingTotalForWeek'));
    expect(source, contains('state.weeklyShoppingBudget'));
    expect(source, contains('openInsights(context)'));

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
