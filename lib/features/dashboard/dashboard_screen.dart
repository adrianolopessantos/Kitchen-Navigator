import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_card.dart';
import '../../core/widgets/knife_compass_logo.dart';
import '../../models/nutrition.dart';
import '../../models/pantry_item.dart';
import '../../core/services/product_lookup_service.dart';
import '../barcode/barcode_scanner_screen.dart';
import '../budget/budget_screen.dart';
import '../cooking/cooking_assistant_screen.dart';
import '../expiry/expiry_screen.dart';
import '../intelligence/ai_kitchen_screen.dart';
import '../inventory/inventory_intelligence_screen.dart';
import '../kitchens/kitchens_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notification_center_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.openPlanner,
    required this.openPantry,
    required this.openShopping,
  });

  final VoidCallback openPlanner;
  final VoidCallback openPantry;
  final VoidCallback openShopping;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final monthlyMeals = state.todaysMonthlyMeals;
    final mealText = monthlyMeals.isEmpty
        ? 'Nothing planned yet'
        : monthlyMeals.map((meal) => meal.name).join(' + ');
    final cookingMinutes = monthlyMeals.fold<int>(
      0,
      (total, meal) {
        if (meal.recipeId == null) return total;
        for (final recipe in state.recipes) {
          if (recipe.id == meal.recipeId) {
            return total + recipe.totalMinutes;
          }
        }
        return total;
      },
    );
    final weeklyShopping = state.selectedWeeklyShoppingItems;
    final shoppingRemaining = weeklyShopping
        .where((item) => !state.isShoppingChecked(item.key))
        .length;
    final weeklyShoppingEstimate = state
        .estimatedShoppingTotalForWeek(state.selectedShoppingWeek);
    final monthlyShoppingEstimate =
        state.estimatedMonthlyPlanShoppingTotal;
    final weeklyBudget = state.weeklyShoppingBudget;
    final monthlyBudget = state.householdProfile.monthlyBudget;
    final health = _overallHealth(state);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              112,
            ),
            sliver: SliverList.list(
              children: [
                _Header(
                  kitchenName: state.activeKitchen.name,
                  kitchenCount: state.kitchenProfiles.length,
                  onKitchenTap: () => openKitchens(context),
                  onSettingsTap: () => openSettings(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(
                  title: 'Today',
                  subtitle: 'Your most important kitchen actions',
                ),
                const SizedBox(height: AppSpacing.sm),
                _TodayMealCard(
                  day: state.todayName,
                  mealText: mealText,
                  people: state.householdPeople,
                  ingredients: monthlyMeals.length,
                  cookingMinutes: cookingMinutes,
                  hasMeal: monthlyMeals.isNotEmpty,
                  onPlan: openPlanner,
                  onCook: openPlanner,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(
                  title: 'Quick actions',
                  subtitle: 'The things you use most often',
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.08,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  children: [
                    DashboardCard(
                      icon: Icons.kitchen_outlined,
                      label: 'Pantry',
                      value: '${state.pantryCount} products',
                      note: state.expiringSoonCount > 0
                          ? '${state.expiringSoonCount} expiring soon'
                          : 'Everything looks fresh',
                      onTap: openPantry,
                    ),
                    DashboardCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Shopping',
                      value: '$shoppingRemaining to buy',
                      note:
                          'Week ${state.selectedShoppingWeek} · €${weeklyShoppingEstimate.toStringAsFixed(2)} estimated',
                      accentColor: AppColors.terracotta,
                      onTap: openShopping,
                    ),
                    DashboardCard(
                      icon: Icons.menu_book_outlined,
                      label: 'Planner',
                      value: '${monthlyMeals.length} meal${monthlyMeals.length == 1 ? '' : 's'} today',
                      note: '${state.householdPeople} people',
                      onTap: openPlanner,
                    ),
                    DashboardCard(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan',
                      value: 'Product barcode',
                      note: 'Purchase, pantry or shopping',
                      accentColor: AppColors.warning,
                      onTap: () => _scanFromDashboard(
                        context,
                        openShopping: openShopping,
                        openPantry: openPantry,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(
                  title: 'Kitchen overview',
                  subtitle: 'Health, nutrition and spending',
                ),
                const SizedBox(height: AppSpacing.sm),
                DashboardCard(
                  icon: Icons.insights_outlined,
                  label: 'Inventory intelligence',
                  value: '${state.pantryHealthScore}% pantry health',
                  note:
                      '${state.lowStockItems.length} low stock · €${state.estimatedPantryValue.toStringAsFixed(0)} stored',
                  wide: true,
                  onTap: () => openInventoryIntelligence(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                DashboardCard(
                  icon: Icons.favorite_outline,
                  label: 'Nutrition',
                  value: state.hasTodaysNutrition
                      ? '${state.todaysNutrition.calories.round()} kcal household'
                      : 'Nutrition analysis pending',
                  note: state.hasTodaysNutrition
                      ? '${state.todaysNutrition.protein.round()} g protein · Estimated'
                      : 'Plan today’s meals to calculate estimates',
                  wide: true,
                  accentColor: AppColors.terracotta,
                  onTap: () => openNutritionCenter(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                DashboardCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget',
                  value:
                      '€${weeklyShoppingEstimate.toStringAsFixed(2)} / €${weeklyBudget.toStringAsFixed(2)} this week',
                  note:
                      '€${monthlyShoppingEstimate.toStringAsFixed(2)} / €${monthlyBudget.toStringAsFixed(2)} monthly estimate',
                  wide: true,
                  accentColor: AppColors.warning,
                  onTap: () => openBudgetCenter(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                DashboardCard(
                  icon: Icons.event_busy_outlined,
                  label: 'Use soon',
                  value:
                      '${state.useSoonItems.length} product${state.useSoonItems.length == 1 ? '' : 's'}',
                  note: state.useSoonItems.isEmpty
                      ? 'No urgent expiry alerts'
                      : '${state.expiresTodayItems.length} need attention today',
                  wide: true,
                  accentColor: state.useSoonItems.isEmpty
                      ? AppColors.primary
                      : AppColors.warning,
                  onTap: () => openExpiryIntelligence(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
Future<void> _scanFromDashboard(
  BuildContext context, {
  required VoidCallback openShopping,
  required VoidCallback openPantry,
}) async {
  final state = AppScope.of(context);
  final barcode = await openBarcodeScanner(context);
  if (!context.mounted ||
      barcode == null ||
      barcode.trim().isEmpty) {
    return;
  }

  final product =
      await ProductLookupService.findByBarcode(barcode) ??
          ProductLookupService.createFallback(barcode);

  if (!context.mounted) return;

  ShoppingItem? shoppingMatch;
  final productKey = _dashboardNormalize(product.name);

  for (final item in state.activeShoppingItems) {
    final itemKey = _dashboardNormalize(item.name);
    if (itemKey == productKey ||
        itemKey.contains(productKey) ||
        productKey.contains(itemKey)) {
      shoppingMatch = item;
      break;
    }
  }

  PantryItem? pantryMatch;
  for (final item in state.pantryItems) {
    final itemKey = _dashboardNormalize(item.name);
    if (itemKey == productKey ||
        itemKey.contains(productKey) ||
        productKey.contains(itemKey)) {
      pantryMatch = item;
      break;
    }
  }

  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              shoppingMatch != null
                  ? 'Found on the shopping list.'
                  : pantryMatch != null
                      ? 'This product is already in Pantry.'
                      : 'Choose what to do with this product.',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            if (shoppingMatch != null)
              ListTile(
                leading: const Icon(
                  Icons.shopping_cart_checkout,
                  color: AppColors.primary,
                ),
                title: const Text('Mark purchased'),
                subtitle:
                    const Text('Add the shopping quantity to Pantry'),
                onTap: () =>
                    Navigator.pop(sheetContext, 'purchase'),
              ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(
                pantryMatch == null
                    ? 'Add to Pantry'
                    : 'Increase Pantry quantity',
              ),
              onTap: () => Navigator.pop(sheetContext, 'pantry'),
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Add to Shopping'),
              onTap: () => Navigator.pop(sheetContext, 'shopping'),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    ),
  );

  if (action == null || !context.mounted) return;

  if (action == 'purchase' && shoppingMatch != null) {
    await state.setShoppingPurchased(shoppingMatch, true);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} purchased and added to Pantry.',
        ),
      ),
    );
    return;
  }

  if (action == 'pantry') {
    state.addPantryItem(
      name: product.name,
      quantity: product.defaultQuantity,
      unit: product.defaultUnit,
      location: product.location,
      expiryDate: DateTime.now().add(
        Duration(days: product.suggestedShelfLifeDays),
      ),
      barcode: product.barcode,
    );
    openPantry();
    return;
  }

  if (action == 'shopping') {
    await state.addManualShoppingItem(
      name: product.name,
      quantity: product.defaultQuantity,
      unit: product.defaultUnit,
      category: 'Other',
      week: state.selectedShoppingWeek,
    );
    openShopping();
  }
}

String _dashboardNormalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}

int _overallHealth(AppState state) {
    final shoppingPenalty = state.selectedWeeklyShoppingItems
            .where((item) => !state.isShoppingChecked(item.key))
            .length
            .clamp(0, 10) *
        2;
    final expiryPenalty =
        state.expiredCount.clamp(0, 5) * 7;
    return (state.pantryHealthScore -
            shoppingPenalty -
            expiryPenalty)
        .clamp(0, 100);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.kitchenName,
    required this.kitchenCount,
    required this.onKitchenTap,
    required this.onSettingsTap,
  });

  final String kitchenName;
  final int kitchenCount;
  final VoidCallback onKitchenTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const KnifeCompassLogo(size: 52),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kitchen Navigator',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 3),
              InkWell(
                onTap: onKitchenTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          kitchenName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '· $kitchenCount',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const Icon(
                        Icons.expand_more,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onSettingsTap,
          tooltip: 'Settings',
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _TodayMealCard extends StatelessWidget {
  const _TodayMealCard({
    required this.day,
    required this.mealText,
    required this.people,
    required this.ingredients,
    required this.cookingMinutes,
    required this.hasMeal,
    required this.onPlan,
    required this.onCook,
  });

  final String day;
  final String mealText;
  final int people;
  final int ingredients;
  final int cookingMinutes;
  final bool hasMeal;
  final VoidCallback onPlan;
  final VoidCallback onCook;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day.toUpperCase(),
              style: const TextStyle(
                color: AppColors.terracotta,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .9,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              mealText,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 23,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _MealMeta(
                  icon: Icons.people_outline,
                  value: '$people',
                  label: 'People',
                ),
                _MealMeta(
                  icon: Icons.list_alt_outlined,
                  value: '$ingredients',
                  label: 'Ingredients',
                ),
                _MealMeta(
                  icon: Icons.schedule_outlined,
                  value: '$cookingMinutes',
                  label: 'Minutes',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPlan,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(hasMeal ? 'Edit plan' : 'Plan meal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onCook,
                    icon: Icon(
                      hasMeal ? Icons.play_arrow : Icons.add,
                    ),
                    label: Text(
                      hasMeal ? 'Start cooking' : 'Add meal',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MealMeta extends StatelessWidget {
  const _MealMeta({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


class _IntegrationOverview extends StatelessWidget {
  const _IntegrationOverview({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final meals = state.todaysMonthlyMeals;
    final progress = state.selectedShoppingWeekProgress;
    final rating = state.familyAverageMealRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Version 11 overview',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _OverviewTile(
              icon: Icons.calendar_month_outlined,
              label: 'Today’s plan',
              value: '${meals.length} meals',
              detail:
                  '${state.todaysGuidedRecipeCount} guided recipes',
            ),
            _OverviewTile(
              icon: Icons.inventory_2_outlined,
              label: 'Pantry risks',
              value: '${state.wasteRiskItems.length}',
              detail:
                  '${state.restockSuggestedItems.length} restock suggestions',
            ),
            _OverviewTile(
              icon: Icons.shopping_cart_outlined,
              label: 'Shopping',
              value: '${(progress * 100).round()}%',
              detail:
                  'Week ${state.selectedShoppingWeek} complete',
            ),
            _OverviewTile(
              icon: Icons.star_outline,
              label: 'Family rating',
              value: rating == 0
                  ? '—'
                  : rating.toStringAsFixed(1),
              detail: '${state.cookingFeedback.length} meals reviewed',
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    detail,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
