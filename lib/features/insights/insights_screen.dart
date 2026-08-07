import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final week = state.selectedShoppingWeek;
    final shoppingTotal = state.estimatedShoppingTotalForWeek(week);
    final budget = state.weeklyShoppingBudget;
    final budgetRemaining = budget - shoppingTotal;
    final shoppingItems = state.selectedWeeklyShoppingItems;
    final shoppingRemaining = shoppingItems
        .where((item) => !state.isShoppingChecked(item.key))
        .length;

    final pantryHealth = state.pantryHealthScore;
    final wasteRisk = state.wasteRiskItems.length;
    final useSoon = state.useSoonItems.length;
    final lowStock = state.lowStockItems.length;
    final estimatedWaste = state.estimatedWasteValue;

    final nutrition = state.todayNutrition;
    final weeklyNutrition = state.weeklyNutrition;

    final budgetProgress =
        budget <= 0 ? 0.0 : (shoppingTotal / budget).clamp(0.0, 1.0);
    final pantryProgress = (pantryHealth / 100).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            32,
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.insights_outlined,
                    color: AppColors.info,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kitchen insights',
                        style:
                            Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Spend, stock, nutrition and attention.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 3,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _InsightCard(
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.budget,
              title: 'Budget',
              value: budgetRemaining >= 0
                  ? '€${budgetRemaining.toStringAsFixed(2)} remaining'
                  : '€${(-budgetRemaining).toStringAsFixed(2)} over',
              subtitle:
                  '€${shoppingTotal.toStringAsFixed(2)} estimated of €${budget.toStringAsFixed(2)} · Week $week',
              progress: budgetProgress,
              footer: budgetRemaining >= 0
                  ? 'Shopping plan is within the weekly target.'
                  : 'Consider substitutions or moving optional items.',
            ),
            const SizedBox(height: AppSpacing.sm),

            _InsightCard(
              icon: Icons.inventory_2_outlined,
              color: AppColors.pantry,
              title: 'Pantry',
              value: '$pantryHealth% health',
              subtitle:
                  '$useSoon use soon · $lowStock low stock · $wasteRisk waste risk',
              progress: pantryProgress,
              footer: estimatedWaste <= 0
                  ? 'No meaningful waste value detected.'
                  : 'Potential waste value: €${estimatedWaste.toStringAsFixed(2)}',
            ),
            const SizedBox(height: AppSpacing.sm),

            _InsightCard(
              icon: Icons.shopping_cart_outlined,
              color: AppColors.shopping,
              title: 'Shopping',
              value: '$shoppingRemaining remaining',
              subtitle:
                  '${shoppingItems.length} items in the selected week',
              progress: shoppingItems.isEmpty
                  ? 0
                  : ((shoppingItems.length - shoppingRemaining) /
                          shoppingItems.length)
                      .clamp(0.0, 1.0),
              footer: shoppingRemaining == 0
                  ? 'Everything on this list is purchased.'
                  : 'Complete the list to keep Pantry synchronized.',
            ),
            const SizedBox(height: AppSpacing.sm),

            _NutritionCard(
              calories: nutrition.calories,
              protein: nutrition.protein,
              carbs: nutrition.carbohydrates,
              fat: nutrition.fat,
              weeklyCalories: weeklyNutrition.calories,
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Needs attention',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            _AttentionRow(
              icon: Icons.event_busy_outlined,
              color: AppColors.warning,
              title: 'Use soon',
              value: '$useSoon product${useSoon == 1 ? '' : 's'}',
              message: useSoon == 0
                  ? 'Nothing urgent.'
                  : 'Prioritize these products in upcoming meals.',
            ),
            const SizedBox(height: AppSpacing.xs),
            _AttentionRow(
              icon: Icons.add_shopping_cart_outlined,
              color: AppColors.shopping,
              title: 'Restock',
              value: '$lowStock product${lowStock == 1 ? '' : 's'}',
              message: lowStock == 0
                  ? 'Stock levels look comfortable.'
                  : 'Add essentials before they run out.',
            ),
            const SizedBox(height: AppSpacing.xs),
            _AttentionRow(
              icon: Icons.delete_outline,
              color: AppColors.danger,
              title: 'Waste risk',
              value: '$wasteRisk product${wasteRisk == 1 ? '' : 's'}',
              message: wasteRisk == 0
                  ? 'No significant waste risk.'
                  : 'Use or freeze these products first.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.footer,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                color: color,
                backgroundColor: color.withValues(alpha: .10),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              footer,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.weeklyCalories,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double weeklyCalories;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.eco_outlined,
                  color: AppColors.nutrition,
                ),
                SizedBox(width: 8),
                Text(
                  'Nutrition',
                  style: TextStyle(
                    color: AppColors.nutrition,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${calories.round()} kcal today',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Macro(
                    label: 'Protein',
                    value: '${protein.round()} g',
                  ),
                ),
                Expanded(
                  child: _Macro(
                    label: 'Carbs',
                    value: '${carbs.round()} g',
                  ),
                ),
                Expanded(
                  child: _Macro(
                    label: 'Fat',
                    value: '${fat.round()} g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${weeklyCalories.round()} kcal estimated across the current week.',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openInsights(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const InsightsScreen(),
    ),
  );
}
