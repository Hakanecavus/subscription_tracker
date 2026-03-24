import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension on DateTime for formatting
extension DateTimeExtension on DateTime {
  /// Format as short date (e.g., "Jan 15, 2024")
  String toShortDateString() {
    return DateFormat('MMM d, y').format(this);
  }

  /// Format as long date (e.g., "January 15, 2024")
  String toLongDateString() {
    return DateFormat('MMMM d, y').format(this);
  }

  /// Format as date time (e.g., "Jan 15, 2024 14:30")
  String toDateTimeString() {
    return DateFormat('MMM d, y HH:mm').format(this);
  }

  /// Format as short month (e.g., "Jan 2024")
  String toMonthYearString() {
    return DateFormat('MMM y').format(this);
  }

  /// Format as ISO date (e.g., "2024-01-15")
  String toIsoDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format as relative time (e.g., "2 days ago", "in 3 days")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = this.difference(now);

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
      final months = (difference.inDays.abs() / 30).floor();
      return difference.isNegative ? '$months months ago' : 'In $months months';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is in this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is in the future
  bool get isInFuture => isAfter(DateTime.now());

  /// Check if date is in the past
  bool get isInPast => isBefore(DateTime.now());

  /// Get first day of month
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  /// Get last day of month
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// Get days in month
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Add months
  DateTime addMonths(int months) {
    return DateTime(year, month + months, day);
  }

  /// Add years
  DateTime addYears(int years) {
    return DateTime(year + years, month, day);
  }
}

/// Extension on double for currency formatting
extension CurrencyExtension on double {
  /// Format as currency
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Format as compact currency (e.g., "\$1.2K")
  String toCompactCurrency({String symbol = '\$'}) {
    return NumberFormat.compactCurrency(
      symbol: symbol,
    ).format(this);
  }

  /// Format as percentage
  String toPercentage({int decimalDigits = 1}) {
    final format = NumberFormat.percentPattern()..maximumFractionDigits = decimalDigits;
    return format.format(this / 100);
  }
}

/// Extension on int for formatting
extension IntExtension on int {
  /// Format with thousand separators
  String toFormattedString() {
    return NumberFormat('#,###').format(this);
  }

  /// Format as ordinal (e.g., 1st, 2nd, 3rd, 4th)
  String toOrdinal() {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}

/// Extension on String for validation
extension StringValidationExtension on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    final urlRegex = RegExp(r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$');
    return urlRegex.hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;

  /// Check if string is empty or null
  bool get isNullOrEmpty => trim().isEmpty;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

/// Extension on BuildContext for theming
extension BuildContextExtension on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
}

/// Extension on Widget for padding shortcuts
extension WidgetPaddingExtension on Widget {
  /// Add padding on all sides
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value),
    child: this,
  );

  /// Add horizontal padding
  Widget paddingHorizontal(double value) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value),
    child: this,
  );

  /// Add vertical padding
  Widget paddingVertical(double value) => Padding(
    padding: EdgeInsets.symmetric(vertical: value),
    child: this,
  );

  /// Add symmetric padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  /// Add padding with specific edges
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: this,
  );
}

/// Extension on List for convenience
extension ListExtension<T> on List<T> {
  /// Split list into chunks
  List<List<T>> chunks(int chunkSize) {
    var chunks = <List<T>>[];
    for (var i = 0; i < length; i += chunkSize) {
      var end = (i + chunkSize < length) ? i + chunkSize : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}
