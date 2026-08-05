import 'package:flutter/material.dart';
import '../../core/services/product_lookup_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';
import '../barcode/barcode_scanner_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final week = state.selectedShoppingWeek;
    final allItems = state.selectedWeeklyShoppingItems;
    final filtered = allItems.where((item) {
      return item.name.toLowerCase().contains(
            query.trim().toLowerCase(),
          );
    }).toList();

    final checkedCount = state.checkedShoppingCountForWeek(week);
    final progress =
        allItems.isEmpty ? 0.0 : checkedCount / allItems.length;
    final estimatedTotal =
        state.estimatedShoppingTotalForWeek(week);
    final groups = <String, List<ShoppingItem>>{};

    for (final item in filtered) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              110,
            ),
            sliver: SliverList.list(
              children: [
                _Header(
                  week: week,
                  itemCount: allItems.length,
                  checkedCount: checkedCount,
                  progress: progress,
                  estimatedTotal: estimatedTotal,
                  weeklyBudget: state.weeklyShoppingBudget,
                  monthlyTotal:
                      state.estimatedMonthlyPlanShoppingTotal,
                  onScan: () => _scanPurchasedProduct(context),
                  onClear: () =>
                      state.clearShoppingChecksForWeek(week),
                ),
                const SizedBox(height: AppSpacing.md),
                _WeekSelector(
                  selectedWeek: week,
                  weeks: state.shoppingWeeksInSelectedMonth,
                  itemCountForWeek: (value) =>
                      state.shoppingItemsForWeek(value).length,
                  onSelected: state.selectShoppingWeek,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: (value) =>
                      setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search this week’s list',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.monthlyMealPlan.entries.isEmpty)
                  const _EmptyState(
                    title: 'Create a monthly meal plan first',
                    message:
                        'The shopping list is built automatically from '
                        'your monthly meals and pantry stock.',
                    icon: Icons.calendar_month_outlined,
                  )
                else if (filtered.isEmpty)
                  const _EmptyState(
                    title: 'Nothing to buy this week',
                    message:
                        'Your pantry already covers the plan, or this '
                        'week has no missing ingredients.',
                    icon: Icons.shopping_cart_checkout_outlined,
                  )
                else
                  ...groups.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.lg,
                      ),
                      child: _ShoppingCategory(
                        title: entry.key,
                        items: entry.value,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanPurchasedProduct(
    BuildContext context,
  ) async {
    final state = AppScope.of(context);
    final barcode = await openBarcodeScanner(context);

    if (!mounted || barcode == null || barcode.trim().isEmpty) {
      return;
    }

    final result =
        await ProductLookupService.findByBarcode(barcode) ??
            ProductLookupService.createFallback(barcode);

    if (!mounted) return;

    ShoppingItem? match;
    final normalizedProduct = _normalize(result.name);

    for (final item in state.selectedWeeklyShoppingItems) {
      final normalizedItem = _normalize(item.name);
      if (normalizedItem == normalizedProduct ||
          normalizedItem.contains(normalizedProduct) ||
          normalizedProduct.contains(normalizedItem)) {
        match = item;
        break;
      }
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Barcode scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (result.brand.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                result.brand,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 12),
            Text('Barcode: ${result.barcode}'),
            Text('Store in: ${result.location.label}'),
            const SizedBox(height: 12),
            Text(
              match == null
                  ? 'No exact match was found in Week '
                      '${state.selectedShoppingWeek}. The product can '
                      'still be added to Pantry.'
                  : 'Matches this week’s item: ${match.name}',
              style: TextStyle(
                color: match == null
                    ? AppColors.warning
                    : AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to pantry'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) return;

    final expiryDate = DateTime.now().add(
      Duration(days: result.suggestedShelfLifeDays),
    );

    if (match != null) {
      state.purchaseShoppingItem(
        item: match,
        location: result.location,
        expiryDate: expiryDate,
        barcode: result.barcode,
      );
      if (!state.isShoppingChecked(match.key)) {
        state.toggleShoppingChecked(match.key);
      }
    } else {
      state.addPantryItem(
        name: result.name,
        quantity: result.defaultQuantity,
        unit: result.defaultUnit,
        location: result.location,
        expiryDate: expiryDate,
        barcode: result.barcode,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.name} added to Pantry.'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.week,
    required this.itemCount,
    required this.checkedCount,
    required this.progress,
    required this.estimatedTotal,
    required this.weeklyBudget,
    required this.monthlyTotal,
    required this.onScan,
    required this.onClear,
  });

  final int week;
  final int itemCount;
  final int checkedCount;
  final double progress;
  final double estimatedTotal;
  final double weeklyBudget;
  final double monthlyTotal;
  final VoidCallback onScan;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final remaining = itemCount - checkedCount;
    final overBudget = estimatedTotal > weeklyBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart shopping',
                    style:
                        Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Weekly lists from your monthly plan and pantry',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF38271F),
                Color(0xFF211A17),
              ],
            ),
            borderRadius:
                BorderRadius.circular(AppRadius.hero),
            border: Border.all(
              color: const Color(0xFF5A3A2D),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta
                          .withValues(alpha: .14),
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.terracotta,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week $week · $remaining remaining',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$checkedCount of $itemCount completed',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '€${estimatedTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: overBudget
                          ? AppColors.danger
                          : AppColors.terracotta,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                color: AppColors.terracotta,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _BudgetStat(
                      label: 'Weekly budget',
                      value: '€${weeklyBudget.toStringAsFixed(2)}',
                      warning: overBudget,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BudgetStat(
                      label: 'Month estimate',
                      value: '€${monthlyTotal.toStringAsFixed(2)}',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reset Week $week checks',
                    onPressed: onClear,
                    icon: const Icon(Icons.restart_alt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color:
                  warning ? AppColors.danger : AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({
    required this.selectedWeek,
    required this.weeks,
    required this.itemCountForWeek,
    required this.onSelected,
  });

  final int selectedWeek;
  final int weeks;
  final int Function(int) itemCountForWeek;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weeks,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final week = index + 1;
          return ChoiceChip(
            selected: selectedWeek == week,
            onSelected: (_) => onSelected(week),
            label: Text(
              'Week $week · ${itemCountForWeek(week)}',
            ),
          );
        },
      ),
    );
  }
}

class _ShoppingCategory extends StatelessWidget {
  const _ShoppingCategory({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _categoryIcon(title),
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${items.length}',
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final checked =
                  state.isShoppingChecked(item.key);

              return Column(
                children: [
                  Dismissible(
                    key: ValueKey(item.key),
                    direction: DismissDirection.startToEnd,
                    confirmDismiss: (_) async {
                      state.toggleShoppingChecked(item.key);
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      color: AppColors.primary
                          .withValues(alpha: .15),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Toggle purchased',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: CheckboxListTile(
                      value: checked,
                      onChanged: (_) =>
                          state.toggleShoppingChecked(item.key),
                      secondary: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _categoryColor(title)
                              .withValues(alpha: .12),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _categoryIcon(title),
                          color: _categoryColor(title),
                          size: 21,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: checked
                              ? AppColors.subtle
                              : AppColors.text,
                          fontWeight: FontWeight.w800,
                          decoration: checked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${_quantity(item.quantity)} ${item.unit} · '
                        '€${item.estimatedTotal.toStringAsFixed(2)}\n'
                        '${item.recipeNames.take(3).join(', ')}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      isThreeLine: true,
                      controlAffinity:
                          ListTileControlAffinity.trailing,
                    ),
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 46),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Dairy & Chilled':
      return Icons.local_drink_outlined;
    case 'Meat & Fish':
      return Icons.set_meal_outlined;
    case 'Fruit & Vegetables':
      return Icons.eco_outlined;
    case 'Bakery':
      return Icons.bakery_dining_outlined;
    case 'Frozen':
      return Icons.ac_unit_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'Dairy & Chilled':
      return const Color(0xFF9BC7F0);
    case 'Meat & Fish':
      return AppColors.terracotta;
    case 'Fruit & Vegetables':
      return AppColors.primary;
    case 'Bakery':
      return AppColors.warning;
    case 'Frozen':
      return const Color(0xFF9DD9E8);
    default:
      return AppColors.muted;
  }
}

String _quantity(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
