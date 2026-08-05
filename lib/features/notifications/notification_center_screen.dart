import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_notification.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final notifications = state.appNotifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification center'),
        actions: [
          TextButton(
            onPressed: notifications.isEmpty
                ? null
                : state.markAllNotificationsRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No smart notifications right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final value = notifications[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_icon(value.type)),
                    ),
                    title: Text(
                      value.title,
                      style: TextStyle(
                        fontWeight: value.read
                            ? FontWeight.w600
                            : FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(value.message),
                    trailing: value.read
                        ? const Icon(Icons.done)
                        : const Icon(
                            Icons.circle,
                            size: 10,
                            color: AppColors.primary,
                          ),
                    onTap: () =>
                        state.markNotificationRead(value.id),
                  ),
                );
              },
            ),
    );
  }

  IconData _icon(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.meal:
        return Icons.restaurant_menu;
      case AppNotificationType.shopping:
        return Icons.shopping_cart_outlined;
      case AppNotificationType.expiry:
        return Icons.event_busy_outlined;
      case AppNotificationType.budget:
        return Icons.account_balance_wallet_outlined;
      case AppNotificationType.planning:
        return Icons.calendar_month_outlined;
      case AppNotificationType.pantry:
        return Icons.inventory_2_outlined;
    }
  }
}

Future<void> openNotificationCenter(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => const NotificationCenterScreen(),
    ),
  );
}
