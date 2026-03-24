import 'package:flutter/material.dart';
import 'app_theme.dart';

/// App typography configuration
class AppTypography {
  // Private constructor
  AppTypography._();

  // Font families (add custom fonts in pubspec.yaml)
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Roboto';

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Custom styles for specific use cases
  static const TextStyle currencyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle currencyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.33,
  );

  static const TextStyle currencySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle statNumber = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  // Extension method to apply color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}

/// Extension for TextStyle helpers
extension TextStyleExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle withOpacity(double opacity) {
    return copyWith(
      color: color?.withOpacity(opacity),
    );
  }
}
