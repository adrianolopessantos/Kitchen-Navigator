import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Recipe Builder has structured ingredient controls', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(source, contains("'Add ingredient'"));
    expect(source, contains("'Quantity'"));
    expect(source, contains("'Unit'"));
    expect(source, contains('_recipeUnits'));
    expect(source, contains("'g'"));
    expect(source, contains("'kg'"));
    expect(source, contains("'tbsp'"));
  });

  test('Recipe Builder has structured timers', () {
    final source = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(source, contains("'Add step'"));
    expect(source, contains("'Timer unit'"));
    expect(source, contains("'No timer'"));
    expect(source, contains("'seconds'"));
    expect(source, contains("'minutes'"));
    expect(source, contains("'hours'"));
    expect(source, contains('_secondsForStepDraft'));
  });

  test('Top Add controls use explicit high contrast foreground', () {
    final pantry = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();
    final recipes = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(pantry, contains('foregroundColor: Colors.white'));
    expect(recipes, contains('foregroundColor: Colors.white'));
  });
}
