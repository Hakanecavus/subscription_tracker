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
  final List<Subscription> subs = result.getOrThrow();
  
  // Sort by Currency (A-Z) then by Amount (High-Low)
  subs.sort((a, b) {
    final curComp = a.currency.compareTo(b.currency);
    if (curComp != 0) return curComp;
    return b.amount.compareTo(a.amount);
  });
  
  return subs;
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
final totalMonthlyCostProvider = FutureProvider<Map<String, double>>((ref) async {
  final allSubs = await ref.watch(allSubscriptionsProvider.future);
  final Map<String, double> totals = {};
  
  for (final sub in allSubs) {
    totals[sub.currency] = (totals[sub.currency] ?? 0.0) + sub.monthlyCost;
  }
  
  return totals;
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

  final List<Subscription> filtered;
  if (searchQuery.isEmpty) {
    filtered = List.from(allSubs);
  } else {
    final lowercaseQuery = searchQuery.toLowerCase();
    filtered = allSubs.where((sub) => 
      sub.name.toLowerCase().contains(lowercaseQuery) || 
      (sub.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  // Sort by Currency (A-Z) then by Amount (High-Low)
  filtered.sort((a, b) {
    final curComp = a.currency.compareTo(b.currency);
    if (curComp != 0) return curComp;
    return b.amount.compareTo(a.amount);
  });

  return filtered;
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

/// Selected analytics currency
final selectedAnalyticsCurrencyProvider = StateProvider<String?>((ref) => null);

/// Category analysis provider
final categoryAnalysisProvider = FutureProvider<Map<String, CategoryAnalysis>>((ref) async {
  final allSubsAsync = ref.watch(allSubscriptionsProvider);
  final selectedCurrency = ref.watch(selectedAnalyticsCurrencyProvider);

  return allSubsAsync.when(
    data: (subs) {
      if (subs.isEmpty) return {};
      
      // Determine the currency to show: selected or first available
      final currencyToShow = selectedCurrency ?? (subs.isNotEmpty ? subs.first.currency : null);
      
      if (currencyToShow == null) return {};

      final filteredSubs = subs.where((s) => s.currency == currencyToShow).toList();
          
      final service = CategoryAnalysisService();
      return service.analyzeByCategory(filteredSubs);
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Total spending provider based on period, returns Map<Currency, Amount>
final totalSpendingProvider = Provider<Map<String, double>>((ref) {
  final allSubsAsync = ref.watch(allSubscriptionsProvider);
  final period = ref.watch(analyticsPeriodProvider);
  
  return allSubsAsync.maybeWhen(
    data: (subs) {
      final Map<String, double> totalsByCurrency = {};
      
      for (final sub in subs) {
        final monthly = sub.monthlyCost;
        final periodCost = switch (period) {
          AnalyticsPeriod.weekly => monthly / 4.33,
          AnalyticsPeriod.monthly => monthly,
          AnalyticsPeriod.yearly => monthly * 12,
        };
        
        totalsByCurrency[sub.currency] = (totalsByCurrency[sub.currency] ?? 0.0) + periodCost;
      }
      
      return totalsByCurrency;
    },
    orElse: () => {},
  );
});

/// Analytics period enum
enum AnalyticsPeriod {
  weekly,
  monthly,
  yearly,
}



