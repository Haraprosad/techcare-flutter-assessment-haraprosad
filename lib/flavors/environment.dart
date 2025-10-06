enum Env {
  DEVELOPMENT,
  STAGING,
  PRODUCTION;

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

  bool get isProduction => this == Env.PRODUCTION;
  bool get isDevelopment => this == Env.DEVELOPMENT;
  bool get isStaging => this == Env.STAGING;
}
