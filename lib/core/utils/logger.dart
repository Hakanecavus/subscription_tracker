import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as external_logger;

/// App logger for debug and production logging
class AppLogger {
  static final external_logger.Logger _logger = external_logger.Logger(
    printer: external_logger.PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Log debug message
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info message
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log warning message
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log error message
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    // In production, you might want to send errors to a crash reporting service
  }

  /// Log verbose message
  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log what a terrible failure
  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log route navigation
  static void logRoute(String from, String to, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final paramsStr = params != null ? ' | params: $params' : '';
      _logger.i('📍 Navigation: $from → $to$paramsStr');
    }
  }

  /// Log database operation
  static void logDb(String operation, {String? table, dynamic data, dynamic result}) {
    if (kDebugMode) {
      final tableStr = table != null ? ' [$table]' : '';
      final dataStr = data != null ? ' | data: $data' : '';
      final resultStr = result != null ? ' | result: $result' : '';
      _logger.d('💾 DB$operation$tableStr$dataStr$resultStr');
    }
  }

  /// Log network request
  static void logNetwork(String method, String url, {Map<String, dynamic>? body, int? statusCode}) {
    if (kDebugMode) {
      final emoji = statusCode == null ? '🌐' : (statusCode >= 200 && statusCode < 300 ? '✅' : '❌');
      final statusStr = statusCode != null ? ' [$statusCode]' : '';
      final bodyStr = body != null ? ' | body: $body' : '';
      _logger.d('$emoji $method $url$statusStr$bodyStr');
    }
  }

  /// Log performance
  static void logPerformance(String operation, Duration duration) {
    if (kDebugMode) {
      _logger.i('⏱️ $operation took ${duration.inMilliseconds}ms');
    }
  }
}
