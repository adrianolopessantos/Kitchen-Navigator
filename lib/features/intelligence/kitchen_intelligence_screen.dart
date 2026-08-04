import 'package:flutter/material.dart';
import '../../core/services/kitchen_intelligence_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../cooking/cooking_assistant_screen.dart';
import '../expiry/expiry_screen.dart';
import '../inventory/inventory_intelligence_screen.dart';
import '../nutrition/nutrition_screen.dart';

class KitchenIntelligenceScreen extends StatelessWidget {
  const KitchenIntelligenceScreen({
    super.key,
    required this.openPlanner,
    required this.openShopping,
  });

  final VoidCallback openPlanner;
  final VoidCallback openShopping;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final brief = KitchenIntelligenceService.buildBrief(state);

    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Intelligence')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            Text(
              brief.greeting,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              brief.headline,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${state.activeKitchen.name} · ${state.todayName}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MetricCard(
                  value: '${brief.estimatedCookingMinutes}',
                  label: 'Cooking min',
                  icon: Icons.schedule_outlined,
                ),
                const SizedBox(width: 8),
                _MetricCard(
                  value: '${brief.shoppingRemaining}',
                  label: 'To buy',
                  icon: Icons.shopping_cart_outlined,
                ),
                const SizedBox(width: 8),
                _MetricCard(
                  value: '${state.pantryHealthScore}%',
                  label: 'Pantry health',
                  icon: Icons.insights_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'PRIORITY ALERTS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 9),
            if (brief.alerts.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                  ),
                  title: Text('Nothing urgent'),
                  subtitle: Text('Your kitchen has no immediate alerts.'),
                ),
              )
            else
              ...brief.alerts.map((alert) => _AlertCard(alert: alert)),
            const SizedBox(height: 18),
            const Text(
              'SMART RECOMMENDATIONS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 9),
            ...brief.recommendations.map(
              (message) => Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: ListTile(
                  leading: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                  ),
                  title: Text(message),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.restaurant_outlined),
                    title: const Text('Meal plan'),
                    subtitle: Text(
                      state.todayMeals.isEmpty
                          ? 'No meal planned'
                          : state.todayMeals
                              .map((meal) => meal.recipe.name)
                              .join(' + '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: openPlanner,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart_outlined),
                    title: const Text('Shopping'),
                    subtitle: Text(
                      '${brief.shoppingRemaining} product${brief.shoppingRemaining == 1 ? '' : 's'} remaining',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: openShopping,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.event_busy_outlined),
                    title: const Text('Expiry'),
                    subtitle: Text(
                      '${state.useSoonItems.length} item${state.useSoonItems.length == 1 ? '' : 's'} need attention',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openExpiryIntelligence(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined),
                    title: const Text('Nutrition'),
                    subtitle: Text(
                      '${state.todayNutrition.calories.round()} kcal · ${state.todayNutrition.protein.round()} g protein',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openNutritionCenter(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.insights_outlined),
                    title: const Text('Inventory'),
                    subtitle: Text(
                      '${state.lowStockItems.length} low-stock item${state.lowStockItems.length == 1 ? '' : 's'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openInventoryIntelligence(context),
                  ),
                ],
              ),
            ),
            if (state.todayMeals.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => openCookingAssistant(
                    context,
                    state.todayMeals.first.recipe,
                    servings: state.todayMeals.first.people,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('Start today’s cooking'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 98),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 21),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final KitchenBriefAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.level) {
      KitchenAlertLevel.urgent => AppColors.danger,
      KitchenAlertLevel.warning => AppColors.warning,
      KitchenAlertLevel.info => AppColors.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(_iconFor(alert.iconName), color: color),
        title: Text(
          alert.title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(alert.message),
      ),
    );
  }

  static IconData _iconFor(String name) {
    switch (name) {
      case 'expired':
        return Icons.warning_amber_rounded;
      case 'schedule':
        return Icons.schedule_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

Future<void> openKitchenIntelligence(
  BuildContext context, {
  required VoidCallback openPlanner,
  required VoidCallback openShopping,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => KitchenIntelligenceScreen(
        openPlanner: openPlanner,
        openShopping: openShopping,
      ),
    ),
  );
}
