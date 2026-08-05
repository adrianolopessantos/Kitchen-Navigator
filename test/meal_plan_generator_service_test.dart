import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/meal_plan_generator_service.dart';
import 'package:kitchen_navigator/models/household_profile.dart';
import 'package:kitchen_navigator/models/monthly_meal_plan.dart';
import 'package:kitchen_navigator/models/pantry_item.dart';
import 'package:kitchen_navigator/models/recipe.dart';

void main() {
  const recipes = [
    Recipe(
      id: 'safe',
      name: 'Vegetable Rice',
      ingredients: ['Rice', 'Carrots', 'Peas'],
      steps: [RecipeStep(instruction: 'Cook', seconds: 1200)],
      cuisine: 'Mediterranean',
      prepMinutes: 10,
      tags: ['vegan'],
    ),
    Recipe(
      id: 'unsafe',
      name: 'Peanut Chicken',
      ingredients: ['Chicken', 'Peanuts'],
      steps: [RecipeStep(instruction: 'Cook', seconds: 1200)],
      prepMinutes: 10,
    ),
  ];

  test('Generator avoids household allergies', () {
    final request = MealPlanGenerationRequest(
      month: DateTime(2026, 8),
      household: const HouseholdProfile(
        householdName: 'Test',
        members: [
          FamilyMember(
            id: '1',
            name: 'Alex',
            type: FamilyMemberType.adult,
            age: 35,
            allergies: ['Peanuts'],
          ),
        ],
        mealsPerDay: 1,
        snacksPerDay: 0,
        monthlyBudget: 500,
        preferredCuisines: ['Mediterranean'],
        maxWeekdayCookingMinutes: 30,
        usePantryFirst: true,
        useLeftovers: true,
        setupComplete: true,
      ),
      recipes: recipes,
      pantryItems: const [],
      appliances: const [],
      activeSlots: const [MealSlotType.dinner],
      existingEntries: const [],
    );

    final result = MealPlanGeneratorService.generate(request);

    expect(
      result.plan.entries.any(
        (entry) => entry.name == 'Peanut Chicken',
      ),
      isFalse,
    );
  });

  test('Generator preserves locked meals during regeneration', () {
    const locked = MonthlyMealEntry(
      id: 'locked',
      dateKey: '2026-08-05',
      slot: MealSlotType.dinner,
      name: 'Family Pizza',
      servings: 4,
      locked: true,
    );

    final result = MealPlanGeneratorService.generate(
      MealPlanGenerationRequest(
        month: DateTime(2026, 8),
        household: HouseholdProfile.initial().copyWith(
          members: const [
            FamilyMember(
              id: '1',
              name: 'Alex',
              type: FamilyMemberType.adult,
              age: 35,
            ),
          ],
          setupComplete: true,
        ),
        recipes: recipes,
        pantryItems: const [
          PantryItem(
            id: 'rice',
            name: 'Rice',
            quantity: 1,
            unit: 'kg',
            location: StorageLocation.pantry,
          ),
        ],
        appliances: const [],
        activeSlots: const [MealSlotType.dinner],
        existingEntries: const [locked],
      ),
    );

    expect(
      result.plan.entries
          .where((entry) => entry.id == 'locked')
          .single
          .name,
      'Family Pizza',
    );
  });

  test('Generator explains suggestions', () {
    final result = MealPlanGeneratorService.generate(
      MealPlanGenerationRequest(
        month: DateTime(2026, 8),
        household: HouseholdProfile.initial().copyWith(
          members: const [
            FamilyMember(
              id: '1',
              name: 'Alex',
              type: FamilyMemberType.adult,
              age: 35,
            ),
          ],
          setupComplete: true,
        ),
        recipes: recipes,
        pantryItems: const [],
        appliances: const [],
        activeSlots: const [MealSlotType.dinner],
        existingEntries: const [],
        targetDate: DateTime(2026, 8, 5),
      ),
    );

    expect(result.plan.entries.single.suggestionReason, isNotEmpty);
    expect(result.summary, contains('Personalized locally'));
  });
}
