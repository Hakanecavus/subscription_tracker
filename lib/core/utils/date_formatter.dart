import 'package:intl/intl.dart';

/// Utility class for date formatting
class DateFormatter {
  DateFormatter._();

  // Short date (e.g., "Jan 15, 2024")
  static final DateFormat shortDate = DateFormat('MMM d, y');

  // Long date (e.g., "January 15, 2024")
  static final DateFormat longDate = DateFormat('MMMM d, y');

  // Short date time (e.g., "Jan 15, 2024 14:30")
  static final DateFormat shortDateTime = DateFormat('MMM d, y HH:mm');

  // Month year (e.g., "Jan 2024")
  static final DateFormat monthYear = DateFormat('MMM y');

  // ISO date (e.g., "2024-01-15")
  static final DateFormat isoDate = DateFormat('yyyy-MM-dd');

  // Day of week (e.g., "Monday")
  static final DateFormat dayOfWeek = DateFormat('EEEE');

  // Short day of week (e.g., "Mon")
  static final DateFormat shortDayOfWeek = DateFormat('EEE');

  // Time only (e.g., "14:30")
  static final DateFormat timeOnly = DateFormat('HH:mm');

  // Relative format
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays.abs() == 0) {
      if (difference.inHours.abs() < 1) {
        return difference.isNegative ? 'Just now' : 'In a moment';
      }
      final hours = difference.inHours.abs();
      return difference.isNegative ? '$hours hours ago' : 'In $hours hours';
    } else if (difference.inDays.abs() == 1) {
      return difference.isNegative ? 'Yesterday' : 'Tomorrow';
    } else if (difference.inDays.abs() < 7) {
      final days = difference.inDays.abs();
      return difference.isNegative ? '$days days ago' : 'In $days days';
    } else if (difference.inDays.abs() < 30) {
      final weeks = (difference.inDays.abs() / 7).floor();
      return difference.isNegative ? '$weeks weeks ago' : 'In $weeks weeks';
    } else {
      return shortDate.format(date);
    }
  }

  // Format days remaining
  static String formatDaysRemaining(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 0) return '${days.abs()} days overdue';
    return '$days days remaining';
  }

  // Format billing cycle text
  static String formatBillingCycle(String cycle, DateTime nextBilling) {
    final days = nextBilling.difference(DateTime.now()).inDays;
    final relative = formatDaysRemaining(days);
    return '$cycle • $relative';
  }
}
