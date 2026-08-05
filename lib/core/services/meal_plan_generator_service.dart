import 'dart:math' as math;

import '../../models/household_profile.dart';
import '../../models/kitchen_appliance.dart';
import '../../models/monthly_meal_plan.dart';
import '../../models/cooking_feedback.dart';
import '../../models/pantry_item.dart';
import '../../models/recipe.dart';

class MealPlanGenerationRequest {
  const MealPlanGenerationRequest({
    required this.month,
    required this.household,
    required this.recipes,
    required this.pantryItems,
    required this.appliances,
    required this.activeSlots,
    required this.existingEntries,
    this.feedback = const [],
    this.targetDate,
    this.targetWeek,
    this.targetSlot,
  });

  final DateTime month;
  final HouseholdProfile household;
  final List<Recipe> recipes;
  final List<PantryItem> pantryItems;
  final List<KitchenAppliance> appliances;
  final List<MealSlotType> activeSlots;
  final List<MonthlyMealEntry> existingEntries;
  final List<CookingFeedback> feedback;
  final DateTime? targetDate;
  final int? targetWeek;
  final MealSlotType? targetSlot;
}

class MealPlanGenerationResult {
  const MealPlanGenerationResult({
    required this.plan,
    required this.summary,
  });

  final MonthlyMealPlan plan;
  final String summary;
}

abstract final class MealPlanGeneratorService {
  static MealPlanGenerationResult generate(
    MealPlanGenerationRequest request,
  ) {
    final daysInMonth =
        DateTime(request.month.year, request.month.month + 1, 0).day;
    final preserved = request.existingEntries.where((entry) {
      if (entry.locked) return true;
      return !_isTargeted(entry, request);
    }).toList();

    final generated = <MonthlyMealEntry>[...preserved];
    final recentRecipeIds = <String>[];
    final people = request.household.people == 0
        ? 1
        : request.household.people;
    var recipeCursor = 0;

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        request.month.year,
        request.month.month,
        day,
      );

      if (!_dateIsTargeted(date, request)) continue;

