import 'package:flutter/material.dart';

/// Contextual App Bar shown during message multi-selection in ChatDetailScreen (like WhatsApp).
class ChatSelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onReply;
  final bool canCopy;
  final bool canReply;

  const ChatSelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onDelete,
    this.onCopy,
    this.onReply,
    this.canCopy = false,
    this.canReply = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.black87),
        tooltip: 'Close',
        onPressed: onClose,
      ),
      titleSpacing: 0,
      title: Text(
        '$selectedCount selected',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'DM Sans',
        ),
      ),
      actions: [
        if (canReply && onReply != null)
          IconButton(
            icon: const Icon(Icons.reply_rounded, color: Colors.black87),
            tooltip: 'Reply',
            onPressed: onReply,
          ),
        if (canCopy && onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.black87),
            tooltip: 'Copy',
            onPressed: onCopy,
          ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFE43A6A),
          ),
          tooltip: 'Delete',
          onPressed: onDelete,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
