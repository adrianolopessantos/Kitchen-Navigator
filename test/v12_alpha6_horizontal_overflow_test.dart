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

  test('Planner custom recipe labels can ellipsize', () {
    final source = File(
      'lib/features/planner/planner_screen.dart',
    ).readAsStringSync();

    expect(source, contains('TextOverflow.ellipsis'));
  });
}
