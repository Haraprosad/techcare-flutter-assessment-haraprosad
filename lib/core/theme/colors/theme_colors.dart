import 'package:flutter/material.dart';

// Theme color schemes
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textInteractive;
  final Color warning;
  final Color alert;

  // Income/Expense specific colors
  final Color income;
  final Color expense;

  // UI element colors
  final Color cardBackground;
  final Color divider;
  final Color disabled;
  final Color onPrimaryContainer;
  final Color onSecondaryContainer;

  // Skeleton/Loading colors
  final Color skeleton;
  final Color skeletonShimmer;

  // Chart colors
  final Color chartColor1;
  final Color chartColor2;
  final Color chartColor3;
  final Color chartColor4;
  final Color chartColor5;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInteractive,
    required this.warning,
    required this.alert,
    required this.income,
    required this.expense,
    required this.cardBackground,
    required this.divider,
    required this.disabled,
    required this.onPrimaryContainer,
    required this.onSecondaryContainer,
    required this.skeleton,
    required this.skeletonShimmer,
    required this.chartColor1,
    required this.chartColor2,
    required this.chartColor3,
    required this.chartColor4,
    required this.chartColor5,
  });
}
