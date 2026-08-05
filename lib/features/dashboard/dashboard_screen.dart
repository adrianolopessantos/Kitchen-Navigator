import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_card.dart';
import '../../core/widgets/knife_compass_logo.dart';
import '../../models/nutrition.dart';
import '../budget/budget_screen.dart';
import '../cooking/cooking_assistant_screen.dart';
import '../expiry/expiry_screen.dart';
import '../intelligence/ai_kitchen_screen.dart';
import '../intelligence/kitchen_intelligence_screen.dart';
import '../inventory/inventory_intelligence_screen.dart';
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
                _HeroBrief(
                  health: health,
                  mealText: mealText,
                  cookingMinutes: cookingMinutes,
                  shoppingCount: shoppingRemaining,
                  expiryCount: state.useSoonItems.length,
                  onTap: () => openKitchenIntelligence(
                    context,
                    openPlanner: openPlanner,
                    openShopping: openShopping,
                  ),
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
                      icon: Icons.auto_awesome,
                      label: 'AI Kitchen',
                      value: 'What can I cook?',
                      note: 'Uses pantry and expiry data',
                      accentColor: AppColors.warning,
                      onTap: () => openAiKitchen(context),
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
                  value:
                      '${state.todayNutrition.calories.round()} kcal planned',
                  note:
                      '${state.todayNutrition.protein.round()} g protein · ${_nutritionGoalLabel(state.nutritionGoal)}',
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

class _HeroBrief extends StatelessWidget {
  const _HeroBrief({
    required this.health,
    required this.mealText,
    required this.cookingMinutes,
    required this.shoppingCount,
    required this.expiryCount,
    required this.onTap,
  });

  final int health;
  final String mealText;
  final int cookingMinutes;
  final int shoppingCount;
  final int expiryCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF203A27),
            Color(0xFF16271D),
            Color(0xFF1C241D),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: const Color(0xFF38523E)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY’S KITCHEN',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Everything at a glance',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HealthRing(value: health),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                mealText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroBadge(
                    icon: Icons.schedule_outlined,
                    text: cookingMinutes == 0
                        ? 'No cooking scheduled'
                        : '$cookingMinutes min cooking',
                  ),
                  _HeroBadge(
                    icon: Icons.shopping_bag_outlined,
                    text: '$shoppingCount to buy',
                  ),
                  _HeroBadge(
                    icon: Icons.eco_outlined,
                    text: '$expiryCount use soon',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Row(
                children: [
                  Text(
                    'Open kitchen brief',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  const _HealthRing({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 7,
            backgroundColor: Colors.white.withValues(alpha: .1),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value%',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'HEALTH',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
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

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: .09),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
