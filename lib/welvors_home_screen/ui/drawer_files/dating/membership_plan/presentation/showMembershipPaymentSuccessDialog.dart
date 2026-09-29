import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/trust_verfication/home.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';

import '../model/membership_plan_model.dart';

/// Shows the payment-success UI as a modal overlay on top of the checkout screen.
///
/// Usage:
/// ```dart
/// await showMembershipPaymentSuccessDialog(
///   context,
///   plan: plan,
///   duration: duration,
///   amount: duration.price,
///   paymentMethod: 'GPay',
/// );
/// ```
Future<void> showMembershipPaymentSuccessDialog(
  BuildContext context, {
  required MembershipPlanModel plan,
  required PlanDuration duration,
  required double amount,
  required String paymentMethod,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Payment successful',
    barrierColor: Colors.black.withOpacity(.56),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _MembershipPaymentSuccessDialog(
        plan: plan,
        duration: duration,
        amount: amount,
        paymentMethod: paymentMethod,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * curved.value,
          sigmaY: 6 * curved.value,
        ),
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .94, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class _MembershipPaymentSuccessDialog extends StatelessWidget {
  final MembershipPlanModel plan;
  final PlanDuration duration;
  final double amount;
  final String paymentMethod;

  const _MembershipPaymentSuccessDialog({
    required this.plan,
    required this.duration,
    required this.amount,
    required this.paymentMethod,
  });

  bool get isElite => plan.tier == MembershipTier.elite;

  String get tierLabel {
    switch (plan.tier) {
      case MembershipTier.premiumPlus:
        return 'Premium+';
      case MembershipTier.vip:
        return 'VIP';
      case MembershipTier.elite:
        return 'VIP Elite';
    }
  }

  String get tierEmoji {
    switch (plan.tier) {
      case MembershipTier.premiumPlus:
        return '🔥';
      case MembershipTier.vip:
        return '👑';
      case MembershipTier.elite:
        return '💠';
    }
  }

  Color get badgeBackground {
    if (isElite) return const Color(0xFFF2F2F2);
    if (plan.tier == MembershipTier.vip) return const Color(0xFFFFF4DD);
    return const Color(0xFFFFE6ED);
  }

  Color get badgeForeground {
    if (isElite) return Colors.black87;
    if (plan.tier == MembershipTier.vip) return const Color(0xFF9A6900);
    return const Color(0xFFC63D65);
  }

  Color get actionColor => plan.tier == MembershipTier.vip
      ? AppColors.gold
      : plan.tier == MembershipTier.premiumPlus
      ? AppColors.pink1
      : isElite
      ? const Color(0xFF1F1F1F)
      : const Color(0xFF202020);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontalPadding = size.width < 360 ? 16.0 : 24.0;

    // Themed colors based on tier
    Color glowColor = plan.tier == MembershipTier.vip
        ? const Color(0xFFFFD700)
        : plan.tier == MembershipTier.premiumPlus
        ? const Color(0xFFE43A6A)
        : Colors.grey.shade400;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                    const BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 30,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PremiumSuccessIcon(
                      tierEmoji: tierEmoji,
                      glowColor: glowColor,
                      isElite: isElite,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to $tierLabel',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 26,
                        height: 1.15,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Your payment of ${_money(amount)} was successful. A receipt has been sent to your email.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A7A7A),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBackground.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: badgeForeground.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 18,
                            color: badgeForeground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All benefits are now active',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: badgeForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TopAndBottomNavScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: actionColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Start Exploring',
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumSuccessIcon extends StatelessWidget {
  final String tierEmoji;
  final Color glowColor;
  final bool isElite;

  const _PremiumSuccessIcon({
    required this.tierEmoji,
    required this.glowColor,
    required this.isElite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor.withOpacity(0.15),
          ),
        ),
        // Middle ring
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor.withOpacity(0.25),
          ),
        ),
        // Inner solid circle
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isElite
                  ? [const Color(0xFF404040), const Color(0xFF1A1A1A)]
                  : [glowColor.withOpacity(0.8), glowColor],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(tierEmoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        // Success checkmark badge
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E), // Vibrant Green
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: Colors.white,
              weight: 900,
            ),
          ),
        ),
      ],
    );
  }
}

String _money(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 3 && remaining % 2 == 0) {
      buffer.write(',');
    }
  }

  return '₹${buffer.toString()}';
}
