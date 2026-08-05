class BudgetForecast {
  const BudgetForecast({
    required this.monthlyBudget,
    required this.estimatedMonthlyCost,
    required this.remainingBudget,
    required this.projectedStatus,
    required this.savingsTarget,
  });

  final double monthlyBudget;
  final double estimatedMonthlyCost;
  final double remainingBudget;
  final String projectedStatus;
  final double savingsTarget;

  bool get overBudget => remainingBudget < 0;
}
