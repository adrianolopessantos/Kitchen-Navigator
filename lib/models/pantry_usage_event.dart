enum PantryUsageType { consumed, wasted, adjusted }

class PantryUsageEvent {
  const PantryUsageEvent({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String itemName;
  final double quantity;
  final String unit;
  final PantryUsageType type;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PantryUsageEvent.fromJson(Map<String, dynamic> json) {
    return PantryUsageEvent(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      itemName: json['itemName'] as String? ?? 'Product',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'each',
      type: PantryUsageType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => PantryUsageType.consumed,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
