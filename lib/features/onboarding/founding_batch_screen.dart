import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';

class FoundingBatchScreen extends StatelessWidget {
  const FoundingBatchScreen({super.key});

  Widget _buildCheckItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.pinkDeep, size: 24),
          const SizedBox(width: 12),
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
                    color: AppColors.ink60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(
    String emoji,
    String title,
    String subtitle,
    String value, {
    bool isFree = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: AppText.body.copyWith(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: AppText.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isFree ? Colors.green : AppColors.pinkDeep,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.pad,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pinkDeep.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.pinkDeep,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FOUNDING BATCH · FILLING FAST',
                            style: AppText.body.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Serious hearts, early\naccess.',
                      style: AppText.display.copyWith(
                        fontSize: 32,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Some people aren\'t looking to pass time — they\'re\nlooking for someone. If that\'s you, come in early,\nbefore the crowd, and find them here first.',
                      style: AppText.sub.copyWith(
                        color: AppColors.ink60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pricing Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.1, 1.0],
                          colors: [
                            Colors.white,
                            Color(0xFFFFF0F5), // Baby pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            245,
                            179,
                            193,
                          ).withOpacity(0.9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pinkSoft.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹299',
                                style: AppText.display.copyWith(fontSize: 40),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '₹999',
                                  style: AppText.body.copyWith(
                                    color: AppColors.muted,
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pinkDeep,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '70% OFF',
                                  style: AppText.body.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'One-time · becomes your first month of\nPremium at launch',
                            style: AppText.body.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCheckItem(
                            '1 month Premium free at launch',
                            'Your ₹299 unlocks the full Premium plan —\nunlimited likes, see who likes you & more',
                          ),
                          _buildCheckItem(
                            'Early access',
                            'Get in before everyone else — first pick of\nmatches',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Perks Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            245,
                            179,
                            193,
                          ).withOpacity(0.9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pinkSoft.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🎁 Your first-month Premium perks',
                                  style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Everything that unlocks the day we launch — free with\nyour founding spot, for your first month.',
                                  style: AppText.body.copyWith(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildPerkItem(
                                  '🚀',
                                  'Weekly Boosts',
                                  '1/week · 4 a month × ₹350',
                                  '₹1,400',
                                ),
                                Divider(
                                  height: 32,
                                  color: AppColors.pinkSoft.withOpacity(0.9),
                                ),
                                _buildPerkItem(
                                  '💝',
                                  'Weekly Compliments',
                                  '1/week · 4 a month × ₹150',
                                  '₹600',
                                ),
                                Divider(
                                  height: 32,
                                  color: AppColors.pinkSoft.withOpacity(0.9),
                                ),
                                _buildPerkItem(
                                  '🗓️',
                                  'Weekly Date Plans',
                                  '1/week · 4 a month × ₹100',
                                  '₹400',
                                ),
                                Divider(
                                  height: 32,
                                  color: AppColors.pinkSoft.withOpacity(0.9),
                                ),
                                _buildPerkItem(
                                  '🔄',
                                  'Daily Rewinds',
                                  '3/day · 90 a month × ₹20',
                                  '₹1,800',
                                ),
                                Divider(
                                  height: 32,
                                  color: AppColors.pinkSoft.withOpacity(0.9),
                                ),
                                _buildPerkItem(
                                  '🪙',
                                  'Welcome Coins',
                                  '100 coins · one-time joining bonus',
                                  'FREE',
                                  isFree: true,
                                ),
                              ],
                            ),
                          ),
                          // Summary Box
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pinkDeep,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            '💎',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Total first-month value',
                                            style: AppText.body.copyWith(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '+ 100 Welcome Coins one-time',
                                        style: AppText.body.copyWith(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹4,200+',
                                  style: AppText.display.copyWith(
                                    color: Colors.white,
                                    fontSize: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'You pay just ',
                                style: AppText.body.copyWith(
                                  color: AppColors.ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₹999',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' ₹299 ',
                                    style: TextStyle(
                                      color: AppColors.pinkDeep,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: 'today'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Insta Card
                    GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://www.instagram.com/welvors_official?utm_source=qr&igsh=MTk5ZnVlZTJkd3kwZA%3D%3D',
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          debugPrint('Could not launch $url');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pinkSoft.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF833AB4),
                                    Color(0xFFFD1D1D),
                                    Color(0xFFF56040),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Follow @welvors_official',
                                    style: AppText.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Daily launch updates & early\ninvites',
                                    style: AppText.body.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pinkSoft.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Follow',
                                style: AppText.body.copyWith(
                                  color: AppColors.pinkDeep,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Secure payment text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 12,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Secure payment · 100% refundable before launch',
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pad,
                8,
                AppDimens.pad,
                16,
              ),
              child: PrimaryButton(
                'Pay ₹299 · Join the waitlist',
                onTap: () {
                  // TODO: Implement payment logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Gateway Coming Soon!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
