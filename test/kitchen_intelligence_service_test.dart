import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/kitchen_intelligence_service.dart';
import 'package:kitchen_navigator/core/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Kitchen Intelligence builds a brief', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();

    await tester.runAsync(() async {
      while (!state.dataLoaded) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    });

    final brief = KitchenIntelligenceService.buildBrief(
      state,
      now: DateTime(2026, 8, 3, 9),
    );

    expect(brief.greeting, 'Good morning');
    expect(brief.headline, isNotEmpty);
    expect(brief.recommendations, isNotEmpty);
  });
}
