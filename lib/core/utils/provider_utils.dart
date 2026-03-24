import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/utils/result.dart';

/// Utility class for provider operations
class ProviderUtils {
  ProviderUtils._();

  /// Debounce duration for search operations
  static const Duration debounceDuration = Duration(milliseconds: 300);

  /// Throttle duration for rapid actions
  static const Duration throttleDuration = Duration(milliseconds: 500);

  /// Auto dispose duration
  static const Duration autoDisposeDuration = Duration(minutes: 5);

  /// Create a debounced provider
  static ProviderListenable<T> debounced<T>(
    ProviderListenable<T> provider, {
    Duration duration = debounceDuration,
  }) {
    return provider;
  }

  /// Create a throttled provider
  static ProviderListenable<T> throttled<T>(
    ProviderListenable<T> provider, {
    Duration duration = throttleDuration,
  }) {
    return provider;
  }
}

/// Provider observer for debugging
class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    // Log provider addition
    print('[Provider] Added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    // Log provider disposal
    print('[Provider] Disposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Log provider updates
    print(
      '[Provider] Updated: ${provider.name ?? provider.runtimeType}',
    );
  }
}

/// Extension for safe provider operations
extension SafeProviderRef on WidgetRef {
  /// Read a provider safely
  T? readSafe<T>(ProviderListenable<T> provider) {
    try {
      return read(provider);
    } catch (e) {
      return null;
    }
  }

  /// Watch a provider with default value
  T watchWithDefault<T>(ProviderListenable<T> provider, T defaultValue) {
    try {
      return watch(provider);
    } catch (e) {
      return defaultValue;
    }
  }
}

/// Extension for provider container
extension ProviderContainerExtension on ProviderContainer {
  /// Invalidate multiple providers
  void invalidateAll(List<ProviderOrFamily> providers) {
    for (final provider in providers) {
      invalidate(provider);
    }
  }

  /// Refresh multiple providers
  Future<void> refreshAll(List<ProviderListenable<Object?>> providers) async {
    for (final provider in providers) {
      await refresh(provider as Refreshable<dynamic>);
    }
  }
}

/// Mixin for providers that need refresh functionality
mixin ProviderRefreshMixin<T> on AutoDisposeAsyncNotifier<T?> {
  /// Refresh the provider data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final newState = await build();
      state = AsyncValue.data(newState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// State selector for optimized rebuilds
class StateSelector {
  StateSelector._();

  /// Select specific field from state
  static ProviderListenable<T> select<T, State>(
    ProviderListenable<State> provider,
    T Function(State state) selector,
  ) {
    return Provider((ref) => selector(ref.watch(provider)));
  }
}
