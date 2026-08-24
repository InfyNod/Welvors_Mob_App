import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';

import '../model/membership_plan_model.dart';
import 'package:flutter/material.dart';

class PlanTabs extends StatelessWidget {
  final MembershipTier selected;
  final ValueChanged<MembershipTier> onChanged;
  final MembershipPlanModel plan;
  const PlanTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.plan,
  });

  Alignment _getAlignment() {
    switch (selected) {
      case MembershipTier.premiumPlus:
        return Alignment.centerLeft;

      case MembershipTier.vip:
        return Alignment.center;

      case MembershipTier.elite:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEEC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Sliding selected background
          AnimatedAlign(
            alignment: _getAlignment(),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [plan.primaryColor, plan.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tab labels
          Row(
            children: [
              _buildTab(title: 'Premium+', tier: MembershipTier.premiumPlus),
              _buildTab(title: 'VIP', tier: MembershipTier.vip),
              _buildTab(title: 'Elite', tier: MembershipTier.elite),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab({required String title, required MembershipTier tier}) {
    final bool isSelected = selected == tier;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(tier),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF777777),
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  Color _selectedColor() {
    switch (selected) {
      case MembershipTier.premiumPlus:
        return const Color(0xFFD63D68);

      case MembershipTier.vip:
        return const Color(0xFFC88D22);

      case MembershipTier.elite:
        return const Color(0xFF111111);
    }
  }
}

class PlanHeroCard extends StatelessWidget {
  final MembershipPlanModel plan;

  const PlanHeroCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final bool elite = plan.tier == MembershipTier.elite;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [plan.primaryColor, plan.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(.35)),
                ),
                child: Text(
                  plan.emoji + '${plan.badge}',
                  style: GoogleFonts.dmSans(
                    color: elite ? const Color(0xFFE6CD7A) : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              if (plan.tier == MembershipTier.elite)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    // border: Border.all(color: Colors.white.withOpacity(.35)),
                  ),
                  child: Text(
                    '🔒INVITE ONLY',
                    style: GoogleFonts.dmSans(
                      color: elite ? Colors.black : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),

              // 🔒 INVITE ONLY
              if (plan.tier == MembershipTier.premiumPlus)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '🔥 MOST POPULAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pinkDeep,
                    ),
                  ),
                ),
            ],
          ),
          hSized10,
          // Text(plan.emoji, style: const TextStyle(fontSize: 25)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(plan.emoji, style: const TextStyle(fontSize: 25)),
              wSized3,
              Text(
                plan.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.05,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.description,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(.9),
            ),
          ),
          hSized5,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.monthlyPrice,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: elite ? const Color(0xFFE7CD7B) : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  plan.tier == MembershipTier.elite ? '/ year' : '/ month',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (plan.yearlySaving.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Or ${plan.yearlyPrice} — ${plan.yearlySaving}',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          if (plan.tier == MembershipTier.elite) ...[
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE7CD7B).withOpacity(.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Profile review required',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE7CD7B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DurationSelector extends StatefulWidget {
  final MembershipPlanModel plan;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DurationSelector({
    super.key,
    required this.plan,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  late final ScrollController _scrollController;

  // Card width + gap
  static const double _cardWidth = 185;
  static const double _cardGap = 12;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedCard(widget.selectedIndex, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant DurationSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerSelectedCard(widget.selectedIndex);
      });
    }
  }

  void _centerSelectedCard(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.sizeOf(context).width;

    const cardWidth = 185.0;
    const cardGap = 12.0;

    final itemWidth = cardWidth + cardGap;

    // Selected card ka center
    final cardCenter = (index * itemWidth) + (cardWidth / 2);

    // Screen ke center par lane ke liye
    final targetOffset = cardCenter - (screenWidth / 2);

    // Scroll boundaries
    final maxOffset = _scrollController.position.maxScrollExtent;

    final offset = targetOffset.clamp(0.0, maxOffset);

    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return SizedBox(
      height: 120,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: plan.durations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final duration = plan.durations[index];
          final selected = index == widget.selectedIndex;

          final borderColor = plan.tier == MembershipTier.premiumPlus
              ? AppColors.pink
              : plan.tier == MembershipTier.vip
              ? const Color(0xFFD39A36)
              : Colors.black;

          return GestureDetector(
            onTap: () {
              // Pehle selection update
              widget.onSelected(index);

              // Phir selected card center
              _centerSelectedCard(index);
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: _cardWidth,
                  height: 120,
                  padding: const EdgeInsets.only(
                    top: 17,
                    left: 17,
                    right: 17,
                    bottom: 10,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? plan.tier == MembershipTier.premiumPlus
                              ? const Color(0xFFFFE7EC)
                              : plan.tier == MembershipTier.vip
                              ? const Color(0xFFFFF5DD)
                              : const Color(0xFFF2F2F0)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected ? borderColor : AppColors.line,
                      width: selected ? 3 : 1.5,
                    ),
                    boxShadow: selected ? AppColors.shadow : null,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duration.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selected ? Mycolor.black : AppColors.muted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            duration.price,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            duration.perMonth,
                            style: AppText.sub.copyWith(fontSize: 11),
                          ),
                        ],
                      ),

                      // Check
                      Positioned(
                        right: 0,
                        top: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? borderColor : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? borderColor
                                  : const Color(0xFFD4D0CA),
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Save Badge
                if (duration.saving.isNotEmpty)
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        duration.saving,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WeeklyBenefitsWidget extends StatelessWidget {
  final WeeklyBenefits benefits;
  final MembershipTier tier;

  const WeeklyBenefitsWidget({
    super.key,
    required this.benefits,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final Color numberColor = tier == MembershipTier.premiumPlus
        ? AppColors.pinkDeep
        : tier == MembershipTier.vip
        ? const Color(0xFFA66F0A)
        : const Color(0xFFC29A38);

    final items = [
      ('🗓️', benefits.datePlans, 'Date plans / wk'),
      ('🚀', benefits.boosts, 'Boosts / wk'),
      ('💝', benefits.compliments, 'Compliments / wk'),
      ('🪙', benefits.coins, 'Coins / wk'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INCLUDED EVERY WEEK',
          style: AppText.eyebrow.copyWith(
            fontSize: 10,
            color: Mycolor.black,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: items.map((item) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: numberColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$3,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FeatureSectionCard extends StatelessWidget {
  final PlanSection section;
  final MembershipTier tier;

  const FeatureSectionCard({
    super.key,
    required this.section,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = tier == MembershipTier.premiumPlus
        ? AppColors.pinkDeep
        : tier == MembershipTier.vip
        ? const Color(0xFF986407)
        : Colors.black;

    final Color checkBackground = tier == MembershipTier.premiumPlus
        ? AppColors.pinkSoft
        : tier == MembershipTier.vip
        ? const Color(0xFFFFF4DC)
        : const Color(0xFFF0EFEB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: checkBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  section.emoji,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  section.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...section.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, left: 5),
                    width: 22,
                    height: 28,
                    decoration: BoxDecoration(
                      color: checkBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 14, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        hSized3,
                        Text(
                          feature.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.25,
                          ),
                        ),
                        if (feature.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            feature.subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
