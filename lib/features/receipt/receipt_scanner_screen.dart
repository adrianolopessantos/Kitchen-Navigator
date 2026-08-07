import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pantry_item.dart';

class ReceiptDraftItem {
  ReceiptDraftItem({
    required this.name,
    this.quantity = 1,
    this.unit = 'each',
    this.location = StorageLocation.pantry,
    this.selected = true,
  });

  String name;
  double quantity;
  String unit;
  StorageLocation location;
  bool selected;
}

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final List<ReceiptDraftItem> _items = [];
  String _rawText = '';
  bool _processing = false;
  String _status =
      'Take a clear photo of the full receipt or choose one from the gallery.';

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  Future<void> _capture(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 95,
      maxWidth: 2200,
    );
    if (file == null) return;

    setState(() {
      _processing = true;
      _status = 'Reading receipt text...';
      _items.clear();
      _rawText = '';
    });

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final recognized = await _recognizer.processImage(inputImage);
      final parsed = _parseReceipt(recognized.text);
      if (!mounted) return;
      setState(() {
        _rawText = recognized.text;
        _items.addAll(parsed);
        _processing = false;
        _status = parsed.isEmpty
            ? 'No product lines were detected. Add products manually or try another photo.'
            : '${parsed.length} possible product lines found. Review before importing.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _status = 'The receipt could not be read. Try a brighter, sharper photo.';
      });
    }
  }

  List<ReceiptDraftItem> _parseReceipt(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final results = <ReceiptDraftItem>[];
    final seen = <String>{};

    for (final original in lines) {
      var line = original
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .replaceAll(RegExp(r'^[*#\-]+\s*'), '')
          .trim();

      if (!_looksLikeProduct(line)) continue;

      line = line
          .replaceAll(RegExp(r'\s+[€\$£]?\d+[,.]\d{2}\s*$'), '')
          .replaceAll(RegExp(r'\s+\d+[,.]\d{2}\s*[€\$£]?\s*$'), '')
          .replaceAll(RegExp(r'^\d+\s*[xX]\s*'), '')
          .trim();

      if (line.length < 2) continue;
      final key = line.toLowerCase();
      if (!seen.add(key)) continue;

      final quantityMatch = RegExp(r'^(\d+(?:[.,]\d+)?)\s+(.+)$').firstMatch(line);
      double quantity = 1;
      String name = line;

      if (quantityMatch != null && line.length > 4) {
        final parsedQuantity = double.tryParse(
          quantityMatch.group(1)!.replaceAll(',', '.'),
        );
        final possibleName = quantityMatch.group(2)!.trim();
        if (parsedQuantity != null &&
            parsedQuantity <= 50 &&
            possibleName.length >= 2) {
          quantity = parsedQuantity;
          name = possibleName;
        }
      }

      results.add(
        ReceiptDraftItem(
          name: _titleCase(name),
          quantity: quantity,
          location: _suggestLocation(name),
        ),
      );
      if (results.length >= 40) break;
    }
    return results;
  }

  bool _looksLikeProduct(String line) {
    final lower = line.toLowerCase();
    if (line.length < 2 || line.length > 55) return false;
    if (!RegExp(r'[a-zA-Z]').hasMatch(line)) return false;

    const blocked = [
      'total', 'subtotal', 'change', 'cash', 'card', 'visa', 'mastercard',
      'vat', 'tax', 'receipt', 'invoice', 'thank you', 'welcome', 'customer',
      'store', 'date', 'time', 'balance', 'discount', 'saving', 'payment',
      'cashier', 'tel', 'www.', '.com', 'transaction',
    ];
    if (blocked.any(lower.contains)) return false;
    if (RegExp(r'^\d{2}[/-]\d{2}[/-]\d{2,4}').hasMatch(line)) return false;
    if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(line)) return false;
    if (RegExp(r'^[€\$£\d\s.,-]+$').hasMatch(line)) return false;
    return true;
  }

  static StorageLocation _suggestLocation(String name) {
    final value = name.toLowerCase();
    if (RegExp(
      r'milk|cheese|yogurt|cream|butter|egg|chicken|beef|pork|ham|bacon|fish|salmon|lettuce|spinach|fresh',
    ).hasMatch(value)) {
      return StorageLocation.fridge;
    }
    if (RegExp(r'frozen|ice cream|chips frozen|peas frozen').hasMatch(value)) {
      return StorageLocation.freezer;
    }
    return StorageLocation.pantry;
  }

  static String _titleCase(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  void _addManualItem() {
    setState(() {
      _items.add(
        ReceiptDraftItem(
          name: 'New product',
          location: StorageLocation.pantry,
        ),
      );
    });
  }

  void _removeItem(int index) => setState(() => _items.removeAt(index));

  void _importSelected() {
    final selected = _items.where((item) => item.selected).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one product.')),
      );
      return;
    }

    final state = AppScope.of(context);
    for (final item in selected) {
      final name = item.name.trim();
      if (name.isEmpty || item.quantity <= 0) continue;
      state.addPantryItem(
        name: name,
        quantity: item.quantity,
        unit: item.unit.trim().isEmpty ? 'each' : item.unit.trim(),
        location: item.location,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selected.length} product${selected.length == 1 ? '' : 's'} added to storage.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan shopping receipt')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.shopping.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.shopping,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Receipt Scanner',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Capture the full receipt in good light. Correct every product before importing.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Container(
              height: 3,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.shopping,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 370;

                if (compact) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _processing
                              ? null
                              : () => _capture(ImageSource.camera),
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                          ),
                          label: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 13),
                            child: Text('Take photo'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _processing
                              ? null
                              : () => _capture(ImageSource.gallery),
                          icon: const Icon(
                            Icons.photo_library_outlined,
                          ),
                          label: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 13),
                            child: Text('Choose from gallery'),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _processing
                            ? null
                            : () => _capture(ImageSource.camera),
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                        ),
                        label: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 13),
                          child: Text('Take photo'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _processing
                            ? null
                            : () => _capture(ImageSource.gallery),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                        ),
                        label: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 13),
                          child: Text('Gallery'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surfaceElevated,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_processing)
                      const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _items.isEmpty
                            ? Icons.receipt_long_outlined
                            : Icons.check_circle_outline,
                        color: _items.isEmpty ? AppColors.muted : AppColors.primary,
                      ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        _status,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Products to import',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addManualItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No products yet. Scan a receipt or add an item manually.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...List.generate(
                _items.length,
                (index) => _ReceiptItemCard(
                  item: _items[index],
                  onChanged: () => setState(() {}),
                  onRemove: () => _removeItem(index),
                ),
              ),
            if (_rawText.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('View recognised receipt text'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SelectableText(
                      _rawText,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _items.isEmpty ? null : _importSelected,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Add selected products to storage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptItemCard extends StatelessWidget {
  const _ReceiptItemCard({
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final ReceiptDraftItem item;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: item.selected,
                  onChanged: (value) {
                    item.selected = value ?? true;
                    onChanged();
                  },
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: item.name,
                    decoration: const InputDecoration(
                      labelText: 'Product',
                      isDense: true,
                    ),
                    onChanged: (value) => item.name = value,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _formatQuantity(item.quantity),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      item.quantity = double.tryParse(value.replaceAll(',', '.')) ?? item.quantity;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      isDense: true,
                    ),
                    onChanged: (value) => item.unit = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            DropdownButtonFormField<StorageLocation>(
              initialValue: item.location,
              decoration: const InputDecoration(
                labelText: 'Store in',
                isDense: true,
              ),
              items: StorageLocation.values.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) item.location = value;
              },
            ),
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

Future<void> openReceiptScanner(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const ReceiptScannerScreen()),
  );
}
