import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';
import '../../models/recipe.dart';

class ExpiryScreen extends StatelessWidget {
  const ExpiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Expiry Intelligence')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            const Text(
              'Use food before it is wasted',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Products are ordered by urgency, with recipes that use them first.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _SummaryCard(
                  value: '${state.expiredItems.length}',
                  label: 'Expired',
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  value: '${state.expiresTodayItems.length}',
                  label: 'Today',
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  value: '${state.expiresThisWeekItems.length + state.expiresTomorrowItems.length}',
                  label: 'This week',
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (state.useSoonItems.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 42,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No urgent expiry items',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Products expiring within seven days will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _ExpirySection(
                title: 'EXPIRED',
                color: AppColors.danger,
                items: state.expiredItems,
              ),
              _ExpirySection(
                title: 'USE TODAY',
                color: AppColors.danger,
                items: state.expiresTodayItems,
              ),
              _ExpirySection(
                title: 'TOMORROW',
                color: AppColors.warning,
                items: state.expiresTomorrowItems,
              ),
              _ExpirySection(
                title: 'THIS WEEK',
                color: AppColors.warning,
                items: state.expiresThisWeekItems,
              ),
            ],
            const SizedBox(height: 18),
            const Text(
              'RECIPES TO USE FOOD SOON',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 9),
            if (state.useSoonRecipeSuggestions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'No matching recipes yet. More suggestions will appear as the recipe library grows.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...state.useSoonRecipeSuggestions.take(6).map(
                    (recipe) => _RecipeSuggestionCard(recipe: recipe),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ExpirySection extends StatelessWidget {
  const _ExpirySection({
    required this.title,
    required this.color,
    required this.items,
  });

  final String title;
  final Color color;
  final List<PantryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _ExpiryItemCard(item: item)),
        ],
      ),
    );
  }
}

class _ExpiryItemCard extends StatelessWidget {
  const _ExpiryItemCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final days = item.daysUntilExpiry(DateTime.now()) ?? 999;
    final recipes = state.recipesForPantryItem(item);

    final Color urgencyColor;
    final String urgencyText;

    if (days < 0) {
      urgencyColor = AppColors.danger;
      urgencyText =
          'Expired ${days.abs()} day${days.abs() == 1 ? '' : 's'} ago';
    } else if (days == 0) {
      urgencyColor = AppColors.danger;
      urgencyText = 'Use today';
    } else if (days == 1) {
      urgencyColor = AppColors.warning;
      urgencyText = 'Use tomorrow';
    } else {
      urgencyColor = AppColors.warning;
      urgencyText = 'Use within $days days';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    days < 0
                        ? Icons.warning_amber_rounded
                        : Icons.schedule_outlined,
                    color: urgencyColor,
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
                        '${_formatQuantity(item.quantity)} ${item.unit} · ${item.location.label}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        urgencyText,
                        style: TextStyle(
                          color: urgencyColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    state.markPantryItemUsed(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} marked as used.')),
                    );
                  },
                  child: const Text('Used'),
                ),
              ],
            ),
            if (recipes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Try: ${recipes.take(3).map((recipe) => recipe.name).join(' · ')}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatQuantity(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _RecipeSuggestionCard extends StatelessWidget {
  const _RecipeSuggestionCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final matches = state.expiringIngredientMatches(recipe);
    final minutes = (recipe.totalSeconds / 60).ceil();

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF243321),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          recipe.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '$minutes min · Uses $matches expiring ingredient${matches == 1 ? '' : 's'}',
          style: const TextStyle(color: AppColors.muted),
        ),
        trailing: const Icon(Icons.chevron_right),
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
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.all(10),
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
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openExpiryIntelligence(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const ExpiryScreen()),
  );
}
