import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Today exposes the Insights center', () {
    final dashboard = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(dashboard, contains("import '../insights/insights_screen.dart';"));
    expect(dashboard, contains("'Insights'"));
    expect(dashboard, contains('openInsights(context)'));
  });

  test('Insights combines core kitchen metrics', () {
    final source = File(
      'lib/features/insights/insights_screen.dart',
    ).readAsStringSync();

    expect(source, contains("'Budget'"));
    expect(source, contains("'Pantry'"));
    expect(source, contains("'Shopping'"));
    expect(source, contains("'Nutrition'"));
    expect(source, contains("'Needs attention'"));
    expect(source, contains('estimatedShoppingTotalForWeek'));
    expect(source, contains('estimatedWasteValue'));
    expect(source, contains('weeklyNutrition'));
  });
}
