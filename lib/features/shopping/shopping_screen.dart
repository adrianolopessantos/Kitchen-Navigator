import 'package:flutter/material.dart';
import '../../core/services/product_lookup_service.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';
import '../barcode/barcode_scanner_screen.dart';

const _shoppingUnits = [
  'each',
  'g',
  'kg',
  'ml',
  'L',
  'pack',
  'tin',
  'bottle',
  'loaf',
  'dozen',
];

const _shoppingCategories = [
  'Fruit & Vegetables',
  'Meat & Fish',
  'Dairy & Chilled',
  'Bakery',
  'Frozen',
  'Pantry',
  'Household',
  'Other',
];

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
    final allItems = state.activeShoppingItems;

    final filtered = allItems.where((item) {
      return item.name.toLowerCase().contains(
            query.trim().toLowerCase(),
          );
    }).toList();

    final remaining = filtered
        .where((item) => !state.isShoppingChecked(item.key))
        .toList();
    final purchased = filtered
        .where((item) => state.isShoppingChecked(item.key))
        .toList();

    final groups = <String, List<ShoppingItem>>{};
    for (final item in remaining) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }

    final checkedCount = state.checkedShoppingCountForWeek(week);
    final estimatedTotal =
        state.estimatedShoppingTotalForWeek(week);
    final remainingEstimatedTotal = allItems
        .where((item) => !state.isShoppingChecked(item.key))
        .fold<double>(
          0,
          (total, item) => total + item.estimatedTotal,
        );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 126),
            sliver: SliverList.list(
              children: [
                _Header(
                  week: state.shoppingMonthView ? 0 : week,
                  remaining: allItems.length - checkedCount,
                  purchased: checkedCount,
                  estimatedTotal: estimatedTotal,
                  remainingEstimatedTotal: remainingEstimatedTotal,
                  weeklyBudget: state.weeklyShoppingBudget,
                  onScan: () => _scanPurchasedProduct(context),
                  onAdd: () => _showItemEditor(context),
                ),
                const SizedBox(height: 14),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.calendar_view_week_outlined),
                      label: Text('Week'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.calendar_month_outlined),
                      label: Text('Month'),
                    ),
                  ],
                  selected: {state.shoppingMonthView},
                  onSelectionChanged: (values) =>
                      state.setShoppingMonthView(values.first),
                ),
                if (state.shoppingMonthView)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Month view combines shelf-stable, frozen and household products. Fresh food remains in weekly lists.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (!state.shoppingMonthView)
                  _WeekSelector(
                  selectedWeek: week,
                  weeks: state.shoppingWeeksInSelectedMonth,
                  itemCountForWeek: (value) =>
                      state.shoppingItemsForWeek(value).length,
                  onSelected: state.selectShoppingWeek,
                ),
                const SizedBox(height: 13),
                TextField(
                  onChanged: (value) =>
                      setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search products',
                  ),
                ),
                const SizedBox(height: 18),
                if (allItems.isEmpty)
                  _EmptyShopping(
                    hasPlan:
                        state.monthlyMealPlan.entries.isNotEmpty,
                    onAdd: () => _showItemEditor(context),
                  )
                else ...[
                  ...groups.entries.map(
                    (entry) => _ShoppingSection(
                      title: entry.key,
                      items: entry.value,
                      onOpen: (item) =>
                          _showItemEditor(context, existing: item),
                      onDelete: (item) =>
                          _deleteWithUndo(context, item),
                    ),
                  ),
                  if (purchased.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _PurchasedSection(
                      items: purchased,
                      onOpen: (item) =>
                          _showItemEditor(context, existing: item),
                      onDelete: (item) =>
                          _deleteWithUndo(context, item),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    ShoppingItem item,
  ) async {
    final state = AppScope.of(context);
    await state.removeShoppingItem(item.key);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => state.restoreShoppingItem(item.key),
          ),
        ),
      );
  }

  Future<void> _showItemEditor(
    BuildContext context, {
    ShoppingItem? existing,
  }) async {
    final state = AppScope.of(context);
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final quantityController = TextEditingController(
      text: existing == null
          ? '1'
          : _quantity(existing.quantity),
    );
    final priceController = TextEditingController(
      text: existing == null
          ? '1.00'
          : existing.estimatedUnitPrice.toStringAsFixed(2),
    );

    var unit = existing?.unit ?? 'each';
    var category = existing?.category ?? 'Pantry';
    var week = existing?.week ?? state.selectedShoppingWeek;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                MediaQuery.viewInsetsOf(context).bottom + 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null
                          ? 'Add product'
                          : 'Product details',
                      style:
                          Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameController,
                      autofocus: existing == null,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                _shoppingUnits.contains(unit)
                                    ? unit
                                    : 'each',
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: _shoppingUnits
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setModalState(() => unit = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _shoppingCategories.contains(category)
                              ? category
                              : 'Other',
                      decoration: const InputDecoration(
                        labelText: 'Aisle / category',
                      ),
                      items: _shoppingCategories
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: week,
                      decoration: const InputDecoration(
                        labelText: 'Shopping week',
                      ),
                      items: List.generate(
                        state.shoppingWeeksInSelectedMonth,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Week ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => week = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Estimated unit price',
                        prefixText: '€ ',
                      ),
                    ),
                    if (existing != null) ...[
                      const SizedBox(height: 10),
                      Card(
                        color: AppColors.surfaceElevated,
                        child: ListTile(
                          leading: const Icon(
                            Icons.calculate_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text('Estimated item total'),
                          subtitle: Text(
                            '${_quantity(existing.quantity)} ${existing.unit} × '
                            '€${existing.estimatedUnitPrice.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            '€${existing.estimatedTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (existing != null &&
                        existing.recipeNames.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'USED IN',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: existing.recipeNames
                            .map(
                              (name) => Chip(label: Text(name)),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final quantity = double.tryParse(
                            quantityController.text
                                .replaceAll(',', '.'),
                          );
                          final price = double.tryParse(
                                priceController.text
                                    .replaceAll(',', '.'),
                              ) ??
                              1;

                          if (name.isEmpty ||
                              quantity == null ||
                              quantity <= 0) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter a product and valid quantity.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (existing == null) {
                            await state.addManualShoppingItem(
                              name: name,
                              quantity: quantity,
                              unit: unit,
                              category: category,
                              week: week,
                              estimatedUnitPrice: price,
                            );
                          } else {
                            await state.updateShoppingItem(
                              existing.copyWith(
                                name: name,
                                quantity: quantity,
                                unit: unit,
                                category: category,
                                week: week,
                                estimatedUnitPrice: price,
                              ),
                            );
                          }

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        child: Text(
                          existing == null
                              ? 'Add to shopping list'
                              : 'Save changes',
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

    // These controllers belong to the modal editor. Flutter can still
    // rebuild the route briefly while the keyboard and sheet complete
    // their closing animations, so disposing them here can cause a
    // TextEditingController-used-after-dispose red screen.
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

    if (match != null) {
      state.purchaseShoppingItem(
        item: match,
        location: result.location,
        expiryDate: DateTime.now().add(
          Duration(days: result.suggestedShelfLifeDays),
        ),
        barcode: result.barcode,
      );
      if (!state.isShoppingChecked(match.key)) {
        state.toggleShoppingChecked(match.key);
      }
    } else {
      await state.addManualShoppingItem(
        name: result.name,
        quantity: result.defaultQuantity,
        unit: result.defaultUnit,
        category: 'Other',
        week: state.selectedShoppingWeek,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          match == null
              ? '${result.name} added to Shopping.'
              : '${result.name} purchased and added to Pantry.',
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.week,
    required this.remaining,
    required this.purchased,
    required this.estimatedTotal,
    required this.remainingEstimatedTotal,
    required this.weeklyBudget,
    required this.onScan,
    required this.onAdd,
  });

  final int week;
  final int remaining;
  final int purchased;
  final double estimatedTotal;
  final double remainingEstimatedTotal;
  final double weeklyBudget;
  final VoidCallback onScan;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final overBudget = estimatedTotal > weeklyBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shopping list',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '${week == 0 ? 'Month' : 'Week $week'} · '
          '$remaining remaining · $purchased purchased',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            ),
            const SizedBox(width: 9),
            OutlinedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Remaining',
                    value: '$remaining',
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Still to buy',
                    value:
                        '€${remainingEstimatedTotal.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Full list',
                    value:
                        '€${estimatedTotal.toStringAsFixed(2)}',
                    warning: overBudget,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Purchased',
                    value: '$purchased',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color:
                warning ? AppColors.danger : AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
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
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
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

class _ShoppingSection extends StatelessWidget {
  const _ShoppingSection({
    required this.title,
    required this.items,
    required this.onOpen,
    required this.onDelete,
  });

  final String title;
  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onOpen;
  final ValueChanged<ShoppingItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => _ShoppingItemRow(
              item: item,
              onOpen: () => onOpen(item),
              onDelete: () => onDelete(item),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchasedSection extends StatelessWidget {
  const _PurchasedSection({
    required this.items,
    required this.onOpen,
    required this.onDelete,
  });

  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onOpen;
  final ValueChanged<ShoppingItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Purchased (${items.length})',
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w900,
        ),
      ),
      children: items
          .map(
            (item) => _ShoppingItemRow(
              item: item,
              onOpen: () => onOpen(item),
              onDelete: () => onDelete(item),
            ),
          )
          .toList(),
    );
  }
}

class _ShoppingItemRow extends StatelessWidget {
  const _ShoppingItemRow({
    required this.item,
    required this.onOpen,
    required this.onDelete,
  });

  final ShoppingItem item;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final purchased = state.isShoppingChecked(item.key);
    final step = state.shoppingQuantityStep(item);

    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
            child: Row(
              children: [
                Checkbox(
                  value: purchased,
                  onChanged: (value) =>
                      state.setShoppingPurchased(
                    item,
                    value ?? false,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: purchased
                                    ? AppColors.subtle
                                    : AppColors.text,
                                fontWeight: FontWeight.w900,
                                decoration: purchased
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (item.manual)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.edit_note,
                                size: 16,
                                color: AppColors.muted,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '€${item.estimatedTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: purchased
                                  ? AppColors.subtle
                                  : AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            enabled: item.quantity > step,
                            onPressed: () =>
                                state.changeShoppingQuantity(
                              item,
                              -step,
                            ),
                          ),
                          InkWell(
                            onTap: onOpen,
                            borderRadius:
                                BorderRadius.circular(10),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                _quantity(item.quantity),
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onPressed: () =>
                                state.changeShoppingQuantity(
                              item,
                              step,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: onOpen,
                            borderRadius:
                                BorderRadius.circular(10),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: .1),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.unit,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.subtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: enabled ? onPressed : null,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
    );
  }
}

class _EmptyShopping extends StatelessWidget {
  const _EmptyShopping({
    required this.hasPlan,
    required this.onAdd,
  });

  final bool hasPlan;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              hasPlan
                  ? Icons.shopping_cart_checkout_outlined
                  : Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              hasPlan
                  ? 'Nothing to buy this week'
                  : 'Create a monthly plan or add a product',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasPlan
                  ? 'Your Pantry may already cover the planned meals.'
                  : 'Manual products can include groceries or household supplies.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Fruit & Vegetables':
      return Icons.eco_outlined;
    case 'Meat & Fish':
      return Icons.set_meal_outlined;
    case 'Dairy & Chilled':
      return Icons.local_drink_outlined;
    case 'Bakery':
      return Icons.bakery_dining_outlined;
    case 'Frozen':
      return Icons.ac_unit_outlined;
    case 'Household':
      return Icons.cleaning_services_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

String _quantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(
        RegExp(r'\.?0+$'),
        '',
      );
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
