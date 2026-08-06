import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Manual shopping items can be added, edited and hidden', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await Future<void>.delayed(const Duration(milliseconds: 40));

    await state.addManualShoppingItem(
      name: 'Kitchen paper',
      quantity: 2,
      unit: 'pack',
      category: 'Household',
      week: 1,
    );

    final added = state.manualShoppingItems.single;
    expect(added.name, 'Kitchen paper');
    expect(added.manual, isTrue);

    await state.updateShoppingItem(
      added.copyWith(quantity: 3),
    );
    expect(state.manualShoppingItems.single.quantity, 3);

    await state.removeShoppingItem(added.key);
    expect(
      state.shoppingItemsForWeek(1)
          .where((item) => item.key == added.key),
      isEmpty,
    );

    await state.restoreShoppingItem(added.key);
    expect(
      state.shoppingItemsForWeek(1)
          .where((item) => item.key == added.key),
      isNotEmpty,
    );
  });

  test('Quantity step follows the selected unit', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await Future<void>.delayed(const Duration(milliseconds: 40));

    const kilograms = ShoppingItem(
      key: 'kg',
      name: 'Rice',
      quantity: 1,
      unit: 'kg',
      category: 'Pantry',
      estimatedUnitPrice: 2,
      recipeNames: [],
    );

    const grams = ShoppingItem(
      key: 'g',
      name: 'Cheese',
      quantity: 200,
      unit: 'g',
      category: 'Dairy & Chilled',
      estimatedUnitPrice: .01,
      recipeNames: [],
    );

    expect(state.shoppingQuantityStep(kilograms), .1);
    expect(state.shoppingQuantityStep(grams), 50);
  });
}
