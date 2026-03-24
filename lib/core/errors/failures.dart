import 'package:equatable/equatable.dart';

/// Base Failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server/Network related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Cache/Local database failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
    super.code,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, code, errors];
}

/// Authentication/Authorization failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Biometric authentication failures
class BiometricFailure extends Failure {
  const BiometricFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Notification failures
class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
