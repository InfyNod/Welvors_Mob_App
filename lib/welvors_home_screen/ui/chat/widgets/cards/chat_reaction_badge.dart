import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Small WhatsApp-style reaction badge displayed on a message card corner.
class ChatReactionBadge extends StatelessWidget {
  final String emoji;
  final bool isMine;
  final VoidCallback? onTap;

  const ChatReactionBadge({
    super.key,
    required this.emoji,
    this.isMine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (emoji.trim().isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE43A6A).withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 14,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
