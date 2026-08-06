import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/app.dart';

import 'test_household_fixture.dart';

void main() {
  setUp(mockCompletedHousehold);

  testWidgets('Kitchen Navigator reaches the current dashboard',
      (tester) async {
    await tester.pumpWidget(const KitchenNavigatorApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Quick actions'), findsOneWidget);
  });
}
