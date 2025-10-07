import 'package:flutter/material.dart';
import 'package:techcare_assessment_app/core/theme/constants/breakpoints.dart';

/// A widget that builds different layouts based on screen size
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktopMin) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.tabletMin) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// A widget that builds different layouts based on orientation
class OrientationLayoutBuilder extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationLayoutBuilder({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// A widget that combines responsive and orientation layouts
class AdaptiveLayoutBuilder extends StatelessWidget {
  final Widget mobilePortrait;
  final Widget? mobileLandscape;
  final Widget? tabletPortrait;
  final Widget? tabletLandscape;
  final Widget? desktop;

  const AdaptiveLayoutBuilder({
    super.key,
    required this.mobilePortrait,
    this.mobileLandscape,
    this.tabletPortrait,
    this.tabletLandscape,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = orientation == Orientation.landscape;
            final width = constraints.maxWidth;

            // Desktop
            if (width >= Breakpoints.desktopMin) {
              return desktop ??
                  (isLandscape ? tabletLandscape : tabletPortrait) ??
                  (isLandscape ? mobileLandscape : mobilePortrait) ??
                  mobilePortrait;
            }

            // Tablet
            if (width >= Breakpoints.tabletMin) {
              if (isLandscape) {
                return tabletLandscape ??
                    tabletPortrait ??
                    mobileLandscape ??
                    mobilePortrait;
              }
              return tabletPortrait ?? mobilePortrait;
            }

            // Mobile
            if (isLandscape) {
              return mobileLandscape ?? mobilePortrait;
            }
            return mobilePortrait;
          },
        );
      },
    );
  }
}

/// A widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;

        if (constraints.maxWidth >= Breakpoints.desktopMin && desktop != null) {
          padding = desktop!;
        } else if (constraints.maxWidth >= Breakpoints.tabletMin &&
            tablet != null) {
          padding = tablet!;
        } else {
          padding = mobile ?? const EdgeInsets.all(16.0);
        }

        return Padding(padding: padding, child: child);
      },
    );
  }
}

/// A widget that provides responsive sizing
class ResponsiveSizedBox extends StatelessWidget {
  final Widget? child;
  final double? mobileWidth;
  final double? mobileHeight;
  final double? tabletWidth;
  final double? tabletHeight;
  final double? desktopWidth;
  final double? desktopHeight;

  const ResponsiveSizedBox({
    super.key,
    this.child,
    this.mobileWidth,
    this.mobileHeight,
    this.tabletWidth,
    this.tabletHeight,
    this.desktopWidth,
    this.desktopHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double? width;
        double? height;

        if (constraints.maxWidth >= Breakpoints.desktopMin) {
          width = desktopWidth ?? tabletWidth ?? mobileWidth;
          height = desktopHeight ?? tabletHeight ?? mobileHeight;
        } else if (constraints.maxWidth >= Breakpoints.tabletMin) {
          width = tabletWidth ?? mobileWidth;
          height = tabletHeight ?? mobileHeight;
        } else {
          width = mobileWidth;
          height = mobileHeight;
        }

        return SizedBox(width: width, height: height, child: child);
      },
    );
  }
}

/// A builder function type for responsive values
typedef ResponsiveValueBuilder<T> =
    T Function(
      BuildContext context,
      DeviceType deviceType,
      Orientation orientation,
    );

/// A widget that provides responsive values via builder
class ResponsiveValue<T> extends StatelessWidget {
  final ResponsiveValueBuilder<T> builder;
  final Widget Function(BuildContext context, T value) child;

  const ResponsiveValue({
    super.key,
    required this.builder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final deviceType = Breakpoints.getDeviceType(context);
        final value = builder(context, deviceType, orientation);
        return child(context, value);
      },
    );
  }
}
