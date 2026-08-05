enum AppNotificationType {
  meal,
  shopping,
  expiry,
  budget,
  planning,
  pantry,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: AppNotificationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => AppNotificationType.planning,
      ),
      title: json['title'] as String? ?? 'Kitchen Navigator',
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      read: json['read'] as bool? ?? false,
    );
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    this.mealReminders = true,
    this.shoppingReminders = true,
    this.expiryAlerts = true,
    this.budgetAlerts = true,
    this.planningReminders = true,
    this.quietHoursEnabled = true,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
  });

  final bool mealReminders;
  final bool shoppingReminders;
  final bool expiryAlerts;
  final bool budgetAlerts;
  final bool planningReminders;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;

  NotificationPreferences copyWith({
    bool? mealReminders,
    bool? shoppingReminders,
    bool? expiryAlerts,
    bool? budgetAlerts,
    bool? planningReminders,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return NotificationPreferences(
      mealReminders: mealReminders ?? this.mealReminders,
      shoppingReminders:
          shoppingReminders ?? this.shoppingReminders,
      expiryAlerts: expiryAlerts ?? this.expiryAlerts,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      planningReminders:
          planningReminders ?? this.planningReminders,
      quietHoursEnabled:
          quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }

  Map<String, dynamic> toJson() => {
        'mealReminders': mealReminders,
        'shoppingReminders': shoppingReminders,
        'expiryAlerts': expiryAlerts,
        'budgetAlerts': budgetAlerts,
        'planningReminders': planningReminders,
        'quietHoursEnabled': quietHoursEnabled,
        'quietStartHour': quietStartHour,
        'quietEndHour': quietEndHour,
      };

  factory NotificationPreferences.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationPreferences(
      mealReminders: json['mealReminders'] as bool? ?? true,
      shoppingReminders:
          json['shoppingReminders'] as bool? ?? true,
      expiryAlerts: json['expiryAlerts'] as bool? ?? true,
      budgetAlerts: json['budgetAlerts'] as bool? ?? true,
      planningReminders:
          json['planningReminders'] as bool? ?? true,
      quietHoursEnabled:
          json['quietHoursEnabled'] as bool? ?? true,
      quietStartHour:
          ((json['quietStartHour'] as num?)?.toInt() ?? 22)
              .clamp(0, 23),
      quietEndHour:
          ((json['quietEndHour'] as num?)?.toInt() ?? 7)
              .clamp(0, 23),
    );
  }
}
