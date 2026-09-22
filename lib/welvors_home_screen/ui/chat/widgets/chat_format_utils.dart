import '../chat_bloc/chat_state.dart';

/// Formatting and helper utilities for chat cards and composer
class ChatFormatUtils {
  ChatFormatUtils._();

  /// Formats message timestamp to readable local time (e.g., '10:30 AM')
  static String formatMessageTime(String time) {
    if (time.isEmpty) return 'Now';
    try {
      final dateTime = DateTime.parse(time).toLocal();
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  /// Formats byte count to human-readable size string (B, KB, MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Checks if message contains an image that should be rendered in quoted preview
  static bool hasReplyImage(ChatMessage message) {
    return message.replyType == ChatMessageType.image ||
        message.replyImageUrl != null ||
        message.replyFileUrl != null;
  }
}
