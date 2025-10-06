import 'package:flutter/material.dart';
import 'package:techcare_assessment_app/core/theme/colors/theme_colors.dart';
import 'package:techcare_assessment_app/core/theme/colors/app_theme_colors_config.dart';
import 'package:techcare_assessment_app/core/theme/base/app_theme_type.dart';
import 'package:techcare_assessment_app/core/theme/constants/app_sizes.dart';

/// Extension to access custom theme colors directly from BuildContext
extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors {
    final brightness = Theme.of(this).brightness;
    final themeType = brightness == Brightness.light
        ? AppThemeType.light
        : AppThemeType.dark;
    return AppThemeColorsConfig.themeColors[themeType]!;
  }
}

/// Extension to access spacing system from BuildContext
extension SpacingExtension on BuildContext {
  // Remove the getter that tries to instantiate AppSpacing
  // AppSpacing get spacing => AppSpacing();
}

/// Extension to access sizing system from BuildContext
extension SizingExtension on BuildContext {
  // Remove the getter that tries to instantiate AppSizes
  // AppSizes get sizes => AppSizes();
}

/// Extension for common theme-based widgets
extension ThemeWidgetsExtension on BuildContext {
  // Dividers
  Widget get thinDivider => Divider(
    height: 1,
    thickness: 0.5,
    color: colors.textSecondary.withOpacity(0.2),
  );

  Widget get thickDivider => Divider(
    height: 2,
    thickness: 1,
    color: colors.textSecondary.withOpacity(0.3),
  );

  // Loading indicators
  Widget get circularLoader => CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
  );

  // Common containers
  Widget cardContainer({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      boxShadow: [
        BoxShadow(
          color: colors.textSecondary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}
