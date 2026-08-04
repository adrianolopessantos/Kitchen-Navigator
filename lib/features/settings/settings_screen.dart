import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../equipment/equipment_screen.dart';
import '../kitchens/kitchens_screen.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../../models/nutrition.dart';
import '../budget/budget_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final plannedMeals = AppState.days.fold<int>(
      0,
      (total, day) => total + state.mealsFor(day).length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Data & storage',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kitchen data is saved locally on this phone.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Saved pantry products'),
                    trailing: Text('${state.pantryCount}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Planned meals'),
                    trailing: Text('$plannedMeals'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(
                      Icons.phone_android_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text('Storage location'),
                    subtitle: Text('This device only'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_city_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('My kitchens'),
                subtitle: Text(
                  '${state.kitchenProfiles.length} location${state.kitchenProfiles.length == 1 ? '' : 's'} · ${state.activeKitchen.name} active',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openKitchens(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.kitchen_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Kitchen equipment'),
                subtitle: Text(
                  '${state.kitchenAppliances.length} appliance${state.kitchenAppliances.length == 1 ? '' : 's'} configured',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openEquipment(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Budget & grocery analytics'),
                subtitle: const Text(
                  'Monthly budget and purchase history',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openBudgetCenter(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.favorite_outline,
                  color: AppColors.primary,
                ),
                title: const Text('Nutrition Center'),
                subtitle: Text(
                  'Goal: ${_nutritionGoalLabel(state.nutritionGoal)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openNutritionCenter(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.monitor_heart_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('App diagnostics'),
                subtitle: const Text(
                  'Check data loading and module status',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openDiagnostics(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.danger,
                ),
                title: const Text('Reset Kitchen Navigator data'),
                subtitle: const Text(
                  'Removes pantry products, meal plans and shopping checks.',
                ),
                onTap: () => _confirmReset(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final state = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset all local data?'),
          content: const Text(
            'This cannot be undone. Your pantry, meal plan and shopping progress will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset data'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await state.clearAllSavedData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local Kitchen Navigator data reset.')),
      );
    }
  }
}

Future<void> openSettings(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
