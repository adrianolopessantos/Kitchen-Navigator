import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shopping retains Version 12 grocery identity', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();
    expect(source, contains('AppColors.shopping'));
    expect(source, contains('item.brand'));
    expect(source, contains('Brand (optional)'));
    expect(source, contains("'Save changes'"));
  });

  test('Pantry retains compact undo workflow', () {
    final source = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();
    expect(source, contains('restorePantryItem'));
    expect(source, contains('AppColors.pantry'));
  });
}
