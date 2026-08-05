import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/meal_plan_generator_service.dart';
import 'package:kitchen_navigator/models/cooking_feedback.dart';
import 'package:kitchen_navigator/models/household_profile.dart';
import 'package:kitchen_navigator/models/monthly_meal_plan.dart';
import 'package:kitchen_navigator/models/recipe.dart';

void main() {
  test('Highly rated recipe receives future planning preference', () {
    const recipes = [
      Recipe(
        id: 'favourite',
        name: 'Family Favourite',
        ingredients: ['Rice', 'Carrots'],
        steps: [RecipeStep(instruction: 'Cook', seconds: 600)],
        prepMinutes: 10,
      ),
      Recipe(
        id: 'other',
        name: 'Other Meal',
        ingredients: ['Rice', 'Peas'],
        steps: [RecipeStep(instruction: 'Cook', seconds: 600)],
        prepMinutes: 10,
      ),
    ];

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
        feedback: [
          CookingFeedback(
            id: '1',
            recipeId: 'favourite',
            recipeName: 'Family Favourite',
            rating: 5,
            createdAt: DateTime(2026, 8, 1),
          ),
        ],
        targetDate: DateTime(2026, 8, 5),
      ),
    );

    expect(result.plan.entries.single.name, 'Family Favourite');
    expect(
      result.plan.entries.single.suggestionReason,
      contains('highly rated family favourite'),
    );
  });
}
