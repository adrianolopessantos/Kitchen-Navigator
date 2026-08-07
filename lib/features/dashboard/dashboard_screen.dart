import 'package:flutter/material.dart';
import '../../core/services/product_lookup_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';
import '../barcode/barcode_scanner_screen.dart';
import '../budget/budget_screen.dart';
import '../expiry/expiry_screen.dart';
import '../inventory/inventory_intelligence_screen.dart';
import '../insights/insights_screen.dart';
import '../kitchens/kitchens_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../settings/settings_screen.dart';

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
    final now = DateTime.now();
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
    final shoppingEstimate = state.estimatedShoppingTotalForWeek(
      state.selectedShoppingWeek,
    );
    final weeklyBudget = state.weeklyShoppingBudget;
    final budgetRemaining = weeklyBudget - shoppingEstimate;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              116,
            ),
            sliver: SliverList.list(
              children: [
                _PremiumHeader(
                  greeting: _greeting(now.hour),
                  date: _friendlyDate(now),
                  kitchenName: state.activeKitchen.name,
                  kitchenCount: state.kitchenProfiles.length,
                  onKitchenTap: () => openKitchens(context),
                  onSettingsTap: () => openSettings(context),
                ),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(
                  icon: Icons.explore_outlined,
                  color: AppColors.today,
                  title: 'Today',
                  subtitle: 'Your next kitchen priority',
                ),
                const SizedBox(height: AppSpacing.sm),
                _TodayFocusCard(
                  day: state.todayName,
                  mealText: mealText,
                  people: state.householdPeople,
                  cookingMinutes: cookingMinutes,
                  hasMeal: monthlyMeals.isNotEmpty,
                  onOpenPlan: openPlanner,
                ),

                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(
                  icon: Icons.bolt_rounded,
                  color: AppColors.bamboo,
                  title: 'Quick actions',
                  subtitle: 'One tap to the things you use most',
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: AppSpacing.xs,
                  mainAxisSpacing: AppSpacing.xs,
                  childAspectRatio: .82,
                  children: [
                    _QuickAction(
                      icon: Icons.calendar_month_outlined,
                      label: 'Plan',
                      color: AppColors.planner,
                      onTap: openPlanner,
                    ),
                    _QuickAction(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Shop',
                      color: AppColors.shopping,
                      onTap: openShopping,
                    ),
                    _QuickAction(
                      icon: Icons.inventory_2_outlined,
                      label: 'Pantry',
                      color: AppColors.pantry,
                      onTap: openPantry,
                    ),
                    _QuickAction(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan',
                      color: AppColors.today,
                      onTap: () => _scanFromDashboard(
                        context,
                        openShopping: openShopping,
                        openPantry: openPantry,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(
                  icon: Icons.dashboard_customize_outlined,
                  color: AppColors.primary,
                  title: 'Kitchen overview',
                  subtitle: 'A quick read on your household',
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.10,
                  children: [
                    _OverviewCard(
                      icon: Icons.shopping_cart_outlined,
                      color: AppColors.shopping,
                      title: 'Shopping',
                      value: '$shoppingRemaining remaining',
                      detail:
                          '€${shoppingEstimate.toStringAsFixed(2)} estimated',
                      status: 'Week ${state.selectedShoppingWeek}',
                      onTap: openShopping,
                    ),
                    _OverviewCard(
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.pantry,
                      title: 'Pantry',
                      value: '${state.pantryCount} products',
                      detail: state.expiringSoonCount == 0
                          ? 'Everything looks fresh'
                          : '${state.expiringSoonCount} expiring soon',
                      status: '${state.pantryHealthScore}% health',
                      onTap: openPantry,
                    ),
                    _OverviewCard(
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.budget,
                      title: 'Budget',
                      value: budgetRemaining >= 0
                          ? '€${budgetRemaining.toStringAsFixed(0)} available'
                          : '€${(-budgetRemaining).toStringAsFixed(0)} over',
                      detail:
                          '€${shoppingEstimate.toStringAsFixed(2)} / €${weeklyBudget.toStringAsFixed(2)}',
                      status: 'This week',
                      onTap: () => openBudgetCenter(context),
                    ),
                    _OverviewCard(
                      icon: Icons.eco_outlined,
                      color: AppColors.nutrition,
                      title: 'Nutrition',
                      value: state.hasTodaysNutrition
                          ? '${state.todaysNutrition.calories.round()} kcal'
                          : 'Analysis pending',
                      detail: state.hasTodaysNutrition
                          ? '${state.todaysNutrition.protein.round()} g protein'
                          : 'Plan meals to calculate',
                      status: 'Estimated',
                      onTap: () => openNutritionCenter(context),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                Card(
                  color: AppColors.info.withValues(alpha: .035),
                  child: InkWell(
                    onTap: () => openInsights(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            color: AppColors.info,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Insights',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Budget, pantry, shopping and nutrition in one place',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.info,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _AttentionStrip(
                  pantryHealth: state.pantryHealthScore,
                  lowStock: state.lowStockItems.length,
                  useSoon: state.useSoonItems.length,
                  onTap: () => openInventoryIntelligence(context),
                  onExpiryTap: () => openExpiryIntelligence(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({
    required this.greeting,
    required this.date,
    required this.kitchenName,
    required this.kitchenCount,
    required this.onKitchenTap,
    required this.onSettingsTap,
  });

  final String greeting;
  final String date;
  final String kitchenName;
  final int kitchenCount;
  final VoidCallback onKitchenTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 62,
          height: 62,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/kitchen_navigator_icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kitchen Navigator',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: onKitchenTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        kitchenName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      ' · $kitchenCount',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const Icon(
                      Icons.expand_more,
                      size: 15,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Settings',
          onPressed: onSettingsTap,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayFocusCard extends StatelessWidget {
  const _TodayFocusCard({
    required this.day,
    required this.mealText,
    required this.people,
    required this.cookingMinutes,
    required this.hasMeal,
    required this.onOpenPlan,
  });

  final String day;
  final String mealText;
  final int people;
  final int cookingMinutes;
  final bool hasMeal;
  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryStrong,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2416452C),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  day.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.restaurant_menu_rounded,
                color: Color(0xFFE8C37D),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasMeal ? mealText : 'Ready when you are',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            hasMeal
                ? '$people people · $cookingMinutes min planned'
                : 'Plan today’s meals and let Kitchen Navigator guide the rest.',
            style: const TextStyle(
              color: Color(0xFFD9E6DE),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryStrong,
              ),
              onPressed: onOpenPlan,
              icon: Icon(
                hasMeal
                    ? Icons.arrow_forward_rounded
                    : Icons.add_rounded,
              ),
              label: Text(
                hasMeal ? 'Open today’s plan' : 'Plan today',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.detail,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String detail;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 21),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: color.withValues(alpha: .8),
                    size: 18,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.subtle,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttentionStrip extends StatelessWidget {
  const _AttentionStrip({
    required this.pantryHealth,
    required this.lowStock,
    required this.useSoon,
    required this.onTap,
    required this.onExpiryTap,
  });

  final int pantryHealth;
  final int lowStock;
  final int useSoon;
  final VoidCallback onTap;
  final VoidCallback onExpiryTap;

  @override
  Widget build(BuildContext context) {
    if (lowStock == 0 && useSoon == 0) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pantry.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.pantry.withValues(alpha: .18),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.pantry,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pantry looks healthy · $pantryHealth%',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _AttentionChip(
            icon: Icons.inventory_outlined,
            label: '$lowStock low stock',
            color: AppColors.shopping,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _AttentionChip(
            icon: Icons.event_busy_outlined,
            label: '$useSoon use soon',
            color: AppColors.notifications,
            onTap: onExpiryTap,
          ),
        ),
      ],
    );
  }
}

class _AttentionChip extends StatelessWidget {
  const _AttentionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: color.withValues(alpha: .18),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
            if (product.brand.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                product.brand,
                style: const TextStyle(
                  color: AppColors.shopping,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
                  color: AppColors.shopping,
                ),
                title: const Text('Mark purchased'),
                subtitle:
                    const Text('Add the shopping quantity to Pantry'),
                onTap: () =>
                    Navigator.pop(sheetContext, 'purchase'),
              ),
            ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.pantry,
              ),
              title: Text(
                pantryMatch == null
                    ? 'Add to Pantry'
                    : 'Increase Pantry quantity',
              ),
              onTap: () => Navigator.pop(sheetContext, 'pantry'),
            ),
            ListTile(
              leading: const Icon(
                Icons.add_shopping_cart,
                color: AppColors.shopping,
              ),
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
    if (product.brand.trim().isNotEmpty &&
        shoppingMatch.brand.trim().isEmpty) {
      shoppingMatch = shoppingMatch.copyWith(
        brand: product.brand.trim(),
      );
      await state.updateShoppingItem(shoppingMatch);
    }

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
      brand: product.brand,
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

String _greeting(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

String _friendlyDate(DateTime value) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
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

  return '${weekdays[value.weekday - 1]}, '
      '${value.day} ${months[value.month - 1]}';
}
