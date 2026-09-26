import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_dimens.dart';
import 'primary_button.dart';

class TermsBottomSheet {
  static void show(BuildContext context, {required VoidCallback onAgree}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TermsBottomSheetWidget(onAgree: onAgree),
    );
  }
}

class _TermsBottomSheetWidget extends StatelessWidget {
  final VoidCallback onAgree;
  const _TermsBottomSheetWidget({required this.onAgree});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F7F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.pad),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.pinkSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '📋',
                    style: TextStyle(fontSize: 25, height: 1.1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms of Service',
                        style: AppText.display.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Updated 1 July 2026',
                        style: AppText.sub.copyWith(
                          color: AppColors.ink60,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.ink.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.ink.withValues(alpha: 0.08)),

          // Content
          Expanded(
            child: RawScrollbar(
              thumbColor: AppColors.ink.withValues(alpha: 0.4),
              radius: const Radius.circular(4),
              thickness: 4,
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.pad),
                children: const [
                  _Section(
                    title: 'Welcome to Welvors',
                    content:
                        'Welvors is a dating service for adults seeking genuine, serious connections. By creating an account you confirm you are at least 18 years old and that the information you provide is true and your own.',
                  ),
                  _Section(
                    title: 'Your account',
                    content:
                        'You are responsible for keeping your login secure. One person, one account. Impersonation, fake profiles, or using someone else’s photos or documents will lead to removal.',
                  ),
                  _Section(
                    title: 'Respectful use',
                    content:
                        'Treat every member with respect. Harassment, hate speech, nudity, solicitation, spam, or asking members for money is strictly prohibited and may result in a permanent ban.',
                  ),
                  _Section(
                    title: 'Verification & safety',
                    content:
                        'We use ID, photo and other checks to build trust scores. Verification helps keep the community real, but always meet new people in public and tell a friend your plans.',
                  ),
                  _Section(
                    title: 'Payments & wallet',
                    content:
                        'Premium plans, boosts, roses, compliments and events are paid features. Coins in your wallet can be earned or purchased. Withdrawals are subject to a 25% service fee. All purchases are final unless required by law.',
                  ),
                  _Section(
                    title: 'Ending your account',
                    content:
                        'You can delete your account any time from Settings. We may suspend accounts that break these terms or put other members at risk.',
                  ),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pad,
              16,
              AppDimens.pad,
              32,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F4),
              border: Border(
                top: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
              ),
            ),
            child: PrimaryButton(
              'Agree & continue',
              onTap: () {
                Navigator.pop(context);
                onAgree();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h2.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppText.body.copyWith(
              fontSize: 13,
              color: AppColors.ink.withValues(alpha: 0.75),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}