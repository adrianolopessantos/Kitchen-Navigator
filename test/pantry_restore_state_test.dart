import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/state/app_state.dart';
import 'package:kitchen_navigator/models/pantry_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Deleted pantry product can be restored', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await Future<void>.delayed(const Duration(milliseconds: 40));

    const item = PantryItem(
      id: 'restore-me',
      name: 'Rice',
      quantity: 2,
      unit: 'kg',
      location: StorageLocation.pantry,
    );

    state.pantryItems.add(item);
    state.removePantryItem(item.id);
    expect(
      state.pantryItems.any((value) => value.id == item.id),
      isFalse,
    );

    state.restorePantryItem(item);
    expect(
      state.pantryItems.any((value) => value.id == item.id),
      isTrue,
    );
  });
}
