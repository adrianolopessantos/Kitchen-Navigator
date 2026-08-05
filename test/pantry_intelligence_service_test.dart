import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/pantry_intelligence_service.dart';
import 'package:kitchen_navigator/models/pantry_item.dart';
import 'package:kitchen_navigator/models/pantry_usage_event.dart';

void main() {
  test('Pantry intelligence predicts days from recent use', () {
    final now = DateTime(2026, 8, 5);
    final insight = PantryIntelligenceService.analyze(
      item: PantryItem(
        id: 'milk',
        name: 'Milk',
        quantity: 2,
        unit: 'L',
        location: StorageLocation.fridge,
        expiryDate: DateTime(2026, 8, 10),
      ),
      usageEvents: [
        PantryUsageEvent(
          id: '1',
          itemName: 'Milk',
          quantity: 3,
          unit: 'L',
          type: PantryUsageType.consumed,
          createdAt: DateTime(2026, 7, 20),
        ),
      ],
      plannedUses: 2,
      minimumStock: .5,
      now: now,
    );

    expect(insight.estimatedDaysRemaining, 20);
    expect(insight.plannedUses, 2);
    expect(insight.wasteRisk, isFalse);
  });

  test('Expiring unused item is marked as waste risk', () {
    final insight = PantryIntelligenceService.analyze(
      item: PantryItem(
        id: 'yogurt',
        name: 'Yogurt',
        quantity: 4,
        unit: 'each',
        location: StorageLocation.fridge,
        expiryDate: DateTime(2026, 8, 6),
      ),
      usageEvents: const [],
      plannedUses: 0,
      minimumStock: 1,
      now: DateTime(2026, 8, 5),
    );

    expect(insight.wasteRisk, isTrue);
  });

  test('Low stock produces a restock quantity', () {
    final insight = PantryIntelligenceService.analyze(
      item: const PantryItem(
        id: 'eggs',
        name: 'Eggs',
        quantity: 2,
        unit: 'each',
        location: StorageLocation.fridge,
      ),
      usageEvents: const [],
      plannedUses: 3,
      minimumStock: 4,
      now: DateTime(2026, 8, 5),
    );

    expect(insight.lowStock, isTrue);
    expect(insight.recommendedRestockQuantity, 6);
  });
}
