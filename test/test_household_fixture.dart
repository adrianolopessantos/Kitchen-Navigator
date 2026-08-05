import 'dart:convert';

import 'package:kitchen_navigator/core/services/household_profile_service.dart';
import 'package:kitchen_navigator/models/household_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void mockCompletedHousehold() {
  const profile = HouseholdProfile(
    householdName: 'Test Family Kitchen',
    members: [
      FamilyMember(
        id: 'test-adult',
        name: 'Test User',
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

  SharedPreferences.setMockInitialValues({
    HouseholdProfileService.storageKey:
        jsonEncode(profile.toJson()),
  });
}
