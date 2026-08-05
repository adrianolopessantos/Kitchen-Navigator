import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/monthly_meal_plan.dart';

abstract final class MonthlyMealPlanService {
  static const storageKey =
      'kitchen_navigator_monthly_meal_plan_v11';

  static Future<MonthlyMealPlan> load(DateTime month) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);

    if (encoded == null || encoded.isEmpty) {
      return MonthlyMealPlan.empty(month);
    }

    try {
      final plan = MonthlyMealPlan.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );

      if (plan.monthKey != monthKeyFor(month)) {
        return MonthlyMealPlan.empty(month);
      }

      return plan;
    } catch (_) {
      return MonthlyMealPlan.empty(month);
    }
  }

  static Future<void> save(MonthlyMealPlan plan) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      storageKey,
      jsonEncode(plan.toJson()),
    );
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
