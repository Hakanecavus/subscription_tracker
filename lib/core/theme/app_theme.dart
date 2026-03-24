import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subscription_tracker/core/constants/app_constants.dart';

/// App theme configuration
class AppTheme {
  // Private constructor
  AppTheme._();

  // Color Palette
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF00BFA6);
  static const Color accentColor = Color(0xFFFF6584);

  // Semantic Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color infoColor = Color(0xFF42A5F5);

  // Background Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFF00BFA6), // Teal
    Color(0xFFFF6584), // Pink
    Color(0xFFFFA726), // Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFFAB47BC), // Purple accent
    Color(0xFF26A69A), // Teal accent
    Color(0xFFEF5350), // Red
    Color(0xFF66BB6A), // Green
    Color(0xFFFFCA28), // Yellow
  ];

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF3F3D56),
        onPrimaryContainer: Color(0xFFE0E0FF),
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF004D40),
        onSecondaryContainer: Color(0xFFB2DFDB),
        tertiary: accentColor,
        onTertiary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceVariant: Color(0xFF333333),
        onSurfaceVariant: darkTextSecondary,
        background: darkBackground,
        onBackground: darkTextPrimary,
        error: errorColor,
        onError: Colors.white,
        outline: Color(0xFF444444),
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: _darkAppBarTheme,
      cardTheme: _darkCardTheme,
      inputDecorationTheme: _darkInputTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      floatingActionButtonTheme: _fabTheme,
      chipTheme: _darkChipTheme,
      bottomNavigationBarTheme: _darkBottomNavTheme,
      dividerTheme: _dividerTheme,
      tooltipTheme: _tooltipTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      bottomSheetTheme: _bottomSheetTheme,
      typography: Typography.material2021(),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        background: lightBackground,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: _lightAppBarTheme,
      cardTheme: _lightCardTheme,
      inputDecorationTheme: _lightInputTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      floatingActionButtonTheme: _fabTheme,
      chipTheme: _lightChipTheme,
      bottomNavigationBarTheme: _lightBottomNavTheme,
      dividerTheme: _dividerTheme,
      tooltipTheme: _tooltipTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      bottomSheetTheme: _bottomSheetTheme,
      typography: Typography.material2021(),
    );
  }

  // AppBar Themes
  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
    elevation: 0,
    centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      );

  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
    elevation: 0,
    centerTitle: true,
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
      );

  // Card Themes
  static CardThemeData get _darkCardTheme => CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
    ),
    color: darkSurface,
    margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: AppConstants.smallPadding),
  );

  static CardThemeData get _lightCardTheme => CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
    ),
    color: lightSurface,
    margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: AppConstants.smallPadding),
  );

  // Input Decoration Themes
  static InputDecorationTheme get _darkInputTheme => InputDecorationTheme(
    filled: true,
    fillColor: darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.defaultPadding,
    ),
  );

  static InputDecorationTheme get _lightInputTheme => InputDecorationTheme(
    filled: true,
    fillColor: lightSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.defaultPadding,
    ),
  );

  // Button Themes
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
        vertical: AppConstants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
        vertical: AppConstants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
    ),
  );

  // FAB Theme
  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
    elevation: 4,
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    ),
  );

  // Chip Themes
  static ChipThemeData get _darkChipTheme => ChipThemeData(
    backgroundColor: darkSurface,
    selectedColor: primaryColor,
    labelStyle: const TextStyle(color: darkTextPrimary),
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    ),
  );

  static ChipThemeData get _lightChipTheme => ChipThemeData(
    backgroundColor: lightBackground,
    selectedColor: primaryColor,
    labelStyle: const TextStyle(color: lightTextPrimary),
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    ),
  );

  // Bottom Navigation Bar Themes
  static BottomNavigationBarThemeData get _darkBottomNavTheme =>
      BottomNavigationBarThemeData(
    backgroundColor: darkSurface,
    selectedItemColor: primaryColor,
    unselectedItemColor: darkTextSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  );

  static BottomNavigationBarThemeData get _lightBottomNavTheme =>
      BottomNavigationBarThemeData(
    backgroundColor: lightSurface,
    selectedItemColor: primaryColor,
    unselectedItemColor: lightTextSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  );

  // Divider Theme
  static DividerThemeData get _dividerTheme => const DividerThemeData(
    thickness: 1,
    indent: AppConstants.defaultPadding,
    endIndent: AppConstants.defaultPadding,
  );

  // Tooltip Theme
  static TooltipThemeData get _tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(AppConstants.smallPadding),
    ),
    textStyle: const TextStyle(color: Colors.white),
  );

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    ),
    contentTextStyle: const TextStyle(color: Colors.white),
  );

  // Dialog Theme
  static DialogThemeData get _dialogTheme => DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 1.5),
    ),
    elevation: 4,
  );

  // Bottom Sheet Theme
  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.largePadding),
      ),
    ),
    elevation: 8,
  );
}

/// Extension for getting category color
extension CategoryColorExtension on int {
  Color getCategoryColor() {
    return AppTheme.categoryColors[this % AppTheme.categoryColors.length];
  }
}
