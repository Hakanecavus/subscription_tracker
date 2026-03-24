import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:timezone/timezone.dart' as tz;

class PaymentDateCalculator {
  static DateTime calculateNextPaymentDate({
    required DateTime startDate,
    required BillingCycle cycle,
    required String timezone,
    DateTime? fromDate,
  }) {
    // Basic fallback if location is not found, although package should be initialized
    tz.Location location;
    try {
      location = tz.getLocation(timezone);
    } catch (_) {
      location = tz.local;
    }

    final tz.TZDateTime start = tz.TZDateTime.from(startDate, location);
    final tz.TZDateTime now = fromDate != null
        ? tz.TZDateTime.from(fromDate, location)
        : tz.TZDateTime.now(location);

    tz.TZDateTime nextPayment = tz.TZDateTime(
      start.location, start.year, start.month, start.day, start.hour, start.minute,
    );

    while (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now)) {
      switch (cycle) {
        case BillingCycle.weekly:
          nextPayment = nextPayment.add(const Duration(days: 7));
          break;
        case BillingCycle.biWeekly:
          nextPayment = nextPayment.add(const Duration(days: 14));
          break;
        case BillingCycle.monthly:
          nextPayment = _addMonths(nextPayment, 1);
          break;
        case BillingCycle.quarterly:
          nextPayment = _addMonths(nextPayment, 3);
          break;
        case BillingCycle.halfYearly:
          nextPayment = _addMonths(nextPayment, 6);
          break;
        case BillingCycle.yearly:
          nextPayment = _addMonths(nextPayment, 12);
          break;
      }
    }

    return nextPayment;
  }

  static tz.TZDateTime _addMonths(tz.TZDateTime date, int months) {
    final newMonth = date.month + months;
    final newYear = date.year + (newMonth - 1) ~/ 12;
    final actualMonth = ((newMonth - 1) % 12) + 1;
    final lastDayOfMonth = DateTime(newYear, actualMonth + 1, 0).day;
    final newDay = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;

    return tz.TZDateTime(date.location, newYear, actualMonth, newDay, date.hour, date.minute);
  }
}

class SpendingCalculator {
  static double calculateMonthlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (sum, sub) {
      if (!sub.isActive) return sum;
      return sum + _toMonthly(sub);
    });
  }

  static double calculateYearlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (sum, sub) {
      if (!sub.isActive) return sum;
      return sum + _toYearly(sub);
    });
  }

  static double _toMonthly(Subscription sub) {
    switch (sub.billingCycle) {
      case BillingCycle.weekly: return sub.amount * 52 / 12;
      case BillingCycle.biWeekly: return sub.amount * 26 / 12;
      case BillingCycle.monthly: return sub.amount;
      case BillingCycle.quarterly: return sub.amount / 3;
      case BillingCycle.halfYearly: return sub.amount / 6;
      case BillingCycle.yearly: return sub.amount / 12;
    }
  }

  static double _toYearly(Subscription sub) {
    switch (sub.billingCycle) {
      case BillingCycle.weekly: return sub.amount * 52;
      case BillingCycle.biWeekly: return sub.amount * 26;
      case BillingCycle.monthly: return sub.amount * 12;
      case BillingCycle.quarterly: return sub.amount * 4;
      case BillingCycle.halfYearly: return sub.amount * 2;
      case BillingCycle.yearly: return sub.amount;
    }
  }
}
