import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/core/errors/failures.dart';
import 'package:subscription_tracker/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Success should contain value', () {
      const result = Success<int>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.asSuccess.value, equals(42));
      expect(result.valueOrNull, equals(42));
    });

    test('FailureResult should contain failure', () {
      const failure = CacheFailure(message: 'Test error');
      const result = FailureResult<int>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.asFailure.failure, equals(failure));
      expect(result.failureOrNull, equals(failure));
    });

    test('fold should call correct callback', () {
      const success = Success<int>(42);
      const failure = FailureResult<int>(CacheFailure(message: 'Error'));

      final successResult = success.fold(
        onSuccess: (value) => 'success: $value',
        onFailure: (failure) => 'failure: ${failure.message}',
      );

      final failureResult = failure.fold(
        onSuccess: (value) => 'success: $value',
        onFailure: (failure) => 'failure: ${failure.message}',
      );

      expect(successResult, equals('success: 42'));
      expect(failureResult, equals('failure: Error'));
    });

    test('getOrElse should return value or default', () {
      const success = Success<int>(42);
      const failure = FailureResult<int>(CacheFailure(message: 'Error'));

      expect(success.getOrElse(0), equals(42));
      expect(failure.getOrElse(0), equals(0));
    });

    test('map should transform success value', () {
      const success = Success<int>(42);
      final mapped = success.map((v) => v * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.asSuccess.value, equals(84));
    });

    test('map should preserve failure', () {
      const failure = FailureResult<int>(CacheFailure(message: 'Error'));
      final mapped = failure.map((v) => v * 2);

      expect(mapped.isFailure, isTrue);
    });
  });
}
