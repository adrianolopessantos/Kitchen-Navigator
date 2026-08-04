import 'package:flutter/material.dart';
import '../../core/services/budget_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/grocery_expense.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  static const categories = [
    'Fruit & Vegetables',
    'Dairy & Chilled',
    'Meat & Fish',
    'Pantry',
    'Frozen',
    'Bakery',
    'Drinks',
    'Household',
    'Other',
  ];

  bool loading = true;
  double monthlyBudget = 400;
  List<GroceryExpense> expenses = [];
  String? loadedKitchenId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final kitchenId = AppScope.of(context).activeKitchenId;
    if (loadedKitchenId != kitchenId) {
      loadedKitchenId = kitchenId;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final snapshot = await BudgetService.load(loadedKitchenId!);
    if (!mounted) return;
    setState(() {
      monthlyBudget = snapshot.monthlyBudget;
      expenses = snapshot.expenses;
      loading = false;
    });
  }

  Future<void> _save() {
    return BudgetService.save(
      kitchenId: loadedKitchenId!,
      monthlyBudget: monthlyBudget,
      expenses: expenses,
    );
  }

  Future<void> _editBudget() async {
    final controller = TextEditingController(
      text: monthlyBudget.toStringAsFixed(0),
    );

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Monthly grocery budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            prefixText: '€ ',
            labelText: 'Budget',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (value != null && value > 0) {
      setState(() => monthlyBudget = value);
      await _save();
    }
  }

  Future<void> _addExpense() async {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    var category = 'Other';
    var purchasedAt = DateTime.now();

    final expense = await showModalBottomSheet<GroceryExpense>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                18,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add grocery purchase',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Weekly supermarket shop',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '€ ',
                        labelText: 'Amount',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: categories.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        title: const Text('Purchase date'),
                        subtitle: Text(_formatDate(purchasedAt)),
                        trailing:
                            const Icon(Icons.calendar_month_outlined),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: purchasedAt,
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 1)),
                          );
                          if (selected != null) {
                            setModalState(() => purchasedAt = selected);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final amount = double.tryParse(
                            amountController.text.replaceAll(',', '.'),
                          );
                          final description =
                              descriptionController.text.trim();

                          if (amount == null ||
                              amount <= 0 ||
                              description.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter a description and valid amount.',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(
                            sheetContext,
                            GroceryExpense(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              description: description,
                              amount: amount,
                              category: category,
                              purchasedAt: purchasedAt,
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('Add purchase'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    descriptionController.dispose();
    amountController.dispose();

    if (expense != null) {
      setState(() {
        expenses = [expense, ...expenses];
      });
      await _save();
    }
  }

  Future<void> _removeExpense(GroceryExpense expense) async {
    setState(() {
      expenses.removeWhere((item) => item.id == expense.id);
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final currentMonth = DateTime.now();
    final monthExpenses = BudgetService.expensesForMonth(
      expenses,
      currentMonth,
    );
    final spent = BudgetService.totalSpent(monthExpenses);
    final remaining = monthlyBudget - spent;
    final progress = monthlyBudget <= 0
        ? 0.0
        : (spent / monthlyBudget).clamp(0.0, 1.0);
    final categoryTotals =
        BudgetService.totalsByCategory(monthExpenses).entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final plannedMeals = AppState.days.fold<int>(
      0,
      (total, day) => total + state.mealsFor(day).length,
    );
    final averageMealCost = plannedMeals <= 0
        ? 0.0
        : state.estimatedShoppingTotal / plannedMeals;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget & Grocery Analytics')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add purchase'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  Text(
                    state.activeKitchen.name,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monthly grocery budget',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'This month',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _editBudget,
                                child: const Text('Edit budget'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _SummaryValue(
                                label: 'Spent',
                                value: '€${spent.toStringAsFixed(2)}',
                              ),
                              _SummaryValue(
                                label: 'Budget',
                                value:
                                    '€${monthlyBudget.toStringAsFixed(2)}',
                              ),
                              _SummaryValue(
                                label: remaining >= 0
                                    ? 'Remaining'
                                    : 'Over budget',
                                value:
                                    '€${remaining.abs().toStringAsFixed(2)}',
                                warning: remaining < 0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InsightCard(
                          label: 'Weekly list',
                          value:
                              '€${state.estimatedShoppingTotal.toStringAsFixed(2)}',
                          note: 'Estimated',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _InsightCard(
                          label: 'Cost per meal',
                          value:
                              '€${averageMealCost.toStringAsFixed(2)}',
                          note: 'Estimated',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'SPENDING BY CATEGORY',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(height: 9),
                  if (categoryTotals.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Add purchases to see category analytics.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: List.generate(
                          categoryTotals.length,
                          (index) {
                            final item = categoryTotals[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(item.key),
                                  trailing: Text(
                                    '€${item.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (index <
                                    categoryTotals.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  const Text(
                    'PURCHASE HISTORY',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(height: 9),
                  if (expenses.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No grocery purchases recorded yet.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    ...expenses.map(
                      (expense) => Card(
                        margin: const EdgeInsets.only(bottom: 9),
                        child: ListTile(
                          leading: const Icon(
                            Icons.receipt_long_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            expense.description,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            '${expense.category} · ${_formatDate(expense.purchasedAt)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '€${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: () =>
                                    _removeExpense(expense),
                                icon:
                                    const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: warning ? AppColors.warning : AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 105),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            note,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openBudgetCenter(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const BudgetScreen()),
  );
}
