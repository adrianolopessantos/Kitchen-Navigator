import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Today dashboard has only the three primary sections', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains("title: 'Today'"));
    expect(source, contains("title: 'Quick actions'"));
    expect(source, contains("title: 'Kitchen overview'"));
    expect(source, isNot(contains('Open kitchen brief')));
    expect(source, isNot(contains('openTodayBrief')));
    expect(source, contains("label: 'Scan'"));
    expect(source, contains('_scanFromDashboard'));
  });

  test('Recipe details use a sticky safe bottom action bar', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(source, contains('SafeArea('));
    expect(source, contains('MediaQuery.sizeOf(sheetContext).height * .88'));
    expect(source, contains("label: const Text('Add missing')"));
    expect(source, contains("label: const Text('Cook')"));
    expect(source, contains('addManualShoppingItem'));
  });
}
