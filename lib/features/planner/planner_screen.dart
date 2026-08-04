import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/recipe.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Weekly meal plan',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => state.clearDay(state.selectedDay),
                  child: const Text('Clear day'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 62,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: AppState.days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = AppState.days[index];
                final count = state.mealsFor(day).length;
                return ChoiceChip(
                  selected: day == state.selectedDay,
                  onSelected: (_) => state.selectDay(day),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(day.substring(0, 3)),
                      if (count > 0)
                        Text(
                          '$count meal${count == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 9),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              children: [
                const Text(
                  'SELECTED FOR',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.selectedDay,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (state.selectedMeals.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'No meals selected. Choose a recipe below.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  ...state.selectedMeals.map((meal) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    meal.recipe.name,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      state.toggleRecipe(state.selectedDay, meal.recipe),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const Text(
                              'People',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: List.generate(8, (index) {
                                final value = index + 1;
                                return ChoiceChip(
                                  selected: meal.people == value,
                                  onSelected: (_) => state.setPeople(
                                    state.selectedDay,
                                    meal.recipe.id,
                                    value,
                                  ),
                                  label: Text('$value'),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                TextField(
                  onChanged: state.setSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search recipes or ingredients',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Add a meal',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...state.filteredRecipes.map(
                  (recipe) => _RecipePickerCard(recipe: recipe),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipePickerCard extends StatelessWidget {
  const _RecipePickerCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final added = state.containsRecipe(state.selectedDay, recipe.id);
    final minutes = (recipe.totalSeconds / 60).ceil();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(
          recipe.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '$minutes min · ${recipe.ingredients.length} ingredients',
          style: const TextStyle(color: AppColors.muted),
        ),
        trailing: FilledButton(
          onPressed: () => state.toggleRecipe(state.selectedDay, recipe),
          child: Text(added ? 'Added' : 'Add'),
        ),
      ),
    );
  }
}
