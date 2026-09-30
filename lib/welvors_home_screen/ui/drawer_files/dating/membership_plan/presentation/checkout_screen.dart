import 'package:google_fonts/google_fonts.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/showMembershipPaymentSuccessDialog.dart';

import '../model/membership_plan_model.dart';
import '../data/membership_plan_repository.dart';

class MembershipCheckoutScreen extends StatefulWidget {
  final MembershipPlanModel plan;
  final PlanDuration duration;

  const MembershipCheckoutScreen({
    super.key,
    required this.plan,
    required this.duration,
  });

  @override
  State<MembershipCheckoutScreen> createState() =>
      _MembershipCheckoutScreenState();
}

class _MembershipCheckoutScreenState extends State<MembershipCheckoutScreen> {
  String _coupon = '';
  bool _couponApplied = false;
  bool _isPaying = false;

  late final TextEditingController _couponController;

  bool get _isElite => widget.plan.tier == MembershipTier.elite;

  bool get _isVip => widget.plan.tier == MembershipTier.vip;

  Color get _accent {
    if (_isElite) {
      return const Color(0xFF161616);
    }

    if (_isVip) {
      return const Color(0xFFB88932);
    }

    return AppColors.pink1;
  }

  Color get _softAccent {
    if (_isElite) {
      return const Color(0xFFF1F1EF);
    }

    if (_isVip) {
      return const Color(0xFF9F7121);
    }

    return AppColors.pinkSoft;
  }

  double get _grossAmount {
    return _parsePrice(widget.duration.price);
  }

  double get _discount {
    if (!_couponApplied) {
      return 0;
    }

    if (_coupon == 'WELVORS20') {
      return _grossAmount * .20;
    }

    if (_coupon == 'FIRST100') {
      return 100;
    }

    return 0;
  }

  double get _payable {
    return (_grossAmount - _discount).clamp(0, double.infinity);
  }

  double get _gstIncluded {
    return _payable - (_payable / 1.18);
  }

  String get _membershipLabel {
    if (_isElite) {
      return 'Lifetime membership';
    }

    return '${widget.duration.title.toLowerCase()} membership';
  }

