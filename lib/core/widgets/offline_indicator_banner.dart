import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/network/cubit/connectivity_cubit.dart';

/// Offline indicator banner that appears at the top of the screen when offline.
///
/// Features:
/// - Auto-shows when connection is lost
/// - Auto-hides when connection is restored
/// - Tap to manually retry connection check
/// - Smooth slide animation
class OfflineIndicatorBanner extends StatelessWidget {
  const OfflineIndicatorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state is DisconnectedState
              ? _buildBanner(context)
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Material(
      color: Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: () {
            // Retry connection check
            context.read<ConnectivityCubit>().refresh();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Tap to retry',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.refresh,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that adds offline indicator to any screen
///
/// Usage:
/// ```dart
/// return WithOfflineIndicator(
///   child: YourScreenWidget(),
/// );
/// ```
class WithOfflineIndicator extends StatelessWidget {
  final Widget child;

  const WithOfflineIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineIndicatorBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Connectivity-aware button that disables when offline
///
/// Usage:
/// ```dart
/// ConnectivityAwareButton(
///   onPressed: () => performNetworkAction(),
///   child: Text('Submit'),
/// )
/// ```
class ConnectivityAwareButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const ConnectivityAwareButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isConnected = state is ConnectedState;

        return ElevatedButton(
          onPressed: isConnected ? onPressed : null,
          style: style,
          child: child,
        );
      },
    );
  }
}
