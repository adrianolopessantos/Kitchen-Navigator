import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/state/app_state.dart';
import 'package:kitchen_navigator/core/services/household_profile_service.dart';
import 'package:kitchen_navigator/core/services/monthly_meal_plan_service.dart';
import 'package:kitchen_navigator/models/household_profile.dart';
import 'package:kitchen_navigator/models/monthly_meal_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  test('Monthly plan is split into weekly shopping periods', () async {
    const household = HouseholdProfile(
      householdName: 'Test Family',
      members: [
        FamilyMember(
          id: '1',
          name: 'Alex',
          type: FamilyMemberType.adult,
          age: 35,
        ),
      ],
      mealsPerDay: 3,
      snacksPerDay: 1,
      monthlyBudget: 500,
      preferredCuisines: ['Mediterranean'],
      maxWeekdayCookingMinutes: 30,
      usePantryFirst: true,
      useLeftovers: true,
      setupComplete: true,
    );

    const plan = MonthlyMealPlan(
      monthKey: '2026-08',
      entries: [
        MonthlyMealEntry(
          id: 'week-1',
          dateKey: '2026-08-03',
          slot: MealSlotType.dinner,
          name: 'Chicken Curry',
          servings: 1,
          recipeId: 'R0011',
        ),
        MonthlyMealEntry(
          id: 'week-2',
          dateKey: '2026-08-10',
          slot: MealSlotType.morningSnack,
          name: 'Apple',
          servings: 1,
          simpleFood: true,
        ),
      ],
    );

    SharedPreferences.setMockInitialValues({
      HouseholdProfileService.storageKey:
          jsonEncode(household.toJson()),
      MonthlyMealPlanService.storageKey:
          jsonEncode(plan.toJson()),
    });

    final state = AppState();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(state.shoppingItemsForWeek(1), isNotEmpty);
    expect(state.shoppingItemsForWeek(2), isNotEmpty);
    expect(
      state.monthlyShoppingItems.map((item) => item.week).toSet(),
      containsAll({1, 2}),
    );
  });

  test('Weekly budget is derived from monthly household budget', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(state.weeklyShoppingBudget, greaterThan(0));
    expect(state.shoppingWeeksInSelectedMonth, inInclusiveRange(4, 5));
  });
}
