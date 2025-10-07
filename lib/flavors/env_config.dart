import 'environment.dart';

/// Manages environment-specific configuration (dev, staging, production)
///
/// This is a singleton that holds API URLs, app names, and other
/// environment-specific settings. You must call `EnvConfig.instantiate()`
/// before accessing any of its properties.

/// Gets thrown when something goes wrong with environment setup
class EnvConfigException implements Exception {
  final String message;

  const EnvConfigException(this.message);

  @override
  String toString() => 'EnvConfigException: $message';
}

/// Singleton that holds all environment-specific configuration
///
/// Usage:
/// 1. Call `EnvConfig.instantiate()` once at app startup
/// 2. Access config anywhere via `EnvConfig.instance.baseUrl`, etc.
class EnvConfig {
  late final String _appName;
  late final String _baseUrl;
  late final String _imageBaseUrl;
  late final Env _env;

  EnvConfig._internal();

  static final EnvConfig instance = EnvConfig._internal();

  /// Prevents re-initialization once config is set
  bool _lock = false;

  /// The app name (includes environment suffix like "MyApp Development")
  String get appName {
    _validateInitialized();
    return _appName;
  }

  /// The API base URL (changes per environment)
  String get baseUrl {
    _validateInitialized();
    return _baseUrl;
  }

  /// Base URL for loading images from the backend
  String get imageBaseUrl {
    _validateInitialized();
    return _imageBaseUrl;
  }

  /// Current environment (dev, staging, or production)
  Env get env {
    _validateInitialized();
    return _env;
  }

  /// Check if config has been initialized without throwing an error
  bool get isInitialized => _lock;

  /// Makes sure config is initialized before accessing properties
  void _validateInitialized() {
    if (!_lock) {
      throw StateError(
        'EnvConfig has not been initialized. Call EnvConfig.instantiate() first.',
      );
    }
  }

  /// Checks that all required config values are valid
  static void _validateParameters({
    required String appName,
    required String baseUrl,
    required Env env,
  }) {
    if (appName.trim().isEmpty) {
      throw const EnvConfigException('App name cannot be empty');
    }

    if (baseUrl.trim().isEmpty) {
      throw const EnvConfigException('Base URL cannot be empty');
    }

    // Make sure the base URL is actually a valid URL
    try {
      final uri = Uri.parse(baseUrl);
      if (!uri.hasScheme ||
          (!uri.scheme.startsWith('http') && uri.scheme != 'mock')) {
        throw const EnvConfigException(
          'Base URL must be a valid HTTP/HTTPS URL or mock:// URL',
        );
      }
    } catch (e) {
      throw EnvConfigException('Invalid base URL format: $baseUrl');
    }
  }

  /// Sets up the environment config - call this once at app startup
  factory EnvConfig.instantiate({
    required String appName,
    required String baseUrl,
    required String imageBaseUrl,
    required Env env,
  }) {
    // If already configured, just return the existing instance
    if (instance._lock) return instance;

    // Validate everything before setting
    _validateParameters(appName: appName, baseUrl: baseUrl, env: env);

    instance._appName = appName.trim();
    instance._baseUrl = baseUrl.trim();
    instance._imageBaseUrl = imageBaseUrl.trim();
    instance._env = env;

    // Lock it so it can't be changed again
    instance._lock = true;

    return instance;
  }

  /// Adds environment suffix to the app name (e.g., "MyApp Development")
  static String createAppName(String baseName, Env environment) {
    if (baseName.trim().isEmpty) {
      throw const EnvConfigException('Base name cannot be empty');
    }

    switch (environment) {
      case Env.DEVELOPMENT:
        return '$baseName Development';
      case Env.STAGING:
        return '$baseName Staging';
      case Env.PRODUCTION:
        return baseName; // Production doesn't get a suffix
    }
  }

  @override
  String toString() {
    if (!_lock) {
      return 'EnvConfig(uninitialized)';
    }
    return 'EnvConfig(env: $_env, appName: $_appName, baseUrl: $_baseUrl)';
  }
}
