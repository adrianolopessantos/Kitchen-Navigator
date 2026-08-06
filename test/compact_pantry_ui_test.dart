import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pantry list is compact and actions live in details', () {
    final source = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();

    expect(source, contains('_CompactPantryRow'));
    expect(source, contains('Product details') ||
        source.contains('_showPantryDetails'));
    expect(source, contains('Use some'));
    expect(source, contains('Add to Shopping'));
    expect(source, contains('DismissDirection.endToStart'));
    expect(source, contains('UNDO'));
    expect(source, contains('Needs attention'));
    expect(source, isNot(contains('Record product use')));
  });
}
