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
      if (category == 'My recipes' && !state.isCustomRecipe(recipe)) {
        return false;
      }
      if (category != 'All' &&
          category != 'My recipes' &&
          recipe.category != category) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;

              return Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.recipes.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.recipes,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recipes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.headlineLarge,
                        ),
                        if (!compact)
                          const Text(
                            'Built-in and your own recipes, together.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (compact)
                    IconButton.filled(
                      tooltip: 'Add recipe',
                      onPressed: () => _showRecipeEditor(context),
                      icon: const Icon(Icons.add),
                    )
                  else
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.recipes,
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                      onPressed: () => _showRecipeEditor(context),
                      icon: const Icon(Icons.add, size: 19),
                      label: const Text('Add'),
                    ),
                ],
              );
            },
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                selected: quickOnly,
                onSelected: (value) =>
                    setState(() => quickOnly = value),
                avatar: const Icon(Icons.timer_outlined, size: 17),
                label: const Text('30 min or less'),
              ),
              FilterChip(
                selected: category == 'My recipes',
                onSelected: (value) => setState(
                  () => category = value ? 'My recipes' : 'All',
                ),
                avatar: const Icon(Icons.person_outline, size: 17),
                label: const Text('My recipes'),
              ),
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
              (recipe) => _RecipeCard(
                recipe: recipe,
                isCustom: state.isCustomRecipe(recipe),
                onEdit: state.isCustomRecipe(recipe)
                    ? () => _showRecipeEditor(
                          context,
                          existing: recipe,
                        )
                    : null,
                onDuplicate: state.isCustomRecipe(recipe)
                    ? () => _duplicateRecipe(context, recipe)
                    : null,
                onDelete: state.isCustomRecipe(recipe)
                    ? () => _deleteRecipe(context, recipe)
                    : null,
              ),
            ),
        ],
      ),
    );
  }


  Future<void> _showRecipeEditor(
    BuildContext context, {
    Recipe? existing,
  }) async {
    final state = AppScope.of(context);
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final categoryController =
        TextEditingController(text: existing?.category ?? 'Everyday');
    final cuisineController =
        TextEditingController(text: existing?.cuisine ?? 'International');
    final servingsController = TextEditingController(
      text: (existing?.servings ?? 2).toString(),
    );
    final prepController = TextEditingController(
      text: (existing?.prepMinutes ?? 10).toString(),
    );
    final ingredientsController = TextEditingController(
      text: existing?.ingredients.join('\n') ?? '',
    );
    final stepsController = TextEditingController(
      text: existing?.steps
              .map((step) {
                if (step.seconds > 0) {
                  return '${step.instruction} | ${step.seconds ~/ 60} min';
                }
                return step.instruction;
              })
              .join('\n') ??
          '',
    );
    final notesController =
        TextEditingController(text: existing?.description ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .90,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          existing == null
                              ? 'Add your recipe'
                              : 'Edit your recipe',
                          style:
                              Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'One ingredient and one step per line. For a timed step, add “| 10 min” after the instruction.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          autofocus: existing == null,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Recipe name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: categoryController,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: cuisineController,
                                decoration: const InputDecoration(
                                  labelText: 'Cuisine',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: servingsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Servings',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: prepController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Prep minutes',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: ingredientsController,
                          minLines: 4,
                          maxLines: 9,
                          textCapitalization:
                              TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Ingredients',
                            hintText:
                                '500 g pasta\n2 tomatoes\n1 tbsp olive oil',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: stepsController,
                          minLines: 5,
                          maxLines: 11,
                          textCapitalization:
                              TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Steps',
                            hintText:
                                'Boil pasta | 10 min\nPrepare sauce | 5 min\nCombine and serve',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.recipes,
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final ingredients = ingredientsController.text
                            .split('\n')
                            .map((value) => value.trim())
                            .where((value) => value.isNotEmpty)
                            .toList();

                        final steps = stepsController.text
                            .split('\n')
                            .map((value) => value.trim())
                            .where((value) => value.isNotEmpty)
                            .map(_parseCustomStep)
                            .toList();

                        if (name.isEmpty ||
                            ingredients.isEmpty ||
                            steps.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Add a name, at least one ingredient and one step.',
                              ),
                            ),
                          );
                          return;
                        }

                        final recipe = Recipe(
                          id: existing?.id ??
                              'custom-${DateTime.now().microsecondsSinceEpoch}',
                          name: name,
                          ingredients: ingredients,
                          steps: steps,
                          servings:
                              int.tryParse(servingsController.text) ?? 2,
                          description: notesController.text.trim(),
                          category:
                              categoryController.text.trim().isEmpty
                                  ? 'Everyday'
                                  : categoryController.text.trim(),
                          cuisine:
                              cuisineController.text.trim().isEmpty
                                  ? 'International'
                                  : cuisineController.text.trim(),
                          difficulty:
                              existing?.difficulty ?? 'Easy',
                          prepMinutes:
                              int.tryParse(prepController.text) ?? 10,
                          equipment:
                              existing?.equipment ?? const [],
                          temperatureCelsius:
                              existing?.temperatureCelsius,
                          tags: <String>{
                            ...?existing?.tags,
                            'Custom',
                          }.toList(),
                        );

                        if (existing == null) {
                          await state.addCustomRecipe(recipe);
                        } else {
                          await state.updateCustomRecipe(recipe);
                        }

                        if (!mounted ||
                            !sheetContext.mounted) {
                          return;
                        }
                        Navigator.pop(sheetContext);
                        setState(() {});
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        existing == null
                            ? 'Save recipe'
                            : 'Save changes',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RecipeStep _parseCustomStep(String value) {
    final parts = value.split('|');
    final instruction = parts.first.trim();
    var seconds = 0;

    if (parts.length > 1) {
      final timing = parts[1].trim().toLowerCase();
      final match = RegExp(r'(\d+)').firstMatch(timing);
      final amount = int.tryParse(match?.group(1) ?? '') ?? 0;

      if (timing.contains('sec')) {
        seconds = amount;
      } else if (timing.contains('hour')) {
        seconds = amount * 3600;
      } else {
        seconds = amount * 60;
      }
    }

    return RecipeStep(
      instruction: instruction,
      seconds: seconds,
    );
  }

  Future<void> _duplicateRecipe(
    BuildContext context,
    Recipe recipe,
  ) async {
    final state = AppScope.of(context);
    final copy = await state.duplicateCustomRecipe(recipe);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${copy.name} created.'),
      ),
    );
    setState(() {});
  }

  Future<void> _deleteRecipe(
    BuildContext context,
    Recipe recipe,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text(
          'Delete “${recipe.name}”? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await AppScope.of(context).deleteCustomRecipe(recipe.id);
    if (!mounted) return;
    setState(() {});
  }


}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.isCustom,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  final Recipe recipe;
  final bool isCustom;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

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
                        if (isCustom)
                          const _RecipeBadge('MY RECIPE'),
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
              if (isCustom)
                PopupMenuButton<String>(
                  tooltip: 'Manage custom recipe',
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.recipes,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'duplicate') onDuplicate?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.copy_outlined),
                        title: Text('Duplicate'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                )
              else
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

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                18,
                16,
                MediaQuery.viewInsetsOf(sheetContext).bottom + 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: missing.isEmpty
                                ? null
                                : () {
                                    for (final ingredient in missing) {
                                      state.addPantryItem(
                                        name: ingredient.name,
                                        quantity: 0,
                                        unit: ingredient.unit,
                                        location: _suggestLocation(
                                          ingredient.name,
                                        ),
                                      );
                                    }
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${missing.length} missing ingredient${missing.length == 1 ? '' : 's'} added to Shopping.',
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                            ),
                            label: const Text('Add missing'),
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
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Cook'),
                          ),
                        ),
                      ],
                    ),
                  ],
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
