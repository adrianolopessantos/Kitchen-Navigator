import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/budget_service.dart';
import 'package:kitchen_navigator/models/grocery_expense.dart';

void main() {
  test('BudgetService totals expenses and categories', () {
    final expenses = [
      GroceryExpense(
        id: '1',
        description: 'Vegetables',
        amount: 12.50,
        category: 'Fruit & Vegetables',
        purchasedAt: DateTime(2026, 8, 1),
      ),
      GroceryExpense(
        id: '2',
        description: 'Milk',
        amount: 2.50,
        category: 'Dairy & Chilled',
        purchasedAt: DateTime(2026, 8, 2),
      ),
    ];

    expect(BudgetService.totalSpent(expenses), 15);
    expect(
      BudgetService.totalsByCategory(expenses)['Fruit & Vegetables'],
      12.50,
    );
  });
}
