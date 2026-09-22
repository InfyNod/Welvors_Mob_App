import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';

/// Banner shown when the user has blocked the peer
class ChatBlockedBanner extends StatelessWidget {
  final String userName;
  final VoidCallback onUnblock;

  const ChatBlockedBanner({
    super.key,
    required this.userName,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(40, 10, 40, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You blocked $userName',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'She can’t message you or see your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF99958F),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onUnblock,
            child: const Text(
              'Unblock',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE83D72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen view shown when the pair has been unmatched
class ChatUnmatchedBanner extends StatelessWidget {
  final String userName;
  final VoidCallback onBack;

  const ChatUnmatchedBanner({
    super.key,
    required this.userName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3EEF8), Color(0xFFFBE9EE)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Unmatched',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You and $userName are no longer matched. This chat has been removed for both of you.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onBack,
                child: const Text(
                  'Back to messages →',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE85D7D),
                    decoration: TextDecoration.underline,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress banner showing replies needed to unlock her gift
class ChatGiftUnlockProgressBanner extends StatelessWidget {
  const ChatGiftUnlockProgressBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const int repliesSoFar = 14;
    const int repliesNeeded = 25;
    const double progress = repliesSoFar / repliesNeeded;
    final int repliesRemaining = repliesNeeded - repliesSoFar;

    return SizedBox(
      height: 75,
      child: Padding(
        key: const ValueKey('gift_unlock_progress'),
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('GIFT UNLOCK PROGRESS', style: AppText.eyebrow),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Mycolor.pinkffeef2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$repliesSoFar / $repliesNeeded',
                    style: AppText.eyebrow.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: AppColors.soft,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                const Text('🎀', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$repliesRemaining more replies to unlock her gift',
                    style: AppText.body.copyWith(color: AppColors.ink60),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress banner showing relationship level and milestones
class ChatRelationshipProgressBanner extends StatelessWidget {
  final VoidCallback onJourneyTap;

  const ChatRelationshipProgressBanner({
    super.key,
    required this.onJourneyTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Padding(
        key: const ValueKey('relationship_progress'),
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💗', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('RELATIONSHIP PROGRESS', style: AppText.eyebrow),
                  ],
                ),
                InkWell(
                  onTap: onJourneyTap,
                  child: Text(
                    'LEVEL 4 ›',
                    style: AppText.eyebrow.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: .72,
                minHeight: 7,
                backgroundColor: AppColors.soft,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last milestone: ',
                  style: AppText.body.copyWith(color: AppColors.ink60),
                ),
                Expanded(
                  child: Text(
                    'Level 3 · First Meet',
                    style: AppText.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
