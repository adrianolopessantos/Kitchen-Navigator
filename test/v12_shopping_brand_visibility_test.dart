import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shopping main list always shows brand information', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(source, contains("'Brand: '"));
    expect(source, contains("'Any brand'"));
    expect(source, contains('item.brand.trim()'));
  });
}
