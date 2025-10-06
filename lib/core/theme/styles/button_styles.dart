import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/theme/colors/theme_colors.dart';
import 'package:techcare_assessment_app/core/theme/constants/app_sizes.dart';
import 'package:techcare_assessment_app/core/utils/app_spacing.dart';

class ButtonStyles {
  static ButtonStyle elevatedButtonStyle(ThemeColors colors) {
    return ElevatedButton.styleFrom(
      backgroundColor: colors.primary,
      foregroundColor: colors.surface,
      elevation: 8,
      shadowColor: colors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      textStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: colors.surface,
      ),
    );
  }

  static ButtonStyle outlinedButtonStyle(ThemeColors colors) {
    return OutlinedButton.styleFrom(
      padding: EdgeInsets.all(10.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      side: BorderSide(color: colors.primary),
      foregroundColor: colors.primary,
    );
  }

  static ButtonStyle textButtonStyle(ThemeColors colors) {
    return TextButton.styleFrom(
      padding: AppSpacing.smPadding,
      foregroundColor: colors.primary,
    );
  }

  static ButtonStyle iconButtonStyle(ThemeColors colors) {
    return IconButton.styleFrom(
      padding: EdgeInsets.all(8.w),
      backgroundColor: colors.surface,
      foregroundColor: colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}
