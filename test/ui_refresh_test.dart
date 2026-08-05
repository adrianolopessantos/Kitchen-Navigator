import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/app.dart';

import 'test_household_fixture.dart';

void main() {
  testWidgets('Visual refresh dashboard loads', (tester) async {
    mockCompletedHousehold();

    await tester.pumpWidget(const KitchenNavigatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Navigator'), findsOneWidget);
    expect(find.text('Everything at a glance'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Quick actions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kitchen overview'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Kitchen overview'), findsOneWidget);
  });
}
