import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/nutrition_intelligence_service.dart';
import 'package:kitchen_navigator/models/household_profile.dart';
import 'package:kitchen_navigator/models/nutrition_summary.dart';

void main() {
  test('Household nutrition is divided using age-based shares', () {
    const household = NutritionSummary(
      calories: 3000,
      protein: 150,
      carbohydrates: 360,
      fat: 90,
      mealCount: 5,
      varietyScore: 80,
    );

    const profile = HouseholdProfile(
      householdName: 'Family',
      members: [
        FamilyMember(
          id: 'adult',
          name: 'Adult',
          type: FamilyMemberType.adult,
          age: 40,
        ),
        FamilyMember(
          id: 'child',
          name: 'Child',
          type: FamilyMemberType.child,
          age: 8,
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

    final estimates =
        NutritionIntelligenceService.allocateToFamily(
      household: household,
      profile: profile,
    );

    expect(estimates.length, 2);
    expect(
      estimates.fold<double>(
        0,
        (total, value) => total + value.calories,
      ),
      closeTo(3000, .01),
    );
    expect(
      estimates.first.calories,
      greaterThan(estimates.last.calories),
    );
  });

  test('No planned nutrition returns no individual estimates', () {
    final estimates =
        NutritionIntelligenceService.allocateToFamily(
      household: NutritionSummary.empty,
      profile: HouseholdProfile.initial(),
    );

    expect(estimates, isEmpty);
    expect(
      NutritionIntelligenceService.hasUsefulData(
        NutritionSummary.empty,
      ),
      isFalse,
    );
  });
}
