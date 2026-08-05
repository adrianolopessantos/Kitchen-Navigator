import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/notification_center_service.dart';
import 'package:kitchen_navigator/models/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Notification preferences persist', () async {
    SharedPreferences.setMockInitialValues({});

    const preferences = NotificationPreferences(
      expiryAlerts: false,
      budgetAlerts: true,
      shoppingReminders: false,
    );

    await NotificationCenterService.savePreferences(preferences);
    final restored =
        await NotificationCenterService.loadPreferences();

    expect(restored.expiryAlerts, isFalse);
    expect(restored.budgetAlerts, isTrue);
    expect(restored.shoppingReminders, isFalse);
  });

  test('Notification center saves read state', () async {
    SharedPreferences.setMockInitialValues({});

    final values = [
      AppNotification(
        id: '1',
        type: AppNotificationType.shopping,
        title: 'Shopping',
        message: 'List ready',
        createdAt: DateTime(2026, 8, 5),
        read: true,
      ),
    ];

    await NotificationCenterService.saveNotifications(values);
    final restored =
        await NotificationCenterService.loadNotifications();

    expect(restored.single.read, isTrue);
  });
}
