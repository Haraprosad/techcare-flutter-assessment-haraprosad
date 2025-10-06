import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/router/navigator_keys.dart';
import 'package:techcare_assessment_app/core/router/route_names.dart';
import 'package:techcare_assessment_app/core/router/route_paths.dart';
import 'package:techcare_assessment_app/core/widgets/scaffold_with_bottom_nav.dart';
import 'package:techcare_assessment_app/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:techcare_assessment_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/pages/transactions_screen.dart';

@singleton
class AppRoutes {
  List<RouteBase> get routes => [
        // Splash Route
        splashRoute,

        // Main App Routes (Inside Shell with Bottom Navigation)
        _mainShellRoute,
      ];
  RouteBase get splashRoute => GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      );

  ShellRoute get _mainShellRoute => ShellRoute(
        navigatorKey: NavigatorKeys.shellNavigator,
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          _dashboardRoute,
          _transactionsRoute,
          _analyticsRoute,
        ],
      );

  GoRoute get _dashboardRoute => GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      );

  GoRoute get _transactionsRoute => GoRoute(
        path: RoutePaths.transactions,
        name: RouteNames.transactions,
        builder: (context, state) => const TransactionsScreen(),
      );

  GoRoute get _analyticsRoute => GoRoute(
        path: RoutePaths.analytics,
        name: RouteNames.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      );
}
     