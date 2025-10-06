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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 835),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(
              create: (context) =>
                  sl<ThemeBloc>()..add(const InitializeTheme()),
            ),
            BlocProvider<LocaleBloc>(create: (context) => sl<LocaleBloc>()),
          ],
          child: const AppView(),
        );
      },
    );
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
