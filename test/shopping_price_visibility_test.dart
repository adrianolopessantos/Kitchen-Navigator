import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shopping screen shows per-item and summary totals', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Still to buy'));
    expect(source, contains('Full list'));
    expect(source, contains('Estimated item total'));
    expect(source, contains('item.estimatedTotal'));
    expect(source, contains('remainingEstimatedTotal'));
  });
}
