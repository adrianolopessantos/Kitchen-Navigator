import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('First launch opens household setup', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const KitchenNavigatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Tell us about your family'), findsOneWidget);
    expect(find.text('Step 1 of 4 · Household'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
