import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shopping Product Details keeps Save outside the scrolling form', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('MediaQuery.sizeOf(context).height * .88'),
    );
    expect(source, contains('Expanded('));
    expect(source, contains('SingleChildScrollView('));
    expect(source, contains("'Save changes'"));
    expect(source, contains('SafeArea('));
  });
}
