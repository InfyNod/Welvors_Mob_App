import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';
import '../chat_quoted_message_widget.dart';

/// Card for standard text messages
class ChatTextCard extends StatelessWidget {
  final ChatMessage message;
  final String peerName;
  final VoidCallback? onTapReply;

  const ChatTextCard({
    super.key,
    required this.message,
    required this.peerName,
    this.onTapReply,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMine = message.isMine;
    final isImage = ChatFormatUtils.hasReplyImage(message);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: EdgeInsets.only(
          left: isMine ? 30 : 0,
          right: isMine ? 0 : 30,
          bottom: 18,
        ),
        padding: (isImage == false)
            ? const EdgeInsets.fromLTRB(10, 10, 10, 8)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isImage
              ? AppColors.white
              : isMine
              ? AppColors.chatpinkcontanersender
              : Colors.white,
          border: Border.all(color: AppColors.chatpinkborder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 20),
          ),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.replyText != null)
              ChatQuotedMessageWidget(
                message: message,
                peerName: peerName,
                onTap: onTapReply ?? () {},
              ),
            if (isImage == false)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 3, 3, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message.text,
                        softWrap: true,
                        style: AppText.body.copyWith(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w300,
                          color: isMine ? Colors.black : AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ChatFormatUtils.formatMessageTime(message.time),
                          style: AppText.sub.copyWith(
                            fontSize: 12,
                            color: isMine
                                ? const Color(0xFFB07B8D)
                                : AppColors.muted,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                ((message.isMine)
                                    ? (message.seen ? ' ✓✓' : '  ✓')
                                    : ""),
                                style: AppText.body.copyWith(
                                  color: message.seen
                                      ? AppColors.primary
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card for animated effect messages (e.g. Heart rain, confetti)
class ChatEffectCard extends StatelessWidget {
  final ChatMessage message;
  final void Function(String emoji, String label) onPlayEffect;

  const ChatEffectCard({
    super.key,
    required this.message,
    required this.onPlayEffect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMine = message.isMine;
    final emoji = message.giftEmoji ?? '✨';
    final label = message.giftName ?? message.text;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: isMine ? AppColors.chatpinkcontanersender : Colors.white,
          border: Border.all(color: AppColors.chatpinkborder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 20),
          ),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.chatpinkborder),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to play again',
                        style: AppText.sub.copyWith(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onPlayEffect(emoji, label),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EBEC),
                      shape: BoxShape.circle,
                      boxShadow: AppColors.shadow,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ChatFormatUtils.formatMessageTime(message.time),
                    style: AppText.sub.copyWith(
                      fontSize: 12,
                      color: isMine ? const Color(0xFFB07B8D) : AppColors.muted,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Text(
                      ((message.isMine)
                          ? (message.seen ? ' ✓✓' : '  ✓')
                          : ""),
                      style: AppText.body.copyWith(
                        color: message.seen
                            ? AppColors.primary
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
