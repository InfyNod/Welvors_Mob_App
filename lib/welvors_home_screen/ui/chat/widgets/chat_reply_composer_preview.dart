import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../chat_bloc/chat_state.dart';

/// Floating preview banner above the composer showing the message being replied to
class ChatReplyComposerPreview extends StatelessWidget {
  final ChatMessage replyingTo;
  final String userName;
  final VoidCallback onCancelReply;

  const ChatReplyComposerPreview({
    super.key,
    required this.replyingTo,
    required this.userName,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = replyingTo.type == ChatMessageType.image;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      padding: const EdgeInsets.fromLTRB(10, 5, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.chatpinkcontanersender.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.chatpinkborder),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          if (isImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: 42,
                height: 42,
                child: _buildThumbnail(replyingTo),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  replyingTo.isMine
                      ? 'Replying to yourself'
                      : 'Replying to $userName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sub.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isImage ? '📷 Photo' : replyingTo.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sub.copyWith(
                    color: AppColors.ink60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancelReply,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.close, size: 20, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ChatMessage message) {
    if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
      return Image.file(
        File(message.fileUrl!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: message.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.soft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 20, color: AppColors.muted),
    );
  }
}
