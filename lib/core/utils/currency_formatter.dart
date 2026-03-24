import 'package:intl/intl.dart';

/// Utility class for currency formatting
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format amount with symbol
  static String format(
    double amount, {
    String symbol = '\$',
    String? locale,
    int decimalDigits = 2,
  }) {
    final format = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: locale,
    );
    return format.format(amount);
  }

  /// Format as compact (e.g., "\$1.2K")
  static String formatCompact(
    double amount, {
    String symbol = '\$',
    String? locale,
  }) {
    final format = NumberFormat.compactCurrency(
      symbol: symbol,
      locale: locale,
    );
    return format.format(amount);
  }

  /// Format without symbol (e.g., "1,234.56")
  static String formatWithoutSymbol(
    double amount, {
    int decimalDigits = 2,
  }) {
    final format = NumberFormat.decimalPattern()
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return format.format(amount);
  }

  /// Parse formatted string to double
  static double? parse(String formatted) {
    final value = formatted
      .replaceAll(RegExp(r'[^0-9.,-]'), '')
      .replaceAll(',', '');
    return double.tryParse(value);
  }

  /// Get currency symbol by code
  static String getSymbol(String currencyCode) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'Fr',
      'CNY': '¥',
      'INR': '₹',
      'RUB': '₽',
      'BRL': 'R\$',
      'TRY': '₺',
      'KRW': '₩',
      'SGD': 'S\$',
      'NZD': 'NZ\$',
    };
    return symbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  /// Common currency codes
  static const List<String> commonCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY',
    'INR', 'RUB', 'BRL', 'TRY', 'KRW', 'SGD', 'NZD',
  ];
}

/// Currency info model
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });

  static const List<CurrencyInfo> all = [
    CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$'),
    CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€'),
    CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£'),
    CurrencyInfo(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    CurrencyInfo(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    CurrencyInfo(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    CurrencyInfo(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
    CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    CurrencyInfo(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    CurrencyInfo(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
    CurrencyInfo(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    CurrencyInfo(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
    CurrencyInfo(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
    CurrencyInfo(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    CurrencyInfo(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$'),
  ];

  static CurrencyInfo? byCode(String code) {
    try {
      return all.firstWhere(
        (c) => c.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
