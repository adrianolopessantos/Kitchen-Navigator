import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V12 starter collection has at least 25 structured recipes', () {
    final source = File(
      'lib/data/essential_recipe_library.dart',
    ).readAsStringSync();

    final starterNames = <String>[
      'Scrambled Eggs',
      'Cheese Omelette',
      'Classic Pancakes',
      'French Toast',
      'Overnight Oats',
      'Creamy Porridge',
      'Avocado Toast',
      'Breakfast Burrito',
      'Roast Chicken',
      'Grilled Chicken Breast',
      'Chicken Curry',
      'Chicken Alfredo',
      'Lemon Chicken',
      'Chicken Stir Fry',
      'Chicken Fajitas',
      'Chicken Parmesan',
      'Beef Stew',
      'Spaghetti Bolognese',
      'Italian Meatballs',
      'Beef Stir Fry',
      'Cottage Pie',
      'Chili Con Carne',
      'Baked Salmon',
      'Fish and Chips',
      'Tuna Pasta',
    ];

    for (final name in starterNames) {
      expect(source, contains("name: '$name'"), reason: name);
    }

    expect(source, contains("'4 each Eggs'"));
    expect(source, contains("'500 g Chicken breast'"));
    expect(source, contains("'300 g Pasta'"));
    expect(source, contains("'2 can Tuna'"));
  });

  test('Existing library remains available beyond starter collection', () {
    final source = File(
      'lib/data/essential_recipe_library.dart',
    ).readAsStringSync();

    // Existing V10 library remains intact; Beta 1.2 upgrades content rather
    // than deleting recipes users already have.
    expect(source, contains("name: 'Chocolate Brownies'"));
    expect(source, contains("name: 'Greek Salad'"));
    expect(source, contains("name: 'Homemade Pizza'"));
  });
}
