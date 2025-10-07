/// Defines the app's runtime environment - dev, staging, or production
///
/// Each environment can have its own API endpoints, feature flags, etc.
/// The .env file is loaded based on which environment is active.
enum Env {
  DEVELOPMENT,
  STAGING,
  PRODUCTION;

  /// Returns the .env filename for this environment
  String get envFileName {
    switch (this) {
      case Env.DEVELOPMENT:
        return '.env.development';
      case Env.STAGING:
        return '.env.staging';
      case Env.PRODUCTION:
        return '.env.production';
    }
  }

  /// Quick checks for which environment we're in
  bool get isProduction => this == Env.PRODUCTION;
  bool get isDevelopment => this == Env.DEVELOPMENT;
  bool get isStaging => this == Env.STAGING;
}
