import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RC1 Shopping Editor exposes essential controls', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Add product'));
    expect(source, contains('Product details'));
    expect(source, contains('Quantity'));
    expect(source, contains('Unit'));
    expect(source, contains('Aisle / category'));
    expect(source, contains('DismissDirection.endToStart'));
    expect(source, contains('UNDO'));
    expect(source, contains('Purchased'));
    expect(source, contains('USED IN'));
  });
}
