import 'package:techcare_assessment_app/core/constants/asset_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_bloc.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_event.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_state.dart';
import 'package:techcare_assessment_app/core/localization/extension/loc.dart';
import 'package:techcare_assessment_app/core/router/route_names.dart';
import 'package:techcare_assessment_app/core/router/route_paths.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';

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
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Theme.of(context).primaryColor,
                    unselectedItemColor: Colors.grey,
                    showUnselectedLabels: true,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard, color: Colors.grey, size: 24.w),
                        activeIcon: Icon(
                          Icons.dashboard,
                          size: 24.w,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.receipt_long, color: Colors.grey, size: 24.w),
                        activeIcon: Icon(
                          Icons.receipt_long,
                          size: 24.w,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: 'Transactions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.analytics, color: Colors.grey, size: 24.w),
                        activeIcon: Icon(
                          Icons.analytics,
                          size: 24.w,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: 'Analytics',
                      ),
                    ],
                  )
                : null, // Set to null to hide bottom nav
          );
        },
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (location.startsWith(RoutePaths.transactions)) return 1;
    if (location.startsWith(RoutePaths.analytics)) return 2;
    return 0;
  }

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
  
