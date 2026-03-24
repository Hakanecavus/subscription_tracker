# 🏗️ Subscription Tracker - Backend Architecture

## 1. Data Models

### Subscription Model
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

enum BillingCycle { weekly, monthly, yearly }

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String name,
    required String category,
    required double price,
    required String currency,
    required BillingCycle billingCycle,
    required DateTime nextPaymentDate,
    required DateTime startDate,
    @Default(true) bool notificationEnabled,
    @Default(3) int notificationDaysBefore,
    required String timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? iconUrl,
    String? color,
    String? notes,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionFromJson;
}
```

### Payment History Model
```dart
@freezed
class PaymentHistory with _$PaymentHistory {
  const factory PaymentHistory({
    required String id,
    required String subscriptionId,
    required double amount,
    required String currency,
    required DateTime paidAt,
    String? notes,
  }) = _PaymentHistory;

  factory PaymentHistory.fromJson(Map<String, dynamic> json) =
      _$PaymentHistoryFromJson;
}
```

### User Preferences Model
```dart
enum AppTheme { light, dark, system }

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default('USD') String defaultCurrency,
    @Default('UTC') String defaultTimezone,
    @Default(AppTheme.system) AppTheme theme,
    @Default('en') String language,
    @Default(false) bool biometricLock,
    @Default(true) bool analyticsEnabled,
    DateTime? lastSyncAt,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesFromJson;
}
```

## 2. Database Schema

### SQL Tables

```sql
-- Subscriptions table
CREATE TABLE subscriptions (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price REAL NOT NULL,
  currency TEXT NOT NULL,
  billing_cycle TEXT NOT NULL,
  next_payment_date TEXT NOT NULL,
  start_date TEXT NOT NULL,
  notification_enabled INTEGER DEFAULT 1,
  notification_days_before INTEGER DEFAULT 3,
  timezone TEXT NOT NULL DEFAULT 'UTC',
  created_at TEXT,
  updated_at TEXT,
  icon_url TEXT,
  color TEXT,
  notes TEXT
);

CREATE INDEX idx_subscriptions_next_payment
  ON subscriptions(next_payment_date);
CREATE INDEX idx_subscriptions_category
  ON subscriptions(category);

-- Payment history table
CREATE TABLE payment_history (
  id TEXT PRIMARY KEY,
  subscription_id TEXT NOT NULL,
  amount REAL NOT NULL,
  currency TEXT NOT NULL,
  paid_at TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE
);

-- Notification settings table
CREATE TABLE notification_settings (
  id TEXT PRIMARY KEY,
  subscription_id TEXT NOT NULL UNIQUE,
  payment_reminder INTEGER DEFAULT 1,
  days_before_payment INTEGER DEFAULT 3,
  FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE
);

-- User preferences table
CREATE TABLE user_preferences (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  default_currency TEXT DEFAULT 'USD',
  default_timezone TEXT DEFAULT 'UTC',
  theme TEXT DEFAULT 'system',
  language TEXT DEFAULT 'en',
  biometric_lock INTEGER DEFAULT 0,
  analytics_enabled INTEGER DEFAULT 1
);

-- Service templates table
CREATE TABLE service_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  default_price REAL,
  default_currency TEXT,
  default_billing_cycle TEXT,
  icon_url TEXT,
  source_url TEXT,
  verified INTEGER DEFAULT 0,
  usage_count INTEGER DEFAULT 0
);

-- Currency rates cache
CREATE TABLE currency_rates (
  from_currency TEXT NOT NULL,
  to_currency TEXT NOT NULL,
  rate REAL NOT NULL,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (from_currency, to_currency)
);
```

## 3. Key Algorithms

### Next Payment Date Calculator
```dart
class PaymentDateCalculator {
  static DateTime calculateNextPaymentDate({
    required DateTime startDate,
    required BillingCycle cycle,
    required String timezone,
    DateTime? fromDate,
  }) {
    final tz.TZDateTime start = tz.TZDateTime.from(startDate, tz.getLocation(timezone));
    final tz.TZDateTime now = fromDate != null
        ? tz.TZDateTime.from(fromDate, tz.getLocation(timezone))
        : tz.TZDateTime.now(tz.getLocation(timezone));

    tz.TZDateTime nextPayment = tz.TZDateTime(
      start.location, start.year, start.month, start.day, start.hour, start.minute,
    );

    while (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now)) {
      switch (cycle) {
        case BillingCycle.weekly:
          nextPayment = nextPayment.add(Duration(days: 7));
          break;
        case BillingCycle.monthly:
          nextPayment = _addMonths(nextPayment, 1);
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
```

### Spending Calculator
```dart
class SpendingCalculator {
  double calculateMonthlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (sum, sub) => sum + _toMonthly(sub));
  }

  double calculateYearlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (sum, sub) => sum + _toYearly(sub));
  }

  double _toMonthly(Subscription sub) {
    switch (sub.billingCycle) {
      case BillingCycle.weekly: return sub.price * 52 / 12;
      case BillingCycle.monthly: return sub.price;
      case BillingCycle.yearly: return sub.price / 12;
    }
  }

  double _toYearly(Subscription sub) {
    switch (sub.billingCycle) {
      case BillingCycle.weekly: return sub.price * 52;
      case BillingCycle.monthly: return sub.price * 12;
      case BillingCycle.yearly: return sub.price;
    }
  }
}
```

### Upcoming Payments
```dart
class UpcomingPaymentsService {
  List<Subscription> getUpcomingPayments({
    required List<Subscription> subscriptions,
    required int days,
  }) {
    final threshold = DateTime.now().add(Duration(days: days));

    return subscriptions
        .where((sub) => sub.nextPaymentDate.isBefore(threshold))
        .toList()
      ..sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
  }
}
```

### Duplicate Detection
```dart
class DuplicateDetector {
  static bool isLikelyDuplicate({
    required String name,
    required String category,
    required List<Subscription> existing,
    double threshold = 0.8,
  }) {
    final normalizedName = _normalize(name);

    return existing.any((sub) {
      final similarity = _calculateSimilarity(normalizedName, _normalize(sub.name));
      return similarity >= threshold && sub.category == category;
    });
  }

