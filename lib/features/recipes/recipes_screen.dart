import 'package:flutter/material.dart';
import '../../core/services/smart_recipe_service.dart';
import '../../core/services/nutrition_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';
import '../../models/recipe.dart';
import '../cooking/cooking_assistant_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String category = 'All';
  String sort = 'Recommended';
  bool quickOnly = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final categories = <String>{
      'All',
      ...state.recipes.map((recipe) => recipe.category),
    }.toList();

    final visible = state.filteredRecipes.where((recipe) {
      if (category != 'All' && recipe.category != category) {
        return false;
      }
      if (quickOnly && recipe.totalMinutes > 30) {
        return false;
      }
      return true;
    }).toList();

    if (sort == 'Fastest') {
      visible.sort(
        (a, b) => a.totalMinutes.compareTo(b.totalMinutes),
      );
    } else if (sort == 'Name') {
      visible.sort((a, b) => a.name.compareTo(b.name));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
        children: [
          const Text(
            'Smart Recipes',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scale recipes, check pantry availability, and find substitutions.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: state.setSearch,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search recipes or ingredients',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final value = categories[index];
                return ChoiceChip(
                  selected: category == value,
                  onSelected: (_) =>
                      setState(() => category = value),
                  label: Text(value),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                selected: quickOnly,
                onSelected: (value) =>
                    setState(() => quickOnly = value),
                avatar: const Icon(Icons.timer_outlined, size: 17),
                label: const Text('30 min or less'),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: sort,
                items: const [
                  DropdownMenuItem(
                    value: 'Recommended',
                    child: Text('Recommended'),
                  ),
                  DropdownMenuItem(
                    value: 'Fastest',
                    child: Text('Fastest'),
                  ),
                  DropdownMenuItem(
                    value: 'Name',
                    child: Text('Name'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => sort = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${visible.length} recipe${visible.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No recipes match the selected filters.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            ...visible.map(
              (recipe) => _RecipeCard(recipe: recipe),
            ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final ingredients = SmartRecipeService.scaleIngredients(
      recipe: recipe,
      people: recipe.servings,
      pantryItems: state.pantryItems,
    );
    final available = ingredients.where((item) => item.available).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF243321),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.category} · ${recipe.totalMinutes} min · '
                      '$available/${ingredients.length} available',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _RecipeBadge(recipe.difficulty),
                        if (recipe.equipment.isNotEmpty)
                          _RecipeBadge(recipe.equipment.first),
                        if (recipe.temperatureCelsius != null)
                          _RecipeBadge('${recipe.temperatureCelsius}°C'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context) async {
    int people = recipe.servings;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final state = AppScope.of(context);
            final ingredients = SmartRecipeService.scaleIngredients(
              recipe: recipe,
              people: people,
              pantryItems: state.pantryItems,
            );
            final missing =
                ingredients.where((item) => !item.available).toList();

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.viewInsetsOf(sheetContext).bottom,
                ),
                child: SizedBox(
                  height:
                      MediaQuery.sizeOf(sheetContext).height * .88,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            18,
                            16,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'People',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: List.generate(8, (index) {
                        final value = index + 1;
                        return ChoiceChip(
                          selected: people == value,
                          onSelected: (_) =>
                              setModalState(() => people = value),
                          label: Text('$value'),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Scaled ingredients',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${ingredients.length - missing.length}/${ingredients.length} available',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...ingredients.map(
                      (ingredient) =>
                          _IngredientLine(ingredient: ingredient),
                    ),
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Card(
                        color: AppColors.surfaceElevated,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Missing ingredients',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                missing
                                    .map((item) => item.name)
                                    .join(', '),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Nutrition per serving',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final nutrition =
                            NutritionService.perServing(recipe);
                        return Card(
                          color: AppColors.surfaceElevated,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Text(
                                  '${nutrition.calories.round()} kcal',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${nutrition.protein.round()} g protein',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  '${nutrition.carbohydrates.round()} g carbs',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  '${nutrition.fat.round()} g fat',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Steps',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ...List.generate(
                      recipe.steps.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${index + 1}. ${recipe.steps[index].instruction}',
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                    ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          10,
                          16,
                          10,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: missing.isEmpty
                                    ? null
                                    : () async {
                                        for (final ingredient
                                            in missing) {
                                          await state
                                              .addManualShoppingItem(
                                            name: ingredient.name,
                                            quantity:
                                                ingredient.quantity,
                                            unit: ingredient.unit,
                                            category: 'Pantry',
                                            week: state
                                                .selectedShoppingWeek,
                                          );
                                        }
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${missing.length} missing ingredient'
                                              '${missing.length == 1 ? '' : 's'} '
                                              'added to Shopping.',
                                            ),
                                          ),
                                        );
                                      },
                                icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                ),
                                label:
                                    const Text('Add missing'),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  openCookingAssistant(
                                    context,
                                    recipe,
                                    servings: people,
                                  );
                                },
                                icon:
                                    const Icon(Icons.play_arrow),
                                label: const Text('Cook'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static StorageLocation _suggestLocation(String name) {
    final value = name.toLowerCase();
    return value.contains('milk') ||
            value.contains('butter') ||
            value.contains('egg') ||
            value.contains('chicken') ||
            value.contains('salmon') ||
            value.contains('cheese')
        ? StorageLocation.fridge
        : StorageLocation.pantry;
  }
}


class _RecipeBadge extends StatelessWidget {
  const _RecipeBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IngredientLine extends StatelessWidget {
  const _IngredientLine({required this.ingredient});

  final ScaledIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      color: AppColors.surfaceElevated,
      child: ExpansionTile(
        leading: Icon(
          ingredient.available
              ? Icons.check_circle_outline
              : Icons.error_outline,
          color: ingredient.available
              ? AppColors.primary
              : AppColors.warning,
        ),
        title: Text(
          ingredient.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${_format(ingredient.quantity)} ${ingredient.unit}'
          '${ingredient.available ? ' · In pantry' : ' · Missing'}',
          style: const TextStyle(color: AppColors.muted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ingredient.substitutions.isEmpty
                    ? 'No suggested substitutions.'
                    : 'Try instead: ${ingredient.substitutions.join(', ')}',
                style: TextStyle(
                  color: ingredient.substitutions.isEmpty
                      ? AppColors.muted
                      : AppColors.primary,
                  fontSize: 12,
                  fontWeight: ingredient.substitutions.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _format(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
