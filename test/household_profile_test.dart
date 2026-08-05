import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/models/household_profile.dart';

void main() {
  test('Household profile serializes family planning data', () {
    final profile = HouseholdProfile(
      householdName: 'Test Family',
      members: const [
        FamilyMember(
          id: 'adult-1',
          name: 'Alex',
          type: FamilyMemberType.adult,
          age: 38,
          dietaryPreferences: [
            DietaryPreference.highProtein,
          ],
          allergies: ['Peanuts'],
          likes: ['Chicken'],
          dislikes: ['Mushrooms'],
        ),
        FamilyMember(
          id: 'child-1',
          name: 'Sam',
          type: FamilyMemberType.child,
          age: 8,
        ),
      ],
      mealsPerDay: 3,
      snacksPerDay: 2,
      monthlyBudget: 650,
      preferredCuisines: const [
        'Mediterranean',
        'Portuguese',
      ],
      maxWeekdayCookingMinutes: 30,
      usePantryFirst: true,
      useLeftovers: true,
      setupComplete: true,
    );

    final restored = HouseholdProfile.fromJson(profile.toJson());

    expect(restored.householdName, 'Test Family');
    expect(restored.people, 2);
    expect(restored.adults, 1);
    expect(restored.children, 1);
    expect(restored.mealsPerDay, 3);
    expect(restored.snacksPerDay, 2);
    expect(restored.householdAllergies, contains('peanuts'));
    expect(
      restored.householdDietaryPreferences,
      contains(DietaryPreference.highProtein),
    );
    expect(restored.setupComplete, isTrue);
  });
}
