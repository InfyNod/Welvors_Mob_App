import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../chat_bloc/chat_state.dart';
import 'chat_format_utils.dart';

/// Renders a quoted/replied message preview inside a message bubble
class ChatQuotedMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final String peerName;
  final VoidCallback onTap;

  const ChatQuotedMessageWidget({
    super.key,
    required this.message,
    required this.peerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = ChatFormatUtils.hasReplyImage(message);

    if (isImage) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18.5),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 300,
                          height: 200,
                          child: _buildReplyImage(message),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💖', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            'COMPLIMENT SENT',
                            style: AppText.sub.copyWith(
                              color: const Color(0xFFE34F72),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE34F72),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message.text,
                              style: AppText.sub.copyWith(
                                color: const Color(0xff6d6b69),
                                fontSize: 14,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'On her ',
                        style: AppText.sub.copyWith(
                          color: const Color(0xFF8A8083),
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: 'hero photo',
                            style: AppText.sub.copyWith(
                              color: const Color(0xFFE34F72),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              height: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF3E2E6)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEFE2E5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👵', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '30 spent',
                                style: AppText.sub.copyWith(
                                  color: const Color(0xFFE34F72),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '8:47 PM',
                              style: AppText.sub.copyWith(
                                color: const Color(0xFF9E9497),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.done_all_rounded,
                              size: 14,
                              color: Color(0xFF9E9497),
                            ),
                          ],
                        ),
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3C9D2), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE34F72).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.reply_rounded,
                        size: 14,
                        color: Color(0xFFE34F72),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          message.isMine ? 'You' : peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sub.copyWith(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.replyText?.trim().isNotEmpty == true
                        ? message.replyText!
                        : 'Message',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sub.copyWith(
                      color: const Color(0xFF5F5A5B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyImage(ChatMessage message) {
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
        placeholder: (_, __) => _imagePlaceholder(),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.soft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.muted, size: 22),
    );
  }
}
