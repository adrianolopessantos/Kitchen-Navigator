import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cook Together supports multi meal sessions', () {
    final cooking = File(
      'lib/features/cooking/cooking_assistant_screen.dart',
    ).readAsStringSync();
    final recipes = File(
      'lib/features/recipes/recipes_screen.dart',
    ).readAsStringSync();

    expect(cooking, contains('MultiMealCookingAssistantScreen'));
    expect(cooking, contains('Cook Together'));
    expect(cooking, contains('take(4)'));
    expect(cooking, contains('Done · next + start timer'));
    expect(recipes, contains('selectedForCooking'));
    expect(recipes, contains('Cook Together supports up to 4 meals'));
  });

  test('Pantry health uses final high contrast palette', () {
    final pantry = File(
      'lib/features/pantry/pantry_screen.dart',
    ).readAsStringSync();

    expect(pantry, contains('Color(0xFFA9D6A5)'));
    expect(pantry, contains('Color(0xFFFFF8E7)'));
    expect(pantry, contains('Color(0xFFD7E3D8)'));
  });
}
