import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/theme/base/app_theme_type.dart';
import 'package:techcare_assessment_app/core/theme/colors/app_theme_colors_config.dart';
import 'package:techcare_assessment_app/core/theme/colors/theme_colors.dart';
import 'package:techcare_assessment_app/core/theme/constants/app_sizes.dart';
import 'package:techcare_assessment_app/core/theme/typography/text_theme.dart';
import '../styles/button_styles.dart';

class AppTheme {
  AppTheme._();

  // Constants for common values
  static EdgeInsets _buttonPadding() => EdgeInsets.all(10.w);
  static const EdgeInsets _textButtonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  static ThemeData lightTheme() {
    final colors = AppThemeColorsConfig.themeColors[AppThemeType.light]!;
    return _createTheme(brightness: Brightness.light, colors: colors);
  }

  static ThemeData darkTheme() {
    final colors = AppThemeColorsConfig.themeColors[AppThemeType.dark]!;
    return _createTheme(brightness: Brightness.dark, colors: colors);
  }

  static ThemeData _createTheme({
    required Brightness brightness,
    required ThemeColors colors,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      secondary: colors.secondary,
      surfaceTint: colors.primary.withAlpha(26), // 0.1 * 255 ≈ 26
      onSurface: colors.textPrimary,
      surface: colors.surface,
      error: colors.secondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: createTextTheme(colors),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        contentPadding: _textButtonPadding,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        color: colors.surface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        selectedIconTheme: IconThemeData(color: colors.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: colors.textSecondary,
          size: 24,
        ),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyles.elevatedButtonStyle(colors),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyles.outlinedButtonStyle(colors),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyles.textButtonStyle(colors),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: colors.textSecondary.withAlpha(51),
          ), // 0.2 * 255 ≈ 51
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colors.primary),
        ),
        contentPadding: _buttonPadding(),
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }
}
