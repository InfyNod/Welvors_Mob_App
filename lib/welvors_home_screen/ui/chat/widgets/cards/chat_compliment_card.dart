import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';

/// Card for sent and received compliments with optional profile photo & fact snippet
class ChatComplimentCard extends StatelessWidget {
  final ChatMessage message;
  final String peerName;

  const ChatComplimentCard({
    super.key,
    required this.message,
    required this.peerName,
  });

  @override
  Widget build(BuildContext context) {
    final coin = message.coinAmount ?? '30';
    final isMine = message.isMine;
    final hasImage = (message.complimentImageUrl ?? '').trim().isNotEmpty;
    final hasFact = (message.complimentFactTitle ?? '').trim().isNotEmpty;
    final read = message.seen;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: (MediaQuery.sizeOf(context).width * .86)
            .clamp(300.0, 520.0)
            .toDouble(),
        margin: EdgeInsets.only(
          left: isMine ? 42 : 0,
          right: isMine ? 0 : 42,
          bottom: 18,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xfffffcfa),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isMine ? 24 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 24),
          ),
          border: Border.all(
            color: isMine ? const Color(0xffffd2dc) : const Color(0xffd9e6fb),
          ),
          boxShadow: [
            BoxShadow(
              color: isMine ? const Color(0x18e34d70) : const Color(0x183b76df),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              SizedBox(
                height: 175,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: message.complimentImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: const Color(0xffdbe7f2)),
                      errorWidget: (_, _, _) => Container(color: const Color(0xffdbe7f2)),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 13,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          '💝 COMPLIMENT ${isMine ? 'SENT' : 'FROM ${peerName.toUpperCase()}'}',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasImage)
                    Row(
                      children: [
                        Text(
                          "💝",
                          style: AppText.eyebrow.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          isMine
                              ? 'COMPLIMENT SENT'
                              : 'COMPLIMENT FROM ${peerName.toUpperCase()}',
                          style: AppText.eyebrow.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  hSized10,
                  if (hasFact) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isMine
                              ? const Color(0xffffdce3)
                              : const Color(0xffdce7f7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xffffeff3)
                                  : const Color(0xffedf3ff),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              message.complimentIcon ?? '✨',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.complimentFactTitle!,
                                  style: AppText.h2.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  message.complimentFactSubtitle ?? '',
                                  style: AppText.body.copyWith(
                                    color: const Color(0xff918c89),
                                    fontSize: 10,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                  ],
                  if ((message.text).trim().isNotEmpty)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff4b83f1),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              message.text,
                              style: AppText.body.copyWith(
                                fontSize: 14,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xff2d292b),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasImage && (message.locationLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'On your ${message.locationLabel}',
                      style: AppText.body.copyWith(
                        color: const Color(0xff8e8986),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xfff0dddd), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isMine
                                ? const Color(0xffffd2dc)
                                : const Color(0xffd5e2fa),
                          ),
                        ),
                        child: Text(
                          isMine ? '🪙$coin spent' : '💝 Compliment received',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ChatFormatUtils.formatMessageTime(message.time),
                            style: AppText.body.copyWith(
                              color: const Color(0xff928d89),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ((message.isMine) ? (read ? ' ✓✓' : '  ✓') : ""),
                            style: AppText.body.copyWith(
                              color: message.seen
                                  ? AppColors.primary
                                  : Colors.white,
                              fontSize: 14,
                            ),
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
}
