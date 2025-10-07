import 'package:flutter/material.dart';

/// Responsive breakpoints for different device sizes
/// Following Material Design guidelines and supporting minimum 320dp width
class Breakpoints {
  Breakpoints._();

  // Breakpoint values (in logical pixels)
  static const double mobileMin = 320.0; // Minimum supported width
  static const double mobileMax = 599.0; // Phone portrait
  static const double tabletMin = 600.0; // Tablet portrait
  static const double tabletMax = 839.0;
  static const double desktopMin = 840.0; // Desktop/Tablet landscape
  static const double desktopMax = 1199.0;
  static const double wideMin = 1200.0; // Wide desktop

  // Landscape breakpoints
  static const double landscapeMobileMin = 480.0;
  static const double landscapeTabletMin = 720.0;

  /// Check if device is mobile (phone)
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < tabletMin;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMin && width < desktopMin;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopMin;
  }

  /// Check if orientation is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if orientation is portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopMin) return DeviceType.desktop;
    if (width >= tabletMin) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Get number of columns for grid layout based on device
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Get horizontal padding based on device type
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  /// Get vertical padding based on device type
  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) return 24.0;
    if (isTablet(context)) return 20.0;
    return 16.0;
  }

  /// Get responsive value based on device type
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get design size for ScreenUtil based on device
  static Size getDesignSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    // Desktop
    if (width >= desktopMin) {
      return const Size(1200, 800);
    }

    // Tablet
    if (width >= tabletMin) {
      return orientation == Orientation.landscape
          ? const Size(1024, 768)
          : const Size(768, 1024);
    }

    // Mobile
    return orientation == Orientation.landscape
        ? const Size(812, 375)
        : const Size(375, 812);
  }

  /// Check if screen width is below minimum supported width
  static bool isBelowMinimumWidth(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMin;
  }
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Extension on BuildContext for easier responsive access
extension ResponsiveContext on BuildContext {
  bool get isMobile => Breakpoints.isMobile(this);
  bool get isTablet => Breakpoints.isTablet(this);
  bool get isDesktop => Breakpoints.isDesktop(this);
  bool get isLandscape => Breakpoints.isLandscape(this);
  bool get isPortrait => Breakpoints.isPortrait(this);
  DeviceType get deviceType => Breakpoints.getDeviceType(this);
  int get gridColumns => Breakpoints.getGridColumns(this);
  double get responsiveHPadding => Breakpoints.getHorizontalPadding(this);
  double get responsiveVPadding => Breakpoints.getVerticalPadding(this);
}
