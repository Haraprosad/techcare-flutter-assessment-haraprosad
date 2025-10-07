import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized logging for the entire app.
///
/// Wraps the Logger package with methods for different log levels.
/// In debug mode, logs go to console with pretty formatting. In release,
/// errors and warnings get sent to monitoring services (when configured).
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: kDebugMode ? Level.trace : Level.error,
  );

  // Singleton so we only have one logger instance
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  /// Debug logs - only show in development
  static void d({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Info logs - general information during development
  static void i({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Warning logs - sent to monitoring in production
  static void w({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _logger.w(message, error: error, stackTrace: stackTrace);

    // Send warnings to Crashlytics/Sentry in production
    if (!kDebugMode) {
      _logToServices(
        message,
        error,
        stackTrace,
        LogLevel.warning,
        metadata: metadata,
      );
    }
  }

  /// Error logs - always sent to monitoring in production
  static void e({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Make sure errors get tracked in production
    if (!kDebugMode) {
      _logToServices(
        message,
        error,
        stackTrace,
        LogLevel.error,
        metadata: metadata,
      );
    }
  }

  /// Fatal logs - critical errors that might crash the app
  static void f({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Definitely need to know about these in production
    if (!kDebugMode) {
      _logToServices(
        message,
        error,
        stackTrace,
        LogLevel.fatal,
        metadata: metadata,
      );
    }
  }

  /// Sends logs to external monitoring services (Crashlytics, Sentry, etc.)
  static Future<void> _logToServices(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    LogLevel level, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      //todo: Uncomment this block during Firebase Crashlytics integration
      // // Log to Firebase Crashlytics
      // await FirebaseCrashlytics.instance.recordError(
      //   error ?? message,
      //   stackTrace,
      //   reason: message,
      //   information: metadata?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      //   fatal: level == LogLevel.fatal,
      // );

      //todo: Uncomment this block during Sentry integration
      // // Log to Sentry
      // await Sentry.captureException(
      //   error ?? message,
      //   stackTrace: stackTrace,
      //   hint: Hint.withMap({'message': message}),
      //   level: _getSentryLevel(level),
      // );
    } catch (e) {
      // Fail silently in production, log to console in debug
      if (kDebugMode) {
        print('Error logging to services: $e');
      }
    }
  }

  /// Helper method to convert log level to Sentry level
  //todo: Uncomment this method during sentry integration
  // static SentryLevel _getSentryLevel(LogLevel level) {
  //   switch (level) {
  //     case LogLevel.warning:
  //       return SentryLevel.warning;
  //     case LogLevel.error:
  //       return SentryLevel.error;
  //     case LogLevel.fatal:
  //       return SentryLevel.fatal;
  //     default:
  //       return SentryLevel.error;
  //   }
  // }
}

enum LogLevel { debug, info, warning, error, fatal }
