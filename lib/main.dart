import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/di/injection.dart';
import 'package:techcare_assessment_app/core/localization/bloc/locale_bloc.dart';
import 'package:techcare_assessment_app/core/localization/l10n/app_localizations.dart';
import 'package:techcare_assessment_app/core/network/services/localization_service/localization_service.dart';
import 'package:techcare_assessment_app/core/router/app_router.dart';
import 'package:techcare_assessment_app/core/theme/base/app_theme.dart';
import 'package:techcare_assessment_app/core/theme/bloc/theme_bloc.dart';
import 'package:techcare_assessment_app/core/theme/constants/breakpoints.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:techcare_assessment_app/core/network/cubit/connectivity_cubit.dart';
import 'package:techcare_assessment_app/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:techcare_assessment_app/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/bloc/transaction_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get adaptive design size based on device type
        // This ensures proper scaling for tablets and phones
        final designSize = _getAdaptiveDesignSize(constraints);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          // Ensure minimum width support (320dp)
          ensureScreenSize: true,
          builder: (_, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<ThemeBloc>(
                  create: (context) =>
                      sl<ThemeBloc>()..add(const InitializeTheme()),
                ),
                BlocProvider<LocaleBloc>(create: (context) => sl<LocaleBloc>()),
                BlocProvider<ConnectivityCubit>(
                  create: (context) => sl<ConnectivityCubit>(),
                ),
                BlocProvider<DashboardBloc>(
                  create: (context) =>
                      sl<DashboardBloc>()
                        ..add(const LoadDashboardDataIfNeededEvent()),
                ),
                BlocProvider<AnalyticsBloc>(
                  create: (context) =>
                      sl<AnalyticsBloc>()..add(const LoadAnalyticsIfNeeded()),
                ),
                BlocProvider<TransactionBloc>(
                  create: (context) => sl<TransactionBloc>(),
                ),
              ],
              child: const AppView(),
            );
          },
        );
      },
    );
  }

  /// Get adaptive design size based on screen dimensions
  Size _getAdaptiveDesignSize(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final isLandscape = width > height;

    // Desktop
    if (width >= Breakpoints.desktopMin) {
      return const Size(1200, 800);
    }

    // Tablet
    if (width >= Breakpoints.tabletMin) {
      return isLandscape ? const Size(1024, 768) : const Size(768, 1024);
    }

    // Mobile (supports minimum 320dp width)
    return isLandscape ? const Size(812, 375) : const Size(375, 812);
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              routerConfig: sl<AppRouter>().routerConfig,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              title: 'Flutter Demo',
              locale: localeState.locale,
              themeMode: themeState.themeMode,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              builder: (context, child) {
                final theme = Theme.of(context);
                final primaryColor = theme.colorScheme.primary;
                final backgroundColor = theme.colorScheme.surface;
                final textColor = theme.colorScheme.primary;

                EasyLoading.instance
                  ..backgroundColor = backgroundColor
                  ..indicatorColor = primaryColor
                  ..textColor = textColor
                  ..progressColor = primaryColor
                  ..userInteractions = false
                  ..loadingStyle = EasyLoadingStyle.custom;

                if (AppLocalizations.of(context) != null) {
                  sl<LocalizationService>().setLocalizations(
                    AppLocalizations.of(context)!,
                  );
                }
                return EasyLoading.init()(context, child);
              },
            );
          },
        );
      },
    );
  }
}
