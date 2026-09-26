import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/model/membership_plan_model.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/choose_plan_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/data/membership_plan_repository.dart';

class PrivacySafetyAndMembership extends StatefulWidget {
  const PrivacySafetyAndMembership({super.key});

  @override
  State<PrivacySafetyAndMembership> createState() =>
      _PrivacySafetyAndMembershipState();
}

class _PrivacySafetyAndMembershipState
    extends State<PrivacySafetyAndMembership> {
  bool _isSafetyModeOn = false;
  List<MembershipPlanModel> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    final repo = MembershipPlanRepository();
    final plans = await repo.fetchPlans();
    if (mounted) {
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVACY & SAFETY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.shadow, // Using the same premium shadow
          ),
          child: Column(
            children: [
              // Header: SafeFace
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          251,
                          219,
                          236,
                        ), // Very light pink
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/safefacee.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SafeFace',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hide your real photo behind an avatar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
              const SizedBox(height: 16),
              // Safety Mode Toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Safety Mode',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Show avatar until you choose to reveal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _isSafetyModeOn
                            ? const Color(0xFFE85A7A)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(2),
                      alignment: _isSafetyModeOn
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'MEMBERSHIP PLANS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal Scrolling Cards
        _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: AppColors.pink),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    if (_plans.isNotEmpty) _buildPremiumPlusCard(_plans[0]),
                    const SizedBox(width: 16),
                    if (_plans.length > 1) _buildVIPCard(_plans[1]),
                    const SizedBox(width: 16),
                    if (_plans.length > 2) _buildVIPEliteCard(_plans[2]),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildPremiumPlusCard(MembershipPlanModel plan) {
    return Container(
      width: 280, // Fixed width for horizontal scrolling
      padding: const EdgeInsets.all(16), // Reduced padding to decrease height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFBE4E7),
          width: 1.5,
        ), // Light pink border
        boxShadow: AppColors.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE4E7), // Light red/pink circle
                  borderRadius: BorderRadius.circular(12), // Rounded square
                ),
                alignment: Alignment.center,
                child: const Text('🔥', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name.replaceAll('_', ' '),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (plan.badgeLabel != null && plan.badgeLabel!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE85A7A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              plan.badgeLabel!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${plan.monthlyPrice} ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: '/ month',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildDynamicFeatures(plan, const Color(0xFFE85A7A), Colors.black87),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChoosePlanScreen(
                    initialTier: MembershipTier.premiumPlus,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE85A7A),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Upgrade now →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVIPCard(MembershipPlanModel plan) {
    return Container(
      width: 280, // Fixed width
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFF4E0),
          width: 1.5,
        ), // Light gold border
        boxShadow: AppColors.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E0), // Light gold background
                  borderRadius: BorderRadius.circular(12), // Rounded square
                ),
                alignment: Alignment.center,
                child: const Text('👑', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name.replaceAll('_', ' '),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (plan.badgeLabel != null && plan.badgeLabel!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFC8933A,
                              ), // Dark gold/brown background
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              plan.badgeLabel!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${plan.monthlyPrice} ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: '/ month',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildDynamicFeatures(plan, const Color(0xFFC8933A), Colors.black87),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ChoosePlanScreen(initialTier: MembershipTier.vip),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFC8933A), // Gold color
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Apply for VIP →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVIPEliteCard(MembershipPlanModel plan) {
    return Container(
      width: 280, // Fixed width
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF222222), // Dark premium background
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333), // Darker background
                  borderRadius: BorderRadius.circular(12), // Rounded square
                ),
                alignment: Alignment.center,
                child: const Text('💫', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name.replaceAll('_', ' '),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // White text for dark theme
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (plan.badgeLabel != null && plan.badgeLabel!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5C07B), // Gold background
                              borderRadius: BorderRadius.circular(
                                5,
                              ), // More rounded badge
                            ),
                            child: Text(
                              plan.badgeLabel!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87, // Dark text
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${plan.monthlyPrice} ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE5C07B), // Gold price
                            ),
                          ),
                          TextSpan(
                            text: '/ month',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildDynamicFeatures(plan, const Color(0xFFE5C07B), Colors.white),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ChoosePlanScreen(initialTier: MembershipTier.elite),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE5C07B), // Gold color
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Request invite →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Dark text on gold button
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text, Color iconColor, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicFeatures(MembershipPlanModel plan, Color iconColor, Color textColor) {
    List<String> allFeatures = [];
    for (var section in plan.sections) {
      for (var feature in section.features) {
        allFeatures.add(feature.title);
      }
    }
    
    final displayFeatures = allFeatures.take(5).toList();
    
    return displayFeatures.map((feat) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: _buildFeatureRow(feat, iconColor, textColor),
      );
    }).toList();
  }
}
