import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/monthly_meal_plan_service.dart';
import 'package:kitchen_navigator/models/monthly_meal_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Monthly plan saves and reloads locally', () async {
    SharedPreferences.setMockInitialValues({});

    final plan = MonthlyMealPlan(
      monthKey: '2026-08',
      entries: const [
        MonthlyMealEntry(
          id: '1',
          dateKey: '2026-08-05',
          slot: MealSlotType.afternoonSnack,
          name: 'Yogurt',
          servings: 4,
          simpleFood: true,
          locked: true,
        ),
      ],
    );

    await MonthlyMealPlanService.save(plan);
    final restored =
        await MonthlyMealPlanService.load(DateTime(2026, 8));

    expect(restored.entries.single.name, 'Yogurt');
    expect(restored.entries.single.locked, isTrue);
  });

  test('A different month starts empty', () async {
    SharedPreferences.setMockInitialValues({});

    await MonthlyMealPlanService.save(
      MonthlyMealPlan(
        monthKey: '2026-08',
        entries: const [],
      ),
    );

    final restored =
        await MonthlyMealPlanService.load(DateTime(2026, 9));

    expect(restored.monthKey, '2026-09');
    expect(restored.entries, isEmpty);
  });
}