  static String _normalize(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static double _calculateSimilarity(String a, String b) {
    final wordsA = a.split(' ').toSet();
    final wordsB = b.split(' ').toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;

    final intersection = wordsA.intersection(wordsB);
    final union = wordsA.union(wordsB);
    return intersection.length / union.length;
  }
}
```

### Category Analysis
```dart
class CategoryAnalysisService {
  Map<String, CategoryAnalysis> analyzeByCategory(List<Subscription> subscriptions) {
    final analysis = <String, List<Subscription>>{};

    for (final sub in subscriptions) {
      analysis.putIfAbsent(sub.category, () => []).add(sub);
    }

    return analysis.map((category, subs) {
      final total = subs.fold(0.0, (sum, s) => sum + s.price);
      return MapEntry(
        category,
        CategoryAnalysis(
          category: category,
          count: subs.length,
          totalSpend: total,
          averageSpend: total / subs.length,
          subscriptions: subs,
        ),
      );
    });
  }
}

class CategoryAnalysis {
  final String category;
  final int count;
  final double totalSpend;
  final double averageSpend;
  final List<Subscription> subscriptions;

  CategoryAnalysis({
    required this.category,
    required this.count,
    required this.totalSpend,
    required this.averageSpend,
    required this.subscriptions,
  });
}
```

## 4. Notification Scheduling

```dart
class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> schedulePaymentReminder(Subscription sub) async {
    if (!sub.notificationEnabled) {
      await cancelNotifications(sub.id);
      return;
    }

    final notificationDate = sub.nextPaymentDate.subtract(
      Duration(days: sub.notificationDaysBefore),
    );

    if (notificationDate.isBefore(DateTime.now())) return;

    final id = sub.id.hashCode.abs();

    await _notifications.zonedSchedule(
      id,
      'Payment Due Soon',
      '${sub.name} - $${sub.price} due in ${sub.notificationDaysBefore} days',
      tz.TZDateTime.from(notificationDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'payment_reminders',
          'Payment Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotifications(String subscriptionId) async {
    await _notifications.cancel(subscriptionId.hashCode.abs());
  }
}
```

## 5. Currency Service

```dart
class CurrencyService {
  final Dio _dio;
  final LocalStorage _storage;
  static const Duration _cacheValidity = Duration(hours: 24);

  Future<Map<String, double>> fetchRates() async {
    try {
      final response = await _dio.get('https://api.exchangerate-api.com/v4/latest/USD');
      final rates = Map<String, double>.from(
        response.data['rates'].map((k, v) => MapEntry(k, v.toDouble())),
      );
      await cacheRates(rates);
      return rates;
    } catch (e) {
      return getCachedRates();
    }
  }

  Future<void> cacheRates(Map<String, double> rates) async {
    await _storage.setString('currency_rates', jsonEncode(rates));
    await _storage.setString('rates_last_update', DateTime.now().toIso8601String());
  }

  Map<String, double> getCachedRates() {
    final cached = _storage.getString('currency_rates');
    if (cached == null) return _defaultRates();
    return Map<String, double>.from(jsonDecode(cached));
  }

  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    final rates = getCachedRates();
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return (amount / fromRate) * toRate;
  }

  Map<String, double> _defaultRates() => {
    'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.50,
    'CAD': 1.35, 'AUD': 1.52, 'TRY': 32.0,
  };
}
```

## 6. Data Sync

```dart
class SyncService {
  final Dio _dio;
  final ServiceTemplateRepository _templateRepository;

  Future<SyncResult> syncServiceTemplates() async {
    try {
      final response = await _dio.get('https://api.subscriptiontracker.app/templates.json');

      final templates = (response.data['templates'] as List)
          .map((json) => ServiceTemplate.fromJson(json))
          .toList();

      for (final template in templates) {
        await _templateRepository.upsert(template);
      }

      return SyncResult.success(updated: templates.length);
    } catch (e) {
      return SyncResult.failure(error: e.toString());
    }
  }
}

class SyncResult {
  final bool success;
  final int updated;
  final String? error;

  const SyncResult.success({this.updated = 0})
      : success = true, error = null;
  const SyncResult.failure({required this.error})
      : success = false, updated = 0;
}
```

## 7. Background Sync

```dart
class BackgroundSyncManager {
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case 'sync_task':
          await _performSync();
          break;
      }
      return Future.value(true);
    });
  }

  static Future<void> _performSync() async {
    final syncService = SyncService(...);
    final currencyService = CurrencyService(...);

    await syncService.syncServiceTemplates();
    await currencyService.fetchRates();
  }

  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'sync_task', 'sync_task',
      frequency: Duration(hours: 24),
    );
  }
}
```
