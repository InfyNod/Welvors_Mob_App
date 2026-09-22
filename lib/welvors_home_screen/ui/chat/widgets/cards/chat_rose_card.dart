import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../../RoseTwinkleOverlay.dart';
import '../../_FloatingRose.dart';
import '../../chat_bloc/chat_state.dart';
/// Card for Rose sent/received messages with animations and reply unlock progress
class ChatRoseCard extends StatelessWidget {
  final ChatMessage message;
  final String peerName;

  const ChatRoseCard({
    super.key,
    required this.message,
    required this.peerName,
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
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        message.isMine
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: message.isMine
                            ? const Color(0xFF8A6010)
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.isMine
                            ? 'ROSE SENT · TO ${peerName.toUpperCase()}'
                            : 'ROSE RECEIVED · FROM ${peerName.toUpperCase()}',
                        style: AppText.eyebrow.copyWith(
                          color: message.isMine
                              ? const Color(0xFF8A6010)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const FloatingRose(),
                ],
              ),
              const Positioned.fill(child: RoseTwinkleOverlay()),
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