      for (final slot in request.activeSlots) {
        if (request.targetSlot != null &&
            slot != request.targetSlot) {
          continue;
        }

        final key = dateKeyFor(date);
        final existingLocked = generated.any(
          (entry) =>
              entry.dateKey == key &&
              entry.slot == slot &&
              entry.locked,
        );
        if (existingLocked) continue;

        if (slot.isSnack) {
          generated.add(
            _simpleEntry(
              date: date,
              slot: slot,
              name: _chooseSnack(
                day,
                slot,
                request.household,
              ),
              people: people,
              reason:
                  'A simple snack matching the family routine.',
            ),
          );
          continue;
        }

        if (slot == MealSlotType.breakfast) {
          generated.add(
            _simpleEntry(
              date: date,
              slot: slot,
              name: _chooseBreakfast(
                day,
                request.household,
              ),
              people: people,
              reason:
                  'A quick breakfast within the weekday time limit.',
            ),
          );
          continue;
        }

        if (slot == MealSlotType.lunch && day % 4 == 0) {
          generated.add(
            _simpleEntry(
              date: date,
              slot: slot,
              name: 'Planned leftovers',
              people: people,
              reason:
                  'Uses leftovers to reduce cost and food waste.',
            ),
          );
          continue;
        }

        final ranked = _rankRecipes(
          request: request,
          date: date,
          slot: slot,
          recentRecipeIds: recentRecipeIds,
        );

        if (ranked.isEmpty) {
          generated.add(
            _simpleEntry(
              date: date,
              slot: slot,
              name: slot == MealSlotType.lunch
                  ? 'Sandwich, fruit and yogurt'
                  : 'Pantry vegetable soup',
              people: people,
              reason:
                  'A safe fallback when no recipe matches every restriction.',
            ),
          );
          continue;
        }

        final selected = ranked[recipeCursor % math.min(5, ranked.length)];
        recipeCursor++;
        recentRecipeIds.add(selected.recipe.id);
        if (recentRecipeIds.length > 8) {
          recentRecipeIds.removeAt(0);
        }

        generated.add(
          MonthlyMealEntry(
            id: '$key-${slot.name}-${selected.recipe.id}',
            dateKey: key,
            slot: slot,
            name: selected.recipe.name,
            servings: people,
            recipeId: selected.recipe.id,
            suggestionReason: selected.reason,
            generationSource: 'local-personalized',
          ),
        );
      }
    }

    generated.sort((a, b) {
      final dateCompare = a.dateKey.compareTo(b.dateKey);
      if (dateCompare != 0) return dateCompare;
      return a.slot.index.compareTo(b.slot.index);
    });

    return MealPlanGenerationResult(
      plan: MonthlyMealPlan(
        monthKey: monthKeyFor(request.month),
        entries: generated,
      ),
      summary:
          'Personalized locally for ${request.household.householdName}, '
          '${people} people, pantry stock, dietary needs, budget, '
          'equipment and cooking-time preferences.',
    );
  }

  static bool _isTargeted(
    MonthlyMealEntry entry,
    MealPlanGenerationRequest request,
  ) {
    final date = DateTime.tryParse(entry.dateKey);
    if (date == null) return false;
    if (!_dateIsTargeted(date, request)) return false;
    if (request.targetSlot != null &&
        entry.slot != request.targetSlot) {
      return false;
    }
    return true;
  }

  static bool _dateIsTargeted(
    DateTime date,
    MealPlanGenerationRequest request,
  ) {
    if (request.targetDate != null) {
      return dateKeyFor(date) == dateKeyFor(request.targetDate!);
    }
    if (request.targetWeek != null) {
      return (((date.day - 1) ~/ 7) + 1) ==
          request.targetWeek;
    }
    return date.year == request.month.year &&
        date.month == request.month.month;
  }

  static MonthlyMealEntry _simpleEntry({
    required DateTime date,
    required MealSlotType slot,
    required String name,
    required int people,
    required String reason,
  }) {
    return MonthlyMealEntry(
      id: '${dateKeyFor(date)}-${slot.name}-${_normalize(name)}',
      dateKey: dateKeyFor(date),
      slot: slot,
      name: name,
      servings: people,
      simpleFood: true,
      suggestionReason: reason,
      generationSource: 'local-personalized',
    );
  }

  static String _chooseSnack(
    int day,
    MealSlotType slot,
    HouseholdProfile household,
  ) {
    final choices = <String>[
      'Seasonal fruit',
      'Yogurt',
      'Banana',
      'Cheese and crackers',
      'Apple',
      'Toast',
    ];

    final likes = household.members
        .expand((member) => member.likes)
        .where((value) => value.trim().isNotEmpty)
        .toList();
    if (likes.isNotEmpty && day % 3 == 0) {
      return likes[day % likes.length];
    }

    return choices[(day + slot.index) % choices.length];
  }

  static String _chooseBreakfast(
    int day,
    HouseholdProfile household,
  ) {
    final choices = <String>[
      'Porridge with banana',
      'Yogurt and fruit',
      'Avocado toast',
      'Scrambled eggs',
      'Overnight oats',
      'French toast',
    ];

    final disliked = household.members
        .expand((member) => member.dislikes)
        .map(_normalize)
        .toSet();

    final safe = choices.where((choice) {
      final key = _normalize(choice);
      return !disliked.any(key.contains);
    }).toList();

    final available = safe.isEmpty ? choices : safe;
    return available[day % available.length];
  }

  static List<_RankedRecipe> _rankRecipes({
    required MealPlanGenerationRequest request,
    required DateTime date,
    required MealSlotType slot,
    required List<String> recentRecipeIds,
  }) {
    final pantryNames =
        request.pantryItems.map((item) => _normalize(item.name)).toSet();
    final expiringNames = request.pantryItems
        .where((item) {
          final days = item.daysUntilExpiry(date);
          return days != null && days >= 0 && days <= 5;
        })
        .map((item) => _normalize(item.name))
        .toSet();

    final allergies = request.household.householdAllergies;
    final dislikes = request.household.members
        .expand((member) => member.dislikes)
        .map(_normalize)
        .toSet();
    final likes = request.household.members
        .expand((member) => member.likes)
        .map(_normalize)
        .toSet();
    final cuisines = request.household.preferredCuisines
        .map(_normalize)
        .toSet();
    final equipment = request.appliances
        .map((item) => _normalize(item.name))
        .toSet();
    final diets =
        request.household.householdDietaryPreferences;

    final ranked = <_RankedRecipe>[];

    for (final recipe in request.recipes) {
      final searchable = _normalize(
        '${recipe.name} ${recipe.ingredients.join(' ')} '
        '${recipe.tags.join(' ')}',
      );

      if (allergies.any(searchable.contains)) continue;
      if (dislikes.any(searchable.contains)) continue;
      if (!_matchesDiet(recipe, diets)) continue;
      if (!_matchesEquipment(recipe, equipment)) continue;

      var score = 0.0;
      final reasons = <String>[];

      final pantryMatches = recipe.ingredients.where((ingredient) {
        final key = _normalize(ingredient);
        return pantryNames.any(
          (pantry) =>
              pantry.contains(key) || key.contains(pantry),
        );
      }).length;
      if (pantryMatches > 0) {
        score += pantryMatches * 4;
        reasons.add('uses $pantryMatches pantry ingredient${pantryMatches == 1 ? '' : 's'}');
      }

      final expiryMatches = recipe.ingredients.where((ingredient) {
        final key = _normalize(ingredient);
        return expiringNames.any(
          (pantry) =>
              pantry.contains(key) || key.contains(pantry),
        );
      }).length;
      if (expiryMatches > 0) {
        score += expiryMatches * 9;
        reasons.add('uses food expiring soon');
      }

      if (cuisines.contains(_normalize(recipe.cuisine))) {
        score += 5;
        reasons.add('matches a preferred cuisine');
      }

      if (likes.any(searchable.contains)) {
        score += 4;
        reasons.add('includes a family favourite');
      }

      if (recipe.totalMinutes <=
          request.household.maxWeekdayCookingMinutes) {
        score += 5;
        reasons.add('fits the cooking-time limit');
      } else if (date.weekday <= DateTime.friday) {
        score -= 5;
      }

      final recipeFeedback = request.feedback
          .where((value) => value.recipeId == recipe.id)
          .toList();
      if (recipeFeedback.isNotEmpty) {
        final averageRating = recipeFeedback
                .map((value) => value.rating)
                .fold<int>(0, (total, value) => total + value) /
            recipeFeedback.length;

        if (averageRating >= 4.5) {
          score += 8;
          reasons.add('is a highly rated family favourite');
        } else if (averageRating <= 2.5) {
          score -= 10;
        }

        if (recipeFeedback.any((value) => value.tooSpicy)) {
          score -= 4;
        }
        if (recipeFeedback.any((value) => value.tooSalty)) {
          score -= 3;
        }
      }

      if (recentRecipeIds.contains(recipe.id)) {
        score -= 12;
      }

      if (slot == MealSlotType.lunch &&
          recipe.totalMinutes <= 30) {
        score += 2;
      }

      final costScore =
          recipe.ingredients.length <= 6 ? 3.0 : 0.0;
      score += costScore;
      if (costScore > 0) {
        reasons.add('uses a shorter, budget-friendly ingredient list');
      }

      ranked.add(
        _RankedRecipe(
          recipe: recipe,
          score: score,
          reason: reasons.isEmpty
              ? 'Adds variety while respecting household restrictions.'
              : _sentence(reasons),
        ),
      );
    }

    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.recipe.totalMinutes.compareTo(
        b.recipe.totalMinutes,
      );
    });
    return ranked;
  }

  static bool _matchesDiet(
    Recipe recipe,
    Set<DietaryPreference> diets,
  ) {
    if (diets.isEmpty) return true;

    final searchable = _normalize(
      '${recipe.name} ${recipe.ingredients.join(' ')} '
      '${recipe.tags.join(' ')}',
    );

    final meatTerms = [
      'chicken',
      'beef',
      'pork',
      'bacon',
      'fish',
      'salmon',
      'cod',
      'shrimp',
      'tuna',
    ];

    if (diets.contains(DietaryPreference.vegan)) {
      final forbidden = [
        ...meatTerms,
        'egg',
        'milk',
        'cheese',
        'butter',
        'cream',
        'yogurt',
      ];
      if (forbidden.any(searchable.contains)) return false;
    }

    if (diets.contains(DietaryPreference.vegetarian) &&
        meatTerms.any(searchable.contains)) {
      return false;
    }

    if (diets.contains(DietaryPreference.pescatarian)) {
      final landMeat = ['chicken', 'beef', 'pork', 'bacon'];
      if (landMeat.any(searchable.contains)) return false;
    }

    if (diets.contains(DietaryPreference.glutenFree) &&
        ['bread', 'pasta', 'flour', 'tortilla']
            .any(searchable.contains)) {
      return false;
    }

    if (diets.contains(DietaryPreference.dairyFree) &&
        ['milk', 'cheese', 'butter', 'cream', 'yogurt']
            .any(searchable.contains)) {
      return false;
    }

    return true;
  }

  static bool _matchesEquipment(
    Recipe recipe,
    Set<String> available,
  ) {
    if (recipe.equipment.isEmpty || available.isEmpty) {
      return true;
    }

    return recipe.equipment.any((required) {
      final key = _normalize(required);
      if (key == 'no cook') return true;
      if (key == 'hob' || key == 'grill') return true;
      return available.any(
        (item) => item.contains(key) || key.contains(item),
      );
    });
  }

  static String _sentence(List<String> reasons) {
    final unique = reasons.toSet().take(3).toList();
    if (unique.length == 1) {
      return '${_capitalize(unique.first)}.';
    }
    final last = unique.removeLast();
    return '${_capitalize(unique.join(', '))} and $last.';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _RankedRecipe {
  const _RankedRecipe({
    required this.recipe,
    required this.score,
    required this.reason,
  });

  final Recipe recipe;
  final double score;
  final String reason;
}
