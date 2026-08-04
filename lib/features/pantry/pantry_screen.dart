import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
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
                  lowStock: state.lowStockItems.length,
                  onInsights: () =>
                      openInventoryIntelligence(context),
                  onExpiry: () =>
                      openExpiryIntelligence(context),
                  onAdd: () => _showItemEditor(context),
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
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const _EmptyPantry()
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _PantryProductCard(
                        item: item,
                        onEdit: () => _showItemEditor(
                          context,
                          existing: item,
                        ),
                        onUse: () {
                          state.markPantryItemUsed(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item.name} marked as used.',
                              ),
                            ),
                          );
                        },
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

  Future<void> _showItemEditor(
    BuildContext context, {
    PantryItem? existing,
  }) async {
    final state = AppScope.of(context);
    final nameController = TextEditingController(
      text: existing?.name ?? '',
    );
    final quantityController = TextEditingController(
      text: existing == null
          ? '1'
          : _formatQuantity(existing.quantity),
    );
    final unitController = TextEditingController(
      text: existing?.unit ?? 'each',
    );
    var location =
        existing?.location ?? StorageLocation.pantry;
    DateTime? expiryDate = existing?.expiryDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
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
                      items: StorageLocation.values.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        );
                      }).toList(),
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
                            initialDate: expiryDate ?? DateTime.now(),
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
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                          ),
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

    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}

class _PantryHeader extends StatelessWidget {
  const _PantryHeader({
    required this.count,
    required this.health,
    required this.expiring,
    required this.lowStock,
    required this.onInsights,
    required this.onExpiry,
    required this.onAdd,
  });

  final int count;
  final int health;
  final int expiring;
  final int lowStock;
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
                    'Pantry',
                    style:
                        Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Everything stored in this kitchen',
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
          child: Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      '$count products stored',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          icon: Icons.inventory_2_outlined,
                          text: '$lowStock low stock',
                          warning: lowStock > 0,
                          onTap: onInsights,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
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

class _PantryProductCard extends StatelessWidget {
  const _PantryProductCard({
    required this.item,
    required this.onEdit,
    required this.onUse,
  });

  final PantryItem item;
  final VoidCallback onEdit;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry(DateTime.now());
    final urgency = _urgency(days);
    final progress = _quantityProgress(item);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: urgency.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    _iconFor(item.name),
                    color: urgency.color,
                    size: 27,
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
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatQuantity(item.quantity)} ${item.unit}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'use') onUse();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'use',
                      child: Text('Mark as used'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _ProductBadge(
                  icon: Icons.place_outlined,
                  text: item.location.label,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ProductBadge(
                    icon: urgency.icon,
                    text: urgency.text,
                    color: urgency.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static _Urgency _urgency(int? days) {
    if (days == null) {
      return const _Urgency(
        text: 'No expiry date',
        color: AppColors.muted,
        icon: Icons.event_available_outlined,
      );
    }
    if (days < 0) {
      return _Urgency(
        text:
            'Expired ${days.abs()} day${days.abs() == 1 ? '' : 's'} ago',
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

  static double _quantityProgress(PantryItem item) {
    final unit = item.unit.toLowerCase();
    double maxValue;
    if (unit == 'kg' || unit == 'l') {
      maxValue = 2;
    } else if (unit == 'g' || unit == 'ml') {
      maxValue = 1000;
    } else {
      maxValue = 10;
    }
    return (item.quantity / maxValue).clamp(0.05, 1.0);
  }

  static IconData _iconFor(String name) {
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
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPantry extends StatelessWidget {
  const _EmptyPantry();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.kitchen_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No pantry products found',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
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

String _formatQuantity(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
