import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Today uses the official Version 12 logo', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/images/kitchen_navigator_icon.png'),
    );
    expect(source, isNot(contains('KnifeCompassLogo')));
  });

  test('Shopping supports optional grocery brands', () {
    final state = File(
      'lib/core/state/app_state.dart',
    ).readAsStringSync();
    final shopping = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(state, contains("this.brand = ''"));
    expect(state, contains("'brand': brand"));
    expect(state, contains("json['brand']"));
    expect(shopping, contains('Brand (optional)'));
    expect(shopping, contains('item.brand'));
    expect(shopping, contains('result.brand'));
  });
}
