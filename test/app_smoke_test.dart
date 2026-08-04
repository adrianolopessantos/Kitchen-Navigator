import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kitchen_navigator/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Kitchen Navigator reaches the dashboard', (tester) async {
    await tester.pumpWidget(const KitchenNavigatorApp());

    // Allow SharedPreferences loading and the AppLoadingGate transition.
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Navigator'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
  });
}
