import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

/// Banner shown when a user is blocked in the conversation
class ChatBlockedBanner extends StatelessWidget {
  final String userName;
  final VoidCallback? onUnblock;
  final bool isBlockedByMe;

  const ChatBlockedBanner({
    super.key,
    required this.userName,
    this.onUnblock,
    this.isBlockedByMe = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(40, 10, 40, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isBlockedByMe
                ? 'You blocked $userName'
                : '$userName has blocked you',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isBlockedByMe
                ? 'You can’t message each other while blocked.'
                : 'You cannot send messages to this conversation.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF99958F),
              height: 1.3,
            ),
          ),
          if (isBlockedByMe && onUnblock != null) ...[
            const SizedBox(height: 10),
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
  final int repliesSoFar;
  final int repliesNeeded;
  final VoidCallback? onTap;

  const ChatGiftUnlockProgressBanner({
    super.key,
    this.repliesSoFar = 14,
    this.repliesNeeded = 25,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (repliesSoFar / (repliesNeeded > 0 ? repliesNeeded : 25)).clamp(0.0, 1.0);
    final int repliesRemaining = (repliesNeeded - repliesSoFar).clamp(0, repliesNeeded);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEFECE6), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'GIFT UNLOCK PROGRESS',
                      style: AppText.eyebrow.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: const Color(0xFF8A8680),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$repliesSoFar / $repliesNeeded',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE85A7A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 7,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFBEBEF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE85A7A), Color(0xFFC73A5E)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.grid_view_rounded, size: 13, color: Color(0xFFE85A7A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    repliesRemaining <= 0
                        ? 'Gift unlocked · enough replies!'
                        : '$repliesRemaining more replies to unlock her gift',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5F5C56),
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

/// Progress banner showing relationship level and milestones
class ChatRelationshipProgressBanner extends StatelessWidget {
  final VoidCallback onJourneyTap;

  const ChatRelationshipProgressBanner({
    super.key,
    required this.onJourneyTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onJourneyTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEFECE6), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💗', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'RELATIONSHIP PROGRESS',
                      style: AppText.eyebrow.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: const Color(0xFF8A8680),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LEVEL 4 ›',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8A5A10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 7,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5EEDF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.64,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0C24B), Color(0xFFE08A2B)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: Color(0xFFE08A2B),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Last milestone: ',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    color: Color(0xFF5F5C56),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Level 3 · First Meet',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE85A7A),
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
