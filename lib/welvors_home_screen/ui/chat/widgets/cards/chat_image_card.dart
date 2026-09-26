import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';

/// Card for rendering sent and received image messages with reply overlay
class ChatImageCard extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onTapImage;
  final VoidCallback? onTapReplyOverlay;

  const ChatImageCard({
    super.key,
    required this.message,
    required this.onTapImage,
    this.onTapReplyOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMine ? 20 : 0,
          right: isMine ? 0 : 20,
          bottom: 18,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 320,
              height: 380,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: isMine
                      ? const Radius.circular(22)
                      : const Radius.circular(0),
                  bottomRight: isMine
                      ? const Radius.circular(0)
                      : const Radius.circular(22),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTapImage,
                        child: Hero(
                          tag: 'chat-image-${message.id}',
                          child: _buildImage(message),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ChatFormatUtils.formatMessageTime(message.time),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 4),
                            Text(
                              message.seen ? '✓✓' : '✓',
                              style: TextStyle(
                                color: message.seen
                                    ? AppColors.primary
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (message.replyToId != null)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: _buildImageReplyOverlay(message),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ChatMessage message) {
    if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
      return Image.file(
        File(message.fileUrl!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: message.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => _imagePlaceholder(),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _buildImageReplyOverlay(ChatMessage message) {
    final isImage = ChatFormatUtils.hasReplyImage(message);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapReplyOverlay,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(12),
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
                  child: _buildReplyThumbnail(message),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reply',
                    style: AppText.sub.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isImage ? '📷 Photo' : message.replyText ?? '',
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
          ],
        ),
      ),
    );
  }

  Widget _buildReplyThumbnail(ChatMessage message) {
    if (message.replyFileUrl != null && message.replyFileUrl!.isNotEmpty) {
      return Image.file(
        File(message.replyFileUrl!),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    if (message.replyImageUrl != null && message.replyImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: message.replyImageUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        placeholder: (_, _) => _imagePlaceholder(),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 390,
      color: AppColors.soft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 60, color: AppColors.muted),
    );
  }
}
