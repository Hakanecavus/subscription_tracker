import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/errors/failures.dart';
import 'package:subscription_tracker/core/utils/result.dart';

/// Base state for Riverpod providers
abstract class BaseState {
  const BaseState();
}

/// Initial state
class InitialState extends BaseState {
  const InitialState();
}

/// Loading state
class LoadingState extends BaseState {
  const LoadingState();
}

/// Success state with data
class SuccessState<T> extends BaseState {
  final T data;

  const SuccessState(this.data);
}

/// Error state
class ErrorState extends BaseState {
  final Failure failure;
  final String? message;

  const ErrorState(this.failure, {this.message});

  String get displayMessage => message ?? failure.message;
}

/// Empty/No data state
class EmptyState extends BaseState {
  const EmptyState();
}

/// Base StateNotifier for async operations
abstract class BaseNotifier<T> extends StateNotifier<BaseState> {
  BaseNotifier() : super(const InitialState());

  /// Current data if available
  T? _currentData;
  T? get currentData => _currentData;

  /// Execute an async operation with state management
  Future<void> executeAsync(
    Future<Result<T>> Function() operation, {
    bool showLoading = true,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onError,
  }) async {
    if (showLoading) {
      state = const LoadingState();
    }

    final result = await operation();

    result.fold(
      onSuccess: (data) {
        _currentData = data;
        state = SuccessState(data);
        onSuccess?.call(data);
      },
      onFailure: (failure) {
        state = ErrorState(failure);
        onError?.call(failure);
      },
    );
  }

  /// Set success state directly
  void setSuccess(T data) {
    _currentData = data;
    state = SuccessState(data);
  }

  /// Set error state directly
  void setError(Failure failure, {String? message}) {
    state = ErrorState(failure, message: message);
  }

  /// Set loading state
  void setLoading() {
    state = const LoadingState();
  }

  /// Set empty state
  void setEmpty() {
    state = const EmptyState();
  }

  /// Reset to initial state
  void reset() {
    _currentData = null;
    state = const InitialState();
  }
}

/// Base AsyncNotifier for Riverpod 2.0
abstract class BaseAsyncNotifier<T> extends AsyncNotifier<T?> {
  /// Build the initial state
  @override
  Future<T?> build();

  /// Execute an async operation with automatic state management
  Future<void> execute(
    Future<Result<T>> Function() operation, {
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onError,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await operation();

      result.fold(
        onSuccess: (data) {
          state = AsyncValue.data(data);
          onSuccess?.call(data);
        },
        onFailure: (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          onError?.call(failure);
        },
      );
    } catch (error, stackTrace) {
      final failure = error is Failure
          ? error
          : UnexpectedFailure(message: error.toString());
      state = AsyncValue.error(failure, stackTrace);
      onError?.call(failure);
    }
  }

  /// Set data directly
  void setData(T data) {
    state = AsyncValue.data(data);
  }

  /// Refresh data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await build() as T);
  }
}

/// Base Family AsyncNotifier
abstract class BaseFamilyAsyncNotifier<T, Arg>
    extends FamilyAsyncNotifier<T?, Arg> {
  @override
  Future<T?> build(Arg arg);

  Future<void> execute(
    Future<Result<T>> Function() operation, {
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onError,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await operation();

      result.fold(
        onSuccess: (data) {
          state = AsyncValue.data(data);
          onSuccess?.call(data);
        },
        onFailure: (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          onError?.call(failure);
        },
      );
    } catch (error, stackTrace) {
      final failure = error is Failure
          ? error
          : UnexpectedFailure(message: error.toString());
      state = AsyncValue.error(failure, stackTrace);
      onError?.call(failure);
    }
  }
}

/// Extension for AsyncValue handling
extension AsyncValueExtension<T> on AsyncValue<T> {
  /// Check if data is not null and has value
  bool get hasData => valueOrNull != null;

  /// Get error message if error
  String? get errorMessage => hasError ? (error as Failure?)?.message : null;

  /// Map to Result type
  Result<T> toResult() {
    return when(
      data: (data) => Success(data as T),
      error: (error, _) => error is Failure
          ? FailureResult(error)
          : FailureResult(UnexpectedFailure(message: error.toString())),
      loading: () => throw StateError('Cannot convert loading state to Result'),
    );
  }
}
