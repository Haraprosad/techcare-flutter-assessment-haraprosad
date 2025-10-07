import 'package:flutter/material.dart';

/// Animated number counter widget that animates number changes
/// with count up/down effect
///
/// Duration: 800ms as per design requirements
class AnimatedNumberCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final Duration duration;
  final Curve curve;

  const AnimatedNumberCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 2,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final formattedValue = animatedValue.toStringAsFixed(decimalPlaces);
        return Text('$prefix$formattedValue$suffix', style: style);
      },
    );
  }
}
