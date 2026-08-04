import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/nutrition.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final totals = state.todayNutrition;
    final targets = state.nutritionTargets;
    final weekly = state.weeklyNutrition;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Center')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            const Text(
              'Today’s nutrition',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${state.todayName} · ${_nutritionGoalLabel(state.nutritionGoal)}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<NutritionGoal>(
              initialValue: state.nutritionGoal,
              decoration: const InputDecoration(
                labelText: 'Nutrition goal',
              ),
              items: NutritionGoal.values.map((goal) {
                return DropdownMenuItem(
                  value: goal,
                  child: Text(_nutritionGoalLabel(goal)),
                );
              }).toList(),
              onChanged: (goal) {
                if (goal != null) state.setNutritionGoal(goal);
              },
            ),
            const SizedBox(height: 16),
            _NutritionProgressCard(
              label: 'Calories',
              value: totals.calories,
              target: targets.calories,
              unit: 'kcal',
              icon: Icons.local_fire_department_outlined,
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.25,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _NutrientTile(
                  label: 'Protein',
                  value: totals.protein,
                  target: targets.protein,
                  unit: 'g',
                ),
                _NutrientTile(
                  label: 'Carbohydrates',
                  value: totals.carbohydrates,
                  target: targets.carbohydrates,
                  unit: 'g',
                ),
                _NutrientTile(
                  label: 'Fat',
                  value: totals.fat,
                  target: targets.fat,
                  unit: 'g',
                ),
                _NutrientTile(
                  label: 'Fibre',
                  value: totals.fibre,
                  target: targets.fibre,
                  unit: 'g',
                ),
                _NutrientTile(
                  label: 'Sugar',
                  value: totals.sugar,
                  target: targets.sugar,
                  unit: 'g',
                  lowerIsBetter: true,
                ),
                _NutrientTile(
                  label: 'Salt',
                  value: totals.salt,
                  target: targets.salt,
                  unit: 'g',
                  lowerIsBetter: true,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'DAILY GUIDANCE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 9),
            ...state.nutritionAdvice.map(
              (message) => Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: ListTile(
                  leading: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    message,
                    style: const TextStyle(color: AppColors.text),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'WEEKLY OVERVIEW',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 9),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _WeeklyRow(
                      label: 'Average calories',
                      value:
                          '${(weekly.calories / 7).round()} kcal/day',
                    ),
                    _WeeklyRow(
                      label: 'Average protein',
                      value:
                          '${(weekly.protein / 7).round()} g/day',
                    ),
                    _WeeklyRow(
                      label: 'Average fibre',
                      value:
                          '${(weekly.fibre / 7).round()} g/day',
                    ),
                    _WeeklyRow(
                      label: 'Meals planned',
                      value:
                          '${AppState.days.fold<int>(0, (total, day) => total + state.mealsFor(day).length)}',
                      last: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nutrition values are prototype estimates based on recipe ingredients. They are not medical advice.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionProgressCard extends StatelessWidget {
  const _NutritionProgressCard({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.icon,
  });

  final String label;
  final double value;
  final double target;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0
        ? 0.0
        : (value / target).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${value.round()} / ${target.round()} $unit',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  const _NutrientTile({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    this.lowerIsBetter = false,
  });

  final String label;
  final double value;
  final double target;
  final String unit;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final over = value > target;
    final statusColor = lowerIsBetter && over
        ? AppColors.warning
        : AppColors.primary;

    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${value.round()} $unit',
            style: TextStyle(
              color: statusColor,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target ${target.round()} $unit',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRow extends StatelessWidget {
  const _WeeklyRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }
}

Future<void> openNutritionCenter(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const NutritionScreen()),
  );
}

String _nutritionGoalLabel(NutritionGoal goal) {
  switch (goal) {
    case NutritionGoal.balanced:
      return 'Balanced';
    case NutritionGoal.loseWeight:
      return 'Lose weight';
    case NutritionGoal.maintainWeight:
      return 'Maintain weight';
    case NutritionGoal.gainMuscle:
      return 'Gain muscle';
    case NutritionGoal.highProtein:
      return 'High protein';
    case NutritionGoal.vegetarian:
      return 'Vegetarian';
    case NutritionGoal.mediterranean:
      return 'Mediterranean';
    case NutritionGoal.lowCarb:
      return 'Low carb';
  }
}
