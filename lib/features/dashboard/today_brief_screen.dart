import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../nutrition/nutrition_screen.dart';
import '../notifications/notification_center_screen.dart';

class TodayBriefScreen extends StatelessWidget {
  const TodayBriefScreen({
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
    final meals = state.todaysMonthlyMeals;
    final remaining = state.selectedWeeklyShoppingItems
        .where((item) => !state.isShoppingChecked(item.key))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Today’s kitchen brief')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionCard(
            icon: Icons.restaurant_menu,
            title: 'Today’s meals',
            value: '${meals.length} planned',
            detail: meals.isEmpty
                ? 'Plan today’s meals'
                : meals.map((meal) => meal.name).join(' · '),
            onTap: () {
              Navigator.pop(context);
              openPlanner();
            },
          ),
          _ActionCard(
            icon: Icons.shopping_cart_outlined,
            title: 'Shopping',
            value: '$remaining remaining',
            detail:
                'Week ${state.selectedShoppingWeek} · '
                '€${state.estimatedShoppingTotalForWeek(state.selectedShoppingWeek).toStringAsFixed(2)}',
            onTap: () {
              Navigator.pop(context);
              openShopping();
            },
          ),
          _ActionCard(
            icon: Icons.inventory_2_outlined,
            title: 'Pantry',
            value: '${state.pantryCount} products',
            detail:
                '${state.wasteRiskItems.length} waste risk · '
                '${state.restockSuggestedItems.length} restock',
            onTap: () {
              Navigator.pop(context);
              openPantry();
            },
          ),
          _ActionCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget',
            value: state.budgetForecast.projectedStatus,
            detail:
                '€${state.budgetForecast.estimatedMonthlyCost.toStringAsFixed(2)} '
                'of €${state.budgetForecast.monthlyBudget.toStringAsFixed(2)}',
            onTap: openShopping,
          ),
          _ActionCard(
            icon: Icons.monitor_heart_outlined,
            title: 'Nutrition',
            value: state.hasTodaysNutrition
                ? '${state.todaysNutrition.calories.round()} kcal household'
                : 'Analysis pending',
            detail: state.hasTodaysNutrition
                ? 'Estimated from today’s plan'
                : 'Plan meals to calculate estimates',
            onTap: () => openNutritionCenter(context),
          ),
          _ActionCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            value: '${state.unreadNotificationCount} unread',
            detail: 'Meal, shopping, expiry and budget alerts',
            onTap: () => openNotificationCenter(context),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(detail),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

Future<void> openTodayBrief(
  BuildContext context, {
  required VoidCallback openPlanner,
  required VoidCallback openPantry,
  required VoidCallback openShopping,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => TodayBriefScreen(
        openPlanner: openPlanner,
        openPantry: openPantry,
        openShopping: openShopping,
      ),
    ),
  );
}
