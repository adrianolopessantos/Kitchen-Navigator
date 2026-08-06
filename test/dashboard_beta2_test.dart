import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard includes current Version 11 intelligence', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains("title: 'Kitchen overview'"));
    expect(source, contains('_scanFromDashboard'));
    expect(source, contains("label: 'Scan'"));
    expect(source, contains('Budget'));
    expect(source, contains('Shopping'));
    expect(source, contains('Pantry'));
    expect(source, contains('Nutrition'));

    // The separate Kitchen Brief and direct notification-center
    // Dashboard entry were intentionally removed during RC2 cleanup.
    expect(source, isNot(contains('openTodayBrief')));
  });
}
