abstract final class RecipeScalingService {
  static double scaleQuantity({
    required double quantity,
    required int originalServings,
    required int targetServings,
  }) {
    if (originalServings <= 0 || targetServings <= 0) {
      return quantity;
    }
    return quantity * targetServings / originalServings;
  }

  static String scaleIngredientText(
    String ingredient, {
    required int originalServings,
    required int targetServings,
  }) {
    if (originalServings <= 0 ||
        targetServings <= 0 ||
        originalServings == targetServings) {
      return ingredient;
    }

    final match = RegExp(
      r'^\s*(\d+(?:[.,]\d+)?)\s*(.*)$',
    ).firstMatch(ingredient);

    if (match == null) return ingredient;

    final value =
        double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) return ingredient;

    final scaled = scaleQuantity(
      quantity: value,
      originalServings: originalServings,
      targetServings: targetServings,
    );

    final display = scaled == scaled.roundToDouble()
        ? scaled.toInt().toString()
        : scaled.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

    return '$display ${match.group(2)!.trim()}'.trim();
  }
}
