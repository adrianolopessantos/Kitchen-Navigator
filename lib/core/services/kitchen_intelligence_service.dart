import '../state/app_state.dart';
import '../../models/pantry_item.dart';

enum KitchenAlertLevel { info, warning, urgent }

class KitchenBriefAlert {
  const KitchenBriefAlert({
    required this.title,
    required this.message,
    required this.level,
    required this.iconName,
  });

  final String title;
  final String message;
  final KitchenAlertLevel level;
  final String iconName;
}

class KitchenMorningBrief {
  const KitchenMorningBrief({
    required this.greeting,
    required this.headline,
    required this.alerts,
    required this.recommendations,
    required this.estimatedCookingMinutes,
    required this.shoppingRemaining,
  });

  final String greeting;
  final String headline;
  final List<KitchenBriefAlert> alerts;
  final List<String> recommendations;
  final int estimatedCookingMinutes;
  final int shoppingRemaining;
}

abstract final class KitchenIntelligenceService {
  static KitchenMorningBrief buildBrief(
    AppState state, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final meals = state.todayMeals;
    final alerts = <KitchenBriefAlert>[];
    final recommendations = <String>[];

    final cookingMinutes = meals.fold<int>(
      0,
      (total, meal) =>
          total + (meal.recipe.totalSeconds / 60).ceil(),
    );

    if (state.expiredItems.isNotEmpty) {
      alerts.add(
        KitchenBriefAlert(
          title: 'Expired products',
          message:
              '${state.expiredItems.length} product${state.expiredItems.length == 1 ? '' : 's'} should be reviewed.',
          level: KitchenAlertLevel.urgent,
          iconName: 'expired',
        ),
      );
    }

    if (state.expiresTodayItems.isNotEmpty) {
      alerts.add(
        KitchenBriefAlert(
          title: 'Use today',
          message: state.expiresTodayItems
              .take(3)
              .map((item) => item.name)
              .join(', '),
          level: KitchenAlertLevel.urgent,
          iconName: 'schedule',
        ),
      );
    }

    if (state.expiresTomorrowItems.isNotEmpty) {
      alerts.add(
        KitchenBriefAlert(
          title: 'Expires tomorrow',
          message: state.expiresTomorrowItems
              .take(3)
              .map((item) => item.name)
              .join(', '),
          level: KitchenAlertLevel.warning,
          iconName: 'schedule',
        ),
      );
    }

    if (state.lowStockItems.isNotEmpty) {
      alerts.add(
        KitchenBriefAlert(
          title: 'Low stock',
          message:
              '${state.lowStockItems.length} product${state.lowStockItems.length == 1 ? '' : 's'} may need reordering.',
          level: KitchenAlertLevel.warning,
          iconName: 'inventory',
        ),
      );
    }

    if (meals.isEmpty) {
      alerts.add(
        const KitchenBriefAlert(
          title: 'No dinner planned',
          message: 'Choose a meal to organise shopping and cooking.',
          level: KitchenAlertLevel.info,
          iconName: 'meal',
        ),
      );
      recommendations.add(
        'Use AI Kitchen to choose a meal from products already available.',
      );
    } else {
      recommendations.add(
        'Allow about $cookingMinutes minutes for today’s planned cooking.',
      );
      if (state.shoppingItems.isNotEmpty) {
        alerts.add(
          KitchenBriefAlert(
            title: 'Shopping needed',
            message:
                '${state.shoppingItems.length} missing ingredient${state.shoppingItems.length == 1 ? '' : 's'} across the weekly plan.',
            level: KitchenAlertLevel.warning,
            iconName: 'shopping',
          ),
        );
      }
    }

    final urgentMatches = _urgentIngredientsUsedByTodayMeal(state);
    if (urgentMatches.isNotEmpty) {
      recommendations.insert(
        0,
        'Today’s meal helps use ${urgentMatches.join(', ')} before it spoils.',
      );
    } else if (state.useSoonItems.isNotEmpty) {
      recommendations.insert(
        0,
        'Consider using ${state.useSoonItems.first.name} in the next meal.',
      );
    }

    final nutrition = state.todayNutrition;
    final target = state.nutritionTargets;

    if (nutrition.protein < target.protein * .7 && meals.isNotEmpty) {
      recommendations.add(
        'Protein is below target; consider eggs, beans, yogurt, fish, tofu, or lean meat.',
      );
    }

    if (nutrition.fibre < target.fibre * .65 && meals.isNotEmpty) {
      recommendations.add(
        'Add vegetables, fruit, beans, or whole grains to improve fibre.',
      );
    }

    if (state.kitchenAppliances.isEmpty) {
      recommendations.add(
        'Add your cooking appliances for tailored temperature guidance.',
      );
    }

    final mealNames = meals.map((meal) => meal.recipe.name).join(' + ');

    return KitchenMorningBrief(
      greeting: _greeting(current.hour),
      headline: meals.isEmpty
          ? 'Your kitchen is ready for a plan'
          : '$mealNames planned for ${state.todayName}',
      alerts: alerts,
      recommendations: recommendations.take(5).toList(),
      estimatedCookingMinutes: cookingMinutes,
      shoppingRemaining: state.shoppingItems.length,
    );
  }

  static List<String> _urgentIngredientsUsedByTodayMeal(
    AppState state,
  ) {
    final urgent = <PantryItem>[
      ...state.expiresTodayItems,
      ...state.expiresTomorrowItems,
    ];
    final matches = <String>{};

    for (final item in urgent) {
      final itemKey = _normalise(item.name);
      for (final meal in state.todayMeals) {
        for (final ingredient in meal.recipe.ingredients) {
          final ingredientKey = _normalise(ingredient);
          if (itemKey == ingredientKey ||
              itemKey.contains(ingredientKey) ||
              ingredientKey.contains(itemKey)) {
            matches.add(item.name);
          }
        }
      }
    }
    return matches.toList();
  }

  static String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  static String _normalise(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
