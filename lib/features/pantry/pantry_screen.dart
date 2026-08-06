import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/services/pantry_intelligence_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';
import '../expiry/expiry_screen.dart';
import '../inventory/inventory_intelligence_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String query = '';
  StorageLocation? selectedLocation;
  String sortMode = 'Attention';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final now = DateTime.now();

    final filtered = state.pantryItems.where((item) {
      final matchesQuery = item.name
          .toLowerCase()
          .contains(query.trim().toLowerCase());
      final matchesLocation =
          selectedLocation == null || item.location == selectedLocation;
      return matchesQuery && matchesLocation;
    }).toList()
      ..sort((a, b) {
        if (sortMode == 'Name') {
          return a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              );
        }
        if (sortMode == 'Location') {
          final location = a.location.label.compareTo(
            b.location.label,
          );
          if (location != 0) return location;
          return a.name.compareTo(b.name);
        }
        if (sortMode == 'Expiry') {
          final aDays = a.daysUntilExpiry(now) ?? 9999;
          final bDays = b.daysUntilExpiry(now) ?? 9999;
          return aDays.compareTo(bDays);
        }

        final aInsight = state.pantryInsightFor(a);
        final bInsight = state.pantryInsightFor(b);

        if (aInsight.wasteRisk != bInsight.wasteRisk) {
          return aInsight.wasteRisk ? -1 : 1;
        }
        if (aInsight.lowStock != bInsight.lowStock) {
          return aInsight.lowStock ? -1 : 1;
        }

        final aDays = a.daysUntilExpiry(now) ?? 9999;
        final bDays = b.daysUntilExpiry(now) ?? 9999;
        return aDays.compareTo(bDays);
      });

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
                _PantryHeader(
                  count: state.pantryCount,
                  health: state.pantryHealthScore,
                  expiring: state.useSoonItems.length,
                  lowStock: state.restockSuggestedItems.length,
                  wasteRisk: state.wasteRiskItems.length,
                  coveredUses: state.pantryCoveredPlanUses,
                  estimatedWaste: state.estimatedWasteValue,
                  onInsights: () =>
                      openInventoryIntelligence(context),
                  onExpiry: () =>
                      openExpiryIntelligence(context),
                  onAdd: () => _showItemEditor(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.wasteRiskItems.isNotEmpty)
                  _AttentionCard(
                    title: 'Use these products soon',
                    message:
                        '${state.wasteRiskItems.length} product${state.wasteRiskItems.length == 1 ? '' : 's'} '
                        'may expire before the monthly plan uses them.',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    items: state.wasteRiskItems
                        .take(3)
                        .map((item) => item.name)
                        .join(' · '),
                  ),
                if (state.wasteRiskItems.isNotEmpty)
                  const SizedBox(height: AppSpacing.sm),
                if (state.restockSuggestedItems.isNotEmpty)
                  _AttentionCard(
                    title: 'Smart restock suggestions',
                    message:
                        '${state.restockSuggestedItems.length} product${state.restockSuggestedItems.length == 1 ? '' : 's'} '
                        'are predicted to run low.',
                    icon: Icons.add_shopping_cart,
                    color: AppColors.terracotta,
                    items: state.restockSuggestedItems
                        .take(3)
                        .map((item) => item.name)
                        .join(' · '),
                  ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  onChanged: (value) =>
                      setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search pantry products',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        selected: selectedLocation == null,
                        onSelected: (_) =>
                            setState(() => selectedLocation = null),
                        label: const Text('All'),
                      ),
                      const SizedBox(width: 8),
                      ...StorageLocation.values.map(
                        (location) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected:
                                selectedLocation == location,
                            onSelected: (_) => setState(
                              () => selectedLocation = location,
                            ),
                            label: Text(location.label),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${filtered.length} product${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: sortMode,
                      items: const [
                        DropdownMenuItem(
                          value: 'Attention',
                          child: Text('Needs attention'),
                        ),
                        DropdownMenuItem(
                          value: 'Expiry',
                          child: Text('Expiry'),
                        ),
                        DropdownMenuItem(
                          value: 'Name',
                          child: Text('Name'),
                        ),
                        DropdownMenuItem(
                          value: 'Location',
                          child: Text('Location'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => sortMode = value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (filtered.isEmpty)
                  const _EmptyPantry()
                else
                  ...filtered.map(
                    (item) => _CompactPantryRow(
                      item: item,
                      insight: state.pantryInsightFor(item),
                      onOpen: () => _showPantryDetails(
                        context,
                        item,
                      ),
                      onDelete: () =>
                          _deletePantryWithUndo(context, item),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePantryWithUndo(
    BuildContext context,
    PantryItem item,
  ) async {
    final state = AppScope.of(context);
    state.removePantryItem(item.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} removed from Pantry'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => state.restorePantryItem(item),
          ),
        ),
      );
  }

  Future<void> _showPantryDetails(
    BuildContext context,
    PantryItem item,
  ) async {
    final state = AppScope.of(context);
    final insight = state.pantryInsightFor(item);
    final days = item.daysUntilExpiry(DateTime.now());
    final urgency = _urgency(days);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: urgency.color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _iconFor(item.name),
                        color: urgency.color,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium,
                          ),
                          Text(
                            '${_formatQuantity(item.quantity)} '
                            '${item.unit} · ${item.location.label}',
                            style: const TextStyle(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  color: AppColors.surfaceElevated,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.event_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Expiry'),
                        trailing: Text(
                          urgency.text,
                          style: TextStyle(
                            color: urgency.color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.primary,
                        ),
                        title: const Text('Planned uses'),
                        trailing: Text(
                          '${insight.plannedUses}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.timelapse_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Estimated stock'),
                        trailing: Text(
                          '~${insight.estimatedDaysRemaining} days',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showConsumeDialog(context, item);
                        },
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Use some'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showItemEditor(
                            context,
                            existing: item,
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (insight.lowStock)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await state
                            .addSuggestedRestockToShopping(item);
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.name} added to Shopping.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Shopping'),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmWaste(context, item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Record as waste'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showConsumeDialog(
    BuildContext context,
    PantryItem item,
  ) async {
    final state = AppScope.of(context);
    final controller = TextEditingController(
      text: _defaultUsage(item).toString(),
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Use ${item.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantity used',
            suffixText: item.unit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(
                controller.text.replaceAll(',', '.'),
              ),
            ),
            child: const Text('Record use'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (amount != null && amount > 0) {
      await state.consumePantryItem(item.id, quantity: amount);
    }
  }

  Future<void> _confirmWaste(
    BuildContext context,
    PantryItem item,
  ) async {
    final state = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record food waste?'),
        content: Text(
          '${item.name} will be removed from the Pantry and recorded '
          'in the usage history as wasted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Record waste'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await state.markPantryItemWasted(item.id);
    }
  }

  Future<void> _showItemEditor(
    BuildContext context, {
    PantryItem? existing,
  }) async {
    final state = AppScope.of(context);
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final quantityController = TextEditingController(
      text: existing == null
          ? '1'
          : _formatQuantity(existing.quantity),
    );
    final unitController =
        TextEditingController(text: existing?.unit ?? 'each');
    var location =
        existing?.location ?? StorageLocation.pantry;
    DateTime? expiryDate = existing?.expiryDate;

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
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                MediaQuery.viewInsetsOf(context).bottom +
                    AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null
                          ? 'Add pantry product'
                          : 'Edit pantry product',
                      style:
                          Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: nameController,
                      autofocus: existing == null,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<StorageLocation>(
                      initialValue: location,
                      decoration: const InputDecoration(
                        labelText: 'Storage location',
                      ),
                      items: StorageLocation.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => location = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      color: AppColors.surfaceElevated,
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Expiry date'),
                        subtitle: Text(
                          expiryDate == null
                              ? 'Not set'
                              : _formatDate(expiryDate!),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate:
                                expiryDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (selected != null) {
                            setModalState(
                              () => expiryDate = selected,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final name =
                              nameController.text.trim();
                          final quantity = double.tryParse(
                            quantityController.text
                                .replaceAll(',', '.'),
                          );
                          final unit =
                              unitController.text.trim();

                          if (name.isEmpty ||
                              quantity == null ||
                              quantity < 0 ||
                              unit.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter a valid product, quantity and unit.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (existing == null) {
                            state.addPantryItem(
                              name: name,
                              quantity: quantity,
                              unit: unit,
                              location: location,
                              expiryDate: expiryDate,
                            );
                          } else {
                            state.updatePantryItem(
                              existing.copyWith(
                                name: name,
                                quantity: quantity,
                                unit: unit,
                                location: location,
                                expiryDate: expiryDate,
                              ),
                            );
                          }

                          Navigator.pop(sheetContext);
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 15),
                          child: Text('Save product'),
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

    // Keep modal controllers alive through the route-close animation.
  }
}

class _PantryHeader extends StatelessWidget {
  const _PantryHeader({
    required this.count,
    required this.health,
    required this.expiring,
    required this.lowStock,
    required this.wasteRisk,
    required this.coveredUses,
    required this.estimatedWaste,
    required this.onInsights,
    required this.onExpiry,
    required this.onAdd,
  });

  final int count;
  final int health;
  final int expiring;
  final int lowStock;
  final int wasteRisk;
  final int coveredUses;
  final double estimatedWaste;
  final VoidCallback onInsights;
  final VoidCallback onExpiry;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
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
                    'Pantry intelligence',
                    style:
                        Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Stock predictions, planned demand and waste risk',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: onInsights,
              tooltip: 'Inventory intelligence',
              icon: const Icon(Icons.insights_outlined),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              onPressed: onAdd,
              tooltip: 'Add product',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF213827),
                Color(0xFF17251C),
              ],
            ),
            borderRadius:
                BorderRadius.circular(AppRadius.hero),
            border: Border.all(
              color: const Color(0xFF39513E),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: health / 100,
                          strokeWidth: 8,
                        ),
                        Center(
                          child: Text(
                            '$health%',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PANTRY HEALTH',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .9,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '$count products · $coveredUses planned uses',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Potential waste: €${estimatedWaste.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    icon: Icons.event_busy_outlined,
                    text: '$expiring expiring',
                    warning: expiring > 0,
                    onTap: onExpiry,
                  ),
                  _StatusPill(
                    icon: Icons.add_shopping_cart,
                    text: '$lowStock restock',
                    warning: lowStock > 0,
                    onTap: onInsights,
                  ),
                  _StatusPill(
                    icon: Icons.delete_outline,
                    text: '$wasteRisk waste risk',
                    warning: wasteRisk > 0,
                    onTap: onExpiry,
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

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      items,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.text,
    required this.warning,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final bool warning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        warning ? AppColors.warning : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: color.withValues(alpha: .24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactPantryRow extends StatelessWidget {
  const _CompactPantryRow({
    required this.item,
    required this.insight,
    required this.onOpen,
    required this.onDelete,
  });

  final PantryItem item;
  final PantryItemInsight insight;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry(DateTime.now());
    final urgency = _urgency(days);
    final status = insight.lowStock
        ? 'LOW'
        : insight.wasteRisk
            ? 'AT RISK'
            : days != null && days <= 3
                ? 'EXPIRING'
                : '';

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 7),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.fromLTRB(
            12,
            5,
            10,
            5,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: urgency.color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(item.name),
              color: urgency.color,
              size: 21,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${_formatQuantity(item.quantity)} ${item.unit}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  '${item.location.label} · ${urgency.text}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: urgency.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: urgency.color,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.subtle,
          ),
          onTap: onOpen,
        ),
      ),
    );
  }
}

class _EmptyPantry extends StatelessWidget {
  const _EmptyPantry();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.kitchen_outlined,
              color: AppColors.primary,
              size: 42,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No pantry products found',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Add products or change the active filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Urgency {
  const _Urgency({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;
}

_Urgency _urgency(int? days) {
  if (days == null) {
    return const _Urgency(
      text: 'No expiry date',
      color: AppColors.muted,
      icon: Icons.event_available_outlined,
    );
  }
  if (days < 0) {
    return _Urgency(
      text: 'Expired ${days.abs()} day${days.abs() == 1 ? '' : 's'} ago',
      color: AppColors.danger,
      icon: Icons.warning_amber_rounded,
    );
  }
  if (days == 0) {
    return const _Urgency(
      text: 'Expires today',
      color: AppColors.danger,
      icon: Icons.warning_amber_rounded,
    );
  }
  if (days <= 3) {
    return _Urgency(
      text: 'Expires in $days days',
      color: AppColors.warning,
      icon: Icons.schedule_outlined,
    );
  }
  return _Urgency(
    text: 'Fresh for $days days',
    color: AppColors.primary,
    icon: Icons.eco_outlined,
  );
}

IconData _iconFor(String name) {
  final key = name.toLowerCase();
  if (key.contains('milk') ||
      key.contains('cheese') ||
      key.contains('yogurt')) {
    return Icons.local_drink_outlined;
  }
  if (key.contains('chicken') ||
      key.contains('beef') ||
      key.contains('fish')) {
    return Icons.set_meal_outlined;
  }
  if (key.contains('apple') ||
      key.contains('tomato') ||
      key.contains('onion') ||
      key.contains('potato') ||
      key.contains('lemon')) {
    return Icons.eco_outlined;
  }
  if (key.contains('bread')) {
    return Icons.bakery_dining_outlined;
  }
  return Icons.inventory_2_outlined;
}

double _defaultUsage(PantryItem item) {
  final unit = item.unit.toLowerCase();
  if (unit == 'kg' || unit == 'l') return 0.25;
  if (unit == 'g' || unit == 'ml') return 100;
  return 1;
}

String _formatQuantity(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