  @override
  void initState() {
    super.initState();

    _couponController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // appBar: AppBar(
      //   backgroundColor: AppColors.white,
      //   surfaceTintColor: AppColors.white,
      //   elevation: 0,

      //   leading: Padding(
      //     padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      //     child: _BackButton(onTap: () => Navigator.pop(context)),
      //   ),

      //   titleSpacing: 8,

      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text('Checkout', style: AppText.h1.copyWith(fontSize: 20)),
      //       const SizedBox(height: 1),
      //       Text(
      //         'Review & pay securely',
      //         style: AppText.sub.copyWith(fontSize: 12),
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 19,
              ),
            ),
            hSized2,
            Text(
              'Review & pay securely',
              style: AppText.sub.copyWith(fontSize: 12),
            ),
          ],
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        //     child: InkWell(
        //       onTap: () => _showHelp(context),
        //       borderRadius: BorderRadius.circular(24),
        //       child: Container(
        //         width: 42,
        //         height: 42,
        //         decoration: const BoxDecoration(
        //           color: Color(0xFFF0EFED),
        //           shape: BoxShape.circle,
        //         ),
        //         alignment: Alignment.center,
        //         child: const Text(
        //           '?',
        //           style: TextStyle(
        //             fontSize: 18,
        //             fontWeight: FontWeight.w800,
        //             color: Color(0xFF66625E),
        //           ),
        //         ),
        //       ),
        //     ),
        // ),
        // ],
      ),
      // ---------------------------------------------------------
      // FIXED BOTTOM PAYMENT BAR
      // ---------------------------------------------------------
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          color: Mycolor.white,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isPaying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.credit_card_outlined, size: 20),
                            const SizedBox(width: 9),
                            Text(
                              'Pay ${_money(_payable)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                "You won't be charged until you confirm",
                style: AppText.sub.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ),

      // ---------------------------------------------------------
      // BODY
      // ---------------------------------------------------------
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------
              // PLAN SUMMARY
              // -------------------------------------------------
              _PlanSummaryCard(
                plan: widget.plan,
                duration: widget.duration,
                accent: _accent,
                softAccent: _softAccent,
                membershipLabel: _membershipLabel,
              ),

              const SizedBox(height: 25),

              // -------------------------------------------------
              // COUPON
              // -------------------------------------------------
              _CouponSection(
                controller: _couponController,
                onApply: _applyCoupon,
                applied: _couponApplied,
                coupon: _coupon,
                accent: _accent,
              ),
              const SizedBox(height: 25),

              // PRICE DETAILS
              const SizedBox(height: 10),

              _PriceDetails(
                plan: widget.plan,
                duration: widget.duration,
                gst: _gstIncluded,
                discount: _discount,
                total: _payable,
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  '♢  powered by Google Play Billing',
                  style: AppText.sub.copyWith(fontSize: 11),
                ),
              ),

              // Extra bottom spacing so last content is comfortable
              // above the fixed payment bar.
              // const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // COUPON
  // -------------------------------------------------------------

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();

    if (code == 'WELVORS20' || code == 'FIRST100') {
      setState(() {
        _coupon = code;
        _couponApplied = true;
      });

      return;
    }

    setState(() {
      _coupon = '';
      _couponApplied = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid coupon code'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------------------------------------------------
  // PAYMENT
  // -------------------------------------------------------------

  void _pay() async {
    setState(() {
      _isPaying = true;
    });

    final repo = MembershipPlanRepository();
    final result = await repo.purchasePackage(widget.duration.id);

    if (mounted) {
      setState(() {
        _isPaying = false;
      });

      if (result['success'] == true) {
        await showMembershipPaymentSuccessDialog(
          context,
          plan: widget.plan,
          duration: widget.duration,
          amount: _payable,
          paymentMethod: 'Google Play',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Failed to process payment. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
}

// ===============================================================
// PLAN SUMMARY CARD
// ===============================================================

class _PlanSummaryCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final PlanDuration duration;
  final Color accent;
  final Color softAccent;
  final String membershipLabel;

  const _PlanSummaryCard({
    required this.plan,
    required this.duration,
    required this.accent,
    required this.softAccent,
    required this.membershipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isElite = plan.tier == MembershipTier.elite;
    final isVip = plan.tier == MembershipTier.vip;

    LinearGradient bgGradient;
    Color textColor = AppColors.ink;
    Color subTextColor = AppColors.ink60;
    Color dividerColor = AppColors.line;

    if (isElite) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      textColor = Colors.white;
      subTextColor = Colors.white70;
      dividerColor = Colors.white24;
    } else if (isVip) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFFF8EA), Color(0xFFF3E1B9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      textColor = const Color(0xFF4A3300);
      subTextColor = const Color(0xFF856724);
      dividerColor = const Color(0xFFE8D099);
    } else {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFFF0F4), Color(0xFFFFDBE5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      textColor = const Color(0xFF5E1325);
      subTextColor = const Color(0xFF9E425B);
      dividerColor = const Color(0xFFFFBCCF);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isElite ? const Color(0xFF4D4D4D) : accent.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isElite ? 0.35 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isElite ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  isElite
                      ? '💠'
                      : isVip
                      ? '👑'
                      : '🔥',
                  style: const TextStyle(fontSize: 29),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      membershipLabel,
                      style: AppText.sub.copyWith(
                        fontSize: 12,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _money(_parsePrice(duration.price)),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(color: dividerColor, height: 1),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.autorenew_rounded, size: 17, color: subTextColor),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  isElite
                      ? 'One-time payment · lifetime access, no renewal'
                      : 'Auto-renews every ${duration.title.split(' ').first == '1' ? 'month' : duration.title.toLowerCase()} · cancel anytime from Settings',
                  style: AppText.sub.copyWith(
                    fontSize: 11.5,
                    height: 1.35,
                    color: subTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// COUPON SECTION
// ===============================================================

class _CouponSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final bool applied;
  final String coupon;
  final Color accent;

  const _CouponSection({
    required this.controller,
    required this.onApply,
    required this.applied,
    required this.coupon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('HAVE A COUPON?'),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter coupon code',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFFB8B6B2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.ink,
                      width: 1.3,
                    ),
                  ),
                  suffixIcon: applied
                      ? const Icon(Icons.check_circle, color: AppColors.green)
                      : null,
                ),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              height: 50,
              width: 88,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: AppText.button.copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _CouponChip(
              label: 'WELVORS20 · 20% off',
              onTap: () => _fill(controller, 'WELVORS20'),
            ),
            _CouponChip(
              label: 'FIRST100 · ₹100 off',
              onTap: () => _fill(controller, 'FIRST100'),
            ),
          ],
        ),
      ],
    );
  }

  static void _fill(TextEditingController controller, String code) {
    controller.text = code;

    controller.selection = TextSelection.collapsed(offset: code.length);
  }
}

// ===============================================================
// COUPON CHIP
// ===============================================================

class _CouponChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CouponChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFD8B86A)),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF856724),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// PAYMENT METHODS
// ===============================================================

// ===============================================================
// PRICE DETAILS
// ===============================================================

class _PriceDetails extends StatelessWidget {
  final MembershipPlanModel plan;
  final PlanDuration duration;

  final double gst;
  final double discount;
  final double total;

  const _PriceDetails({
    required this.plan,
    required this.duration,
    required this.gst,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: plan.tier == MembershipTier.elite
                ? 'VIP Elite · Lifetime'
                : '${plan.name} · ${_durationLabel(duration.title)}',
            value: _money(total),
          ),

          if (discount > 0) ...[
            const SizedBox(height: 9),

            _PriceRow(
              label: 'Coupon discount',
              value: '- ${_money(discount)}',
              valueColor: AppColors.green,
            ),
          ],

          const SizedBox(height: 9),

          _PriceRow(label: 'GST (18%, incl.)', value: _money(gst)),

          const SizedBox(height: 14),

          Divider(color: AppColors.line, height: 1),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total payable',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),

              Text(
                _money(total),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// PRICE ROW
// ===============================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.body.copyWith(fontSize: 13, color: AppColors.muted),
          ),
        ),

        const SizedBox(width: 15),

        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// SECTION LABEL
// ===============================================================

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Mycolor.black,
        letterSpacing: 1.25,
      ),
    );
  }
}

// ===============================================================
// HELPERS
// ===============================================================

String _durationLabel(String title) {
  return title.toLowerCase();
}

double _parsePrice(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');

  return double.tryParse(cleaned) ?? 0;
}

String _money(double value) {
  final rounded = value.round();

  final digits = rounded.toString();

  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;

    buffer.write(digits[i]);

    if (remaining > 3 && remaining % 2 == 0) {
      buffer.write(',');
    }
  }

  return '₹${buffer.toString()}';
}
