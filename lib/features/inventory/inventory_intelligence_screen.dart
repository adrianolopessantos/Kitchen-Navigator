import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';

class InventoryIntelligenceScreen extends StatelessWidget {
  const InventoryIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final health = state.pantryHealthScore;

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Intelligence')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            const Text(
              'Pantry health',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Understand what is running low, expiring, and how much food is stored.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: 126,
                      height: 126,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: health / 100,
                            strokeWidth: 12,
                            backgroundColor: AppColors.border,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$health%',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  state.pantryHealthLabel,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _SummaryCard(
                          value: '${state.pantryCount}',
                          label: 'Products',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _SummaryCard(
                          value: '${state.lowStockItems.length}',
                          label: 'Low stock',
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        _SummaryCard(
                          value:
                              '€${state.estimatedPantryValue.toStringAsFixed(0)}',
                          label: 'Est. value',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'LOW STOCK & REORDER',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 9),
            if (state.lowStockItems.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No products are currently below their estimated minimum level.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...state.lowStockItems.map(
                (item) => _LowStockCard(item: item),
              ),
            const SizedBox(height: 18),
            const Text(
              'STOCK OVERVIEW',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 9),
            if (state.pantryItems.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Add pantry products to see inventory insights.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...state.pantryItems.map(
                (item) => _StockOverviewCard(item: item),
              ),
          ],
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final minimum = state.minimumStockFor(item);
    final days = state.estimatedDaysRemaining(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_format(item.quantity)} ${item.unit} remaining · about $days days',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Suggested minimum: ${_format(minimum)} ${item.unit}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () {
                state.addLowStockToShopping(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} added to Shopping.'),
                  ),
                );
              },
              child: const Text('Reorder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockOverviewCard extends StatelessWidget {
  const _StockOverviewCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final value = state.estimatedItemValue(item);
    final days = state.estimatedDaysRemaining(item);
    final minimum = state.minimumStockFor(item);
    final ratio = minimum <= 0
        ? 1.0
        : (item.quantity / (minimum * 3)).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '€${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: AppColors.border,
            ),
            const SizedBox(height: 7),
            Text(
              '${_format(item.quantity)} ${item.unit} · estimated $days days remaining · ${item.location.label}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _format(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

Future<void> openInventoryIntelligence(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => const InventoryIntelligenceScreen(),
    ),
  );
}
