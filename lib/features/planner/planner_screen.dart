import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/monthly_meal_plan.dart';
import '../../models/recipe.dart';
import '../cooking/cooking_assistant_screen.dart';
import '../cooking/cooking_feedback_screen.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final month = state.selectedPlannerDate;
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final entries = state.monthlyMealsFor(month);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly meal plan',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _monthLabel(month),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Previous month',
                      onPressed: () => state.changePlannerMonth(
                        DateTime(month.year, month.month - 1),
                      ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: 'Next month',
                      onPressed: () => state.changePlannerMonth(
                        DateTime(month.year, month.month + 1),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _PlanSummary(
                  people: state.householdPeople,
                  daysInMonth: daysInMonth,
                  plannedEntries: state.monthlyMealPlan.entries.length,
                  weeklyPeriods: state.weeklyShoppingPeriods.length,
                  onGenerate: state.generateMonthlyFoundation,
                ),
                if (state.lastMealGenerationSummary.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.psychology_alt_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text('Why this plan?'),
                      subtitle: Text(
                        state.lastMealGenerationSummary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _CalendarGrid(
                  month: month,
                  selectedDate: state.selectedPlannerDate,
                  entriesFor: state.monthlyMealsFor,
                  onSelected: state.selectPlannerDate,
                ),
                const SizedBox(height: 20),
                _DayHeader(
                  date: state.selectedPlannerDate,
                  onClear: () =>
                      state.clearMonthlyDay(state.selectedPlannerDate),
                  onRegenerate: () =>
                      state.regenerateMonthlyDay(
                    state.selectedPlannerDate,
                  ),
                ),
                const SizedBox(height: 10),
                if (entries.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No meals planned for this day yet.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  ...entries.map(
                    (entry) => _MealEntryCard(entry: entry),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _showAddMeal(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add meal or snack'),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Weekly shopping periods',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(5, (index) {
                  final week = index + 1;
                  final count =
                      state.weeklyShoppingPeriods[week]?.length ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('$week'),
                      ),
                      title: Text('Week $week'),
                      subtitle: Text(
                        '$count planned meal${count == 1 ? '' : 's'}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Regenerate Week $week',
                        onPressed: () =>
                            state.regenerateMonthlyWeek(week),
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMeal(BuildContext context) async {
    final state = AppScope.of(context);
    MealSlotType slot = state.activeMealSlots.isEmpty
        ? MealSlotType.dinner
        : state.activeMealSlots.first;
    final simpleController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                18,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to ${_shortDate(state.selectedPlannerDate)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<MealSlotType>(
                      initialValue: slot,
                      decoration: const InputDecoration(
                        labelText: 'Meal slot',
                      ),
                      items: state.activeMealSlots
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => slot = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Simple food',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: simpleController,
                      decoration: const InputDecoration(
                        hintText: 'Fruit, yogurt, toast, leftovers...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await state.addSimpleMonthlyMeal(
                            date: state.selectedPlannerDate,
                            slot: slot,
                            name: simpleController.text,
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        icon: const Icon(Icons.apple_outlined),
                        label: const Text('Add simple food'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Or choose a recipe',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...state.recipes.take(12).map(
                      (recipe) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(recipe.name),
                        subtitle: Text(
                          '${recipe.category} · ${recipe.totalMinutes} min',
                        ),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () async {
                          await state.addRecipeMonthlyMeal(
                            date: state.selectedPlannerDate,
                            slot: slot,
                            recipe: recipe,
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    simpleController.dispose();
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({
    required this.people,
    required this.daysInMonth,
    required this.plannedEntries,
    required this.weeklyPeriods,
    required this.onGenerate,
  });

  final int people;
  final int daysInMonth;
  final int plannedEntries;
  final int weeklyPeriods;
  final Future<void> Function() onGenerate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$daysInMonth days · $people people',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '$plannedEntries planned',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  plannedEntries == 0
                      ? 'Create personalized monthly plan'
                      : 'Regenerate all unlocked meals',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.entriesFor,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final List<MonthlyMealEntry> Function(DateTime) entriesFor;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = leading + days;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Row(
              children: [
                _Weekday('M'),
                _Weekday('T'),
                _Weekday('W'),
                _Weekday('T'),
                _Weekday('F'),
                _Weekday('S'),
                _Weekday('S'),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: .82,
              ),
              itemCount: cells,
              itemBuilder: (context, index) {
                if (index < leading) return const SizedBox.shrink();

                final day = index - leading + 1;
                final date = DateTime(month.year, month.month, day);
                final selected =
                    dateKeyFor(date) == dateKeyFor(selectedDate);
                final count = entriesFor(date).length;

                return InkWell(
                  onTap: () => onSelected(date),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: .16)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: AppColors.primary)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (count > 0)
                          Text(
                            '$count',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.onClear,
    required this.onRegenerate,
  });

  final DateTime date;
  final VoidCallback onClear;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _fullDate(date),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Regenerate this day',
          onPressed: onRegenerate,
          icon: const Icon(Icons.refresh),
        ),
        TextButton(
          onPressed: onClear,
          child: const Text('Clear unlocked'),
        ),
      ],
    );
  }
}

class _MealEntryCard extends StatelessWidget {
  const _MealEntryCard({required this.entry});

  final MonthlyMealEntry entry;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(
          entry.simpleFood
              ? Icons.apple_outlined
              : Icons.restaurant_menu,
          color: AppColors.primary,
        ),
        title: Text(
          entry.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${entry.slot.label} · ${entry.servings} '
          'serving${entry.servings == 1 ? '' : 's'}'
          '${entry.suggestionReason.isEmpty ? '' : '\n${entry.suggestionReason}'}',
        ),
        isThreeLine: entry.suggestionReason.isNotEmpty,
        trailing: PopupMenuButton<String>(
          tooltip: 'Meal actions',
          onSelected: (value) async {
            if (value == 'cook') {
              await _openMealForCooking(context, entry);
            } else if (value == 'regenerate') {
              await state.regenerateMonthlyMeal(entry);
            } else if (value == 'lock') {
              await state.toggleMonthlyMealLock(entry.id);
            } else if (value == 'remove') {
              await state.removeMonthlyMeal(entry.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'cook',
              child: Row(
                children: [
                  Icon(
                    entry.recipeId == null
                        ? Icons.restaurant_outlined
                        : Icons.soup_kitchen_outlined,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.recipeId == null
                        ? 'View meal'
                        : 'Start cooking',
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'regenerate',
              enabled: !entry.locked,
              child: const Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 10),
                  Text('Regenerate meal'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'lock',
              child: Row(
                children: [
                  Icon(
                    entry.locked
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                  ),
                  const SizedBox(width: 10),
                  Text(entry.locked ? 'Unlock meal' : 'Lock meal'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 10),
                  Text('Remove meal'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _openMealForCooking(context, entry),
      ),
    );
  }
}


Future<void> _openMealForCooking(
  BuildContext context,
  MonthlyMealEntry entry,
) async {
  final state = AppScope.of(context);

  if (entry.recipeId == null) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(entry.name),
        content: Text(
          '${entry.slot.label} · ${entry.servings} serving'
          '${entry.servings == 1 ? '' : 's'}\n\n'
          'This simple meal does not need guided recipe steps.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    return;
  }

  Recipe? recipe;
  for (final candidate in state.recipes) {
    if (candidate.id == entry.recipeId) {
      recipe = candidate;
      break;
    }
  }

  if (recipe == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The recipe for ${entry.name} could not be found.',
        ),
      ),
    );
    return;
  }

  final completed = await openCookingAssistant(
    context,
    recipe,
    servings: entry.servings,
  );

  if (completed == true && context.mounted) {
    await openCookingFeedback(context, recipe);
  }
}


String _monthLabel(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

String _shortDate(DateTime value) {
  return '${value.day}/${value.month}/${value.year}';
}

String _fullDate(DateTime value) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return '${weekdays[value.weekday - 1]}, ${value.day}/${value.month}';
}
