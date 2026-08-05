import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/budget_intelligence_service.dart';

void main() {
  test('Budget forecast detects over-budget plans', () {
    final value = BudgetIntelligenceService.forecast(
      monthlyBudget: 500,
      estimatedMonthlyCost: 560,
    );

    expect(value.overBudget, isTrue);
    expect(value.savingsTarget, 60);
    expect(value.projectedStatus, 'Over budget');
  });

  test('Budget forecast reports remaining budget', () {
    final value = BudgetIntelligenceService.forecast(
      monthlyBudget: 500,
      estimatedMonthlyCost: 420,
    );

    expect(value.overBudget, isFalse);
    expect(value.remainingBudget, 80);
  });
}
