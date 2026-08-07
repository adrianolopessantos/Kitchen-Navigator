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
  final Set<String> selectedForCooking = <String>{};
  bool cookTogetherMode = false;
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
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.recipes,
                        foregroundColor: Colors.white,
                      ),
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
          const SizedBox(height: 10),
          Container(
            height: 3,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.recipes,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cooking,
                side: BorderSide(
                  color: cookTogetherMode
                      ? AppColors.cooking
                      : AppColors.border,
                ),
                backgroundColor: cookTogetherMode
                    ? AppColors.cooking.withValues(alpha: .08)
                    : AppColors.surface,
              ),
              onPressed: () {
                setState(() {
                  cookTogetherMode = !cookTogetherMode;
                  if (!cookTogetherMode) {
                    selectedForCooking.clear();
                  }
                });
              },
              icon: Icon(
                cookTogetherMode
                    ? Icons.close
                    : Icons.soup_kitchen_outlined,
              ),
              label: Text(
                cookTogetherMode
                    ? 'Cancel Cook Together'
                    : 'Cook Together · 2–4 meals',
              ),
            ),
          ),
          if (cookTogetherMode) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cooking.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: AppColors.cooking.withValues(alpha: .22),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    color: AppColors.cooking,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      selectedForCooking.isEmpty
                          ? 'Tap 2 to 4 recipe cards to select your meals.'
                          : '${selectedForCooking.length} meal${selectedForCooking.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (selectedForCooking.length >= 2)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cooking,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      onPressed: () => _openCookTogether(context),
                      child: const Text('Start'),
                    ),
                ],
              ),
            ),
          ],
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
                selectedForCooking:
                    selectedForCooking.contains(recipe.id),
                selectionMode: cookTogetherMode,
                onToggleCooking: () {
                  setState(() {
                    if (!selectedForCooking.add(recipe.id)) {
                      selectedForCooking.remove(recipe.id);
                    } else if (selectedForCooking.length > 4) {
                      selectedForCooking.remove(recipe.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cook Together supports up to 4 meals.',
                          ),
                        ),
                      );
                    }
                  });
                },
              ),
            ),
        ],
      ),
    );
  }


  Future<void> _openCookTogether(BuildContext context) async {
    final state = AppScope.of(context);
    final selected = state.recipes
        .where((recipe) => selectedForCooking.contains(recipe.id))
        .take(4)
        .toList();

    if (selected.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 2 recipes to Cook Together.'),
        ),
      );
      return;
    }

    await openMultiMealCookingAssistant(
      context,
      selected,
    );

    if (!mounted) return;
    setState(() {
      selectedForCooking.clear();
      cookTogetherMode = false;
    });
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
    final notesController =
        TextEditingController(text: existing?.description ?? '');

    final ingredientRows = existing == null
        ? <_IngredientDraft>[_IngredientDraft()]
        : existing.ingredients
            .map(_ingredientDraftFromText)
            .toList();

    final stepRows = existing == null
        ? <_StepDraft>[_StepDraft()]
        : existing.steps
            .map(_stepDraftFromRecipeStep)
            .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * .92,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        18,
                        16,
                        28,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            existing == null
                                ? 'Build your recipe'
                                : 'Edit your recipe',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add ingredients with quantity and unit, then build each cooking step with an optional timer.',
                            style: TextStyle(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameController,
                            autofocus: existing == null,
                            textCapitalization:
                                TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Recipe name',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      categoryController,
                                  decoration:
                                      const InputDecoration(
                                    labelText: 'Category',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller:
                                      cuisineController,
                                  decoration:
                                      const InputDecoration(
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
                                  controller:
                                      servingsController,
                                  keyboardType:
                                      TextInputType.number,
                                  decoration:
                                      const InputDecoration(
                                    labelText: 'Servings',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: prepController,
                                  keyboardType:
                                      TextInputType.number,
                                  decoration:
                                      const InputDecoration(
                                    labelText: 'Prep minutes',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const _RecipeBuilderSectionTitle(
                            icon: Icons.shopping_basket_outlined,
                            title: 'Ingredients',
                            subtitle:
                                'Name, quantity and kitchen unit',
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(
                            ingredientRows.length,
                            (index) {
                              final row =
                                  ingredientRows[index];
                              final units = <String>{
                                ..._recipeUnits,
                                row.unit,
                              }.where(
                                (value) => value.isNotEmpty,
                              ).toList();

                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.backgroundSoft,
                                  borderRadius:
                                      BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller:
                                          row.nameController,
                                      textCapitalization:
                                          TextCapitalization
                                              .sentences,
                                      decoration:
                                          InputDecoration(
                                        labelText:
                                            'Ingredient ${index + 1}',
                                        hintText:
                                            'e.g. Chicken breast',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller: row
                                                .quantityController,
                                            keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                              decimal: true,
                                            ),
                                            decoration:
                                                const InputDecoration(
                                              labelText:
                                                  'Quantity',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child:
                                              DropdownButtonFormField<
                                                  String>(
                                            value: units
                                                    .contains(
                                                        row.unit)
                                                ? row.unit
                                                : 'each',
                                            isExpanded: true,
                                            decoration:
                                                const InputDecoration(
                                              labelText: 'Unit',
                                            ),
                                            items: units
                                                .map(
                                                  (unit) =>
                                                      DropdownMenuItem(
                                                    value: unit,
                                                    child: Text(
                                                      unit,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setModalState(
                                                  () => row.unit =
                                                      value,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          tooltip:
                                              'Remove ingredient',
                                          onPressed:
                                              ingredientRows.length <=
                                                      1
                                                  ? null
                                                  : () =>
                                                      setModalState(
                                                        () {
                                                          ingredientRows
                                                              .removeAt(
                                                            index,
                                                          );
                                                        },
                                                      ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setModalState(
                                () => ingredientRows.add(
                                  _IngredientDraft(),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text(
                                'Add ingredient',
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _RecipeBuilderSectionTitle(
                            icon: Icons.format_list_numbered,
                            title: 'Cooking steps',
                            subtitle:
                                'Add an optional timer to each step',
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(
                            stepRows.length,
                            (index) {
                              final row = stepRows[index];
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.backgroundSoft,
                                  borderRadius:
                                      BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Step ${index + 1}',
                                          style: const TextStyle(
                                            color:
                                                AppColors.recipes,
                                            fontWeight:
                                                FontWeight.w800,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          tooltip:
                                              'Remove step',
                                          onPressed:
                                              stepRows.length <= 1
                                                  ? null
                                                  : () =>
                                                      setModalState(
                                                        () {
                                                          stepRows
                                                              .removeAt(
                                                            index,
                                                          );
                                                        },
                                                      ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      controller:
                                          row.instructionController,
                                      minLines: 2,
                                      maxLines: 4,
                                      textCapitalization:
                                          TextCapitalization
                                              .sentences,
                                      decoration:
                                          const InputDecoration(
                                        labelText:
                                            'Instruction',
                                        hintText:
                                            'e.g. Simmer the sauce',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller:
                                                row.timeController,
                                            enabled:
                                                row.timeUnit !=
                                                    'No timer',
                                            keyboardType:
                                                TextInputType
                                                    .number,
                                            decoration:
                                                const InputDecoration(
                                              labelText: 'Time',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child:
                                              DropdownButtonFormField<
                                                  String>(
                                            value:
                                                row.timeUnit,
                                            isExpanded: true,
                                            decoration:
                                                const InputDecoration(
                                              labelText:
                                                  'Timer unit',
                                            ),
                                            items:
                                                _recipeTimeUnits
                                                    .map(
                                                      (unit) =>
                                                          DropdownMenuItem(
                                                        value: unit,
                                                        child: Text(
                                                          unit,
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setModalState(
                                                  () {
                                                    row.timeUnit =
                                                        value;
                                                    if (value ==
                                                        'No timer') {
                                                      row.timeController
                                                          .clear();
                                                    }
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setModalState(
                                () => stepRows.add(
                                  _StepDraft(),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label:
                                  const Text('Add step'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: notesController,
                            minLines: 2,
                            maxLines: 5,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Notes (optional)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.recipes,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final name =
                              nameController.text.trim();

                          final ingredients =
                              ingredientRows
                                  .where(
                                    (row) => row
                                        .nameController
                                        .text
                                        .trim()
                                        .isNotEmpty,
                                  )
                                  .map(
                                    (row) {
                                      final quantity = row
                                              .quantityController
                                              .text
                                              .trim()
                                              .isEmpty
                                          ? '1'
                                          : row
                                              .quantityController
                                              .text
                                              .trim()
                                              .replaceAll(
                                                ',',
                                                '.',
                                              );
                                      return '$quantity ${row.unit} '
                                              '${row.nameController.text.trim()}'
                                          .trim();
                                    },
                                  )
                                  .toList();

                          final steps = stepRows
                              .where(
                                (row) => row
                                    .instructionController
                                    .text
                                    .trim()
                                    .isNotEmpty,
                              )
                              .map(
                                (row) => RecipeStep(
                                  instruction: row
                                      .instructionController
                                      .text
                                      .trim(),
                                  seconds:
                                      _secondsForStepDraft(
                                    row,
                                  ),
                                ),
                              )
                              .toList();

                          if (name.isEmpty ||
                              ingredients.isEmpty ||
                              steps.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Add a recipe name, at least one ingredient and one cooking step.',
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
                            servings: int.tryParse(
                                  servingsController.text,
                                ) ??
                                2,
                            description:
                                notesController.text.trim(),
                            category: categoryController
                                    .text
                                    .trim()
                                    .isEmpty
                                ? 'Everyday'
                                : categoryController.text
                                    .trim(),
                            cuisine: cuisineController
                                    .text
                                    .trim()
                                    .isEmpty
                                ? 'International'
                                : cuisineController.text
                                    .trim(),
                            difficulty:
                                existing?.difficulty ??
                                    'Easy',
                            prepMinutes: int.tryParse(
                                  prepController.text,
                                ) ??
                                10,
                            equipment:
                                existing?.equipment ??
                                    const [],
                            temperatureCelsius:
                                existing
                                    ?.temperatureCelsius,
                            tags: <String>{
                              ...?existing?.tags,
                              'Custom',
                            }.toList(),
                          );

                          if (existing == null) {
                            await state
                                .addCustomRecipe(recipe);
                          } else {
                            await state
                                .updateCustomRecipe(recipe);
                          }

                          if (!mounted ||
                              !sheetContext.mounted) {
                            return;
                          }
                          Navigator.pop(sheetContext);
                          setState(() {});
                        },
                        icon:
                            const Icon(Icons.save_outlined),
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
      ),
    );

    nameController.dispose();
    categoryController.dispose();
    cuisineController.dispose();
    servingsController.dispose();
    prepController.dispose();
    notesController.dispose();
    for (final row in ingredientRows) {
      row.dispose();
    }
    for (final row in stepRows) {
      row.dispose();
    }
  }

  _IngredientDraft _ingredientDraftFromText(String value) {
    final match = RegExp(
      r'^\s*(\d+(?:[.,]\d+)?)\s+([^\s]+)\s+(.+)$',
    ).firstMatch(value.trim());

    if (match == null) {
      return _IngredientDraft(
        name: value.trim(),
        quantity: '1',
        unit: 'each',
      );
    }

    return _IngredientDraft(
      name: match.group(3)?.trim() ?? value.trim(),
      quantity:
          (match.group(1) ?? '1').replaceAll(',', '.'),
      unit: match.group(2)?.trim() ?? 'each',
    );
  }

  _StepDraft _stepDraftFromRecipeStep(RecipeStep step) {
    if (step.seconds <= 0) {
      return _StepDraft(
        instruction: step.instruction,
        timeUnit: 'No timer',
      );
    }

    if (step.seconds % 3600 == 0) {
      return _StepDraft(
        instruction: step.instruction,
        time: '${step.seconds ~/ 3600}',
        timeUnit: 'hours',
      );
    }

    if (step.seconds % 60 == 0) {
      return _StepDraft(
        instruction: step.instruction,
        time: '${step.seconds ~/ 60}',
        timeUnit: 'minutes',
      );
    }

    return _StepDraft(
      instruction: step.instruction,
      time: '${step.seconds}',
      timeUnit: 'seconds',
    );
  }

  int _secondsForStepDraft(_StepDraft row) {
    if (row.timeUnit == 'No timer') return 0;

    final amount =
        int.tryParse(row.timeController.text.trim()) ?? 0;
    if (amount <= 0) return 0;

    switch (row.timeUnit) {
      case 'hours':
        return amount * 3600;
      case 'minutes':
        return amount * 60;
      case 'seconds':
      default:
        return amount;
    }
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


const List<String> _recipeUnits = [
  'g',
  'kg',
  'ml',
  'L',
  'tsp',
  'tbsp',
  'cup',
  'each',
  'piece',
  'clove',
  'slice',
  'can',
  'pack',
];

const List<String> _recipeTimeUnits = [
  'No timer',
  'seconds',
  'minutes',
  'hours',
];

class _IngredientDraft {
  _IngredientDraft({
    String name = '',
    String quantity = '1',
    this.unit = 'each',
  })  : nameController = TextEditingController(text: name),
        quantityController =
            TextEditingController(text: quantity);

  final TextEditingController nameController;
  final TextEditingController quantityController;
  String unit;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}

class _StepDraft {
  _StepDraft({
    String instruction = '',
    String time = '',
    this.timeUnit = 'No timer',
  })  : instructionController =
            TextEditingController(text: instruction),
        timeController = TextEditingController(text: time);

  final TextEditingController instructionController;
  final TextEditingController timeController;
  String timeUnit;

  void dispose() {
    instructionController.dispose();
    timeController.dispose();
  }
}

class _RecipeBuilderSectionTitle extends StatelessWidget {
  const _RecipeBuilderSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.recipes.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.recipes,
            size: 20,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.isCustom,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    required this.selectedForCooking,
    required this.selectionMode,
    required this.onToggleCooking,
  });

  final Recipe recipe;
  final bool selectedForCooking;
  final bool selectionMode;
  final VoidCallback onToggleCooking;
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
        onTap: selectionMode
            ? onToggleCooking
            : () => _openDetails(context),
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
              if (selectionMode)
                IconButton(
                  tooltip: selectedForCooking
                      ? 'Remove from Cook Together'
                      : 'Select for Cook Together',
                  onPressed: onToggleCooking,
                  icon: Icon(
                    selectedForCooking
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selectedForCooking
                        ? AppColors.cooking
                        : AppColors.muted,
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
