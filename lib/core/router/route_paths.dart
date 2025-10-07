import 'package:flutter/foundation.dart';

/// URL paths for each screen in the app.
///
/// These define the actual navigation paths - what you'd see in the URL
/// on web or use when deep linking. All screens with bottom nav share
/// the same root level so the nav bar stays visible.
@immutable
class RoutePaths {
  static const String splash = '/splash';

  // Main screens - these all show the bottom navigation bar
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';

  const RoutePaths._();
}
