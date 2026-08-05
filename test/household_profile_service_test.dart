import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/household_profile_service.dart';
import 'package:kitchen_navigator/models/household_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Household profile saves and reloads locally', () async {
    SharedPreferences.setMockInitialValues({});

    final profile = HouseholdProfile.initial().copyWith(
      householdName: 'Saved Family',
      members: const [
        FamilyMember(
          id: '1',
          name: 'Jordan',
          type: FamilyMemberType.adult,
          age: 35,
        ),
      ],
      mealsPerDay: 3,
      snacksPerDay: 2,
      monthlyBudget: 700,
      setupComplete: true,
    );

    await HouseholdProfileService.save(profile);
    final restored = await HouseholdProfileService.load();

    expect(restored.householdName, 'Saved Family');
    expect(restored.members.single.name, 'Jordan');
    expect(restored.monthlyBudget, 700);
    expect(restored.setupComplete, isTrue);
  });

  test('Missing household profile returns first-run defaults', () async {
    SharedPreferences.setMockInitialValues({});

    final restored = await HouseholdProfileService.load();

    expect(restored.setupComplete, isFalse);
    expect(restored.mealsPerDay, 3);
  });
}
