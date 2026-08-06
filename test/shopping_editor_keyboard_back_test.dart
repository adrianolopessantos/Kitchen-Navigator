import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shopping editor does not dispose controllers during route close', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(source, contains('useSafeArea: true'));
    expect(source, isNot(contains('nameController.dispose()')));
    expect(source, isNot(contains('quantityController.dispose()')));
    expect(source, isNot(contains('priceController.dispose()')));
  });
}
