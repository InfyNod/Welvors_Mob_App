import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../../RoseTwinkleOverlay.dart';
import '../../_FloatingRose.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';

/// Card for virtual gift messages with unlock progress
class ChatGiftCard extends StatelessWidget {
  final ChatMessage message;
  final String peerName;

  const ChatGiftCard({
    super.key,
    required this.message,
    required this.peerName,
  });

  @override
  Widget build(BuildContext context) {
    final current = message.messageProgress ?? 0;
    final target = message.messageTarget ?? 0;
    final hasProgress = target > 0;
    final progress = hasProgress ? (current / target).clamp(0.0, 1.0) : 0.0;
    final remaining = hasProgress ? (target - current).clamp(0, target) : 0;
    final isMine = message.isMine;
    final name = peerName.trim().isEmpty ? 'AANYA' : peerName.toUpperCase();
    final spent =
        message.giftCoins?.replaceFirst('+', '').replaceFirst(' Coins', '') ??
        '0';
    final unlocked = message.giftClaimed || (hasProgress && current >= target);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: (MediaQuery.sizeOf(context).width * .86)
            .clamp(300.0, 520.0)
            .toDouble(),
        margin: EdgeInsets.only(
          left: isMine ? 42 : 0,
          right: isMine ? 0 : 42,
          bottom: 20,
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
            color: isMine ? const Color(0xffffd2dc) : const Color(0xffd8e5ff),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isMine ? const Color(0x18e34d70) : const Color(0x183b76df),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.imageUrl ?? '').trim().isNotEmpty)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: message.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: const Color(0xffeee8e5),
                          alignment: Alignment.center,
                          child: Text(
                            message.giftEmoji ?? '🎁',
                            style: const TextStyle(fontSize: 54),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xffeee8e5),
                          alignment: Alignment.center,
                          child: Text(
                            message.giftEmoji ?? '🎁',
                            style: const TextStyle(fontSize: 54),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          isMine ? '🎁 GIFT SENT' : '🎁 GIFT FROM $name',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3367c9),
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.giftEmoji ?? '🎁',
                        style: const TextStyle(fontSize: 19),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          message.giftName ?? 'Gift',
                          style: AppText.h2.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((message.text).trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                  ],
                  if (hasProgress) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isMine
                              ? const Color(0xffffd9e1)
                              : const Color(0xffdce7fb),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reply progress',
                                style: AppText.body.copyWith(
                                  color: const Color(0xff918c89),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                '$current/$target replies',
                                style: AppText.body.copyWith(
                                  color: isMine
                                      ? AppColors.primary
                                      : const Color(0xff3168ca),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: isMine
                                  ? const Color(0xffffe1e7)
                                  : const Color(0xffe2eafa),
                              valueColor: AlwaysStoppedAnimation(
                                isMine
                                    ? AppColors.primary
                                    : const Color(0xff4d87ee),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            unlocked
                                ? '✓ She replied enough — your gift is unlocked'
                                : '$remaining more replies and your gift unlocks${isMine ? '' : ' as'} ${isMine ? '' : '🪙$spent'}',
                            style: AppText.body.copyWith(
                              color: unlocked
                                  ? const Color(0xff2bb36b)
                                  : const Color(0xff686360),
                              fontSize: 12,
                              fontWeight: unlocked
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const Divider(color: Color(0xfff1dddd), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isMine
                                ? const Color(0xffffd4de)
                                : const Color(0xffd4e1fb),
                          ),
                        ),
                        child: Text(
                          '🪙$spent ${isMine ? 'spent' : 'pending'}',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3269ce),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ChatFormatUtils.formatMessageTime(message.time),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 4),
                            Text(
                              message.seen ? '✓✓' : '✓',
                              style: TextStyle(
                                color: message.seen
                                    ? AppColors.primary
                                    : Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

/// Card for combined engagement bundle messages (rose + gift combo)
class ChatEngagementBundleCard extends StatelessWidget {
  final ChatMessage message;

  const ChatEngagementBundleCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final progress = message.messageProgress;
    final target = message.messageTarget;
    final hasReplyProgress = progress != null && target != null && target > 0;
    final remaining = hasReplyProgress
        ? (target - progress).clamp(0, target)
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF6D7C2), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF9EEEF),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(child: RoseTwinkleOverlay()),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              message.isMine
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 13,
                              color: message.isMine
                                  ? const Color(0xFF8A6010)
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const FloatingRose(),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            message.isMine ? 'ROSE SENT' : 'ROSE RECEIVED',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.eyebrow.copyWith(
                              fontSize: 10,
                              color: message.isMine
                                  ? const Color(0xFF8A6010)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(child: RoseTwinkleOverlay()),
                    Column(
                      children: [
                        const SizedBox(height: 27),
                        FloatingGift(imageUrl: message.imageUrl),
                        const SizedBox(height: 13),
                        Text(
                          message.giftName ?? 'Special Gift',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF302A2C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '"${message.complimentMessage ?? 'You are a beautiful soul, and I cherish every moment we share together.'}"',
              textAlign: TextAlign.center,
              style: AppText.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.35,
                color: const Color(0xFF272326),
              ),
            ),
          ),
          if (message.hintLine != null) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFF0ECEC), width: 1),
              ),
              child: Text(
                message.hintLine!,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: const Color(0xFF686163),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],
          if (hasReplyProgress) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 1, 18, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xfff3d4dc), width: 1.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          message.isMine
                              ? 'Her reply progress'
                              : 'Reply progress',
                          style: AppText.body.copyWith(
                            color: const Color(0xFF8B8680),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$progress/$target replies',
                        style: AppText.body.copyWith(
                          color: const Color(0xFFD83D62),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (progress / target).clamp(0.0, 1.0),
                      minHeight: 11,
                      backgroundColor: const Color(0xFFF4E1E6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD94768),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message.isMine
                        ? '$remaining more replies to unlock your rose for her'
                        : '$remaining more replies to unlock her rose',
                    style: AppText.body.copyWith(
                      color: const Color(0xFF686163),
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!message.isMine) ...[
            const SizedBox(height: 14),
            Text(
              "She sent this hoping you'd write back. Keep it going  — a few replies in, the rose unlocks as 🪙 10.",
              style: AppText.sub1.copyWith(
                color: const Color(0xFFC7395E),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            message.isMine
                ? "Sent · ${DateFormat('hh:mm a').format(DateTime.parse(message.time).toLocal())} · ${message.seen ? '✓✓ Seen' : '✓ Sent'}"
                : 'Received today ·${DateFormat('hh:mm a').format(DateTime.parse(message.time).toLocal())} · her rose unlocks as you talk',
            textAlign: TextAlign.center,
            style: AppText.sub1.copyWith(
              color: const Color(0xFF999294),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
