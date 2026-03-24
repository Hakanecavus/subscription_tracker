import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/presentation/screens/splash_screen.dart';
import 'package:subscription_tracker/presentation/screens/dashboard_screen.dart';
import 'package:subscription_tracker/presentation/screens/onboarding_screen.dart';
import 'package:subscription_tracker/presentation/screens/analytics_screen.dart';
import 'package:subscription_tracker/presentation/screens/settings_screen.dart';
import 'package:subscription_tracker/presentation/screens/subscriptions/add_subscription_screen.dart';
import 'package:subscription_tracker/presentation/screens/subscriptions/subscription_detail_screen.dart';
import 'package:subscription_tracker/presentation/screens/subscriptions/subscriptions_screen.dart';


/// Global navigator key for accessing context outside of widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Router configuration for the app
class AppRouter {
  // Private constructor
  AppRouter._();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    routes: [
      // Splash/Onboarding
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.routeNames[AppRoutes.splash],
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.routeNames[AppRoutes.onboarding],
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Home Shell (Bottom Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => Scaffold(
          body: navigationShell,
          bottomNavigationBar: Consumer(
            builder: (context, ref, _) {
              final l = ref.watch(appLocalizationsProvider);
              return NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: navigationShell.goBranch,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.dashboard_outlined),
                    selectedIcon: const Icon(Icons.dashboard),
                    label: l.tr('dashboard'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.subscriptions_outlined),
                    selectedIcon: const Icon(Icons.subscriptions),
                    label: l.tr('subscriptions'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.analytics_outlined),
                    selectedIcon: const Icon(Icons.analytics),
                    label: l.tr('analytics'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: l.tr('settings'),
                  ),
                ],
              );
            },
          ),
        ),
        branches: [
          // Dashboard Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.routeNames[AppRoutes.dashboard],
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Subscriptions Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subscriptions,
                name: AppRoutes.routeNames[AppRoutes.subscriptions],
                builder: (context, state) => const SubscriptionsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: AppRoutes.routeNames[AppRoutes.addSubscription],
                    builder: (context, state) => const AddSubscriptionScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: AppRoutes.routeNames[AppRoutes.editSubscription],
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return AddSubscriptionScreen(subscriptionId: id);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    name: AppRoutes.routeNames[AppRoutes.subscriptionDetail],
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return SubscriptionDetailScreen(subscriptionId: id ?? '');
                    },
                  ),
                ],
              ),
            ],
          ),
          // Analytics Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                name: AppRoutes.routeNames[AppRoutes.analytics],
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          // Settings Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.routeNames[AppRoutes.settings],
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: AppRoutes.routeNames[AppRoutes.categories],
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Categories')),
                    ),
                  ),
                  GoRoute(
                    path: 'backup',
                    name: AppRoutes.routeNames[AppRoutes.backup],
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Backup')),
                    ),
                  ),
                  GoRoute(
                    path: 'security',
                    name: AppRoutes.routeNames[AppRoutes.security],
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Security')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Calendar (standalone)
      GoRoute(
        path: AppRoutes.calendar,
        name: AppRoutes.routeNames[AppRoutes.calendar],
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Calendar')),
        ),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.path}" does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    // Redirect logic
    redirect: (context, state) {
      // Add authentication/initialization redirects here
      return null;
    },

    // Observers for analytics
    observers: [
      // RouteObserver for screen tracking
    ],
  );

  /// Navigation helper methods
  static void go(BuildContext context, String location) {
    context.go(location);
  }

  static void goNamed(BuildContext context, String name, {Map<String, String>? pathParameters}) {
    context.goNamed(name, pathParameters: pathParameters ?? {});
  }

  static void push(BuildContext context, String location) {
    context.push(location);
  }

  static void pushNamed(BuildContext context, String name, {Map<String, String>? pathParameters}) {
    context.pushNamed(name, pathParameters: pathParameters ?? {});
  }

  static void replace(BuildContext context, String location) {
    context.replace(location);
  }

  static void replaceNamed(BuildContext context, String name, {Map<String, String>? pathParameters}) {
    context.replaceNamed(name, pathParameters: pathParameters ?? {});
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static void popUntil(BuildContext context, String location) {
    while (context.canPop() && ModalRoute.of(context)?.settings.name != location) {
      context.pop();
    }
  }

  static bool canPop(BuildContext context) => context.canPop();
}

/// Extension for easy navigation access
extension GoRouterExtension on BuildContext {
  void goRoute(String location) => AppRouter.go(this, location);
  void goNamedRoute(String name, {Map<String, String>? pathParameters}) =>
      AppRouter.goNamed(this, name, pathParameters: pathParameters);
  void pushRoute(String location) => AppRouter.push(this, location);
  void pushNamedRoute(String name, {Map<String, String>? pathParameters}) =>
      AppRouter.pushNamed(this, name, pathParameters: pathParameters);
  void replaceRoute(String location) => AppRouter.replace(this, location);
  void replaceNamedRoute(String name, {Map<String, String>? pathParameters}) =>
      AppRouter.replaceNamed(this, name, pathParameters: pathParameters);
  void popRoute() => AppRouter.pop(this);
}
