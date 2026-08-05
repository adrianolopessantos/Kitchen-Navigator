import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard includes Beta 2 intelligence cards', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Daily intelligence'));
    expect(source, contains('Nutrition'));
    expect(source, contains('Budget forecast'));
    expect(source, contains('Waste intelligence'));
    expect(source, contains('openNotificationCenter'));
  });
}
