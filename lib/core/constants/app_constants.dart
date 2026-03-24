/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Subscription Tracker';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'subscription_tracker.db';
  static const int databaseVersion = 1;

  // Storage Keys
  static const String userPreferencesKey = 'user_preferences';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String firstLaunchKey = 'first_launch';
  static const String lastBackupDateKey = 'last_backup_date';

  // Notification
  static const String notificationChannelId = 'subscription_reminders';
  static const String notificationChannelName = 'Subscription Reminders';
  static const String notificationChannelDescription =
      'Notifications for upcoming subscription payments';

  // DateTime
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String shortMonthFormat = 'MMM yyyy';

  // Currency defaults
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Chart
  static const int maxChartDataPoints = 12;
  static const double defaultChartHeight = 200.0;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 200);

  // Workmanager
  static const String checkSubscriptionsTask = 'checkUpcomingSubscriptions';
  static const String dailyNotificationTask = 'dailyNotificationCheck';

  // Notification Timing
  static const List<int> reminderDaysBefore = [1, 3, 7];

  // Limits
  static const int maxCategories = 20;
  static const int maxSubscriptions = 500;
}
