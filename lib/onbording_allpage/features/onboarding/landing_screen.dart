import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stat_pill.dart';
import '../../widgets/terms_bottom_sheet.dart';
import '../../widgets/privacy_bottom_sheet.dart';
import 'login_screen.dart';
import 'onboarding_flow_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isTermsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.pad),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Premium Logo Header
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    fontFamily: 'DM Sans',
                  ),
                  children: [
                    TextSpan(
                      text: 'Wel',
                      style: TextStyle(color: AppColors.ink),
                    ),
                    TextSpan(
                      text: 'vors',
                      style: TextStyle(color: AppColors.pinkDeep),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Illustration placeholder
              const Expanded(child: Center(child: _Illustration())),

              // Text Content
              Text(
                'Dating for people who\nare serious, not in a\nhurry.',
                textAlign: TextAlign.center,
                style: AppText.display.copyWith(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Real connections with people who want\nthe same things you do. No biodata, no\nfamily pressure — just you, on your own\ntimeline.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: AppColors.ink.withOpacity(0.65),
                  height: 1.5,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 28),

              // Chips
              Wrap(
                spacing: 8,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: const [
                  StatPill(
                    text: 'Verified profiles',
                    emoji: '✓',
                    emojiColor: AppColors.pinkDeep,
                  ),
                  StatPill(text: 'Serious intentions', emoji: '💜'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                children: const [
                  StatPill(text: 'Real-life events', emoji: '🎉'),
                ],
              ),
              const SizedBox(height: 40),

              // Terms & Privacy Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isTermsAccepted = !_isTermsAccepted;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _isTermsAccepted ? AppColors.pinkSoft.withOpacity(0.3) : const Color(0xFFF9F9F9),
                    border: Border.all(
                      color: _isTermsAccepted ? AppColors.pinkDeep.withOpacity(0.4) : const Color(0xFFEBE6DF), 
                      width: 1.5
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 2, right: 12),
                        decoration: BoxDecoration(
                          color: _isTermsAccepted ? AppColors.pinkDeep : Colors.white,
                          border: Border.all(
                            color: _isTermsAccepted ? AppColors.pinkDeep : const Color(0xFFD6CFC4),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _isTermsAccepted ? [
                            BoxShadow(
                              color: AppColors.pinkDeep.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                        child: _isTermsAccepted 
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                      ),
                      // Text
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppText.body.copyWith(
                              fontSize: 13,
                              color: AppColors.ink.withOpacity(0.8),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'I have read and agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: Color(0xFFD64D6F),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFFD64D6F),
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  TermsBottomSheet.show(context, onAgree: () {
                                    setState(() {
                                      _isTermsAccepted = true;
                                    });
                                  });
                                },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: Color(0xFFD64D6F),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFFD64D6F),
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  PrivacyBottomSheet.show(context, onAgree: () {
                                    setState(() {
                                      _isTermsAccepted = true;
                                    });
                                  });
                                },
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                'Get started',
                onTap: _isTermsAccepted ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingFlowScreen(),
                    ),
                  );
                } : null,
              ),
              const SizedBox(height: 16),

              // Login Link
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppText.pill.copyWith(
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Log in',
                      style: const TextStyle(
                        color: AppColors.pinkDeep,
                        fontWeight: FontWeight.w800,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.3,
      child: Lottie.asset('assets/Proposal.json', fit: BoxFit.contain),
    );
  }
}
