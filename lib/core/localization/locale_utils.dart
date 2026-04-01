import 'dart:ui';

/// Detect device language and return supported language name
String detectDeviceLanguage() {
  final deviceLocale = PlatformDispatcher.instance.locale;
  final languageCode = deviceLocale.languageCode;

  return switch (languageCode) {
    'tr' => 'Türkçe',
    'es' => 'Español',
    'fr' => 'Français',
    'de' => 'Deutsch',
    _ => 'English',
  };
}

/// Get default currency based on detected language
String detectDefaultCurrency() {
  final deviceLocale = PlatformDispatcher.instance.locale;
  final languageCode = deviceLocale.languageCode;

  return switch (languageCode) {
    'tr' => 'TRY ₺',
    'es' => 'EUR €',
    'fr' => 'EUR €',
    'de' => 'EUR €',
    _ => 'USD \$',
  };
}
