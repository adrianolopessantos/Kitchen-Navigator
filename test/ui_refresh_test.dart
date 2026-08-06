import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Current dashboard keeps the three final sections', () {
    final source = File(
      'lib/features/dashboard/dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains("title: 'Today'"));
    expect(source, contains("title: 'Quick actions'"));
    expect(source, contains("title: 'Kitchen overview'"));

    expect(source, isNot(contains('Everything at a glance')));
    expect(source, isNot(contains('Open kitchen brief')));
    expect(source, isNot(contains('openTodayBrief')));
  });
}
