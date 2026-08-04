import '../../models/pantry_item.dart';
import '../../models/recipe.dart';

class AiKitchenRequest {
  const AiKitchenRequest({
    required this.people,
    required this.maxMinutes,
    required this.useExpiringFirst,
    required this.vegetarianOnly,
    required this.pantryItems,
    required this.recipes,
  });

  final int people;
  final int maxMinutes;
  final bool useExpiringFirst;
  final bool vegetarianOnly;
  final List<PantryItem> pantryItems;
  final List<Recipe> recipes;
}

class AiMealSuggestion {
  const AiMealSuggestion({
    required this.recipe,
    required this.score,
    required this.reasons,
    required this.missingIngredients,
    required this.expiringMatches,
  });

  final Recipe recipe;
  final double score;
  final List<String> reasons;
  final List<String> missingIngredients;
  final List<String> expiringMatches;
}

abstract final class AiKitchenService {
  static Future<List<AiMealSuggestion>> generate(
    AiKitchenRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final now = DateTime.now();
    final pantryKeys = request.pantryItems
        .where((item) => item.quantity > 0)
        .map((item) => _normalise(item.name))
        .toList();

    final expiringKeys = request.pantryItems
        .where((item) {
          final days = item.daysUntilExpiry(now);
          return days != null && days <= 3;
        })
        .map((item) => _normalise(item.name))
        .toList();

    final suggestions = <AiMealSuggestion>[];

    for (final recipe in request.recipes) {
      final minutes = (recipe.totalSeconds / 60).ceil();
      if (minutes > request.maxMinutes) continue;
      if (request.vegetarianOnly && !_looksVegetarian(recipe)) continue;

      final missing = <String>[];
      final available = <String>[];
      final expiringMatches = <String>[];

      for (final ingredient in recipe.ingredients) {
        final ingredientKey = _normalise(ingredient);
        final inPantry = pantryKeys.any(
          (key) =>
              key == ingredientKey ||
              key.contains(ingredientKey) ||
              ingredientKey.contains(key),
        );

        if (inPantry) {
          available.add(ingredient);
        } else {
          missing.add(ingredient);
        }

        final expiring = expiringKeys.any(
          (key) =>
              key == ingredientKey ||
              key.contains(ingredientKey) ||
              ingredientKey.contains(key),
        );
        if (expiring) expiringMatches.add(ingredient);
      }

      final pantryRatio = recipe.ingredients.isEmpty
          ? 0.0
          : available.length / recipe.ingredients.length;

      var score = pantryRatio * 60;
      score += (request.maxMinutes - minutes).clamp(0, request.maxMinutes) /
          request.maxMinutes *
          18;
      score += expiringMatches.length * (request.useExpiringFirst ? 14 : 4);
      score -= missing.length * 3;

      final reasons = <String>[
        if (available.isNotEmpty)
          '${available.length} ingredient${available.length == 1 ? '' : 's'} already available',
        if (expiringMatches.isNotEmpty)
          'Uses ${expiringMatches.length} item${expiringMatches.length == 1 ? '' : 's'} expiring soon',
        'Ready in about $minutes minutes',
        'Scaled for ${request.people} people',
      ];

      suggestions.add(
        AiMealSuggestion(
          recipe: recipe,
          score: score,
          reasons: reasons,
          missingIngredients: missing,
          expiringMatches: expiringMatches,
        ),
      );
    }

    suggestions.sort((a, b) => b.score.compareTo(a.score));
    return suggestions.take(6).toList();
  }

  static bool _looksVegetarian(Recipe recipe) {
    final text = [
      recipe.name,
      ...recipe.ingredients,
    ].join(' ').toLowerCase();

    return !RegExp(
      r'chicken|beef|pork|ham|bacon|salmon|fish|tuna|prawn|turkey|meat',
    ).hasMatch(text);
  }

  static String _normalise(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
