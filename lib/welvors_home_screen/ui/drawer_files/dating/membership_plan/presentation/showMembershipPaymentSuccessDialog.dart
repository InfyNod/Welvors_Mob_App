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
        return '⭐';
      case MembershipTier.vip:
        return '💎';
      case MembershipTier.elite:
        return '👑';
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

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 30,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SuccessIcon(),
                    const SizedBox(height: 25),
                    Text(
                      'Payment successful',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 23,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF202020),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You're now a $tierLabel member.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 15.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8D8984),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_money(amount)} paid · receipt sent to your email.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 15.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8D8984),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBackground,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '$tierEmoji $tierLabel unlocked',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: badgeForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 27),
                    SizedBox(
                      width: double.infinity,
                      height: 66,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: Text(
                          'Start exploring',
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
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

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.green,
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withOpacity(.24),
            blurRadius: 24,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, size: 56, color: Colors.white),
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
