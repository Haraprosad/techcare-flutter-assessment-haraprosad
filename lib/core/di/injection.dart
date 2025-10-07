import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

/// Global service locator instance - use this to get dependencies anywhere in the app
final GetIt sl = GetIt.instance;

/// Sets up all our dependencies using code generation.
///
/// This scans the lib and test folders for @injectable annotations
/// and wires everything up automatically. Call this once at app startup.
@InjectableInit(generateForDir: ['lib', 'test'])
Future<void> configureDependencies() async {
  try {
    await sl.init();
    AppLogger.i(message: '✅ Dependencies configured successfully');
  } catch (e) {
    AppLogger.e(message: '❌ Failed to configure dependencies: $e');
    rethrow;
  }
}
