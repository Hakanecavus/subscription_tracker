import 'package:subscription_tracker/core/errors/failures.dart';

/// Result type for functional error handling
/// Similar to Either in functional programming
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  Success<T> get asSuccess => this as Success<T>;
  FailureResult<T> get asFailure => this as FailureResult<T>;

  T? get valueOrNull => isSuccess ? asSuccess.value : null;
  Failure? get failureOrNull => isFailure ? asFailure.failure : null;

  /// Fold pattern - handle both cases
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(value: final v) => onSuccess(v),
      FailureResult<T>(failure: final f) => onFailure(f),
      _ => throw StateError('Unknown Result type'),
    };
  }

  /// Map success value
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final v) => Success(transform(v)),
      FailureResult<T>(failure: final f) => FailureResult(f),
      _ => throw StateError('Unknown Result type'),
    };
  }

  /// Async map success value
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) transform) async {
    return switch (this) {
      Success<T>(value: final v) => Success(await transform(v)),
      FailureResult<T>(failure: final f) => FailureResult(f),
      _ => throw StateError('Unknown Result type'),
    };
  }

  /// Get value or throw
  T getOrThrow() {
    return switch (this) {
      Success<T>(value: final v) => v,
      FailureResult<T>(failure: final f) => throw f,
      _ => throw StateError('Unknown Result type'),
    };
  }

  /// Get value or return default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(value: final v) => v,
      FailureResult<T>() => defaultValue,
      _ => throw StateError('Unknown Result type'),
    };
  }

  /// Get value or compute default
  T getOrCompute(T Function() compute) {
    return switch (this) {
      Success<T>(value: final v) => v,
      FailureResult<T>() => compute(),
      _ => throw StateError('Unknown Result type'),
    };
  }
}

/// Success case containing the value
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success(value: $value)';
}

/// Failure case containing the error
final class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);

  @override
  String toString() => 'FailureResult(failure: $failure)';
}

/// Extension for handling async operations
extension ResultAsyncExtension<T> on Future<T> {
  Future<Result<T>> toResult() async {
    try {
      final value = await this;
      return Success(value);
    } catch (error, stackTrace) {
      if (error is Failure) {
        return FailureResult<T>(error);
      }
      return FailureResult<T>(
        UnexpectedFailure(
          message: error.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Extension for catching exceptions and converting to Result
extension ResultCatchExtension<T> on Future<Result<T>> {
  Future<Result<T>> catchFailure() async {
    try {
      return await this;
    } catch (error, stackTrace) {
      if (error is Failure) {
        return FailureResult<T>(error);
      }
      return FailureResult<T>(
        UnexpectedFailure(
          message: error.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
