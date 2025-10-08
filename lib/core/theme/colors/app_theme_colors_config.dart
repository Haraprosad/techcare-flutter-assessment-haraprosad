import 'package:flutter/material.dart';
import 'package:techcare_assessment_app/core/theme/base/app_theme_type.dart';
import 'package:techcare_assessment_app/core/theme/colors/theme_colors.dart';

class AppThemeColorsConfig {
  // Status Colors (refined for better UX)
  static const Color _warning = Color(0xFFFFB020);
  static const Color _alert = Color(0xFFFF4757);

  // Theme color schemes
  static final Map<AppThemeType, ThemeColors> themeColors = {
    AppThemeType.light: ThemeColors(
      primary: const Color(0xFF2CCB7B), // Professional green
      secondary: const Color(0xFF7C3AED), // Premium purple
      success: const Color(0xFF2CCB7B), // Matching green for success
      background: const Color(0xFFFAFAFA), // Soft white
      surface: const Color(0xFFFFFFFF), // Pure white
      textPrimary: const Color(0xFF2C2C2C), // Rich dark gray
      textSecondary: const Color(0xFF6B7280),
      textInteractive: const Color(0xFF2CCB7B), // Medium gray // Light gray
      warning: _warning,
      alert: _alert,
      // Income/Expense colors
      income: const Color(0xFF10B981), // Green for income
      expense: const Color(0xFFEF4444), // Red for expense
      // UI element colors
      cardBackground: const Color(0xFFFFFFFF), // White cards
      divider: const Color(0xFFE5E7EB), // Light gray divider
      disabled: const Color(0xFF9CA3AF), // Gray for disabled
      onPrimaryContainer: const Color(0xFF2C2C2C), // Dark text on light primary
      onSecondaryContainer: const Color(
        0xFF2C2C2C,
      ), // Dark text on light secondary
      // Skeleton colors
      skeleton: const Color(0xFFE0E0E0), // Light gray skeleton
      skeletonShimmer: const Color(0xFFF5F5F5), // Lighter gray shimmer
      // Chart colors for light theme
      chartColor1: const Color(0xFFFF6B6B), // Warm red
      chartColor2: const Color(0xFF4ECDC4), // Teal
      chartColor3: const Color(0xFFFFD93D), // Yellow
      chartColor4: const Color(0xFFF38181), // Pink
      chartColor5: const Color(0xFF95A5A6), // Gray
    ),
    AppThemeType.dark: ThemeColors(
      primary: const Color(0xFF3B82F6), // Vibrant blue
      secondary: const Color(0xFF8B5CF6), // Bright purple
      success: const Color(0xFF34D399), // Bright green
      background: const Color(0xFF0F172A), // Deep navy
      surface: const Color(0xFF1E293B), // Slate gray
      textPrimary: const Color(0xFFF8FAFC), // Pure white
      textSecondary: const Color(0xFFCBD5E1),
      textInteractive: const Color(0xFF3B82F6), // Light gray
      warning: _warning,
      alert: _alert,
      // Income/Expense colors for dark theme
      income: const Color(0xFF34D399), // Bright green for income
      expense: const Color(0xFFF87171), // Bright red for expense
      // UI element colors for dark theme
      cardBackground: const Color(0xFF1E293B), // Slate surface
      divider: const Color(0xFF334155), // Dark gray divider
      disabled: const Color(0xFF64748B), // Medium gray for disabled
      onPrimaryContainer: const Color(0xFFF8FAFC), // Light text on dark primary
      onSecondaryContainer: const Color(
        0xFFF8FAFC,
      ), // Light text on dark secondary
      // Skeleton colors for dark theme
      skeleton: const Color(0xFF334155), // Dark gray skeleton
      skeletonShimmer: const Color(0xFF475569), // Lighter dark gray shimmer
      // Chart colors for dark theme - more vibrant for visibility
      chartColor1: const Color(0xFFFF6B9D), // Bright pink-red
      chartColor2: const Color(0xFF4ECDC4), // Teal (works in dark)
      chartColor3: const Color(
        0xFFFFA500,
      ), // Orange (better than yellow in dark)
      chartColor4: const Color(0xFFFF92A5), // Light pink
      chartColor5: const Color(0xFFA8B3CF), // Light gray-blue
    ),
  };
}
