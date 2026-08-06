import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pantry uses compact rows and a details sheet', () {
    final source = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();

    expect(source, contains('_CompactPantryRow'));
    expect(source, contains('_showPantryDetails'));
    expect(source, contains('DismissDirection.endToStart'));
    expect(source, contains("label: 'UNDO'"));
    expect(source, contains('Use some'));
    expect(source, contains('Edit'));
    expect(source, contains('Record as waste'));
  });
}
