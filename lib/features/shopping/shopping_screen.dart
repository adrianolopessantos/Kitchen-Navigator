import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';

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
    final allItems = state.shoppingItems;
    final filtered = allItems.where((item) {
      return item.name.toLowerCase().contains(
            query.trim().toLowerCase(),
          );
    }).toList();

    final checkedCount = allItems.where((item) {
      return state.isShoppingChecked(item.key);
    }).length;
    final progress = allItems.isEmpty
        ? 0.0
        : checkedCount / allItems.length;

    final grouped = <String, List<ShoppingItem>>{};
    for (final item in filtered) {
      grouped.putIfAbsent(item.category, () => []).add(item);
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
                _ShoppingHeader(
                  itemCount: allItems.length,
                  checkedCount: checkedCount,
                  progress: progress,
                  estimatedTotal:
                      state.estimatedShoppingTotal,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  onChanged: (value) =>
                      setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search shopping list',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const _EmptyShopping()
                else
                  ...grouped.entries.map(
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
}

class _ShoppingHeader extends StatelessWidget {
  const _ShoppingHeader({
    required this.itemCount,
    required this.checkedCount,
    required this.progress,
    required this.estimatedTotal,
  });

  final int itemCount;
  final int checkedCount;
  final double progress;
  final double estimatedTotal;

  @override
  Widget build(BuildContext context) {
    final remaining = itemCount - checkedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shopping',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        const Text(
          'Grouped by aisle and ready to check off',
          style: TextStyle(color: AppColors.muted),
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
                          '$remaining item${remaining == 1 ? '' : 's'} remaining',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 21,
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
                    style: const TextStyle(
                      color: AppColors.terracotta,
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
            ],
          ),
        ),
      ],
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
                    key: ValueKey('$title-${item.key}'),
                    direction: DismissDirection.startToEnd,
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
                    confirmDismiss: (_) async {
                      state.toggleShoppingChecked(item.key);
                      return false;
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 180),
                      color: checked
                          ? AppColors.primary
                              .withValues(alpha: .06)
                          : Colors.transparent,
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
                          '${_formatQuantity(item.quantity)} ${item.unit} · '
                          '€${item.estimatedTotal.toStringAsFixed(2)}'
                          '${item.recipeNames.isEmpty ? '' : ' · ${item.recipeNames.join(', ')}'}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                        controlAffinity:
                            ListTileControlAffinity.trailing,
                      ),
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

class _EmptyShopping extends StatelessWidget {
  const _EmptyShopping();

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
                Icons.shopping_cart_checkout_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Shopping list complete',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Missing ingredients from planned meals will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
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

String _formatQuantity(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
