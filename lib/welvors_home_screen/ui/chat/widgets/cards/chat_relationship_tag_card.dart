import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import '../../chat_bloc/chat_state.dart';

/// Card for relationship tag proposals with Accept and Maybe Later buttons
class ChatRelationshipTagCard extends StatelessWidget {
  final ChatMessage message;
  final String peerName;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ChatRelationshipTagCard({
    super.key,
    required this.message,
    required this.peerName,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    String title = 'Relationship Proposal';
    final rawTag = (message.text).trim().toUpperCase();

    if (rawTag.contains('IN_RELATIONSHIP')) {
      title = 'In a Relationship';
    } else if (rawTag.contains('OPEN_RELATIONSHIP')) {
      title = 'Open Relationship';
    } else if (rawTag.contains('ENGAGED')) {
      title = 'Engaged';
    } else if (rawTag.contains('DATE_TO_MARRY')) {
      title = 'Date to Marry';
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8FA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RELATIONSHIP TAG',
                        style: AppText.eyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(title, style: AppText.h2.copyWith(fontSize: 17)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            RichText(
              text: TextSpan(
                style: AppText.body.copyWith(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.ink60,
                ),
                children: [
                  if (isMine)
                    const TextSpan(text: 'Relationship tag proposal sent.')
                  else ...[
                    TextSpan(
                      text: '$peerName has proposed this relationship status to ',
                    ),
                    TextSpan(
                      text: title,
                      style: AppText.body.copyWith(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' on both profiles.'),
                  ],
                ],
              ),
            ),
            if (!isMine && message.relationshipStatus == "PENDING") ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Maybe later',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Mycolor.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
