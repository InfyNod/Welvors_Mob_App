import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import '../../ChatVideoPlayer.dart';
import '../../chat_bloc/chat_state.dart';

/// Card for video messages with inline video player
class ChatVideoCard extends StatelessWidget {
  final ChatMessage message;

  const ChatVideoCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final url = message.videoUrl?.trim();
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.shadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ChatVideoPlayer(url: url),
        ),
      ),
    );
  }
}
