import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:techcare_assessment_app/core/constants/env_constants.dart';
import 'package:techcare_assessment_app/core/constants/string_constants.dart';
import 'package:techcare_assessment_app/core/di/injection.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/observers/bloc_observer.dart';
import 'package:techcare_assessment_app/core/storage/hive_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/flutter_error_screen.dart';
import '../main.dart';
import 'env_config.dart';
import 'environment.dart';

/// The main app initialization flow - sets up everything before the app runs
///
/// This handles:
/// - Loading environment variables (.env files)
/// - Setting up dependency injection
/// - Initializing local storage (Hive)
/// - Configuring error handling
/// - Starting the app
Future<void> initializeApp(Env env) async {
  // Wrap everything in a zone to catch async errors that escape normal handling
  await runZonedGuarded(
    () async {
      // Flutter needs this before we can use any platform services
      WidgetsFlutterBinding.ensureInitialized();

      // Load the .env file for this environment (dev/staging/prod)
      await dotenv.load(fileName: env.envFileName);

      // Set up the global config singleton with values from .env
      EnvConfig.instantiate(
        appName: EnvConfig.createAppName(StringConstants.appName, env),
        baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
        imageBaseUrl: dotenv.env[EnvConstants.envKeyImageBaseUrl] ?? '',
        env: env,
      );

      // Initialize dependency injection - registers all services, repos, BLoCs
      await configureDependencies();

      // Set up Hive for local data storage
      AppLogger.i(message: '🗄️ Initializing Hive storage...');
      final hiveManager = sl<HiveManager>();
      await hiveManager.initialize();
      AppLogger.i(message: '✅ Hive storage initialized successfully');

      // Set up BLoC observer to log state changes (helpful for debugging)
      Bloc.observer = AppBlocObserver();

      // Finally, launch the app!
      runApp(const MyApp());

      //************Device Preview (Uncomment to test on multiple screen sizes)***
      // Useful for testing responsive layouts during development
      //
      // runApp(DevicePreview(
      //   enabled: !kReleaseMode,
      //   builder: (context) => const MyApp(),
      // ));
      //***************************************************************************
    },
    (exception, stackTrace) async {
      // Catch any unhandled async errors that slip through
      AppLogger.f(
        message: "runZonedGuarded caught error",
        error: exception,
        stackTrace: stackTrace,
      );
    },
  );

  // Set up Flutter's error handler for widget/rendering errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Show the error in the console
    FlutterError.presentError(details);

    // Log it for debugging
    AppLogger.f(
      message: "Flutter error: ${details.exception}",
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Handle errors from the native platform (iOS/Android)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.e(
      message: "Platform error: $error",
      error: error,
      stackTrace: stack,
    );

    return true; // Indicates we handled the error
  };

  // Replace Flutter's ugly red error screen with a nicer one
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const FlutterErrorScreen();
  };
}
