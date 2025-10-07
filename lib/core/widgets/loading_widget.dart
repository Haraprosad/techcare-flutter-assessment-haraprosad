import 'package:flutter/material.dart';

/// Simple centered loading spinner widget.
///
/// Just a circular progress indicator in the middle of the screen.
/// Use this when waiting for data to load or processes to complete.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
