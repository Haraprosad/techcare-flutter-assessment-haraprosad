import 'package:flutter/material.dart';
import 'package:techcare_assessment_app/core/theme/constants/breakpoints.dart';

/// A widget that ensures the app works properly on minimum width screens (320dp)
/// Shows a warning when screen is too narrow for optimal experience
class MinimumWidthConstraint extends StatelessWidget {
  final Widget child;
  final bool showWarning;
  final double minimumWidth;

  const MinimumWidthConstraint({
    super.key,
    required this.child,
    this.showWarning = true,
    this.minimumWidth = Breakpoints.mobileMin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isBelowMinimum = screenWidth < minimumWidth;

        if (isBelowMinimum && showWarning) {
          return Stack(
            children: [
              child,
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Material(
                  color: Colors.orange.shade900.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Screen width (${screenWidth.toInt()}dp) is below recommended minimum (${minimumWidth.toInt()}dp)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return child;
      },
    );
  }
}

/// A widget that provides constrained minimum width for its child
/// This ensures content doesn't break on very narrow screens
class ConstrainedMinWidth extends StatelessWidget {
  final Widget child;
  final double minWidth;

  const ConstrainedMinWidth({
    super.key,
    required this.child,
    this.minWidth = Breakpoints.mobileMin,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: child,
    );
  }
}

/// Extension to check minimum width support
extension MinimumWidthCheck on BuildContext {
  bool get isBelowMinimumWidth {
    return MediaQuery.of(this).size.width < Breakpoints.mobileMin;
  }

  bool get meetsMinimumWidth {
    return MediaQuery.of(this).size.width >= Breakpoints.mobileMin;
  }
}
