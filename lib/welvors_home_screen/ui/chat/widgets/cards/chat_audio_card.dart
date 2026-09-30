import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';
import '../chat_quoted_message_widget.dart';

/// Card for voice note / audio messages
class ChatAudioCard extends StatelessWidget {
  final ChatMessage message;
  final bool isPlaying;
  final VoidCallback onToggleAudio;
  final String? peerName;
  final VoidCallback? onTapReply;

  const ChatAudioCard({
    super.key,
    required this.message,
    required this.isPlaying,
    required this.onToggleAudio,
    this.peerName,
    this.onTapReply,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 5),
            bottomRight: Radius.circular(isMine ? 5 : 20),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if ((message.replyText != null && message.replyText!.trim().isNotEmpty) ||
                (message.replyToId != null && message.replyToId!.trim().isNotEmpty))
              ChatQuotedMessageWidget(
                message: message,
                peerName: peerName ?? '',
                onTap: onTapReply ?? () {},
              ),
            Row(
              children: [
                GestureDetector(
                  onTap: onToggleAudio,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(28, (index) {
                          final height = index.isEven ? 9.0 : 16.0;
                          return Container(
                            width: 3,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isMine ? AppColors.primary : AppColors.ink60,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Voice message',
                        style: AppText.sub.copyWith(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (message.fileSize != null)
                  Text(
                    message.fileSize!,
                    style: AppText.sub.copyWith(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ChatFormatUtils.formatMessageTime(message.time),
                  style: AppText.sub.copyWith(
                    fontSize: 11,
                    color: isMine ? const Color(0xFFB07B8D) : AppColors.muted,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Text(
                    message.seen
                        ? ' ✓✓'
                        : (message.delivered ? ' ✓✓' : '  ✓'),
                    style: AppText.body.copyWith(
                      color: message.seen
                          ? AppColors.primary
                          : (isMine ? const Color(0xFFB07B8D) : Colors.black54),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
