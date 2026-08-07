import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Alpha 3 installs the premium Today dashboard', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('_PremiumHeader'));
    expect(source, contains('_TodayFocusCard'));
    expect(source, contains('_QuickAction'));
    expect(source, contains('_OverviewCard'));

    expect(source, contains("title: 'Today'"));
    expect(source, contains("title: 'Quick actions'"));
    expect(source, contains("title: 'Kitchen overview'"));

    expect(source, contains('AppColors.shopping'));
    expect(source, contains('AppColors.pantry'));
    expect(source, contains('AppColors.budget'));
    expect(source, contains('AppColors.nutrition'));

    expect(
      source,
      contains('assets/images/kitchen_navigator_icon.png'),
    );
    expect(source, contains('_greeting(now.hour)'));
  });

  test('Dashboard scanner keeps Version 12 grocery brands', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('product.brand'));
    expect(source, contains('brand: product.brand'));
    expect(source, contains('updateShoppingItem'));
  });
}
