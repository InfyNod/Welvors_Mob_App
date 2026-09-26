import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_dimens.dart';
import 'primary_button.dart';

class PrivacyBottomSheet {
  static void show(BuildContext context, {required VoidCallback onAgree}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PrivacyBottomSheetWidget(onAgree: onAgree),
    );
  }
}

class _PrivacyBottomSheetWidget extends StatelessWidget {
  final VoidCallback onAgree;
  const _PrivacyBottomSheetWidget({required this.onAgree});

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
                    '🔒',
                    style: TextStyle(fontSize: 25, height: 1.1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy',
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
                    title: 'What we collect',
                    content:
                        'Your phone number, profile details, photos, and the choices you make in the app (interests, intentions, location). Verification documents are handled separately and never shown on your profile.',
                  ),
                  _Section(
                    title: 'How we use it',
                    content:
                        'To build your profile, suggest compatible people, keep the platform safe, and improve matching. We never sell your personal data.',
                  ),
                  _Section(
                    title: 'Who can see you',
                    content:
                        'You control visibility. Free & Premium members and VIP members live in separate pools and cannot see across them. Only the city or venue is shown to others — never your exact location.',
                  ),
                  _Section(
                    title: 'Your documents',
                    content:
                        'ID and verification files are encrypted, used only to confirm your identity, and are never displayed to other members or shared for advertising.',
                  ),
                  _Section(
                    title: 'Your rights',
                    content:
                        'You can access, download, correct or delete your data any time from Settings › Data & rights. Deleting your account removes your profile from discovery immediately.',
                  ),
                  _Section(
                    title: 'Contact',
                    content:
                        'Questions about your data? Reach our Grievance Officer at privacy@welvors.com.',
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
