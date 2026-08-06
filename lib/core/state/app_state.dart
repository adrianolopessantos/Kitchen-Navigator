import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/pantry_item.dart';
import '../../models/kitchen_appliance.dart';
import '../../models/kitchen_profile.dart';
import '../../models/nutrition.dart';
import '../services/nutrition_service.dart';
import '../../models/recipe.dart';
import '../../models/household_profile.dart';
import '../../models/monthly_meal_plan.dart';
import '../../models/pantry_usage_event.dart';
import '../../models/cooking_feedback.dart';
import '../../models/app_notification.dart';
import '../../models/nutrition_summary.dart';
import '../../models/budget_forecast.dart';
import '../services/pantry_intelligence_service.dart';
import '../services/meal_plan_generator_service.dart';
import '../services/cooking_feedback_service.dart';
import '../services/notification_center_service.dart';
import '../services/nutrition_intelligence_service.dart';
import '../services/budget_intelligence_service.dart';
import '../services/monthly_meal_plan_service.dart';
import '../services/household_profile_service.dart';
import '../../data/essential_recipe_library.dart';

class PlannedMeal {
  const PlannedMeal({required this.recipe, required this.people});

  final Recipe recipe;
  final int people;

  PlannedMeal copyWith({int? people}) =>
      PlannedMeal(recipe: recipe, people: people ?? this.people);
}

class ShoppingItem {
  const ShoppingItem({
    required this.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.estimatedUnitPrice,
    required this.recipeNames,
    this.week = 1,
    this.sourceDateKeys = const [],
    this.manual = false,
  });

  final String key;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final double estimatedUnitPrice;
  final List<String> recipeNames;
  final int week;
  final List<String> sourceDateKeys;
  final bool manual;

  double get estimatedTotal => quantity * estimatedUnitPrice;

  ShoppingItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? category,
    double? estimatedUnitPrice,
    int? week,
    bool? manual,
  }) {
    return ShoppingItem(
      key: key,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      estimatedUnitPrice:
          estimatedUnitPrice ?? this.estimatedUnitPrice,
      recipeNames: recipeNames,
      week: week ?? this.week,
      sourceDateKeys: sourceDateKeys,
      manual: manual ?? this.manual,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
        'estimatedUnitPrice': estimatedUnitPrice,
        'recipeNames': recipeNames,
        'week': week,
        'sourceDateKeys': sourceDateKeys,
        'manual': manual,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      key: json['key'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Product',
      quantity:
          (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? 'each',
      category: json['category'] as String? ?? 'Pantry',
      estimatedUnitPrice:
          (json['estimatedUnitPrice'] as num?)?.toDouble() ??
              1,
      recipeNames: (json['recipeNames'] as List<dynamic>? ??
              const [])
          .map((value) => value.toString())
          .toList(),
      week: (json['week'] as num?)?.toInt() ?? 1,
      sourceDateKeys:
          (json['sourceDateKeys'] as List<dynamic>? ??
                  const [])
              .map((value) => value.toString())
              .toList(),
      manual: json['manual'] as bool? ?? false,
    );
  }
}

class AppState extends ChangeNotifier {
  AppState() {
    _loadSavedData();
  }

  bool dataLoaded = false;
  HouseholdProfile householdProfile = HouseholdProfile.initial();
  MonthlyMealPlan monthlyMealPlan =
      MonthlyMealPlan.empty(DateTime.now());
  DateTime selectedPlannerDate =
      normalizedDate(DateTime.now());
  int selectedShoppingWeek = 1;
  String lastMealGenerationSummary = '';

  bool get householdSetupComplete =>
      householdProfile.setupComplete;

  int get householdPeople =>
      householdProfile.people == 0 ? 1 : householdProfile.people;

  static const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Recipe> recipes = essentialRecipeLibrary;

  final Map<String, List<PlannedMeal>> _plan = {
    for (final day in days) day: <PlannedMeal>[],
  };

  final List<PantryItem> pantryItems = [];
  final List<PantryUsageEvent> pantryUsageEvents = [];
  final List<CookingFeedback> cookingFeedback = [];
  final List<AppNotification> appNotifications = [];
  NotificationPreferences notificationPreferences =
      const NotificationPreferences();
  final Set<String> checkedShoppingItems = {};
  final Map<String, ShoppingItem> shoppingOverrides = {};
  final List<ShoppingItem> manualShoppingItems = [];
  final Set<String> hiddenShoppingItems = {};
  final List<KitchenAppliance> kitchenAppliances = [];
  TemperatureUnit temperatureUnit = TemperatureUnit.celsius;
  final List<KitchenProfile> kitchenProfiles = [];
  String activeKitchenId = 'home';
  NutritionGoal nutritionGoal = NutritionGoal.balanced;

  KitchenProfile get activeKitchen {
    for (final profile in kitchenProfiles) {
      if (profile.id == activeKitchenId) return profile;
    }
    return kitchenProfiles.isNotEmpty
        ? kitchenProfiles.first
        : const KitchenProfile(
            id: 'home',
            name: 'Home',
            iconName: 'home',
          );
  }

  String selectedDay = 'Monday';
  String search = '';
  StorageLocation? pantryFilter;
  String pantrySearch = '';

  List<PlannedMeal> mealsFor(String day) => List.unmodifiable(_plan[day] ?? []);

  List<PlannedMeal> get selectedMeals => mealsFor(selectedDay);

  List<Recipe> get filteredRecipes {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return recipes;
    return recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(query) ||
          recipe.ingredients.any(
            (item) => item.toLowerCase().contains(query),
          );
    }).toList();
  }

  String get todayName => days[DateTime.now().weekday - 1];

  List<PlannedMeal> get todayMeals => mealsFor(todayName);

  int get todayPeople => todayMeals.isEmpty
      ? 2
      : todayMeals
          .map((meal) => meal.people)
          .reduce((a, b) => a > b ? a : b);

  int get requiredIngredients => todayMeals
      .expand((meal) => meal.recipe.ingredients)
      .map(_normalize)
      .toSet()
      .length;

  int get pantryCount => pantryItems.length;

  double get estimatedPantryValue {
    return pantryItems.fold<double>(
      0,
      (total, item) => total + _estimatedItemValue(item),
    );
  }

  List<PantryItem> get lowStockItems {
    final items = pantryItems.where(_isLowStock).toList();
    items.sort((a, b) {
      final aRatio = _stockRatio(a);
      final bRatio = _stockRatio(b);
      final ratioOrder = aRatio.compareTo(bRatio);
      if (ratioOrder != 0) return ratioOrder;
      return a.name.compareTo(b.name);
    });
    return items;
  }

  List<PantryItem> get healthyStockItems {
    return pantryItems.where((item) => !_isLowStock(item)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  int get pantryHealthScore {
    if (pantryItems.isEmpty) return 0;

    final expiredPenalty = expiredCount * 12;
    final expiringPenalty = expiringSoonCount * 5;
    final lowStockPenalty = lowStockItems.length * 4;

    return (100 - expiredPenalty - expiringPenalty - lowStockPenalty)
        .clamp(0, 100);
  }

  String get pantryHealthLabel {
    final score = pantryHealthScore;
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Needs attention';
    return 'At risk';
  }

  int plannedUsesForPantryItem(PantryItem item) {
    final itemKey = _normalize(item.name);
    var uses = 0;

    for (final entry in monthlyMealPlan.entries) {
      if (entry.recipeId == null) {
        final simpleKey = _normalize(entry.name);
        if (simpleKey == itemKey ||
            simpleKey.contains(itemKey) ||
            itemKey.contains(simpleKey)) {
          uses++;
        }
        continue;
      }

      Recipe? recipe;
      for (final candidate in recipes) {
        if (candidate.id == entry.recipeId) {
          recipe = candidate;
          break;
        }
      }

      if (recipe == null) continue;
      final matches = recipe.ingredients.any((ingredient) {
        final ingredientKey = _normalize(ingredient);
        return ingredientKey == itemKey ||
            ingredientKey.contains(itemKey) ||
            itemKey.contains(ingredientKey);
      });
      if (matches) uses++;
    }

    return uses;
  }

  PantryItemInsight pantryInsightFor(PantryItem item) {
    return PantryIntelligenceService.analyze(
      item: item,
      usageEvents: pantryUsageEvents,
      plannedUses: plannedUsesForPantryItem(item),
      minimumStock: _minimumStockFor(item),
      now: DateTime.now(),
    );
  }

  List<PantryItem> get wasteRiskItems {
    final result = pantryItems
        .where((item) => pantryInsightFor(item).wasteRisk)
        .toList();
    result.sort((a, b) {
      final aDays = a.daysUntilExpiry(DateTime.now()) ?? 999;
      final bDays = b.daysUntilExpiry(DateTime.now()) ?? 999;
      return aDays.compareTo(bDays);
    });
    return result;
  }

  List<PantryItem> get restockSuggestedItems {
    final result = pantryItems
        .where(
          (item) =>
              pantryInsightFor(item).recommendedRestockQuantity > 0,
        )
        .toList();
    result.sort(
      (a, b) => pantryInsightFor(a)
          .estimatedDaysRemaining
          .compareTo(pantryInsightFor(b).estimatedDaysRemaining),
    );
    return result;
  }

  int get pantryCoveredPlanUses {
    return pantryItems.fold<int>(
      0,
      (total, item) => total + plannedUsesForPantryItem(item),
    );
  }

  double get estimatedWasteValue {
    return wasteRiskItems.fold<double>(
      0,
      (total, item) => total + _estimatedItemValue(item),
    );
  }

  int estimatedDaysRemaining(PantryItem item) {
    final threshold = _minimumStockFor(item);
    if (threshold <= 0) return 30;

    final ratio = item.quantity / threshold;
    return (ratio * 7).round().clamp(1, 90);
  }

  double minimumStockFor(PantryItem item) => _minimumStockFor(item);

  double estimatedItemValue(PantryItem item) => _estimatedItemValue(item);

  void addLowStockToShopping(PantryItem item) {
    final key = _normalize(item.name);
    checkedShoppingItems.remove(key);

    final existing = pantryItems.indexWhere(
      (candidate) => candidate.id == item.id,
    );
    if (existing >= 0) {
      pantryItems[existing] = item.copyWith(quantity: 0);
      _savePantry();
    }

    notifyListeners();
  }

  bool _isLowStock(PantryItem item) {
    return item.quantity > 0 &&
        item.quantity <= _minimumStockFor(item);
  }

  double _stockRatio(PantryItem item) {
    final minimum = _minimumStockFor(item);
    if (minimum <= 0) return 99;
    return item.quantity / minimum;
  }

  double _minimumStockFor(PantryItem item) {
    final unit = item.unit.trim().toLowerCase();
    final name = _normalize(item.name);

    if (unit == 'kg' || unit == 'l') return 0.5;
    if (unit == 'g' || unit == 'ml') return 250;
    if (unit == 'pack' || unit == 'jar') return 1;

    if (name.contains('egg')) return 4;
    if (name.contains('potato') ||
        name.contains('onion') ||
        name.contains('tomato') ||
        name.contains('lemon')) {
      return 2;
    }

    return 1;
  }

  double _estimatedItemValue(PantryItem item) {
    final name = _normalize(item.name);
    final unit = item.unit.trim().toLowerCase();

    double unitPrice;
    if (name.contains('chicken') ||
        name.contains('beef') ||
        name.contains('salmon') ||
        name.contains('fish')) {
      unitPrice = unit == 'g' ? 0.012 : 6.0;
    } else if (name.contains('milk')) {
      unitPrice = unit == 'l' ? 1.8 : 1.8;
    } else if (name.contains('egg')) {
      unitPrice = 0.35;
    } else if (name.contains('cheese') ||
        name.contains('butter') ||
        name.contains('yogurt')) {
      unitPrice = unit == 'g' ? 0.01 : 2.5;
    } else if (unit == 'kg') {
      unitPrice = 2.2;
    } else if (unit == 'g') {
      unitPrice = 0.004;
    } else if (unit == 'l') {
      unitPrice = 1.7;
    } else if (unit == 'ml') {
      unitPrice = 0.002;
    } else if (unit == 'pack' || unit == 'jar') {
      unitPrice = 2.0;
    } else {
      unitPrice = 0.75;
    }

    return item.quantity * unitPrice;
  }



  int get expiringSoonCount {
    final now = DateTime.now();
    return pantryItems.where((item) {
      final days = item.daysUntilExpiry(now);
      return days != null && days >= 0 && days <= 3;
    }).length;
  }

  int get expiredCount {
    final now = DateTime.now();
    return pantryItems.where((item) {
      final days = item.daysUntilExpiry(now);
      return days != null && days < 0;
    }).length;
  }


  List<PantryItem> get expiredItems {
    final now = DateTime.now();
    return pantryItems.where((item) {
      final days = item.daysUntilExpiry(now);
      return days != null && days < 0;
    }).toList()
      ..sort((a, b) =>
          (a.daysUntilExpiry(now) ?? 9999).compareTo(
            b.daysUntilExpiry(now) ?? 9999,
          ));
  }

  List<PantryItem> get expiresTodayItems {
    final now = DateTime.now();
    return pantryItems.where((item) => item.daysUntilExpiry(now) == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<PantryItem> get expiresTomorrowItems {
    final now = DateTime.now();
    return pantryItems.where((item) => item.daysUntilExpiry(now) == 1).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<PantryItem> get expiresThisWeekItems {
    final now = DateTime.now();
    return pantryItems.where((item) {
      final days = item.daysUntilExpiry(now);
      return days != null && days >= 2 && days <= 7;
    }).toList()
      ..sort((a, b) =>
          (a.daysUntilExpiry(now) ?? 9999).compareTo(
            b.daysUntilExpiry(now) ?? 9999,
          ));
  }

  List<PantryItem> get useSoonItems {
    final now = DateTime.now();
    return pantryItems.where((item) {
      final days = item.daysUntilExpiry(now);
      return days != null && days <= 7;
    }).toList()
      ..sort((a, b) =>
          (a.daysUntilExpiry(now) ?? 9999).compareTo(
            b.daysUntilExpiry(now) ?? 9999,
          ));
  }

  List<Recipe> recipesForPantryItem(PantryItem item) {
    final productKey = _normalize(item.name);
    return recipes.where((recipe) {
      return recipe.ingredients.any((ingredient) {
        final ingredientKey = _normalize(ingredient);
        return ingredientKey == productKey ||
            ingredientKey.contains(productKey) ||
            productKey.contains(ingredientKey);
      });
    }).toList();
  }

  List<Recipe> get useSoonRecipeSuggestions {
    final suggested = <Recipe>[];
    final seen = <String>{};

    for (final item in useSoonItems) {
      for (final recipe in recipesForPantryItem(item)) {
        if (seen.add(recipe.id)) suggested.add(recipe);
      }
    }

    suggested.sort((a, b) {
      final aMatches = _expiringIngredientMatches(a);
      final bMatches = _expiringIngredientMatches(b);
      final matchOrder = bMatches.compareTo(aMatches);
      if (matchOrder != 0) return matchOrder;
      return a.name.compareTo(b.name);
    });

    return suggested;
  }

  int expiringIngredientMatches(Recipe recipe) =>
      _expiringIngredientMatches(recipe);

  int _expiringIngredientMatches(Recipe recipe) {
    final keys = useSoonItems.map((item) => _normalize(item.name)).toList();
    return recipe.ingredients.where((ingredient) {
      final ingredientKey = _normalize(ingredient);
      return keys.any(
        (key) =>
            key == ingredientKey ||
            key.contains(ingredientKey) ||
            ingredientKey.contains(key),
      );
    }).length;
  }

  Future<void> consumePantryItem(
    String id, {
    double? quantity,
  }) async {
    final index = pantryItems.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final item = pantryItems[index];
    final amount = (quantity ?? _defaultUsageAmount(item))
        .clamp(0.0, item.quantity)
        .toDouble();
    if (amount <= 0) return;

    pantryUsageEvents.add(
      PantryUsageEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        itemName: item.name,
        quantity: amount,
        unit: item.unit,
        type: PantryUsageType.consumed,
        createdAt: DateTime.now(),
      ),
    );

    final remaining = item.quantity - amount;
    if (remaining <= 0) {
      pantryItems.removeAt(index);
    } else {
      pantryItems[index] = item.copyWith(quantity: remaining);
    }

    await _savePantry();
    await _savePantryUsage();
    notifyListeners();
  }

  Future<void> markPantryItemWasted(String id) async {
    final index = pantryItems.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final item = pantryItems.removeAt(index);
    pantryUsageEvents.add(
      PantryUsageEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        itemName: item.name,
        quantity: item.quantity,
        unit: item.unit,
        type: PantryUsageType.wasted,
        createdAt: DateTime.now(),
      ),
    );

    await _savePantry();
    await _savePantryUsage();
    notifyListeners();
  }

  void markPantryItemUsed(String id) {
    consumePantryItem(id);
  }

  double _defaultUsageAmount(PantryItem item) {
    final unit = item.unit.trim().toLowerCase();
    if (unit == 'kg' || unit == 'l') return 0.25;
    if (unit == 'g' || unit == 'ml') return 100;
    return 1;
  }

  Future<void> addSuggestedRestockToShopping(
    PantryItem item,
  ) async {
    final insight = pantryInsightFor(item);
    if (insight.recommendedRestockQuantity <= 0) return;

    checkedShoppingItems.removeWhere(
      (key) => key.contains(_normalize(item.name)),
    );
    await _saveShoppingChecks();
    notifyListeners();
  }

  List<PantryItem> get filteredPantryItems {
    final query = pantrySearch.trim().toLowerCase();
    return pantryItems.where((item) {
      final locationMatches =
          pantryFilter == null || item.location == pantryFilter;
      final searchMatches =
          query.isEmpty || item.name.toLowerCase().contains(query);
      return locationMatches && searchMatches;
    }).toList()
      ..sort((a, b) {
        final aDays = a.daysUntilExpiry(DateTime.now());
        final bDays = b.daysUntilExpiry(DateTime.now());
        if (aDays == null && bDays == null) {
          return a.name.compareTo(b.name);
        }
        if (aDays == null) return 1;
        if (bDays == null) return -1;
        return aDays.compareTo(bDays);
      });
  }

  List<ShoppingItem> get shoppingItems {
    final Map<String, _ShoppingAccumulator> totals = {};

    for (final day in days) {
      for (final meal in mealsFor(day)) {
        final scale = math.max(1.0, meal.people / meal.recipe.servings);

        for (final ingredient in meal.recipe.ingredients) {
          final key = _normalize(ingredient);
          if (_pantryContains(key)) continue;

          final info = _ingredientInfo(ingredient);
          final accumulator = totals.putIfAbsent(
            key,
            () => _ShoppingAccumulator(
              name: ingredient,
              quantity: 0,
              unit: info.unit,
              category: info.category,
              price: info.price,
              recipeNames: <String>{},
            ),
          );

          accumulator.quantity += info.baseQuantity * scale;
          accumulator.recipeNames.add(meal.recipe.name);
        }
      }
    }

    final result = totals.entries.map((entry) {
      final value = entry.value;
      return ShoppingItem(
        key: entry.key,
        name: value.name,
        quantity: _roundQuantity(value.quantity),
        unit: value.unit,
        category: value.category,
        estimatedUnitPrice: value.price,
        recipeNames: value.recipeNames.toList()..sort(),
      );
    }).toList();

    result.sort((a, b) {
      final category = a.category.compareTo(b.category);
      if (category != 0) return category;
      return a.name.compareTo(b.name);
    });

    return result;
  }

  double get estimatedShoppingTotal =>
      shoppingItems.fold(0, (total, item) => total + item.estimatedTotal);

  int get shoppingCount => shoppingItems.length;

  Map<String, List<ShoppingItem>> get shoppingGroups {
    final groups = <String, List<ShoppingItem>>{};
    for (final item in shoppingItems) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }
    return groups;
  }



  int get shoppingWeeksInSelectedMonth {
    final month = selectedPlannerDate;
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    return ((daysInMonth - 1) ~/ 7) + 1;
  }

  double get weeklyShoppingBudget {
    final weeks = shoppingWeeksInSelectedMonth;
    return weeks == 0
        ? householdProfile.monthlyBudget
        : householdProfile.monthlyBudget / weeks;
  }

  void selectShoppingWeek(int week) {
    selectedShoppingWeek =
        week.clamp(1, shoppingWeeksInSelectedMonth);
    notifyListeners();
  }

  List<ShoppingItem> get monthlyShoppingItems {
    final totals = <String, _ShoppingAccumulator>{};

    for (final entry in monthlyMealPlan.entries) {
      final date = DateTime.tryParse(entry.dateKey);
      if (date == null) continue;

      final week = ((date.day - 1) ~/ 7) + 1;
      final ingredients = <String>[];

      if (entry.recipeId != null) {
        Recipe? recipe;
        for (final candidate in recipes) {
          if (candidate.id == entry.recipeId) {
            recipe = candidate;
            break;
          }
        }
        ingredients.addAll(recipe?.ingredients ?? [entry.name]);
      } else {
        ingredients.add(entry.name);
      }

      for (final ingredient in ingredients) {
        final key = _normalize(ingredient);
        if (key.isEmpty || _pantryContains(key)) continue;

        final info = _ingredientInfo(ingredient);
        final servingScale =
            math.max(1.0, entry.servings / householdPeople);
        final accumulator = totals.putIfAbsent(
          '$week:$key',
          () => _ShoppingAccumulator(
            name: ingredient,
            quantity: 0,
            unit: info.unit,
            category: info.category,
            price: info.price,
            recipeNames: <String>{},
          ),
        );

        accumulator.quantity +=
            info.baseQuantity * servingScale;
        accumulator.recipeNames.add(entry.name);
        accumulator.dateKeys.add(entry.dateKey);
      }
    }

    final result = totals.entries.map((entry) {
      final separator = entry.key.indexOf(':');
      final week =
          int.tryParse(entry.key.substring(0, separator)) ?? 1;
      final key = entry.key.substring(separator + 1);
      final value = entry.value;

      return ShoppingItem(
        key: 'month-${monthlyMealPlan.monthKey}-w$week-$key',
        name: value.name,
        quantity: _roundQuantity(value.quantity),
        unit: value.unit,
        category: value.category,
        estimatedUnitPrice: value.price,
        recipeNames: value.recipeNames.toList()..sort(),
        week: week,
        sourceDateKeys: value.dateKeys.toList()..sort(),
      );
    }).toList()
      ..sort((a, b) {
        final weekCompare = a.week.compareTo(b.week);
        if (weekCompare != 0) return weekCompare;
        final categoryCompare = a.category.compareTo(b.category);
        if (categoryCompare != 0) return categoryCompare;
        return a.name.compareTo(b.name);
      });

    final edited = result
        .where((item) => !hiddenShoppingItems.contains(item.key))
        .map((item) => shoppingOverrides[item.key] ?? item)
        .toList();

    edited.addAll(
      manualShoppingItems.where(
        (item) => !hiddenShoppingItems.contains(item.key),
      ),
    );

    edited.sort((a, b) {
      final weekCompare = a.week.compareTo(b.week);
      if (weekCompare != 0) return weekCompare;
      final checkedCompare =
          isShoppingChecked(a.key) == isShoppingChecked(b.key)
              ? 0
              : isShoppingChecked(a.key)
                  ? 1
                  : -1;
      if (checkedCompare != 0) return checkedCompare;
      final categoryCompare = a.category.compareTo(b.category);
      if (categoryCompare != 0) return categoryCompare;
      return a.name.compareTo(b.name);
    });

    return edited;
  }

  List<ShoppingItem> shoppingItemsForWeek(int week) {
    return monthlyShoppingItems
        .where((item) => item.week == week)
        .toList();
  }

  List<ShoppingItem> get selectedWeeklyShoppingItems =>
      shoppingItemsForWeek(selectedShoppingWeek);

  double estimatedShoppingTotalForWeek(int week) {
    return shoppingItemsForWeek(week).fold(
      0,
      (total, item) => total + item.estimatedTotal,
    );
  }

  double get estimatedMonthlyPlanShoppingTotal =>
      monthlyShoppingItems.fold(
        0,
        (total, item) => total + item.estimatedTotal,
      );

  Map<String, List<ShoppingItem>>
      shoppingGroupsForSelectedWeek() {
    final groups = <String, List<ShoppingItem>>{};
    for (final item in selectedWeeklyShoppingItems) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }
    return groups;
  }

  int checkedShoppingCountForWeek(int week) {
    return shoppingItemsForWeek(week)
        .where((item) => isShoppingChecked(item.key))
        .length;
  }

  Future<void> clearShoppingChecksForWeek(int week) async {
    final weekKeys =
        shoppingItemsForWeek(week).map((item) => item.key).toSet();
    checkedShoppingItems.removeWhere(weekKeys.contains);
    await _saveShoppingChecks();
    notifyListeners();
  }

  static const _profilesStorageKey =
      'kitchen_navigator_kitchen_profiles_v1';
  static const _activeKitchenStorageKey =
      'kitchen_navigator_active_kitchen_v1';
  static const _nutritionGoalStorageKey =
      'kitchen_navigator_nutrition_goal_v1';

  String get _pantryStorageKey =>
      'kitchen_navigator_${activeKitchenId}_pantry_v1';
  String get _plannerStorageKey =>
      'kitchen_navigator_${activeKitchenId}_planner_v1';
  String get _pantryUsageStorageKey =>
      'kitchen_navigator_${activeKitchenId}_pantry_usage_v11';
  String get _shoppingChecksStorageKey =>
      'kitchen_navigator_${activeKitchenId}_shopping_checks_v1';
  String get _shoppingEditsStorageKey =>
      'kitchen_navigator_${activeKitchenId}_shopping_edits_v11';
  String get _equipmentStorageKey =>
      'kitchen_navigator_${activeKitchenId}_equipment_v1';
  String get _temperatureUnitStorageKey =>
      'kitchen_navigator_${activeKitchenId}_temperature_unit_v1';

  Future<void> _loadSavedData() async {
    final preferences = await SharedPreferences.getInstance();
    householdProfile = await HouseholdProfileService.load();
    monthlyMealPlan =
        await MonthlyMealPlanService.load(DateTime.now());
    cookingFeedback
      ..clear()
      ..addAll(await CookingFeedbackService.load());
    appNotifications
      ..clear()
      ..addAll(
        await NotificationCenterService.loadNotifications(),
      );
    notificationPreferences =
        await NotificationCenterService.loadPreferences();
    await refreshSmartNotifications();

    final profilesJson = preferences.getString(_profilesStorageKey);
    if (profilesJson != null && profilesJson.isNotEmpty) {
      final decoded = jsonDecode(profilesJson) as List<dynamic>;
      kitchenProfiles
        ..clear()
        ..addAll(
          decoded.map(
            (value) => _kitchenProfileFromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          ),
        );
    } else {
      kitchenProfiles.add(
        const KitchenProfile(
          id: 'home',
          name: 'Home',
          iconName: 'home',
        ),
      );
      await _saveKitchenProfiles();
    }

    activeKitchenId =
        preferences.getString(_activeKitchenStorageKey) ??
            kitchenProfiles.first.id;

    final savedGoal = preferences.getString(_nutritionGoalStorageKey);
    nutritionGoal = NutritionGoal.values.firstWhere(
      (goal) => goal.name == savedGoal,
      orElse: () => NutritionGoal.balanced,
    );

    if (!kitchenProfiles.any((item) => item.id == activeKitchenId)) {
      activeKitchenId = kitchenProfiles.first.id;
    }

    await _loadActiveKitchenData(preferences);
    dataLoaded = true;
    notifyListeners();
  }

  Future<void> _loadActiveKitchenData(
    SharedPreferences preferences,
  ) async {
    pantryItems.clear();
    pantryUsageEvents.clear();
    checkedShoppingItems.clear();
    shoppingOverrides.clear();
    manualShoppingItems.clear();
    hiddenShoppingItems.clear();
    kitchenAppliances.clear();
    for (final day in days) {
      _plan[day]?.clear();
    }

    try {
      final pantryJson = preferences.getString(_pantryStorageKey);
      if (pantryJson != null && pantryJson.isNotEmpty) {
        final decoded = jsonDecode(pantryJson) as List<dynamic>;
        pantryItems.addAll(
          decoded.map(
            (value) => _pantryItemFromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          ),
        );
      }

      final usageJson =
          preferences.getString(_pantryUsageStorageKey);
      if (usageJson != null && usageJson.isNotEmpty) {
        final decoded = jsonDecode(usageJson) as List<dynamic>;
        pantryUsageEvents.addAll(
          decoded.map(
            (value) => PantryUsageEvent.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          ),
        );
      }

      final plannerJson = preferences.getString(_plannerStorageKey);
      if (plannerJson != null && plannerJson.isNotEmpty) {
        final decoded =
            Map<String, dynamic>.from(jsonDecode(plannerJson) as Map);

        for (final day in days) {
          final savedMeals = decoded[day];
          if (savedMeals is! List) continue;

          final restored = <PlannedMeal>[];
          for (final value in savedMeals) {
            final map = Map<String, dynamic>.from(value as Map);
            final recipeId = map['recipeId'] as String?;
            final people = (map['people'] as num?)?.toInt() ?? 2;

            Recipe? recipe;
            for (final candidate in recipes) {
              if (candidate.id == recipeId) {
                recipe = candidate;
                break;
              }
            }

            if (recipe != null) {
              restored.add(
                PlannedMeal(
                  recipe: recipe,
                  people: people.clamp(1, 8),
                ),
              );
            }
          }

          _plan[day]
            ?..clear()
            ..addAll(restored);
        }
      }

      checkedShoppingItems.addAll(
        preferences.getStringList(_shoppingChecksStorageKey) ??
            const <String>[],
      );

      final shoppingEditsJson =
          preferences.getString(_shoppingEditsStorageKey);
      if (shoppingEditsJson != null &&
          shoppingEditsJson.isNotEmpty) {
        final decoded = Map<String, dynamic>.from(
          jsonDecode(shoppingEditsJson) as Map,
        );

        final overrides =
            decoded['overrides'] as List<dynamic>? ?? const [];
        for (final value in overrides) {
          final item = ShoppingItem.fromJson(
            Map<String, dynamic>.from(value as Map),
          );
          shoppingOverrides[item.key] = item;
        }

        manualShoppingItems.addAll(
          (decoded['manual'] as List<dynamic>? ?? const [])
              .map(
                (value) => ShoppingItem.fromJson(
                  Map<String, dynamic>.from(value as Map),
                ),
              ),
        );

        hiddenShoppingItems.addAll(
          (decoded['hidden'] as List<dynamic>? ?? const [])
              .map((value) => value.toString()),
        );
      }

      final equipmentJson =
          preferences.getString(_equipmentStorageKey);
      if (equipmentJson != null && equipmentJson.isNotEmpty) {
        final decoded = jsonDecode(equipmentJson) as List<dynamic>;
        kitchenAppliances.addAll(
          decoded.map(
            (value) => _applianceFromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          ),
        );
      }

      final unitName =
          preferences.getString(_temperatureUnitStorageKey);
      temperatureUnit =
          unitName == TemperatureUnit.fahrenheit.name
              ? TemperatureUnit.fahrenheit
              : TemperatureUnit.celsius;
    } catch (_) {
      pantryItems.clear();
      pantryUsageEvents.clear();
      checkedShoppingItems.clear();
      shoppingOverrides.clear();
      manualShoppingItems.clear();
      hiddenShoppingItems.clear();
      kitchenAppliances.clear();
      for (final day in days) {
        _plan[day]?.clear();
      }
    }
  }

  Future<void> saveHouseholdProfile(
    HouseholdProfile profile,
  ) async {
    householdProfile = profile;
    await HouseholdProfileService.save(profile);
    notifyListeners();
  }

  Future<void> _saveKitchenProfiles() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _profilesStorageKey,
      jsonEncode(
        kitchenProfiles.map(_kitchenProfileToJson).toList(),
      ),
    );
    await preferences.setString(
      _activeKitchenStorageKey,
      activeKitchenId,
    );
  }

  Future<void> switchKitchen(String kitchenId) async {
    if (kitchenId == activeKitchenId) return;
    if (!kitchenProfiles.any((item) => item.id == kitchenId)) return;

    activeKitchenId = kitchenId;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _activeKitchenStorageKey,
      activeKitchenId,
    );
    await _loadActiveKitchenData(preferences);
    notifyListeners();
  }

  Future<void> addKitchenProfile({
    required String name,
    required String iconName,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final profile = KitchenProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: trimmed,
      iconName: iconName,
    );

    kitchenProfiles.add(profile);
    await _saveKitchenProfiles();
    await switchKitchen(profile.id);
  }

  Future<void> updateKitchenProfile(
    KitchenProfile profile,
  ) async {
    final index = kitchenProfiles.indexWhere(
      (item) => item.id == profile.id,
    );
    if (index < 0) return;
    kitchenProfiles[index] = profile;
    await _saveKitchenProfiles();
    notifyListeners();
  }

  Future<void> removeKitchenProfile(String id) async {
    if (kitchenProfiles.length <= 1) return;

    final preferences = await SharedPreferences.getInstance();
    kitchenProfiles.removeWhere((item) => item.id == id);

    await preferences.remove(
      'kitchen_navigator_${id}_pantry_v1',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_pantry_usage_v11',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_planner_v1',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_shopping_checks_v1',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_shopping_edits_v11',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_equipment_v1',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_temperature_unit_v1',
    );

    if (activeKitchenId == id) {
      activeKitchenId = kitchenProfiles.first.id;
      await _loadActiveKitchenData(preferences);
    }

    await _saveKitchenProfiles();
    notifyListeners();
  }

  Map<String, dynamic> _kitchenProfileToJson(
    KitchenProfile profile,
  ) {
    return {
      'id': profile.id,
      'name': profile.name,
      'iconName': profile.iconName,
    };
  }

  KitchenProfile _kitchenProfileFromJson(
    Map<String, dynamic> json,
  ) {
    return KitchenProfile(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Kitchen',
      iconName: json['iconName'] as String? ?? 'home',
    );
  }

  Future<void> _savePantry() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      pantryItems.map(_pantryItemToJson).toList(),
    );
    await preferences.setString(_pantryStorageKey, encoded);
  }

  Future<void> _savePantryUsage() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _pantryUsageStorageKey,
      jsonEncode(
        pantryUsageEvents.map((event) => event.toJson()).toList(),
      ),
    );
  }

  Future<void> _savePlanner() async {
    final preferences = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};

    for (final day in days) {
      data[day] = (_plan[day] ?? const <PlannedMeal>[])
          .map(
            (meal) => {
              'recipeId': meal.recipe.id,
              'people': meal.people,
            },
          )
          .toList();
    }

    await preferences.setString(
      _plannerStorageKey,
      jsonEncode(data),
    );
  }

  Future<void> _saveShoppingChecks() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _shoppingChecksStorageKey,
      checkedShoppingItems.toList(),
    );
  }

  Future<void> _saveShoppingEdits() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _shoppingEditsStorageKey,
      jsonEncode({
        'overrides':
            shoppingOverrides.values.map((item) => item.toJson()).toList(),
        'manual':
            manualShoppingItems.map((item) => item.toJson()).toList(),
        'hidden': hiddenShoppingItems.toList(),
      }),
    );
  }

  Future<void> clearAllSavedData() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pantryStorageKey);
    await preferences.remove(_pantryUsageStorageKey);
    await preferences.remove(_plannerStorageKey);
    await preferences.remove(_shoppingChecksStorageKey);
    await preferences.remove(_shoppingEditsStorageKey);
    await preferences.remove(_equipmentStorageKey);
    await preferences.remove(_temperatureUnitStorageKey);
    await HouseholdProfileService.clear();
    await MonthlyMealPlanService.clear();

    householdProfile = HouseholdProfile.initial();
    monthlyMealPlan = MonthlyMealPlan.empty(DateTime.now());
    selectedPlannerDate = normalizedDate(DateTime.now());
    pantryItems.clear();
    pantryUsageEvents.clear();
    checkedShoppingItems.clear();
    shoppingOverrides.clear();
    manualShoppingItems.clear();
    hiddenShoppingItems.clear();
    kitchenAppliances.clear();
    temperatureUnit = TemperatureUnit.celsius;
    for (final day in days) {
      _plan[day]?.clear();
    }

    notifyListeners();
  }

  Future<void> _saveEquipment() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _equipmentStorageKey,
      jsonEncode(
        kitchenAppliances.map(_applianceToJson).toList(),
      ),
    );
    await preferences.setString(
      _temperatureUnitStorageKey,
      temperatureUnit.name,
    );
  }

  void setTemperatureUnit(TemperatureUnit value) {
    temperatureUnit = value;
    _saveEquipment();
    notifyListeners();
  }

  void addAppliance(KitchenAppliance appliance) {
    kitchenAppliances.add(appliance);
    _saveEquipment();
    notifyListeners();
  }

  void updateAppliance(KitchenAppliance appliance) {
    final index = kitchenAppliances.indexWhere(
      (item) => item.id == appliance.id,
    );
    if (index < 0) return;
    kitchenAppliances[index] = appliance;
    _saveEquipment();
    notifyListeners();
  }

  void removeAppliance(String id) {
    kitchenAppliances.removeWhere((item) => item.id == id);
    _saveEquipment();
    notifyListeners();
  }

  Map<String, dynamic> _applianceToJson(KitchenAppliance appliance) {
    return {
      'id': appliance.id,
      'type': appliance.type.name,
      'name': appliance.name,
      'minCelsius': appliance.minCelsius,
      'maxCelsius': appliance.maxCelsius,
      'preheatRequired': appliance.preheatRequired,
      'capacityLitres': appliance.capacityLitres,
      'powerWatts': appliance.powerWatts,
    };
  }

  KitchenAppliance _applianceFromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'fanOven';
    final type = ApplianceType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => ApplianceType.fanOven,
    );

    return KitchenAppliance(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      name: json['name'] as String? ?? type.defaultName,
      minCelsius: (json['minCelsius'] as num?)?.toInt() ??
          type.defaultMinCelsius,
      maxCelsius: (json['maxCelsius'] as num?)?.toInt() ??
          type.defaultMaxCelsius,
      preheatRequired:
          json['preheatRequired'] as bool? ?? type.usuallyPreheats,
      capacityLitres:
          (json['capacityLitres'] as num?)?.toDouble(),
      powerWatts: (json['powerWatts'] as num?)?.toInt(),
    );
  }

  int displayTemperature(int celsius) {
    if (temperatureUnit == TemperatureUnit.celsius) return celsius;
    return ((celsius * 9 / 5) + 32).round();
  }

  Map<String, dynamic> _pantryItemToJson(PantryItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'location': item.location.name,
      'expiryDate': item.expiryDate?.toIso8601String(),
      'barcode': item.barcode,
    };
  }

  PantryItem _pantryItemFromJson(Map<String, dynamic> json) {
    final locationName = json['location'] as String? ?? 'pantry';
    final location = StorageLocation.values.firstWhere(
      (value) => value.name == locationName,
      orElse: () => StorageLocation.pantry,
    );

    final expiryText = json['expiryDate'] as String?;

    return PantryItem(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Product',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? 'each',
      location: location,
      expiryDate:
          expiryText == null ? null : DateTime.tryParse(expiryText),
      barcode: json['barcode'] as String?,
    );
  }


  Map<String, Object> get diagnosticsSnapshot {
    return {
      'activeKitchen': activeKitchen.name,
      'kitchens': kitchenProfiles.length,
      'pantryItems': pantryItems.length,
      'pantryUsageEvents': pantryUsageEvents.length,
      'wasteRiskItems': wasteRiskItems.length,
      'restockSuggestions': restockSuggestedItems.length,
      'plannedMeals': days.fold<int>(
        0,
        (total, day) => total + mealsFor(day).length,
      ),
      'shoppingItems': shoppingItems.length,
      'appliances': kitchenAppliances.length,
      'expiredItems': expiredCount,
      'expiringSoon': expiringSoonCount,
      'lowStockItems': lowStockItems.length,
      'dataLoaded': dataLoaded,
      'householdSetupComplete': householdSetupComplete,
      'householdMembers': householdProfile.members.length,
      'monthlyPlanEntries': monthlyMealPlan.entries.length,
      'mealGenerationSummary': lastMealGenerationSummary,
      'cookingFeedbackCount': cookingFeedback.length,
      'familyAverageMealRating': familyAverageMealRating,
      'unreadNotifications': unreadNotificationCount,
      'nutritionCalories': todaysNutrition.calories,
      'budgetForecastStatus': budgetForecast.projectedStatus,
      'monthlyShoppingItems': monthlyShoppingItems.length,
      'manualShoppingItems': manualShoppingItems.length,
      'shoppingOverrides': shoppingOverrides.length,
      'selectedShoppingWeek': selectedShoppingWeek,
    };
  }


  NutritionTotals nutritionForDay(String day) {
    var total = NutritionTotals.zero;

    for (final meal in mealsFor(day)) {
      total += NutritionService.forRecipe(
        meal.recipe,
        servings: meal.people,
      );
    }

    return total;
  }

  NutritionTotals get todayNutrition =>
      nutritionForDay(todayName);

  NutritionTotals get weeklyNutrition {
    var total = NutritionTotals.zero;
    for (final day in days) {
      total += nutritionForDay(day);
    }
    return total;
  }

  NutritionTargets get nutritionTargets =>
      NutritionService.targetsFor(nutritionGoal);

  List<String> get nutritionAdvice =>
      NutritionService.advice(todayNutrition, nutritionTargets);

  Future<void> setNutritionGoal(NutritionGoal goal) async {
    nutritionGoal = goal;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _nutritionGoalStorageKey,
      goal.name,
    );
    notifyListeners();
  }


  List<MonthlyMealEntry> monthlyMealsFor(DateTime date) {
    return monthlyMealPlan.forDate(date);
  }

  void selectPlannerDate(DateTime date) {
    selectedPlannerDate = normalizedDate(date);
    notifyListeners();
  }

  Future<void> changePlannerMonth(DateTime month) async {
    monthlyMealPlan = await MonthlyMealPlanService.load(month);
    selectedPlannerDate = DateTime(month.year, month.month, 1);
    selectedShoppingWeek = 1;
    notifyListeners();
  }

  List<MealSlotType> get activeMealSlots {
    final result = <MealSlotType>[];

    if (householdProfile.mealsPerDay >= 1) {
      result.add(MealSlotType.breakfast);
    }
    if (householdProfile.snacksPerDay >= 1) {
      result.add(MealSlotType.morningSnack);
    }
    if (householdProfile.mealsPerDay >= 2) {
      result.add(MealSlotType.lunch);
    }
    if (householdProfile.snacksPerDay >= 2) {
      result.add(MealSlotType.afternoonSnack);
    }
    if (householdProfile.mealsPerDay >= 3) {
      result.add(MealSlotType.dinner);
    }
    if (householdProfile.snacksPerDay >= 3) {
      result.add(MealSlotType.eveningSnack);
    }

    return result;
  }

  Future<void> addSimpleMonthlyMeal({
    required DateTime date,
    required MealSlotType slot,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final entry = MonthlyMealEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dateKey: dateKeyFor(date),
      slot: slot,
      name: trimmed,
      servings: householdPeople,
      simpleFood: true,
    );

    monthlyMealPlan = monthlyMealPlan.copyWith(
      entries: [...monthlyMealPlan.entries, entry],
    );
    await MonthlyMealPlanService.save(monthlyMealPlan);
    notifyListeners();
  }

  Future<void> addRecipeMonthlyMeal({
    required DateTime date,
    required MealSlotType slot,
    required Recipe recipe,
  }) async {
    final entry = MonthlyMealEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dateKey: dateKeyFor(date),
      slot: slot,
      name: recipe.name,
      servings: householdPeople,
      recipeId: recipe.id,
    );

    monthlyMealPlan = monthlyMealPlan.copyWith(
      entries: [...monthlyMealPlan.entries, entry],
    );
    await MonthlyMealPlanService.save(monthlyMealPlan);
    notifyListeners();
  }

  Future<void> removeMonthlyMeal(String id) async {
    monthlyMealPlan = monthlyMealPlan.copyWith(
      entries: monthlyMealPlan.entries
          .where((entry) => entry.id != id)
          .toList(),
    );
    await MonthlyMealPlanService.save(monthlyMealPlan);
    notifyListeners();
  }

  Future<void> toggleMonthlyMealLock(String id) async {
    monthlyMealPlan = monthlyMealPlan.copyWith(
      entries: monthlyMealPlan.entries.map((entry) {
        if (entry.id != id) return entry;
        return entry.copyWith(locked: !entry.locked);
      }).toList(),
    );
    await MonthlyMealPlanService.save(monthlyMealPlan);
    notifyListeners();
  }

  Future<void> clearMonthlyDay(DateTime date) async {
    final key = dateKeyFor(date);
    monthlyMealPlan = monthlyMealPlan.copyWith(
      entries: monthlyMealPlan.entries
          .where((entry) => entry.dateKey != key || entry.locked)
          .toList(),
    );
    await MonthlyMealPlanService.save(monthlyMealPlan);
    notifyListeners();
  }

  Future<void> generateMonthlyFoundation() async {
    await generatePersonalizedMonth();
  }

  Future<void> generatePersonalizedMonth() async {
    await _runMealGeneration();
  }

  Future<void> regenerateMonthlyMeal(
    MonthlyMealEntry entry,
  ) async {
    if (entry.locked) return;
    final date = DateTime.tryParse(entry.dateKey);
    if (date == null) return;

    await _runMealGeneration(
      targetDate: date,
      targetSlot: entry.slot,
    );
  }

  Future<void> regenerateMonthlyDay(DateTime date) async {
    await _runMealGeneration(targetDate: date);
  }

  Future<void> regenerateMonthlyWeek(int week) async {
    await _runMealGeneration(targetWeek: week);
  }

  Future<void> _runMealGeneration({
    DateTime? targetDate,
    int? targetWeek,
    MealSlotType? targetSlot,
  }) async {
    final result = MealPlanGeneratorService.generate(
      MealPlanGenerationRequest(
        month: selectedPlannerDate,
        household: householdProfile,
        recipes: recipes,
        pantryItems: pantryItems,
        appliances: kitchenAppliances,
        activeSlots: activeMealSlots,
        existingEntries: monthlyMealPlan.entries,
        feedback: cookingFeedback,
        targetDate: targetDate,
        targetWeek: targetWeek,
        targetSlot: targetSlot,
      ),
    );

    monthlyMealPlan = result.plan;
    lastMealGenerationSummary = result.summary;
    await MonthlyMealPlanService.save(monthlyMealPlan);
    notifyListeners();
  }


  Map<int, List<MonthlyMealEntry>> get weeklyShoppingPeriods {
    final result = <int, List<MonthlyMealEntry>>{};
    for (final entry in monthlyMealPlan.entries) {
      final date = DateTime.parse(entry.dateKey);
      final week = ((date.day - 1) ~/ 7) + 1;
      result.putIfAbsent(week, () => []).add(entry);
    }
    return result;
  }



  NutritionSummary get todaysNutrition {
    return NutritionIntelligenceService.summarizeDay(
      date: DateTime.now(),
      entries: monthlyMealPlan.entries,
      recipes: recipes,
    );
  }


  bool get hasTodaysNutrition =>
      NutritionIntelligenceService.hasUsefulData(
        todaysNutrition,
      );

  List<FamilyMemberNutritionEstimate>
      get todaysFamilyNutritionEstimates {
    return NutritionIntelligenceService.allocateToFamily(
      household: todaysNutrition,
      profile: householdProfile,
    );
  }

  BudgetForecast get budgetForecast {
    return BudgetIntelligenceService.forecast(
      monthlyBudget: householdProfile.monthlyBudget,
      estimatedMonthlyCost: estimatedMonthlyPlanShoppingTotal,
    );
  }

  double get totalRecordedWasteQuantity {
    return pantryUsageEvents
        .where((event) => event.type == PantryUsageType.wasted)
        .fold<double>(
          0,
          (total, event) => total + event.quantity,
        );
  }

  int get unreadNotificationCount =>
      appNotifications.where((value) => !value.read).length;

  Future<void> saveNotificationPreferences(
    NotificationPreferences value,
  ) async {
    notificationPreferences = value;
    await NotificationCenterService.savePreferences(value);
    await refreshSmartNotifications();
    notifyListeners();
  }

  Future<void> markNotificationRead(String id) async {
    for (var i = 0; i < appNotifications.length; i++) {
      if (appNotifications[i].id == id) {
        appNotifications[i] =
            appNotifications[i].copyWith(read: true);
      }
    }
    await NotificationCenterService.saveNotifications(
      appNotifications,
    );
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    for (var i = 0; i < appNotifications.length; i++) {
      appNotifications[i] =
          appNotifications[i].copyWith(read: true);
    }
    await NotificationCenterService.saveNotifications(
      appNotifications,
    );
    notifyListeners();
  }

  Future<void> refreshSmartNotifications() async {
    final generated = <AppNotification>[];
    final now = DateTime.now();

    if (notificationPreferences.mealReminders &&
        todaysMonthlyMeals.isNotEmpty) {
      generated.add(
        AppNotification(
          id: 'meal-${dateKeyFor(now)}',
          type: AppNotificationType.meal,
          title: 'Today’s meal plan is ready',
          message:
              '${todaysMonthlyMeals.length} meal${todaysMonthlyMeals.length == 1 ? '' : 's'} planned for today.',
          createdAt: now,
        ),
      );
    }

    if (notificationPreferences.shoppingReminders &&
        selectedWeeklyShoppingItems.isNotEmpty &&
        checkedShoppingCountForWeek(selectedShoppingWeek) <
            selectedWeeklyShoppingItems.length) {
      final remaining = selectedWeeklyShoppingItems.length -
          checkedShoppingCountForWeek(selectedShoppingWeek);
      generated.add(
        AppNotification(
          id: 'shopping-${monthlyMealPlan.monthKey}-$selectedShoppingWeek',
          type: AppNotificationType.shopping,
          title: 'Shopping list needs attention',
          message:
              '$remaining product${remaining == 1 ? '' : 's'} remaining in Week $selectedShoppingWeek.',
          createdAt: now,
        ),
      );
    }

    if (notificationPreferences.expiryAlerts &&
        wasteRiskItems.isNotEmpty) {
      generated.add(
        AppNotification(
          id: 'expiry-${dateKeyFor(now)}',
          type: AppNotificationType.expiry,
          title: 'Use food before it expires',
          message:
              '${wasteRiskItems.length} pantry product${wasteRiskItems.length == 1 ? '' : 's'} may be wasted.',
          createdAt: now,
        ),
      );
    }

    if (notificationPreferences.budgetAlerts &&
        budgetForecast.remainingBudget < 0) {
      generated.add(
        AppNotification(
          id: 'budget-${monthlyMealPlan.monthKey}',
          type: AppNotificationType.budget,
          title: 'Monthly food budget forecast',
          message:
              'The current plan is €${budgetForecast.savingsTarget.toStringAsFixed(2)} over budget.',
          createdAt: now,
        ),
      );
    }

    if (notificationPreferences.planningReminders &&
        monthlyMealPlan.entries.isEmpty) {
      generated.add(
        AppNotification(
          id: 'planning-${monthlyMealPlan.monthKey}',
          type: AppNotificationType.planning,
          title: 'Create this month’s meal plan',
          message:
              'Generate a plan to unlock shopping, nutrition and budget forecasts.',
          createdAt: now,
        ),
      );
    }

    final previous = {
      for (final value in appNotifications) value.id: value,
    };

    appNotifications
      ..clear()
      ..addAll(
        generated.map(
          (value) => previous[value.id] == null
              ? value
              : value.copyWith(read: previous[value.id]!.read),
        ),
      );

    await NotificationCenterService.saveNotifications(
      appNotifications,
    );
  }

  Future<void> refreshCookingFeedback() async {
    cookingFeedback
      ..clear()
      ..addAll(await CookingFeedbackService.load());
    notifyListeners();
  }

  List<MonthlyMealEntry> get todaysMonthlyMeals {
    return monthlyMealsFor(DateTime.now());
  }

  int get todaysGuidedRecipeCount =>
      todaysMonthlyMeals.where((entry) => entry.recipeId != null).length;

  double get selectedShoppingWeekProgress {
    final items = selectedWeeklyShoppingItems;
    if (items.isEmpty) return 0;
    return checkedShoppingCountForWeek(selectedShoppingWeek) /
        items.length;
  }

  double get familyAverageMealRating {
    if (cookingFeedback.isEmpty) return 0;
    final total = cookingFeedback.fold<int>(
      0,
      (sum, value) => sum + value.rating,
    );
    return total / cookingFeedback.length;
  }

  Future<void> applyRecipePantryUsage(
    Recipe recipe, {
    required int servings,
  }) async {
    final scale = servings <= 0
        ? 1.0
        : servings / math.max(1, recipe.servings);

    for (final ingredient in recipe.ingredients) {
      final key = _normalize(ingredient);
      PantryItem? match;

      for (final item in pantryItems) {
        final itemKey = _normalize(item.name);
        if (itemKey == key ||
            itemKey.contains(key) ||
            key.contains(itemKey)) {
          match = item;
          break;
        }
      }

      if (match == null) continue;

      final amount = _defaultUsageAmount(match) * scale;
      await consumePantryItem(
        match.id,
        quantity: amount.clamp(0.0, match.quantity).toDouble(),
      );
    }
  }

  void selectDay(String day) {
    selectedDay = day;
    notifyListeners();
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  bool containsRecipe(String day, String id) =>
      (_plan[day] ?? []).any((meal) => meal.recipe.id == id);

  void toggleRecipe(String day, Recipe recipe) {
    final meals = _plan[day]!;
    final index = meals.indexWhere((meal) => meal.recipe.id == recipe.id);
    if (index >= 0) {
      meals.removeAt(index);
    } else {
      meals.add(PlannedMeal(recipe: recipe, people: 2));
    }
    checkedShoppingItems.clear();
    _savePlanner();
    _saveShoppingChecks();
    notifyListeners();
  }

  void setPeople(String day, String recipeId, int value) {
    final meals = _plan[day]!;
    final index = meals.indexWhere((meal) => meal.recipe.id == recipeId);
    if (index < 0) return;
    meals[index] = meals[index].copyWith(people: value.clamp(1, 8));
    checkedShoppingItems.clear();
    _savePlanner();
    _saveShoppingChecks();
    notifyListeners();
  }

  void clearDay(String day) {
    _plan[day]?.clear();
    checkedShoppingItems.clear();
    _savePlanner();
    _saveShoppingChecks();
    notifyListeners();
  }

  void setPantryFilter(StorageLocation? value) {
    pantryFilter = value;
    notifyListeners();
  }

  void setPantrySearch(String value) {
    pantrySearch = value;
    notifyListeners();
  }

  void addPantryItem({
    required String name,
    required double quantity,
    required String unit,
    required StorageLocation location,
    DateTime? expiryDate,
    String? barcode,
  }) {
    pantryItems.add(
      PantryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        quantity: quantity,
        unit: unit.trim(),
        location: location,
        expiryDate: expiryDate,
        barcode: barcode?.trim().isEmpty == true ? null : barcode?.trim(),
      ),
    );
    checkedShoppingItems.remove(_normalize(name));
    _savePantry();
    _saveShoppingChecks();
    notifyListeners();
  }

  void updatePantryItem(PantryItem updatedItem) {
    final index = pantryItems.indexWhere((item) => item.id == updatedItem.id);
    if (index < 0) return;
    pantryItems[index] = updatedItem;
    _savePantry();
    notifyListeners();
  }

  void removePantryItem(String id) {
    pantryItems.removeWhere((item) => item.id == id);
    _savePantry();
    notifyListeners();
  }

  Future<void> updateShoppingItem(
    ShoppingItem item,
  ) async {
    if (item.manual) {
      final index = manualShoppingItems.indexWhere(
        (value) => value.key == item.key,
      );
      if (index >= 0) {
        manualShoppingItems[index] = item;
      }
    } else {
      shoppingOverrides[item.key] = item;
    }
    await _saveShoppingEdits();
    notifyListeners();
  }

  Future<void> addManualShoppingItem({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required int week,
    double estimatedUnitPrice = 1,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || quantity <= 0) return;

    manualShoppingItems.add(
      ShoppingItem(
        key:
            'manual-${DateTime.now().microsecondsSinceEpoch}',
        name: trimmed,
        quantity: quantity,
        unit: unit.trim().isEmpty ? 'each' : unit.trim(),
        category: category,
        estimatedUnitPrice:
            estimatedUnitPrice.clamp(0.0, 10000).toDouble(),
        recipeNames: const [],
        week: week.clamp(1, shoppingWeeksInSelectedMonth),
        manual: true,
      ),
    );
    await _saveShoppingEdits();
    notifyListeners();
  }

  Future<void> removeShoppingItem(String key) async {
    hiddenShoppingItems.add(key);
    checkedShoppingItems.remove(key);
    await _saveShoppingEdits();
    await _saveShoppingChecks();
    notifyListeners();
  }

  Future<void> restoreShoppingItem(String key) async {
    hiddenShoppingItems.remove(key);
    await _saveShoppingEdits();
    notifyListeners();
  }

  double shoppingQuantityStep(ShoppingItem item) {
    switch (item.unit.trim().toLowerCase()) {
      case 'kg':
      case 'l':
        return .1;
      case 'g':
      case 'ml':
        return 50;
      default:
        return 1;
    }
  }

  Future<void> changeShoppingQuantity(
    ShoppingItem item,
    double delta,
  ) async {
    final updated = item.copyWith(
      quantity:
          (item.quantity + delta).clamp(.01, 100000).toDouble(),
    );
    await updateShoppingItem(updated);
  }

  void toggleShoppingChecked(String key) {
    if (!checkedShoppingItems.add(key)) {
      checkedShoppingItems.remove(key);
    }
    _saveShoppingChecks();
    notifyListeners();
  }

  bool isShoppingChecked(String key) => checkedShoppingItems.contains(key);

  void purchaseShoppingItem({
    required ShoppingItem item,
    required StorageLocation location,
    DateTime? expiryDate,
    String? barcode,
  }) {
    addPantryItem(
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      location: location,
      expiryDate: expiryDate,
      barcode: barcode,
    );
  }

  bool _pantryContains(String ingredientKey) {
    return pantryItems.any((item) {
      if (item.quantity <= 0) return false;
      final pantryKey = _normalize(item.name);
      return pantryKey == ingredientKey ||
          pantryKey.contains(ingredientKey) ||
          ingredientKey.contains(pantryKey);
    });
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static double _roundQuantity(double value) =>
      (value * 10).roundToDouble() / 10;

  static _IngredientInfo _ingredientInfo(String name) {
    final key = _normalize(name);

    if (key.contains('chicken') || key.contains('salmon')) {
      return const _IngredientInfo(
        baseQuantity: 250,
        unit: 'g',
        category: 'Meat & Fish',
        price: 0.012,
      );
    }

    if (key.contains('milk') || key.contains('coconut milk')) {
      return const _IngredientInfo(
        baseQuantity: 0.5,
        unit: 'L',
        category: 'Dairy & Chilled',
        price: 1.80,
      );
    }

    if (key.contains('butter') ||
        key.contains('parmesan') ||
        key.contains('feta')) {
      return const _IngredientInfo(
        baseQuantity: 1,
        unit: 'pack',
        category: 'Dairy & Chilled',
        price: 2.50,
      );
    }

    if (key.contains('egg')) {
      return const _IngredientInfo(
        baseQuantity: 4,
        unit: 'each',
        category: 'Dairy & Chilled',
        price: 0.35,
      );
    }

    if (key.contains('potato') ||
        key.contains('tomato') ||
        key.contains('onion') ||
        key.contains('cucumber') ||
        key.contains('lemon')) {
      return const _IngredientInfo(
        baseQuantity: 2,
        unit: 'each',
        category: 'Fruit & Vegetables',
        price: 0.60,
      );
    }

    if (key.contains('pasta')) {
      return const _IngredientInfo(
        baseQuantity: 250,
        unit: 'g',
        category: 'Pantry',
        price: 0.004,
      );
    }

    if (key.contains('salt') ||
        key.contains('pepper') ||
        key.contains('curry powder')) {
      return const _IngredientInfo(
        baseQuantity: 1,
        unit: 'pack',
        category: 'Herbs & Spices',
        price: 1.20,
      );
    }

    if (key.contains('pesto')) {
      return const _IngredientInfo(
        baseQuantity: 1,
        unit: 'jar',
        category: 'Pantry',
        price: 2.50,
      );
    }

    return const _IngredientInfo(
      baseQuantity: 1,
      unit: 'each',
      category: 'Other',
      price: 1.50,
    );
  }
}

class _IngredientInfo {
  const _IngredientInfo({
    required this.baseQuantity,
    required this.unit,
    required this.category,
    required this.price,
  });

  final double baseQuantity;
  final String unit;
  final String category;
  final double price;
}

class _ShoppingAccumulator {
  _ShoppingAccumulator({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.price,
    required this.recipeNames,
  });

  final String name;
  double quantity;
  final String unit;
  final String category;
  final double price;
  final Set<String> recipeNames;
  final Set<String> dateKeys = <String>{};
}
