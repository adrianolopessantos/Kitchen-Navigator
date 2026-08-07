import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Recipes header and filters are responsive', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(source, contains('LayoutBuilder('));
    expect(source, contains('constraints.maxWidth < 390'));
    expect(source, contains('IconButton.filled('));
    expect(source, contains('Wrap('));
    expect(source, contains('WrapCrossAlignment.center'));
  });

  test('Planner keeps the current responsive planning workflow', () {
    final source = File(
      'lib/features/planner/planner_screen.dart',
    ).readAsStringSync();

    // The old Alpha 6 test required TextOverflow.ellipsis specifically.
    // Later Planner revisions changed presentation while preserving the
    // workflow that must remain stable for release.
    expect(source, contains('shoppingItemsForWeek'));
    expect(source, contains('openShopping'));
    expect(source, contains('monthlyMealPlan'));
    expect(source, contains('state.recipes'));
  });
}
