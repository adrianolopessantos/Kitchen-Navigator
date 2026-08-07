import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cook Together is explicit and responsive', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(source, contains("'Cook Together · 2–4 meals'"));
    expect(source, contains('cookTogetherMode'));
    expect(source, contains("'Start'"));
    expect(source, contains('Tap 2 to 4 recipe cards'));
    expect(source, contains('LayoutBuilder('));
    expect(source, contains('WrapCrossAlignment.center'));
  });

  test('Receipt top actions adapt to narrow screens', () {
    final source = File(
      'lib/features/receipt/receipt_scanner_screen.dart',
    ).readAsStringSync();

    expect(source, contains('constraints.maxWidth < 370'));
    expect(source, contains("'Choose from gallery'"));
    expect(source, contains('TextOverflow.ellipsis'));
  });
}
