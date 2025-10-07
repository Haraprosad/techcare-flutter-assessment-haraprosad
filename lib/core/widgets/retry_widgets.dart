import 'package:flutter/material.dart';

/// Snackbar that shows when optimistic update fails with retry option
///
/// Features:
/// - Shows error message
/// - Provides retry button
/// - Auto-dismisses after timeout
/// - Undo option for reversible operations
class OptimisticUpdateRetrySnackbar {
  /// Show error snackbar with retry option
  static void showRetrySnackbar({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar for confirmed operations
  static void showSuccessSnackbar({
    required BuildContext context,
    required String message,
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: duration,
        action: onUndo != null
            ? SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: onUndo,
              )
            : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show pending snackbar for operations in progress
  static void showPendingSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Dialog for showing retry options when operation fails
class RetryOptionsDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const RetryOptionsDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onRetry,
    required VoidCallback onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RetryOptionsDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        onCancel: onCancel,
      ),
    );
  }
}

/// Inline retry widget for failed operations
class InlineRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isCompact;

  const InlineRetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return InkWell(
        onTap: onRetry,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Tap to retry',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.red.shade900, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
