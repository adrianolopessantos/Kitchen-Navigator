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
  });

  final String key;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final double estimatedUnitPrice;
  final List<String> recipeNames;

  double get estimatedTotal => quantity * estimatedUnitPrice;
}

class AppState extends ChangeNotifier {
  AppState() {
    _loadSavedData();
  }

  bool dataLoaded = false;

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
  final Set<String> checkedShoppingItems = {};
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

  void markPantryItemUsed(String id) {
    removePantryItem(id);
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
  String get _shoppingChecksStorageKey =>
      'kitchen_navigator_${activeKitchenId}_shopping_checks_v1';
  String get _equipmentStorageKey =>
      'kitchen_navigator_${activeKitchenId}_equipment_v1';
  String get _temperatureUnitStorageKey =>
      'kitchen_navigator_${activeKitchenId}_temperature_unit_v1';

  Future<void> _loadSavedData() async {
    final preferences = await SharedPreferences.getInstance();

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
    checkedShoppingItems.clear();
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
      checkedShoppingItems.clear();
      kitchenAppliances.clear();
      for (final day in days) {
        _plan[day]?.clear();
      }
    }
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
      'kitchen_navigator_${id}_planner_v1',
    );
    await preferences.remove(
      'kitchen_navigator_${id}_shopping_checks_v1',
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

  Future<void> clearAllSavedData() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pantryStorageKey);
    await preferences.remove(_plannerStorageKey);
    await preferences.remove(_shoppingChecksStorageKey);
    await preferences.remove(_equipmentStorageKey);
    await preferences.remove(_temperatureUnitStorageKey);

    pantryItems.clear();
    checkedShoppingItems.clear();
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
}
