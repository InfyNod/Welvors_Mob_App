import 'package:flutter/material.dart';

/// Reusable modern floating SnackBar utility and widget for Welvors.
///
/// Provides quick methods:
/// - [CustomSnackBar.showError]
/// - [CustomSnackBar.showSuccess]
/// - [CustomSnackBar.showWarning]
/// - [CustomSnackBar.showInfo]
/// - [CustomSnackBar.show]
class CustomSnackBar {
  CustomSnackBar._();

  /// Primary Welvors accent pink
  static const Color primaryPink = Color(0xFFE43A6A);

  /// Shows an error / alert snackbar with Welvors pink or custom accent.
  static void showError(
    BuildContext context,
    String message, {
    String title = 'Notice',
    IconData icon = Icons.info_outline_rounded,
    Color accentColor = primaryPink,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      icon: icon,
      accentColor: accentColor,
      duration: duration,
    );
  }

  /// Shows a success snackbar with green accent.
  static void showSuccess(
    BuildContext context,
    String message, {
    String title = 'Success',
    IconData icon = Icons.check_circle_outline_rounded,
    Color accentColor = const Color(0xFF10B981),
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      icon: icon,
      accentColor: accentColor,
      duration: duration,
    );
  }

  /// Shows a warning snackbar with amber accent.
  static void showWarning(
    BuildContext context,
    String message, {
    String title = 'Warning',
    IconData icon = Icons.warning_amber_rounded,
    Color accentColor = const Color(0xFFF59E0B),
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      icon: icon,
      accentColor: accentColor,
      duration: duration,
    );
  }

  /// Shows an info snackbar with blue accent.
  static void showInfo(
    BuildContext context,
    String message, {
    String title = 'Information',
    IconData icon = Icons.info_outline_rounded,
    Color accentColor = const Color(0xFF3B82F6),
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      icon: icon,
      accentColor: accentColor,
      duration: duration,
    );
  }

  /// Displays the custom floating snackbar in the given [context].
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData icon = Icons.info_outline_rounded,
    Color accentColor = primaryPink,
    Color backgroundColor = const Color(0xFF1E1E24),
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      build(
        message: message,
        title: title,
        icon: icon,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  /// Builds a [SnackBar] instance configured with [CustomSnackBarContent].
  static SnackBar build({
    required String message,
    String? title,
    IconData icon = Icons.info_outline_rounded,
    Color accentColor = primaryPink,
    Color backgroundColor = const Color(0xFF1E1E24),
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.zero,
      duration: duration,
      content: CustomSnackBarContent(
        message: message,
        title: title,
        icon: icon,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// Standalone reusable widget for rendering the styled SnackBar card.
class CustomSnackBarContent extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  const CustomSnackBarContent({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline_rounded,
    this.accentColor = const Color(0xFFE43A6A),
    this.backgroundColor = const Color(0xFF1E1E24),
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
