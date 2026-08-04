import '../../models/pantry_item.dart';
import '../../models/recipe.dart';

class ScaledIngredient {
  const ScaledIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.available,
    required this.substitutions,
  });

  final String name;
  final double quantity;
  final String unit;
  final bool available;
  final List<String> substitutions;
}

abstract final class SmartRecipeService {
  static List<ScaledIngredient> scaleIngredients({
    required Recipe recipe,
    required int people,
    required List<PantryItem> pantryItems,
  }) {
    final scale = people / recipe.servings;

    return recipe.ingredients.map((ingredient) {
      final info = _ingredientInfo(ingredient);
      return ScaledIngredient(
        name: ingredient,
        quantity: _round(info.quantity * scale),
        unit: info.unit,
        available: _isAvailable(ingredient, pantryItems),
        substitutions: _substitutionsFor(ingredient),
      );
    }).toList();
  }

  static bool _isAvailable(
    String ingredient,
    List<PantryItem> pantryItems,
  ) {
    final ingredientKey = _normalise(ingredient);

    return pantryItems.any((item) {
      if (item.quantity <= 0) return false;
      final itemKey = _normalise(item.name);
      return itemKey == ingredientKey ||
          itemKey.contains(ingredientKey) ||
          ingredientKey.contains(itemKey);
    });
  }

  static _IngredientQuantity _ingredientInfo(String ingredient) {
    final key = _normalise(ingredient);

    if (key.contains('chicken') ||
        key.contains('salmon') ||
        key.contains('beef')) {
      return const _IngredientQuantity(250, 'g');
    }
    if (key.contains('milk') || key.contains('coconut milk')) {
      return const _IngredientQuantity(0.5, 'L');
    }
    if (key.contains('butter')) {
      return const _IngredientQuantity(30, 'g');
    }
    if (key.contains('egg')) {
      return const _IngredientQuantity(4, 'each');
    }
    if (key.contains('potato')) {
      return const _IngredientQuantity(500, 'g');
    }
    if (key.contains('pasta')) {
      return const _IngredientQuantity(250, 'g');
    }
    if (key.contains('parmesan') || key.contains('feta cheese')) {
      return const _IngredientQuantity(100, 'g');
    }
    if (key.contains('tomato') ||
        key.contains('onion') ||
        key.contains('cucumber') ||
        key.contains('lemon')) {
      return const _IngredientQuantity(2, 'each');
    }
    if (key.contains('pesto')) {
      return const _IngredientQuantity(120, 'g');
    }
    if (key.contains('salt') ||
        key.contains('pepper') ||
        key.contains('curry powder')) {
      return const _IngredientQuantity(1, 'tsp');
    }

    return const _IngredientQuantity(1, 'each');
  }

  static List<String> _substitutionsFor(String ingredient) {
    final key = _normalise(ingredient);

    if (key.contains('coconut milk')) {
      return const ['Greek yogurt', 'Cooking cream', 'Oat cream'];
    }
    if (key.contains('milk')) {
      return const ['Oat milk', 'Soy milk', 'Water + cream'];
    }
    if (key.contains('butter')) {
      return const ['Olive oil', 'Margarine'];
    }
    if (key.contains('egg')) {
      return const ['Flax egg', 'Aquafaba'];
    }
    if (key.contains('parmesan')) {
      return const ['Grana Padano', 'Pecorino', 'Nutritional yeast'];
    }
    if (key.contains('feta')) {
      return const ['Goat cheese', 'Halloumi', 'Firm tofu'];
    }
    if (key.contains('pesto')) {
      return const ['Basil + olive oil', 'Tomato sauce'];
    }
    if (key.contains('chicken')) {
      return const ['Turkey', 'Tofu', 'Chickpeas'];
    }
    if (key.contains('salmon')) {
      return const ['Trout', 'Cod', 'Tofu'];
    }
    if (key.contains('pasta')) {
      return const ['Rice', 'Couscous', 'Noodles'];
    }

    return const [];
  }

  static String _normalise(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static double _round(double value) =>
      (value * 10).roundToDouble() / 10;
}

class _IngredientQuantity {
  const _IngredientQuantity(this.quantity, this.unit);

  final double quantity;
  final String unit;
}
