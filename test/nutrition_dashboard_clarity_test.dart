import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard avoids misleading zero nutrition values', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Nutrition analysis pending'));
    expect(source, contains('state.hasTodaysNutrition'));
    expect(source, contains('kcal household'));
    expect(
      source,
      isNot(contains('state.todayNutrition.calories.round()')),
    );
  });
}
