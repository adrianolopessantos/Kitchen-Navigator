import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Current Pantry and Shopping redesigns are installed', () {
    final pantry = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();
    final shopping = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(pantry, contains('_CompactPantryRow'));
    expect(pantry, contains('Needs attention'));
    expect(pantry, contains('Use some'));
    expect(pantry, contains('Add to Shopping'));

    expect(shopping, contains('Shopping list'));
    expect(shopping, contains('Add product'));
    expect(shopping, contains('Still to buy'));
    expect(shopping, contains('Full list'));
    expect(shopping, contains("label: Text('Month')"));
  });
}
