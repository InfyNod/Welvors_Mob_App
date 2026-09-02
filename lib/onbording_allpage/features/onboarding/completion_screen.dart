import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import 'user_data.dart';
import 'splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key});

  Widget _buildNumberedCard(int number, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced from 12
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ), // Reduced from 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28, // Reduced from 32
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.pinkDeep,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: AppText.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // Reduced from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppText.body.copyWith(
                    color: AppColors.muted,
                    fontSize: 11, // Reduced from 12
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = userData.name.split(' ').first;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.pad,
                  vertical: 9,
                ), // Reduced vertical padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Checkmark Animation and Pill Stack
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Lottie.asset(
                              'assets/check.json',
                              width: 280, // Reduced from 180
                              height: 200, // Reduced from 180
                              fit: BoxFit.contain,
                              repeat: false,
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '✓ Profile 100% complete',
                                style: AppText.body.copyWith(
                                  color: AppColors.pinkDeep,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title
                    Text(
                      'You\'re all set, $firstName.',
                      textAlign: TextAlign.center,
                      style: AppText.display.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'Your profile is saved and ready. You\'re all\nset to start exploring profiles on Welvors.',
                      textAlign: TextAlign.center,
                      style: AppText.sub.copyWith(
                        color: AppColors.ink60,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Section Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'WHAT\'S NEXT',
                        style: AppText.eyebrow.copyWith(
                          color: AppColors.muted,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cards
                    _buildNumberedCard(
                      1,
                      'Explore Profiles',
                      'Discover and connect with like-minded individuals',
                    ),
                    _buildNumberedCard(
                      2,
                      'Find Your Match',
                      'Engage in meaningful conversations and build real connections',
                    ),
                    _buildNumberedCard(
                      3,
                      'Go on Dates',
                      'Experience curated dates designed just for you',
                    ),

                    const SizedBox(height: 12),

                    // Secure payment text -> changed to generic text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '✨ Get ready to experience Welvors',
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Primary Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pad,
                8,
                AppDimens.pad,
                16,
              ),
              child: PrimaryButton(
                'Explore Profiles →',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_completed', true);

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
