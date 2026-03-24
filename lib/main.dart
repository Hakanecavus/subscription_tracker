import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/core/theme/app_theme.dart';
import 'package:subscription_tracker/core/utils/app_router.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/providers/core_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for all supported locales
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('tr', null);
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('fr', null);
  await initializeDateFormatting('de', null);

  runApp(
    ProviderScope(
      parent: providerContainer,
      child: const MyApp(),
    ),
  );
}

/// Main application widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Subscription Tracker',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _mapThemeMode(themeMode),

      // Router configuration
      routerConfig: router,

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
        Locale('es', ''),
      ],
      locale: Locale(ref.watch(appLocalizationsProvider).localeCode),
    );
  }

  ThemeMode _mapThemeMode(ThemeModeState state) {
    switch (state) {
      case ThemeModeState.light:
        return ThemeMode.light;
      case ThemeModeState.dark:
        return ThemeMode.dark;
      case ThemeModeState.system:
        return ThemeMode.system;
    }
  }
}
