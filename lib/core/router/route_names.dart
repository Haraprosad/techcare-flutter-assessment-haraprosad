import 'package:flutter/foundation.dart';

/// Route names used internally by GoRouter.
///
/// These are like IDs for each route - you won't see them in the URL bar,
/// but they're useful for navigation and testing. Keep them in sync with RoutePaths.
@immutable
class RouteNames {
  static const String splash = 'splash';

  // Main app screens
  static const String dashboard = 'dashboard';
  static const String transactions = 'transactions';
  static const String analytics = 'analytics';

  const RouteNames._();
}
