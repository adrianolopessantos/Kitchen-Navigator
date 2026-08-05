import '../../models/budget_forecast.dart';

abstract final class BudgetIntelligenceService {
  static BudgetForecast forecast({
    required double monthlyBudget,
    required double estimatedMonthlyCost,
  }) {
    final remaining = monthlyBudget - estimatedMonthlyCost;
    final status = remaining < 0
        ? 'Over budget'
        : remaining < monthlyBudget * .1
            ? 'Close to limit'
            : 'On track';

    return BudgetForecast(
      monthlyBudget: monthlyBudget,
      estimatedMonthlyCost: estimatedMonthlyCost,
      remainingBudget: remaining,
      projectedStatus: status,
      savingsTarget: remaining < 0 ? remaining.abs() : 0,
    );
  }
}
