import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/app.dart';

import 'test_household_fixture.dart';

void main() {
  testWidgets('Pantry and Shopping redesigns load', (tester) async {
    mockCompletedHousehold();

    await tester.pumpWidget(const KitchenNavigatorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();

    expect(find.text('Everything stored in this kitchen'), findsOneWidget);
    expect(find.text('PANTRY HEALTH'), findsOneWidget);

    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();

    expect(
      find.text('Grouped by aisle and ready to check off'),
      findsOneWidget,
    );
  });
}
