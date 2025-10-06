import 'package:techcare_assessment_app/core/observers/router_observer.dart';
import 'package:techcare_assessment_app/core/router/app_routes.dart';
import 'package:techcare_assessment_app/core/router/navigator_keys.dart';
import 'package:techcare_assessment_app/core/router/route_paths.dart';
import 'package:techcare_assessment_app/core/widgets/error_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouter {
  final AppRoutes _appRoutes;

  AppRouter(this._appRoutes);

  late final GoRouter routerConfig = GoRouter(
    navigatorKey: NavigatorKeys.rootNavigator,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: _appRoutes.routes,
    errorBuilder: (context, state) =>
        ErrorScreen(errorMessage: state.error.toString()),
    observers: [AppRouterObserver()],
  );
}
      