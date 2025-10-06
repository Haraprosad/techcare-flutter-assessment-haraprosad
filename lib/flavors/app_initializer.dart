import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:techcare_assessment_app/core/constants/env_constants.dart';
import 'package:techcare_assessment_app/core/constants/string_constants.dart';
import 'package:techcare_assessment_app/core/di/injection.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/observers/bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/flutter_error_screen.dart';
import '../main.dart';
import 'env_config.dart';
import 'environment.dart';

Future<void> initializeApp(Env env) async {
  // Set up zone-based error handling to catch unhandled async errors
  await runZonedGuarded(
    () async {
      // Initialize Flutter framework bindings
      // This must be called before using any Flutter services
      WidgetsFlutterBinding.ensureInitialized();

      // Load environment-specific configuration from .env file
      // This populates dotenv.env with key-value pairs from the specified file
      await dotenv.load(fileName: env.envFileName);

      // Configure the global environment configuration singleton
      // This makes environment settings available throughout the app
      EnvConfig.instantiate(
        appName: EnvConfig.createAppName(StringConstants.appName, env),
        baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
        env: env,
      );

      // Initialize dependency injection container
      // Sets up all services, repositories, BLoCs, and other dependencies
      await configureDependencies();

      // Configure BLoC observer for state management monitoring
      // Provides logging and debugging capabilities for BLoC events and states
      Bloc.observer = AppBlocObserver();

      // Launch the main application widget tree
      runApp(const MyApp());

      //************Device Preview Integration (Optional)**************** */
      // Uncomment the following code to enable DevicePreview for responsive design testing
      // This is useful during development to test the app on different screen sizes
      //
      // runApp(DevicePreview(
      //   enabled: !kReleaseMode, // Only enable in debug mode
      //   builder: (context) => MyApp(), // Wrap your app
      // ));
      //******************************************************************** */
    },
    (exception, stackTrace) async {
      // Handle unhandled asynchronous errors within the guarded zone
      // This catches errors that occur outside of Flutter's error handling
      AppLogger.f(
        message: "runZonedGuarded caught error",
        error: exception,
        stackTrace: stackTrace,
      );
    },
  );

  // Configure Flutter framework error handler
  // This handles errors that occur in the widget tree, rendering, or framework
  FlutterError.onError = (FlutterErrorDetails details) {
    // Ensure the error is displayed in the console/logs
    FlutterError.presentError(details);

    // Log the error using our custom logging system
    AppLogger.f(
      message: "Flutter error: ${details.exception}",
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Configure platform/OS error handler
  // This handles errors from the native platform (iOS/Android)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // Log platform errors for debugging
    AppLogger.e(
      message: "Platform error: $error",
      error: error,
      stackTrace: stack,
    );

    // Return true to indicate the error was handled
    return true;
  };

  // Configure custom error widget builder
  // Replaces Flutter's default red error screen with a user-friendly alternative
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const FlutterErrorScreen();
  };
}
