import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/core/localization/locale_utils.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';

/// Splash screen shown during app initialization
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    // Check if this is first launch
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('onboarding_completed') == null;

    if (isFirstLaunch) {
      // First launch - detect device language and currency
      await _setupDeviceLocale(prefs);
    }

    // Navigate to appropriate screen
    if (mounted) {
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      if (onboardingCompleted) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  Future<void> _setupDeviceLocale(SharedPreferences prefs) async {
    // Detect device language
    final deviceLanguage = detectDeviceLanguage();
    final deviceCurrency = detectDefaultCurrency();

    // Save detected language and currency
    await prefs.setString('selected_language', deviceLanguage);
    await prefs.setString('selected_currency', deviceCurrency);

    // Update providers (for immediate use in onboarding)
    ref.read(selectedLanguageProvider.notifier).state = deviceLanguage;
    ref.read(selectedCurrencyProvider.notifier).state = deviceCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.credit_card,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Subscription Tracker',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
