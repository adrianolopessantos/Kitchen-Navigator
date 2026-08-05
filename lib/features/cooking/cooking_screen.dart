import 'package:flutter/material.dart';
import '../../core/services/recipe_scaling_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/monthly_meal_plan.dart';
import '../../models/recipe.dart';
import 'cooking_assistant_screen.dart';
import 'cooking_feedback_screen.dart';

class CookingScreen extends StatelessWidget {
  const CookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final today = DateTime.now();
    final planned = state.monthlyMealsFor(today);
    final recipes = planned
        .where((entry) => entry.recipeId != null)
        .map((entry) => _recipeFor(state.recipes, entry))
        .whereType<_CookingChoice>()
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
        children: [
          Text(
            'Cooking assistant',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 5),
          const Text(
            'Guided steps, voice control, timers and kitchen memory',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          _TodayCard(
            plannedCount: planned.length,
            recipeCount: recipes.length,
            people: state.householdPeople,
          ),
          const SizedBox(height: 22),
          const Text(
            'Today’s planned recipes',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          if (recipes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                  'No recipe is planned for today. Choose one from the recipe library below.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            ...recipes.map(
              (choice) => _RecipeCookingCard(
                recipe: choice.recipe,
                slot: choice.entry.slot.label,
                servings: choice.entry.servings,
                onStart: () => _startCooking(
                  context,
                  choice.recipe,
                  choice.entry.servings,
                ),
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            'Recipe library',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ...state.recipes.take(12).map(
                (recipe) => _RecipeCookingCard(
                  recipe: recipe,
                  slot: recipe.category,
                  servings: state.householdPeople,
                  onStart: () => _startCooking(
                    context,
                    recipe,
                    state.householdPeople,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static _CookingChoice? _recipeFor(
    List<Recipe> recipes,
    MonthlyMealEntry entry,
  ) {
    for (final recipe in recipes) {
      if (recipe.id == entry.recipeId) {
        return _CookingChoice(entry, recipe);
      }
    }
    return null;
  }

  Future<void> _startCooking(
    BuildContext context,
    Recipe recipe,
    int servings,
  ) async {
    final completed = await openCookingAssistant(
      context,
      recipe,
      servings: servings,
    );

    if (completed == true && context.mounted) {
      final state = AppScope.of(context);
      await state.applyRecipePantryUsage(
        recipe,
        servings: servings,
      );
      await openCookingFeedback(context, recipe);
      await state.refreshCookingFeedback();
    }
  }
}

class _CookingChoice {
  const _CookingChoice(this.entry, this.recipe);
  final MonthlyMealEntry entry;
  final Recipe recipe;
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.plannedCount,
    required this.recipeCount,
    required this.people,
  });

  final int plannedCount;
  final int recipeCount;
  final int people;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.soup_kitchen_outlined,
              color: AppColors.primary,
              size: 38,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '$plannedCount planned meals · $recipeCount guided recipes · $people people',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCookingCard extends StatelessWidget {
  const _RecipeCookingCard({
    required this.recipe,
    required this.slot,
    required this.servings,
    required this.onStart,
  });

  final Recipe recipe;
  final String slot;
  final int servings;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final firstIngredient = recipe.ingredients.isEmpty
        ? ''
        : RecipeScalingService.scaleIngredientText(
            recipe.ingredients.first,
            originalServings: recipe.servings,
            targetServings: servings,
          );

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.restaurant_menu),
        ),
        title: Text(
          recipe.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '$slot · $servings servings · ${recipe.totalMinutes} min'
          '${firstIngredient.isEmpty ? '' : '\nFirst ingredient: $firstIngredient'}',
        ),
        isThreeLine: firstIngredient.isNotEmpty,
        trailing: FilledButton(
          onPressed: onStart,
          child: const Text('Cook'),
        ),
      ),
    );
  }
}
