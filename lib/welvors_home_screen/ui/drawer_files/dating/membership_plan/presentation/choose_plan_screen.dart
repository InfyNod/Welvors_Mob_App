import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/retry.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_dimens.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/autotext.dart';

import '../bloc/membership_plan_bloc.dart';
import '../bloc/membership_plan_event.dart';
import '../bloc/membership_plan_state.dart';
import '../data/membership_plan_repository.dart';
import '../model/membership_plan_model.dart';
import '../widgets/membership_plan_widgets.dart';
import 'checkout_screen.dart';

class ChoosePlanScreen extends StatelessWidget {
  final MembershipTier initialTier;

  const ChoosePlanScreen({super.key, required this.initialTier});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MembershipPlanBloc(repository: MembershipPlanRepository())
            ..add(LoadMembershipPlans(initialTier: initialTier)),
      child: const _ChoosePlanView(),
    );
  }
}

class _ChoosePlanView extends StatefulWidget {
  const _ChoosePlanView();

  @override
  State<_ChoosePlanView> createState() => _ChoosePlanViewState();
}

class _ChoosePlanViewState extends State<_ChoosePlanView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text(
          'Choose your plan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          color: Mycolor.white,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: BlocBuilder<MembershipPlanBloc, MembershipPlanState>(
            builder: (context, state) {
              // if (state.status == MembershipPlanStatus.loading ||
              //     state.status == MembershipPlanStatus.initial) {
              //   return const SizedBox(
              //     height: 56,
              //     child: Center(
              //       child: CircularProgressIndicator(color: AppColors.pink),
              //     ),
              //   );
              // }

              if (state.status == MembershipPlanStatus.failure) {
                return SizedBox(
                  height: 56,
                  child: Center(
                    child: Text(state.errorMessage, style: AppText.body),
                  ),
                );
              }

              final plan = state.selectedPlan;

              if (plan == null) {
                return const SizedBox.shrink();
              }

              return _buildBottomButton(context, state, plan);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<MembershipPlanBloc, MembershipPlanState>(
          builder: (context, state) {
            if (state.status == MembershipPlanStatus.loading ||
                state.status == MembershipPlanStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.pink),
              );
            }

            if (state.status == MembershipPlanStatus.failure) {
              return Center(
                child: Text(state.errorMessage, style: AppText.body),
              );
            }

            final plan = state.selectedPlan;

            if (plan == null) {
              return const SizedBox.shrink();
            }

            return Stack(
              children: [
                Column(
                  children: [
                    hSized10,

                    // _buildAppBar(context),
                    _buildTabs(context, state, plan),
                    const SizedBox(height: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pad,
                          0,
                          AppDimens.pad,
                          10,
                        ),
                        child: _buildContent(context, state, plan),
                      ),
                    ),
                  ],
                ),
                // _buildBottomButton(context, state, plan),
                hSized10,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          Padding(
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
          const Spacer(),
          Text(
            'Choose your plan',
            style: AppText.h2.copyWith(
              fontSize: 20,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // _roundIconButton(
          //   icon: Icons.question_mark_rounded,
          //   onTap: () => _showHelp(context),
          // ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
    );
  }

  Widget _buildTabs(
    BuildContext context,
    MembershipPlanState state,
    MembershipPlanModel plan,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: PlanTabs(
        plan: plan,
        selected: state.selectedTier,
        onChanged: (tier) {
          // Tab change
          context.read<MembershipPlanBloc>().add(SelectMembershipTier(tier));

          // Vertical screen ko top par scroll karo
          // Smoothly scroll content to top
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            }
          });
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MembershipPlanState state,
    MembershipPlanModel plan,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanHeroCard(plan: plan),
        const SizedBox(height: 10),
        if (plan.tier == MembershipTier.elite) _buildEliteNotice(),
        if (plan.tier == MembershipTier.elite) const SizedBox(height: 16),
        DurationSelector(
          plan: plan,
          selectedIndex: state.selectedDurationIndex,
          onSelected: (index) {
            context.read<MembershipPlanBloc>().add(SelectPlanDuration(index));
          },
        ),
        hSized10,
        WeeklyBenefitsWidget(benefits: plan.weeklyBenefits, tier: plan.tier),
        const SizedBox(height: 15),
        ...plan.sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FeatureSectionCard(section: section, tier: plan.tier),
          ),
        ),
        if (plan.tier == MembershipTier.elite)
          Center(
            child: Text(
              "For ambitious individuals seeking private, high-trust, curated connections.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff928e88),
                letterSpacing: 0.8,
              ),
            ),
          ),
        if (plan.tier == MembershipTier.elite)
          Center(
            child: Text(
              "Not for everyone. Built for those who value privacy, standards & meaningful access.",

              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff928e88),
                letterSpacing: 0.8,
              ),
            ),
          ),
        if (plan.tier == MembershipTier.elite) hSized10,
      ],
    );
  }

  Widget _buildEliteNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF292929),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(.15)),
            ),
            alignment: Alignment.center,
            child: const Text('📋', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Applications reviewed weekly.\n',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Approval not guaranteed. Identity + lifestyle verification required.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white.withOpacity(.7),
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

  Widget _buildBottomButton(
    BuildContext context,
    MembershipPlanState state,
    MembershipPlanModel plan,
  ) {
    final duration = plan.durations[state.selectedDurationIndex];

    final bool elite = plan.tier == MembershipTier.elite;
    final bool vip = plan.tier == MembershipTier.vip;

    final Color buttonColor = elite
        ? Colors.black
        : vip
        ? const Color(0xFFC28A26)
        : AppColors.pink1;

    final String action = elite
        ? 'Request'
        : vip
        ? 'Apply'
        : 'Continue';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(.30),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                _handlePlanSelection(context, plan, duration);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$action with  ${duration.price} ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          elite
              ? 'Applications reviewed weekly · Approval not guaranteed'
              : vip
              ? 'Limited VIP memberships released monthly'
              : 'Cancel anytime · 7-day money-back guarantee',
          style: AppText.sub.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  void _handlePlanSelection(
    BuildContext context,
    MembershipPlanModel plan,
    PlanDuration duration,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MembershipCheckoutScreen(plan: plan, duration: duration),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Membership plans', style: AppText.h1),
              const SizedBox(height: 10),
              Text(
                'Choose the membership that best matches your dating and privacy needs.',
                style: AppText.body.copyWith(
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
