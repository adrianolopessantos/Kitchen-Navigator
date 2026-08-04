enum StorageLocation { pantry, fridge, freezer }

extension StorageLocationLabel on StorageLocation {
  String get label {
    switch (this) {
      case StorageLocation.pantry:
        return 'Pantry';
      case StorageLocation.fridge:
        return 'Fridge';
      case StorageLocation.freezer:
        return 'Freezer';
    }
  }
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.location,
    this.expiryDate,
    this.barcode,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final StorageLocation location;
  final DateTime? expiryDate;
  final String? barcode;

  PantryItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    StorageLocation? location,
    DateTime? expiryDate,
    String? barcode,
    bool clearExpiry = false,
  }) {
    return PantryItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      expiryDate: clearExpiry ? null : (expiryDate ?? this.expiryDate),
      barcode: barcode ?? this.barcode,
    );
  }

  int? daysUntilExpiry(DateTime now) {
    if (expiryDate == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );
    return expiry.difference(today).inDays;
  }
}
