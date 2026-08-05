import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/app.dart';

import 'test_household_fixture.dart';

void main() {
  setUp(mockCompletedHousehold);

  testWidgets('Kitchen Navigator reaches the dashboard', (tester) async {
    await tester.pumpWidget(const KitchenNavigatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Navigator'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
  });
}
