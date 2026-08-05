import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_notification.dart';

abstract final class NotificationCenterService {
  static const _notificationsKey =
      'kitchen_navigator_notifications_v11';
  static const _preferencesKey =
      'kitchen_navigator_notification_preferences_v11';

  static Future<List<AppNotification>> loadNotifications() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_notificationsKey);
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map(
            (value) => AppNotification.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotifications(
    List<AppNotification> values,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _notificationsKey,
      jsonEncode(values.map((value) => value.toJson()).toList()),
    );
  }

  static Future<NotificationPreferences>
      loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_preferencesKey);
    if (encoded == null || encoded.isEmpty) {
      return const NotificationPreferences();
    }

    try {
      return NotificationPreferences.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );
    } catch (_) {
      return const NotificationPreferences();
    }
  }

  static Future<void> savePreferences(
    NotificationPreferences value,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _preferencesKey,
      jsonEncode(value.toJson()),
    );
  }
}
