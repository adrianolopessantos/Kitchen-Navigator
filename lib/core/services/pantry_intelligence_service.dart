import '../../models/pantry_item.dart';
import '../../models/pantry_usage_event.dart';

class PantryItemInsight {
  const PantryItemInsight({
    required this.estimatedDaysRemaining,
    required this.plannedUses,
    required this.lowStock,
    required this.wasteRisk,
    required this.recommendedRestockQuantity,
  });

  final int estimatedDaysRemaining;
  final int plannedUses;
  final bool lowStock;
  final bool wasteRisk;
  final double recommendedRestockQuantity;
}

abstract final class PantryIntelligenceService {
  static PantryItemInsight analyze({
    required PantryItem item,
    required List<PantryUsageEvent> usageEvents,
    required int plannedUses,
    required double minimumStock,
    required DateTime now,
  }) {
    final normalizedName = normalize(item.name);
    final cutoff = now.subtract(const Duration(days: 30));

    final recentConsumption = usageEvents
        .where(
          (event) =>
              normalize(event.itemName) == normalizedName &&
              event.type == PantryUsageType.consumed &&
              !event.createdAt.isBefore(cutoff),
        )
        .fold<double>(0, (total, event) => total + event.quantity);

    final dailyConsumption = recentConsumption > 0
        ? recentConsumption / 30
        : _fallbackDailyConsumption(item, minimumStock);

    final estimatedDays = dailyConsumption <= 0
        ? 90
        : (item.quantity / dailyConsumption).round().clamp(0, 90);

    final expiryDays = item.daysUntilExpiry(now);
    final wasteRisk = expiryDays != null &&
        expiryDays <= 3 &&
        item.quantity > 0 &&
        plannedUses == 0;

    final lowStock = item.quantity <= minimumStock;
    final target = minimumStock * 2;
    final restock = lowStock
    ? (target - item.quantity).clamp(0.0, target).toDouble()
    : 0.0;

    return PantryItemInsight(
      estimatedDaysRemaining: estimatedDays,
      plannedUses: plannedUses,
      lowStock: lowStock,
      wasteRisk: wasteRisk,
      recommendedRestockQuantity: restock,
    );
  }

  static double _fallbackDailyConsumption(
    PantryItem item,
    double minimumStock,
  ) {
    if (minimumStock <= 0) return 0;
    return minimumStock / 7;
  }

  static String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
