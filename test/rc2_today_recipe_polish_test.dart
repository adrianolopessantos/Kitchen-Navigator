import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Today dashboard keeps the primary Version 12 sections', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains("title: 'Today'"));
    expect(source, contains("title: 'Quick actions'"));
    expect(source, contains("title: 'Kitchen overview'"));
    expect(source, isNot(contains('Open kitchen brief')));
    expect(source, isNot(contains('openTodayBrief')));
    expect(source, contains('_scanFromDashboard'));
  });

  test('Recipe details keep safe bottom actions', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    // Later V12 revisions changed the exact sheet height from the old
    // RC2 hard-coded .88 value. Guard the actual release behavior instead.
    expect(source, contains('SafeArea('));
    expect(source, contains('MediaQuery.sizeOf(sheetContext).height'));
    expect(source, contains('Add missing'));
    expect(source, contains('Cook'));
    expect(source, contains('openCookingAssistant'));
    expect(source, contains('FilledButton.icon'));
    expect(source, contains('OutlinedButton.icon'));
  });
}
