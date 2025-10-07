import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:techcare_assessment_app/core/router/route_names.dart';

/// The app's splash screen - shown on launch with a fade-in animation
///
/// Displays the app logo for 2 seconds, then navigates to the dashboard.
/// Uses a simple opacity animation for a smooth fade-in effect.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the fade-in animation (1.5 seconds)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Start the navigation timer
    _initializeSplash();
  }

  /// Waits 2 seconds then navigates to the dashboard
  void _initializeSplash() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.pushReplacementNamed(RouteNames.dashboard);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: FlutterLogo(
                  size: 150.w,
                ), // TODO: Replace with actual app logo
              );
            },
          ),
        ),
      ),
    );
  }
}
