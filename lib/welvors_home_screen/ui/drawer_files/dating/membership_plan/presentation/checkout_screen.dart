import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/showMembershipPaymentSuccessDialog.dart';

import '../model/membership_plan_model.dart';

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
  String _paymentMethod = 'upi';
  String _upiApp = 'GPay';

  String _coupon = '';
  bool _couponApplied = false;

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
                    color: Colors.black.withOpacity(0.04),
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
                  onPressed: _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
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
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------
              // PAYMENT METHOD
              // -------------------------------------------------
              const _SectionLabel('PAYMENT METHOD'),

              const SizedBox(height: 10),

              _PaymentMethods(
                selectedMethod: _paymentMethod,
                selectedUpi: _upiApp,
                accent: _accent,

                onMethodChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                  });
                },

                onUpiChanged: (value) {
                  setState(() {
                    _paymentMethod = 'upi';
                    _upiApp = value;
                  });
                },
              ),

              const SizedBox(height: 25),

              // -------------------------------------------------
              // PRICE DETAILS
              // -------------------------------------------------
              const _SectionLabel('PRICE DETAILS'),

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
                  '♢  256-bit encrypted · powered by Razorpay',
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
    await showMembershipPaymentSuccessDialog(
      context,
      plan: widget.plan,
      duration: widget.duration,
      amount: _payable,
      paymentMethod: _paymentMethod == 'upi' ? _upiApp : _paymentMethod,
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
}

// ===============================================================
// BACK BUTTON
// ===============================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0EFED),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.ink,
          ),
        ),
      ),
    );
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  color: isElite ? Colors.black : softAccent,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  isElite
                      ? '👑'
                      : plan.tier == MembershipTier.vip
                      ? '💎'
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      membershipLabel,
                      style: AppText.sub.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              Text(
                _money(_parsePrice(duration.price)),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(color: AppColors.line, height: 1),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.autorenew_rounded, size: 17, color: AppColors.muted),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  isElite
                      ? 'One-time payment · lifetime access, no renewal'
                      : 'Auto-renews every ${duration.title.split(' ').first == '1' ? 'month' : duration.title.toLowerCase()} · cancel anytime from Settings',
                  style: AppText.sub.copyWith(fontSize: 11.5, height: 1.35),
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

  const _CouponSection({
    required this.controller,
    required this.onApply,
    required this.applied,
    required this.coupon,
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
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
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
                  backgroundColor: AppColors.ink,
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

class _PaymentMethods extends StatelessWidget {
  final String selectedMethod;
  final String selectedUpi;
  final Color accent;

  final ValueChanged<String> onMethodChanged;

  final ValueChanged<String> onUpiChanged;

  const _PaymentMethods({
    required this.selectedMethod,
    required this.selectedUpi,
    required this.accent,
    required this.onMethodChanged,
    required this.onUpiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // UPI
        _MethodCard(
          selected: selectedMethod == 'upi',
          accent: accent,
          icon: '📱',
          title: 'UPI',
          subtitle: 'GPay · PhonePe · Paytm · any UPI app',
          onTap: () => onMethodChanged('upi'),
        ),
        if (selectedMethod == 'upi')
          Column(
            children: [
              const SizedBox(height: 12),

              Row(
                children: [
                  _UpiChip(
                    label: 'GPay',
                    selected: selectedUpi == 'GPay',
                    dot: const Color(0xFF55B946),
                    onTap: () => onUpiChanged('GPay'),
                  ),

                  const SizedBox(width: 8),

                  _UpiChip(
                    label: 'PhonePe',
                    selected: selectedUpi == 'PhonePe',
                    dot: const Color(0xFFB276E8),
                    onTap: () => onUpiChanged('PhonePe'),
                  ),

                  const SizedBox(width: 8),

                  _UpiChip(
                    label: 'Paytm',
                    selected: selectedUpi == 'Paytm',
                    dot: const Color(0xFF789CD8),
                    onTap: () => onUpiChanged('Paytm'),
                  ),

                  const SizedBox(width: 8),

                  _UpiChip(
                    label: 'Other',
                    selected: selectedUpi == 'Other',
                    dot: const Color(0xFF8E8E8E),
                    onTap: () => onUpiChanged('Other'),
                    plus: true,
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 10),

        // CARD
        _MethodCard(
          selected: selectedMethod == 'card',
          accent: accent,
          icon: '💳',
          title: 'Credit / Debit card',
          subtitle: 'Visa · Mastercard · RuPay · Amex',
          onTap: () => onMethodChanged('card'),
        ),

        const SizedBox(height: 10),

        // WALLET
        _MethodCard(
          selected: selectedMethod == 'wallet',
          accent: accent,
          icon: '👛',
          title: 'Welvors Wallet',
          subtitle: 'Balance: ₹2,450 coins',
          onTap: () => onMethodChanged('wallet'),
        ),

        const SizedBox(height: 10),

        // BANK
        _MethodCard(
          selected: selectedMethod == 'bank',
          accent: accent,
          icon: '🏦',
          title: 'Net banking',
          subtitle: 'All major banks supported',
          onTap: () => onMethodChanged('bank'),
        ),
      ],
    );
  }
}

// ===============================================================
// METHOD CARD
// ===============================================================

class _MethodCard extends StatelessWidget {
  final bool selected;
  final Color accent;

  final String icon;
  final String title;
  final String subtitle;

  final VoidCallback onTap;
  final Widget? child;

  const _MethodCard({
    required this.selected,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? accent : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(icon, style: const TextStyle(fontSize: 18)),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.h2.copyWith(fontSize: 16)),

                        const SizedBox(height: 2),

                        Text(
                          subtitle,
                          style: AppText.sub.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),

                  _RadioMark(selected: selected, accent: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// RADIO MARK
// ===============================================================

class _RadioMark extends StatelessWidget {
  final bool selected;
  final Color accent;

  const _RadioMark({required this.selected, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: selected ? accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : AppColors.line,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 15)
          : null,
    );
  }
}

// ===============================================================
// UPI CHIP
// ===============================================================

class _UpiChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color dot;

  final VoidCallback onTap;

  final bool plus;

  const _UpiChip({
    required this.label,
    required this.selected,
    required this.dot,
    required this.onTap,
    this.plus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 68,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFFAEE) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? const Color(0xFFC49A4B) : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              plus
                  ? const Icon(Icons.add, size: 24, color: AppColors.muted)
                  : Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                      ),
                    ),

              const SizedBox(height: 4),

              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color(0xFF795D1D) : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
