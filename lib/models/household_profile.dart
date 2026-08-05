enum FamilyMemberType { adult, child }

enum DietaryPreference {
  none,
  vegetarian,
  vegan,
  pescatarian,
  glutenFree,
  dairyFree,
  lowCarb,
  highProtein,
  mediterranean,
  diabeticFriendly,
}

extension DietaryPreferenceLabel on DietaryPreference {
  String get label {
    switch (this) {
      case DietaryPreference.none:
        return 'No special diet';
      case DietaryPreference.vegetarian:
        return 'Vegetarian';
      case DietaryPreference.vegan:
        return 'Vegan';
      case DietaryPreference.pescatarian:
        return 'Pescatarian';
      case DietaryPreference.glutenFree:
        return 'Gluten free';
      case DietaryPreference.dairyFree:
        return 'Dairy free';
      case DietaryPreference.lowCarb:
        return 'Low carb';
      case DietaryPreference.highProtein:
        return 'High protein';
      case DietaryPreference.mediterranean:
        return 'Mediterranean';
      case DietaryPreference.diabeticFriendly:
        return 'Diabetic friendly';
    }
  }
}

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.type,
    required this.age,
    this.dietaryPreferences = const [],
    this.allergies = const [],
    this.likes = const [],
    this.dislikes = const [],
  });

  final String id;
  final String name;
  final FamilyMemberType type;
  final int age;
  final List<DietaryPreference> dietaryPreferences;
  final List<String> allergies;
  final List<String> likes;
  final List<String> dislikes;

  FamilyMember copyWith({
    String? name,
    FamilyMemberType? type,
    int? age,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
    List<String>? likes,
    List<String>? dislikes,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      dietaryPreferences:
          dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'age': age,
      'dietaryPreferences':
          dietaryPreferences.map((value) => value.name).toList(),
      'allergies': allergies,
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'adult';

    return FamilyMember(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Family member',
      type: FamilyMemberType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => FamilyMemberType.adult,
      ),
      age: (json['age'] as num?)?.toInt() ?? 18,
      dietaryPreferences:
          (json['dietaryPreferences'] as List<dynamic>? ??
                  const <dynamic>[])
              .map((value) => DietaryPreference.values.firstWhere(
                    (preference) => preference.name == value,
                    orElse: () => DietaryPreference.none,
                  ))
              .where((value) => value != DietaryPreference.none)
              .toList(),
      allergies: _strings(json['allergies']),
      likes: _strings(json['likes']),
      dislikes: _strings(json['dislikes']),
    );
  }

  static List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

class HouseholdProfile {
  const HouseholdProfile({
    required this.householdName,
    required this.members,
    required this.mealsPerDay,
    required this.snacksPerDay,
    required this.monthlyBudget,
    required this.preferredCuisines,
    required this.maxWeekdayCookingMinutes,
    required this.usePantryFirst,
    required this.useLeftovers,
    required this.setupComplete,
  });

  factory HouseholdProfile.initial() {
    return const HouseholdProfile(
      householdName: 'My Family Kitchen',
      members: [],
      mealsPerDay: 3,
      snacksPerDay: 1,
      monthlyBudget: 500,
      preferredCuisines: ['Mediterranean'],
      maxWeekdayCookingMinutes: 30,
      usePantryFirst: true,
      useLeftovers: true,
      setupComplete: false,
    );
  }

  final String householdName;
  final List<FamilyMember> members;
  final int mealsPerDay;
  final int snacksPerDay;
  final double monthlyBudget;
  final List<String> preferredCuisines;
  final int maxWeekdayCookingMinutes;
  final bool usePantryFirst;
  final bool useLeftovers;
  final bool setupComplete;

  int get adults =>
      members.where((item) => item.type == FamilyMemberType.adult).length;

  int get children =>
      members.where((item) => item.type == FamilyMemberType.child).length;

  int get people => members.length;

  Set<String> get householdAllergies => members
      .expand((member) => member.allergies)
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();

  Set<DietaryPreference> get householdDietaryPreferences =>
      members.expand((member) => member.dietaryPreferences).toSet();

  HouseholdProfile copyWith({
    String? householdName,
    List<FamilyMember>? members,
    int? mealsPerDay,
    int? snacksPerDay,
    double? monthlyBudget,
    List<String>? preferredCuisines,
    int? maxWeekdayCookingMinutes,
    bool? usePantryFirst,
    bool? useLeftovers,
    bool? setupComplete,
  }) {
    return HouseholdProfile(
      householdName: householdName ?? this.householdName,
      members: members ?? this.members,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      snacksPerDay: snacksPerDay ?? this.snacksPerDay,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      preferredCuisines:
          preferredCuisines ?? this.preferredCuisines,
      maxWeekdayCookingMinutes:
          maxWeekdayCookingMinutes ?? this.maxWeekdayCookingMinutes,
      usePantryFirst: usePantryFirst ?? this.usePantryFirst,
      useLeftovers: useLeftovers ?? this.useLeftovers,
      setupComplete: setupComplete ?? this.setupComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'householdName': householdName,
      'members': members.map((member) => member.toJson()).toList(),
      'mealsPerDay': mealsPerDay,
      'snacksPerDay': snacksPerDay,
      'monthlyBudget': monthlyBudget,
      'preferredCuisines': preferredCuisines,
      'maxWeekdayCookingMinutes': maxWeekdayCookingMinutes,
      'usePantryFirst': usePantryFirst,
      'useLeftovers': useLeftovers,
      'setupComplete': setupComplete,
    };
  }

  factory HouseholdProfile.fromJson(Map<String, dynamic> json) {
    return HouseholdProfile(
      householdName:
          json['householdName'] as String? ?? 'My Family Kitchen',
      members: (json['members'] as List<dynamic>? ??
              const <dynamic>[])
          .map(
            (value) => FamilyMember.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(),
      mealsPerDay:
          ((json['mealsPerDay'] as num?)?.toInt() ?? 3).clamp(1, 6),
      snacksPerDay:
          ((json['snacksPerDay'] as num?)?.toInt() ?? 1).clamp(0, 4),
      monthlyBudget:
          ((json['monthlyBudget'] as num?)?.toDouble() ?? 500)
              .clamp(0, 100000),
      preferredCuisines:
          FamilyMember._strings(json['preferredCuisines']),
      maxWeekdayCookingMinutes:
          ((json['maxWeekdayCookingMinutes'] as num?)?.toInt() ??
                  30)
              .clamp(5, 240),
      usePantryFirst: json['usePantryFirst'] as bool? ?? true,
      useLeftovers: json['useLeftovers'] as bool? ?? true,
      setupComplete: json['setupComplete'] as bool? ?? false,
    );
  }
}
