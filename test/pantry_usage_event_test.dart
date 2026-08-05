import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/models/pantry_usage_event.dart';

void main() {
  test('Pantry usage event serializes consumption and waste', () {
    final event = PantryUsageEvent(
      id: '1',
      itemName: 'Apple',
      quantity: 2,
      unit: 'each',
      type: PantryUsageType.wasted,
      createdAt: DateTime(2026, 8, 5),
    );

    final restored = PantryUsageEvent.fromJson(event.toJson());

    expect(restored.itemName, 'Apple');
    expect(restored.quantity, 2);
    expect(restored.type, PantryUsageType.wasted);
  });
}
