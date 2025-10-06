
import 'environment.dart';

/// #Environment Configuration Management

/// Exception thrown when environment configuration validation fails.
class EnvConfigException implements Exception {
  /// The error message describing what went wrong.
  final String message;
  
  /// Creates a new environment configuration exception.
  const EnvConfigException(this.message);
  
  @override
  String toString() => 'EnvConfigException: $message';
}

/// Singleton class for managing environment-specific application configuration.
class EnvConfig {
  /// The display name of the application.

  late final String _appName;
  
  /// The base URL for API endpoints.
  
  late final String _baseUrl;

  late final String _imageBaseUrl;
  
  /// The current application environment.
  late final Env _env;

  /// Private constructor for singleton pattern.
  EnvConfig._internal();
  
  /// The singleton instance of [EnvConfig].
  static final EnvConfig instance = EnvConfig._internal();

  /// Lock flag to prevent multiple initializations.
  bool _lock = false;

  /// Gets the application name.
  /// 
  /// Throws [StateError] if accessed before initialization.
  String get appName {
    _validateInitialized();
    return _appName;
  }

  /// Gets the base URL for API endpoints.
  /// 
  /// Throws [StateError] if accessed before initialization.
  String get baseUrl {
    _validateInitialized();
    return _baseUrl;
  }

   String get imageBaseUrl {
    _validateInitialized();
    return _imageBaseUrl;
  }

  /// Gets the current environment.
  /// 
  /// Throws [StateError] if accessed before initialization.
  Env get env {
    _validateInitialized();
    return _env;
  }

  /// Gets whether the configuration has been initialized.
  /// 
  /// This is useful for checking initialization status without
  /// throwing exceptions.
  bool get isInitialized => _lock;

  /// Validates that the configuration has been initialized.
  /// 
  /// Throws [StateError] if not initialized.
  void _validateInitialized() {
    if (!_lock) {
      throw StateError(
        'EnvConfig has not been initialized. Call EnvConfig.instantiate() first.',
      );
    }
  }

  /// Validates the provided configuration parameters.
  /// 
  /// Throws [EnvConfigException] if any parameter is invalid.
  static void _validateParameters({
    required String appName,
    required String baseUrl,
    required Env env,
  }) {
    // Validate app name
    if (appName.trim().isEmpty) {
      throw const EnvConfigException('App name cannot be empty');
    }

    // Validate base URL format
    if (baseUrl.trim().isEmpty) {
      throw const EnvConfigException('Base URL cannot be empty');
    }

    try {
      final uri = Uri.parse(baseUrl);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        throw const EnvConfigException(
          'Base URL must be a valid HTTP/HTTPS URL',
        );
      }
    } catch (e) {
      throw EnvConfigException('Invalid base URL format: $baseUrl');
    }
  }
  
  /// Factory constructor to initialize the environment configuration.
  factory EnvConfig.instantiate({
    required String appName,
    required String baseUrl,
    required Env env,
  }) {
    // Return existing instance if already locked (configured)
    if (instance._lock) return instance;

    // Validate parameters before setting
    _validateParameters(
      appName: appName,
      baseUrl: baseUrl,
      env: env,
    );

    // Configure the singleton instance
    instance._appName = appName.trim();
    instance._baseUrl = baseUrl.trim();
    instance._env = env;
    
    // Lock the configuration to prevent future modifications
    instance._lock = true;
    
    return instance;
  }

  /// Creates an app name based on the environment.

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
        return baseName;
    }
  }

  /// Returns a string representation of the configuration.
  @override
  String toString() {
    if (!_lock) {
      return 'EnvConfig(uninitialized)';
    }
    return 'EnvConfig(env: $_env, appName: $_appName, baseUrl: $_baseUrl)';
  }
}
