enum MealSlotType {
  breakfast,
  morningSnack,
  lunch,
  afternoonSnack,
  dinner,
  eveningSnack,
}

extension MealSlotTypeLabel on MealSlotType {
  String get label {
    switch (this) {
      case MealSlotType.breakfast:
        return 'Breakfast';
      case MealSlotType.morningSnack:
        return 'Morning snack';
      case MealSlotType.lunch:
        return 'Lunch';
      case MealSlotType.afternoonSnack:
        return 'Afternoon snack';
      case MealSlotType.dinner:
        return 'Dinner';
      case MealSlotType.eveningSnack:
        return 'Evening snack';
    }
  }

  bool get isSnack =>
      this == MealSlotType.morningSnack ||
      this == MealSlotType.afternoonSnack ||
      this == MealSlotType.eveningSnack;
}

class MonthlyMealEntry {
  const MonthlyMealEntry({
    required this.id,
    required this.dateKey,
    required this.slot,
    required this.name,
    required this.servings,
    this.recipeId,
    this.simpleFood = false,
    this.locked = false,
    this.suggestionReason = '',
    this.generationSource = 'manual',
  });

  final String id;
  final String dateKey;
  final MealSlotType slot;
  final String name;
  final int servings;
  final String? recipeId;
  final bool simpleFood;
  final bool locked;
  final String suggestionReason;
  final String generationSource;

  MonthlyMealEntry copyWith({
    String? name,
    int? servings,
    bool? locked,
    String? suggestionReason,
    String? generationSource,
  }) {
    return MonthlyMealEntry(
      id: id,
      dateKey: dateKey,
      slot: slot,
      name: name ?? this.name,
      servings: servings ?? this.servings,
      recipeId: recipeId,
      simpleFood: simpleFood,
      locked: locked ?? this.locked,
      suggestionReason:
          suggestionReason ?? this.suggestionReason,
      generationSource:
          generationSource ?? this.generationSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'slot': slot.name,
      'name': name,
      'servings': servings,
      'recipeId': recipeId,
      'simpleFood': simpleFood,
      'locked': locked,
      'suggestionReason': suggestionReason,
      'generationSource': generationSource,
    };
  }

  factory MonthlyMealEntry.fromJson(Map<String, dynamic> json) {
    return MonthlyMealEntry(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      dateKey: json['dateKey'] as String? ?? dateKeyFor(DateTime.now()),
      slot: MealSlotType.values.firstWhere(
        (value) => value.name == json['slot'],
        orElse: () => MealSlotType.dinner,
      ),
      name: json['name'] as String? ?? 'Meal',
      servings: ((json['servings'] as num?)?.toInt() ?? 1).clamp(1, 20),
      recipeId: json['recipeId'] as String?,
      simpleFood: json['simpleFood'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      suggestionReason:
          json['suggestionReason'] as String? ?? '',
      generationSource:
          json['generationSource'] as String? ?? 'manual',
    );
  }
}

class MonthlyMealPlan {
  const MonthlyMealPlan({
    required this.monthKey,
    required this.entries,
  });

  final String monthKey;
  final List<MonthlyMealEntry> entries;

  factory MonthlyMealPlan.empty(DateTime month) {
    return MonthlyMealPlan(
      monthKey: monthKeyFor(month),
      entries: const [],
    );
  }

  List<MonthlyMealEntry> forDate(DateTime date) {
    final key = dateKeyFor(date);
    final result = entries.where((entry) => entry.dateKey == key).toList()
      ..sort((a, b) => a.slot.index.compareTo(b.slot.index));
    return result;
  }

  MonthlyMealPlan copyWith({
    String? monthKey,
    List<MonthlyMealEntry>? entries,
  }) {
    return MonthlyMealPlan(
      monthKey: monthKey ?? this.monthKey,
      entries: entries ?? this.entries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthKey': monthKey,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }

  factory MonthlyMealPlan.fromJson(Map<String, dynamic> json) {
    return MonthlyMealPlan(
      monthKey: json['monthKey'] as String? ??
          monthKeyFor(DateTime.now()),
      entries: (json['entries'] as List<dynamic>? ?? const [])
          .map(
            (value) => MonthlyMealEntry.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(),
    );
  }
}

String dateKeyFor(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String monthKeyFor(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}

DateTime normalizedDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
