import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/models/monthly_meal_plan.dart';

void main() {
  test('Monthly meal plan supports 31 days and locked meals', () {
    final entries = List.generate(
      31,
      (index) => MonthlyMealEntry(
        id: 'meal-${index + 1}',
        dateKey: dateKeyFor(DateTime(2026, 8, index + 1)),
        slot: MealSlotType.dinner,
        name: 'Dinner ${index + 1}',
        servings: 4,
        locked: index == 0,
      ),
    );

    final plan = MonthlyMealPlan(
      monthKey: '2026-08',
      entries: entries,
    );

    expect(plan.entries.length, 31);
    expect(plan.forDate(DateTime(2026, 8, 1)).single.locked, isTrue);
    expect(plan.forDate(DateTime(2026, 8, 31)).single.name, 'Dinner 31');
  });

  test('Monthly meal plan serializes simple foods and recipes', () {
    final plan = MonthlyMealPlan(
      monthKey: '2026-08',
      entries: [
        MonthlyMealEntry(
          id: 'fruit',
          dateKey: '2026-08-01',
          slot: MealSlotType.morningSnack,
          name: 'Apple',
          servings: 3,
          simpleFood: true,
          suggestionReason: 'A simple family snack.',
          generationSource: 'local-personalized',
        ),
        MonthlyMealEntry(
          id: 'recipe',
          dateKey: '2026-08-01',
          slot: MealSlotType.dinner,
          name: 'Chicken Curry',
          servings: 3,
          recipeId: 'R0011',
        ),
      ],
    );

    final restored = MonthlyMealPlan.fromJson(plan.toJson());

    expect(restored.entries.length, 2);
    expect(restored.entries.first.simpleFood, isTrue);
    expect(
      restored.entries.first.suggestionReason,
      'A simple family snack.',
    );
    expect(
      restored.entries.first.generationSource,
      'local-personalized',
    );
    expect(restored.entries.last.recipeId, 'R0011');
  });
}
