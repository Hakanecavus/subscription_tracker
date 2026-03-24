import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _notifications;

  NotificationScheduler(this._notifications);

  Future<void> schedulePaymentReminder(Subscription sub) async {
    if (!sub.hasReminder || !sub.isActive) {
      await cancelNotifications(sub.id);
      return;
    }

    final reminderDays = sub.reminderDays;
    if (reminderDays == null || reminderDays.isEmpty) return;

    for (final daysBefore in reminderDays) {
      final notificationDate = sub.nextBillingDate.subtract(Duration(days: daysBefore));

      if (notificationDate.isBefore(DateTime.now())) continue;

      // Create a unique deterministic ID for each reminder based on subscription ID and days before
      final id = (sub.id + daysBefore.toString()).hashCode.abs();

      await _notifications.zonedSchedule(
        id,
        'Payment Due Soon',
        '${sub.name} - ${sub.amount} ${sub.currency} due in $daysBefore days',
        tz.TZDateTime.from(notificationDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'payment_reminders',
            'Payment Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotifications(String subscriptionId) async {
    // Note: cancellation by ID in a loop could be implemented if we track the generated IDs.
    // For simplicity, without a dedicated database table for notifications, we cancel all.
    // In a full implementation, we might store these IDs or calculate them again.
    // We can cancel by the predictable IDs based on reminderDays 1, 3, 7 (or whatever defaults).
    final defaultDays = [1, 2, 3, 4, 5, 6, 7];
    for (final days in defaultDays) {
      final id = (subscriptionId + days.toString()).hashCode.abs();
      await _notifications.cancel(id);
    }
  }
}
