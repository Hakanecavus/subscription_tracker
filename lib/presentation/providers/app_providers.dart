import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/category_repository.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';
import 'package:subscription_tracker/domain/usecases/analysis_services.dart';
import 'package:subscription_tracker/presentation/providers/core_providers.dart';

// ============== SUBSCRIPTION PROVIDERS ==============

/// All subscriptions provider
final allSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.getActive();
  return result.getOrThrow();
});

/// Subscription by ID provider (Family)
final subscriptionByIdProvider = FutureProvider.family<Subscription?, String>(
  (ref, id) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getById(id);
    return result.getOrThrow();
  },
);

/// Subscriptions by category provider
final subscriptionsByCategoryProvider = FutureProvider.family<List<Subscription>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getByCategory(categoryId);
    return result.getOrThrow();
  },
);

/// Due subscriptions provider
final dueSubscriptionsProvider = FutureProvider.family<List<Subscription>, int>(
  (ref, days) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getDueWithinDays(days);
    return result.getOrThrow();
  },
);

/// Total monthly cost provider
final totalMonthlyCostProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.getTotalMonthlyCost();
  return result.getOrThrow();
});

/// Total yearly cost provider
final totalYearlyCostProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.getTotalYearlyCost();
  return result.getOrThrow();
});

/// Subscription search provider
final subscriptionSearchProvider = StateProvider<String>((ref) => '');

/// Filtered subscriptions provider
final filteredSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final searchQuery = ref.watch(subscriptionSearchProvider);
  final allSubs = await ref.watch(allSubscriptionsProvider.future);

  if (searchQuery.isEmpty) {
    return allSubs;
  }

  final lowercaseQuery = searchQuery.toLowerCase();
  return allSubs.where((sub) => 
    sub.name.toLowerCase().contains(lowercaseQuery) || 
    (sub.description?.toLowerCase().contains(lowercaseQuery) ?? false)
  ).toList();
});

// ============== CATEGORY PROVIDERS ==============

/// All categories provider
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  
  // Try to get categories
  final result = await repository.getAll();
  final categories = result.getOrElse(<Category>[]);
  
  // If no categories, initialize defaults and fetch again
  if (categories.isEmpty) {
    await repository.initializeDefaults();
    final refreshed = await repository.getAll();
    return refreshed.getOrElse(<Category>[]);
  }
  
  return categories;
});

/// Category by ID provider
final categoryByIdProvider = FutureProvider.family<Category?, String>(
  (ref, id) async {
    final repository = ref.watch(categoryRepositoryProvider);
    final result = await repository.getById(id);
    return result.getOrThrow();
  },
);

/// Category subscription counts provider
final categorySubscriptionCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getSubscriptionCounts();
  return result.getOrThrow();
});

// ============== UI STATE PROVIDERS ==============

/// Selected category filter
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Sort order provider
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.nextBilling);

/// View mode provider (grid/list)
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

/// Selected tab index
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// Sort order enum
enum SortOrder {
  name,
  amount,
  nextBilling,
  dateAdded,
}

/// View mode enum
enum ViewMode {
  list,
  grid,
}

// ============== THEME PROVIDERS ==============

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeModeState>((ref) => ThemeModeState.system);

/// Theme mode state
enum ThemeModeState {
  light,
  dark,
  system,
}

// ============== SETTINGS PROVIDERS ==============

/// Selected currency provider
final selectedCurrencyProvider = StateProvider<String>((ref) => 'USD \$');

/// Selected language provider
final selectedLanguageProvider = StateProvider<String>((ref) => 'English');

/// Notifications enabled provider
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

/// Reminder days before payment provider
final reminderDaysProvider = StateProvider<int>((ref) => 3);

/// Biometric lock provider
final biometricLockProvider = StateProvider<bool>((ref) => false);

/// Selected template for pre-filling (e.g. {'name': 'Netflix', 'amount': 15.99, 'icon': Icons.movie})
final selectedTemplateProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// ============== ANALYTICS PROVIDERS ==============

/// Selected analytics period
final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.monthly);

/// Category analysis provider
final categoryAnalysisProvider = FutureProvider<Map<String, CategoryAnalysis>>((ref) async {
  final allSubsAsync = ref.watch(allSubscriptionsProvider);
  return allSubsAsync.when(
    data: (subs) {
      final service = CategoryAnalysisService();
      return service.analyzeByCategory(subs);
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Total spending provider based on period
final totalSpendingProvider = Provider<double>((ref) {
  final allSubsAsync = ref.watch(allSubscriptionsProvider);
  final period = ref.watch(analyticsPeriodProvider);
  
  return allSubsAsync.maybeWhen(
    data: (subs) {
      final totalMonthly = subs.fold(0.0, (sum, sub) => sum + sub.monthlyCost);
      return switch (period) {
        AnalyticsPeriod.weekly => totalMonthly / 4.33,
        AnalyticsPeriod.monthly => totalMonthly,
        AnalyticsPeriod.yearly => totalMonthly * 12,
      };
    },
    orElse: () => 0.0,
  );
});

/// Analytics period enum
enum AnalyticsPeriod {
  weekly,
  monthly,
  yearly,
}



