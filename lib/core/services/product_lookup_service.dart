import '../../models/pantry_item.dart';

class ProductLookupResult {
  const ProductLookupResult({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.defaultQuantity,
    required this.defaultUnit,
    required this.location,
    required this.suggestedShelfLifeDays,
    this.imageUrl,
  });

  final String barcode;
  final String name;
  final String brand;
  final String category;
  final double defaultQuantity;
  final String defaultUnit;
  final StorageLocation location;
  final int suggestedShelfLifeDays;
  final String? imageUrl;
}

abstract final class ProductLookupService {
  static const Map<String, ProductLookupResult> _catalog = {
    '5000112637922': ProductLookupResult(
      barcode: '5000112637922',
      name: 'Semi-skimmed Milk',
      brand: 'Sample Dairy',
      category: 'Dairy',
      defaultQuantity: 1,
      defaultUnit: 'L',
      location: StorageLocation.fridge,
      suggestedShelfLifeDays: 7,
    ),
    '5449000000996': ProductLookupResult(
      barcode: '5449000000996',
      name: 'Sparkling Soft Drink',
      brand: 'Sample Brand',
      category: 'Drinks',
      defaultQuantity: 1.5,
      defaultUnit: 'L',
      location: StorageLocation.pantry,
      suggestedShelfLifeDays: 180,
    ),
    '3017620422003': ProductLookupResult(
      barcode: '3017620422003',
      name: 'Hazelnut Cocoa Spread',
      brand: 'Sample Brand',
      category: 'Pantry',
      defaultQuantity: 350,
      defaultUnit: 'g',
      location: StorageLocation.pantry,
      suggestedShelfLifeDays: 180,
    ),
    '8000500310427': ProductLookupResult(
      barcode: '8000500310427',
      name: 'Chocolate Confectionery',
      brand: 'Sample Brand',
      category: 'Snacks',
      defaultQuantity: 100,
      defaultUnit: 'g',
      location: StorageLocation.pantry,
      suggestedShelfLifeDays: 120,
    ),
    '7622210449283': ProductLookupResult(
      barcode: '7622210449283',
      name: 'Chocolate Biscuits',
      brand: 'Sample Brand',
      category: 'Snacks',
      defaultQuantity: 154,
      defaultUnit: 'g',
      location: StorageLocation.pantry,
      suggestedShelfLifeDays: 120,
    ),
  };

  static Future<ProductLookupResult?> findByBarcode(String barcode) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return _catalog[barcode.trim()];
  }

  static ProductLookupResult createFallback(String barcode) {
    return ProductLookupResult(
      barcode: barcode.trim(),
      name: 'Unknown product',
      brand: '',
      category: 'Other',
      defaultQuantity: 1,
      defaultUnit: 'each',
      location: StorageLocation.pantry,
      suggestedShelfLifeDays: 30,
    );
  }
}
