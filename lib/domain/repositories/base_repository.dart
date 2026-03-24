import 'package:subscription_tracker/core/errors/failures.dart';
import 'package:subscription_tracker/core/utils/result.dart';

/// Base repository class with common error handling
abstract class BaseRepository {
  /// Execute a database operation with error handling
  Future<Result<T>> executeDbOperation<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (error, stackTrace) {
      return FailureResult(
        CacheFailure(
          message: 'Database operation failed: ${error.toString()}',
          code: 'DB_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Execute a network operation with error handling
  Future<Result<T>> executeNetworkOperation<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (error, stackTrace) {
      return FailureResult(
        ServerFailure(
          message: 'Network operation failed: ${error.toString()}',
          code: 'NETWORK_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Execute a local operation with error handling
  Future<Result<T>> executeLocalOperation<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (error, stackTrace) {
      return FailureResult(
        UnexpectedFailure(
          message: 'Local operation failed: ${error.toString()}',
          code: 'LOCAL_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Execute a validation operation
  Result<T> executeValidation<T>(T Function() validation, {Map<String, String>? errors}) {
    try {
      final result = validation();
      return Success(result);
    } catch (error, stackTrace) {
      return FailureResult(
        ValidationFailure(
          message: 'Validation failed: ${error.toString()}',
          errors: errors,
          code: 'VALIDATION_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
