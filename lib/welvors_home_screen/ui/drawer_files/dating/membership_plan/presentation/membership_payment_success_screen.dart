import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';

import '../model/membership_plan_model.dart';

class MembershipPaymentSuccessScreen extends StatelessWidget {
  final MembershipPlanModel plan;
  final PlanDuration duration;
  final double amount;
  final String paymentMethod;

  const MembershipPaymentSuccessScreen({
    super.key,
    required this.plan,
    required this.duration,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isElite = plan.tier == MembershipTier.elite;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.shadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: AppColors.greenSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.green,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Payment successful',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _money(amount),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    isElite
                        ? 'Your VIP Elite lifetime membership is active.'
                        : 'Your ${plan.name} membership is active.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _DetailCard(
                    plan: plan,
                    duration: duration,
                    paymentMethod: paymentMethod,
                    amount: amount,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isElite
                            ? Colors.black
                            : plan.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Continue to Welvors',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
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
    );
  }
}

class _DetailCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final PlanDuration duration;
  final String paymentMethod;
  final double amount;

  const _DetailCard({
    required this.plan,
    required this.duration,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _row('Membership', plan.name),
          const SizedBox(height: 10),
          _row('Duration', duration.title),
          const SizedBox(height: 10),
          _row('Payment method', paymentMethod),
          const SizedBox(height: 10),
          _row('Status', 'Paid · Success', valueColor: AppColors.green),
          const SizedBox(height: 14),
          Divider(color: AppColors.line),
          const SizedBox(height: 13),
          _row('Amount paid', _money(amount), bold: true),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}

String _money(double value) {
  final digits = value.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    b.write(digits[i]);
    if (remaining > 3 && remaining % 2 == 0) b.write(',');
  }
  return '₹${b.toString()}';
}
