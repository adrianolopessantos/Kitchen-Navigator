import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Smart shopping retains barcode purchase flow', () {
    final source = File(
      'lib/features/shopping/shopping_screen.dart',
    ).readAsStringSync();

    expect(source, contains('openBarcodeScanner(context)'));
    expect(source, contains('ProductLookupService.findByBarcode'));
    expect(source, contains('purchaseShoppingItem'));
    expect(source, contains('toggleShoppingChecked'));
    expect(source, contains("label: const Text('Scan')"));
  });
}
