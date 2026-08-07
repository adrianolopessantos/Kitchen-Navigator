import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cook Together has timer and spoken alerts', () {
    final source = File(
      'lib/features/cooking/cooking_assistant_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Timer alerts'));
    expect(source, contains('Voice guidance'));
    expect(source, contains('Repeat focus'));
    expect(source, contains('timer finished.'));
    expect(source, contains('Focus now.'));
    expect(source, contains('Timer finished · action needed'));
  });
}
