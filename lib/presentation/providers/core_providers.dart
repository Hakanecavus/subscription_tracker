import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subscription_tracker/core/utils/app_router.dart';
import 'package:subscription_tracker/core/utils/provider_utils.dart';
import 'package:subscription_tracker/data/datasources/local/database_helper.dart';
import 'package:subscription_tracker/data/datasources/local/category_local_datasource.dart';
import 'package:subscription_tracker/data/datasources/local/subscription_local_datasource.dart';
import 'package:subscription_tracker/data/repositories/category_repository_impl.dart';
import 'package:subscription_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:subscription_tracker/domain/repositories/category_repository.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';

// ============== PROVIDER OVERRIDES ==============
/// Provider container with overrides
final ProviderContainer providerContainer = ProviderContainer(
  observers: [ProviderLogger()],
);

// ============== DATABASE PROVIDERS ==============
/// Database helper provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// ============== DATA SOURCE PROVIDERS ==============
/// Subscription local data source provider
final subscriptionLocalDataSourceProvider = Provider<SubscriptionLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SubscriptionLocalDataSourceImpl(dbHelper: dbHelper);
});

/// Category local data source provider
final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryLocalDataSourceImpl(dbHelper: dbHelper);
});

// ============== REPOSITORY PROVIDERS ==============
/// Subscription repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final localDataSource = ref.watch(subscriptionLocalDataSourceProvider);
  return SubscriptionRepositoryImpl(localDataSource: localDataSource);
});

/// Category repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(localDataSource: localDataSource);
});

// ============== NAVIGATION PROVIDERS ==============
/// App router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// Router refresh stream provider (for auth state changes)
final routerRefreshProvider = StreamProvider<void>((ref) {
  // Stream to refresh router on auth state changes
  return Stream.periodic(const Duration(seconds: 1));
});
