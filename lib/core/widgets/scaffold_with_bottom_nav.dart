import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_bloc.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_event.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_state.dart';
import 'package:techcare_assessment_app/core/router/route_names.dart';
import 'package:techcare_assessment_app/core/router/route_paths.dart';
import 'package:go_router/go_router.dart';
import 'package:techcare_assessment_app/core/localization/extension/loc.dart';

import '../di/injection.dart';

/// Main scaffold wrapper that includes the bottom navigation bar.
///
/// Wraps child screens and conditionally shows/hides the bottom nav
/// based on the navigation state. Handles tab selection and navigation
/// between the main app sections.
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext ctx) => sl<NavigationBloc>(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          final shouldShowBottomNav = state.showBottomNav;

          return Scaffold(
            body: child,
            bottomNavigationBar: shouldShowBottomNav
                ? BottomNavigationBar(
                    currentIndex: _calculateSelectedIndex(context),
                    onTap: (index) => _onItemTapped(index, context),
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard),
                        label: context.loc.nav_dashboard,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.receipt_long),
                        label: context.loc.nav_transactions,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.analytics),
                        label: context.loc.nav_analytics,
                      ),
                    ],
                  )
                : null, // Hide the nav bar when state says so
          );
        },
      ),
    );
  }

  /// Figures out which tab should be highlighted based on current route
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.fullPath;
    if (location.startsWith(RoutePaths.transactions)) return 1;
    if (location.startsWith(RoutePaths.analytics)) return 2;
    return 0; // Default to dashboard
  }

  /// Handles tab taps - updates state and navigates to the selected screen
  void _onItemTapped(int index, BuildContext context) {
    context.read<NavigationBloc>().add(NavigationTabChanged(index));

    switch (index) {
      case 0:
        context.goNamed(RouteNames.dashboard);
        break;
      case 1:
        context.goNamed(RouteNames.transactions);
        break;
      case 2:
        context.goNamed(RouteNames.analytics);
        break;
    }
  }
}
