import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subscription_tracker/core/constants/routes.dart';

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
    // Initialize dependencies, check auth, etc.
    await Future.delayed(const Duration(seconds: 2));
    // Navigate to appropriate screen
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
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
