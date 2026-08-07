import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Custom recipes support full management', () {
    final state = File(
      'lib/core/state/app_state.dart',
    ).readAsStringSync();

    expect(state, contains('isCustomRecipe'));
    expect(state, contains('updateCustomRecipe'));
    expect(state, contains('deleteCustomRecipe'));
    expect(state, contains('duplicateCustomRecipe'));
  });

  test('Recipes exposes current structured recipe tools', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(source, contains("'My recipes'"));
    expect(source, contains("'MY RECIPE'"));
    expect(source, contains("'Duplicate'"));
    expect(source, contains('_showRecipeEditor'));

    // Beta 1.1 replaced the old free-text _parseCustomStep parser
    // with structured ingredient rows and explicit timer-unit handling.
    expect(source, contains("'Add ingredient'"));
    expect(source, contains("'Quantity'"));
    expect(source, contains("'Unit'"));
    expect(source, contains("'Add step'"));
    expect(source, contains("'Timer unit'"));
    expect(source, contains('_secondsForStepDraft'));
  });

  test('Planner keeps monthly shopping workflow and state recipes', () {
    final source = File(
      'lib/features/planner/planner_screen.dart',
    ).readAsStringSync();

    expect(source, contains('shoppingItemsForWeek'));
    expect(source, contains('openShopping'));
    expect(source, contains('monthlyMealPlan'));
    expect(source, contains('state.recipes'));
  });
}
