import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard keeps current Version 12 nutrition behavior', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    // V11 Beta 2.1 used the placeholder text
    // "Nutrition analysis pending". Version 12 now uses real nutrition
    // state plus the Insights entry, so guard the current behavior instead.
    expect(source, contains('state.hasTodaysNutrition'));
    expect(source, contains('Nutrition'));
    expect(source, contains('openInsights(context)'));
    expect(
      source,
      isNot(contains('Nutrition analysis pending')),
    );
  });
}
