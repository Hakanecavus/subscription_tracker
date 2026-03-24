/// Route constants for navigation
class AppRoutes {
  // Route paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String subscriptions = '/subscriptions';
  static const String addSubscription = '/subscriptions/add';
  static const String editSubscription = '/subscriptions/edit';
  static const String subscriptionDetail = '/subscriptions/detail';
  static const String analytics = '/analytics';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String categories = '/categories';
  static const String backup = '/backup';
  static const String security = '/security';

  // Route names for analytics/logging
  static const Map<String, String> routeNames = {
    splash: 'splash',
    onboarding: 'onboarding',
    home: 'home',
    dashboard: 'dashboard',
    subscriptions: 'subscriptions',
    addSubscription: 'add_subscription',
    editSubscription: 'edit_subscription',
    subscriptionDetail: 'subscription_detail',
    analytics: 'analytics',
    calendar: 'calendar',
    settings: 'settings',
    categories: 'categories',
    backup: 'backup',
    security: 'security',
  };

  // Route parameters
  static const String subscriptionIdParam = 'id';
  static const String categoryIdParam = 'categoryId';
}

/// Database table names
class DatabaseTables {
  static const String subscriptions = 'subscriptions';
  static const String categories = 'categories';
  static const String paymentHistory = 'payment_history';
  static const String settings = 'settings';
  static const String reminders = 'reminders';
}

/// Shared preference keys
class PreferenceKeys {
  static const String themeMode = 'theme_mode';
  static const String currencyCode = 'currency_code';
  static const String languageCode = 'language_code';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String defaultReminderDays = 'default_reminder_days';
  static const String showCompletedSubscriptions = 'show_completed';
  static const String sortOrder = 'sort_order';
  static const String viewMode = 'view_mode';
}

/// Asset paths
class AssetPaths {
  static const String images = 'assets/images/';
  static const String icons = 'assets/icons/';
  static const String animations = 'assets/animations/';
}

/// Error messages
class ErrorMessages {
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String cacheError = 'Failed to save data locally.';
  static const String validationError = 'Please check your input.';
  static const String authError = 'Authentication failed.';
  static const String biometricError = 'Biometric authentication failed.';
  static const String notFoundError = 'Item not found.';
}
