import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/grocery_expense.dart';

class BudgetSnapshot {
  const BudgetSnapshot({
    required this.monthlyBudget,
    required this.expenses,
  });

  final double monthlyBudget;
  final List<GroceryExpense> expenses;
}

abstract final class BudgetService {
  static String _budgetKey(String kitchenId) =>
      'kitchen_navigator_${kitchenId}_monthly_budget_v1';

  static String _expensesKey(String kitchenId) =>
      'kitchen_navigator_${kitchenId}_grocery_expenses_v1';

  static Future<BudgetSnapshot> load(String kitchenId) async {
    final preferences = await SharedPreferences.getInstance();
    final monthlyBudget =
        preferences.getDouble(_budgetKey(kitchenId)) ?? 400;

    final encoded = preferences.getString(_expensesKey(kitchenId));
    final expenses = <GroceryExpense>[];

    if (encoded != null && encoded.isNotEmpty) {
      try {
        final decoded = jsonDecode(encoded) as List<dynamic>;
        expenses.addAll(
          decoded.map(
            (value) => GroceryExpense.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          ),
        );
      } catch (_) {
        expenses.clear();
      }
    }

    expenses.sort(
      (a, b) => b.purchasedAt.compareTo(a.purchasedAt),
    );

    return BudgetSnapshot(
      monthlyBudget: monthlyBudget,
      expenses: expenses,
    );
  }

  static Future<void> save({
    required String kitchenId,
    required double monthlyBudget,
    required List<GroceryExpense> expenses,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(
      _budgetKey(kitchenId),
      monthlyBudget,
    );
    await preferences.setString(
      _expensesKey(kitchenId),
      jsonEncode(
        expenses.map((expense) => expense.toJson()).toList(),
      ),
    );
  }

  static List<GroceryExpense> expensesForMonth(
    List<GroceryExpense> expenses,
    DateTime month,
  ) {
    return expenses.where((expense) {
      return expense.purchasedAt.year == month.year &&
          expense.purchasedAt.month == month.month;
    }).toList();
  }

  static double totalSpent(List<GroceryExpense> expenses) {
    return expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  static Map<String, double> totalsByCategory(
    List<GroceryExpense> expenses,
  ) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }
}
