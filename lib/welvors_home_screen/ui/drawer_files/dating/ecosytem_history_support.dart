import 'package:flutter/material.dart';
import 'help_support/help_support_screen.dart';
import 'legal_policies/legal_policy_screen.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/features/onboarding/refer_and_earn_screen.dart';
import 'commitment_management.dart/commitment_screen.dart';
import '../../event/all_screen/my_ticket.dart';
import '../../date_now/date_now_2/requests_sent/requests_sent_screen.dart';
import 'commitment_management.dart/commitment_bloc/commitment_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../date_now/date_api_service/date_now_api_service.dart';
import 'logout/logout_screen.dart';
import 'account_setting/account_setting._screen.dart';

import 'package:velvors/config/env_config.dart';

class EcosystemHistorySupport extends StatefulWidget {
  const EcosystemHistorySupport({super.key});

  @override
  State<EcosystemHistorySupport> createState() =>
      _EcosystemHistorySupportState();
}

class _EcosystemHistorySupportState extends State<EcosystemHistorySupport> {
  int _myPlansCount = 0;
  int _approvedRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDatesCount();
  }

  Future<void> _fetchDatesCount() async {
    // Fetch my plans
    final res = await DateNowApiService.getMyPlans(period: 'Today');
    if (res != null && res['success'] == true) {
      final List<dynamic> data = res['data'] ?? [];
      _myPlansCount = data.length;
    }
    
    // Fetch sent requests
    try {
      const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhMTM0OGNlNC0zMTgzLTRkNzgtYWI4Ni00ODZhMjg4NzcyMjQiLCJpYXQiOjE3ODY3MDI5OTgsImV4cCI6MTc4OTI5NDk5OH0.acSy-NV8wDq8p4793J2rYatcnAsxvc49Oq2KM3AZA2A';
      final url = Uri.parse('${EnvConfig.apiBaseUrl}/user/my-date-plan-requests');
      final response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          _approvedRequestsCount = items.where((item) {
            final status = item['status']?.toString().toUpperCase() ?? '';
            return status == 'APPROVED';
          }).length;
        }
      }
    } catch (e) {
      debugPrint('Error fetching requests: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CORE ECOSYSTEM
        _buildSectionTitle('CORE ECOSYSTEM'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.shadow,
          ),
          child: Column(
            children: [
              _buildEcosystemTile(
                icon: '🔮',
                iconBgColor: const Color(0xFFF3E5F5), // Light purple
                title: 'Forever Love Programme',
                subtitleRich: TextSpan(
                  children: [
                    TextSpan(
                      text: '3-year journey tracking · ',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const TextSpan(
                      text: '5 Lakh Status',
                      style: TextStyle(
                        color: Color(0xFFE85A7A), // Deep pink
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildEcosystemTile(
                icon: '💎',
                iconBgColor: const Color(0xFFE3F2FD), // Light blue
                title: 'Commitment Management',
                subtitleRich: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Your exclusive status · ',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    TextSpan(
                      text: CommitmentBloc.isSingle
                          ? 'Single'
                          : (CommitmentBloc.currentCommitment?.partnerName ??
                                'Priya'),
                      style: const TextStyle(
                        color: Color(0xFFE85A7A), // Deep pink
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' · requests',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommitmentScreen(),
                    ),
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildEcosystemTile(
                icon: '🛡️',
                iconBgColor: const Color(0xFFFBE4E7), // Light red
                title: 'Trust & Verification',
                subtitleRich: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Trust Score ',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const TextSpan(
                      text: '20/100',
                      style: TextStyle(
                        color: Color(0xFFE85A7A), // Deep pink
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' · Verify to boost & get more matches',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
                onTap: () {
                 Navigator.pushNamed(context, '/TrustVerificationScreen');
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ACTIVITY & HISTORY
        _buildSectionTitle('ACTIVITY & HISTORY'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  return _buildActivityCard(
                    icon: '📅',
                    iconBgColor: const Color(0xFFF5F5F5),
                    title: 'My Bookings',
                    subtitle: 'VIEW YOUR BOOKINGS',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTicketScreen(),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  final totalDatesCount = _myPlansCount + _approvedRequestsCount;

                  return _buildActivityCard(
                    icon: '⏱️',
                    iconBgColor: const Color(0xFFF5F5F5),
                    title: 'My Dates',
                    subtitle: '$totalDatesCount UPCOMING DATE${totalDatesCount == 1 ? '' : 'S'}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestsSentScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ACCOUNT & SUPPORT
        _buildSectionTitle('ACCOUNT & SUPPORT'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.shadow,
          ),
          child: Column(
            children: [
              _buildSimpleTile(
                icon: '🎁',
                iconBgColor: const Color(0xFFE8F5E9), // Light green
                title: 'Refer & Earn',
                subtitle: 'Get ₹100 + ₹500 per friend',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferAndEarnScreen(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '⚙️',
                iconBgColor: const Color(0xFFE3F2FD), // Light blue
                title: 'Account Settings',
                subtitle: 'Privacy, Notifications, Security',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountSettingScreen(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '❓',
                iconBgColor: const Color(0xFFFBE4E7), // Light red
                title: 'Help & Support',
                subtitle: 'FAQ, Chat with Support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '⚖️',
                iconBgColor: const Color(0xFFF5F5F5), // Light grey
                title: 'Legal & Policies',
                subtitle: 'Terms, Privacy, Refunds & more',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalPoliciesScreen(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '🚪',
                iconBgColor: const Color(0xFFFFF3E0), // Light orange
                title: 'Logout',
                subtitle: 'Sign out of your account',
                titleColor: Colors.red.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogoutScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 19),
        Center(
          child: Text(
            'WELVORS V2.4.0',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEcosystemTile({
    required String icon,
    required Color iconBgColor,
    required String title,
    required InlineSpan subtitleRich,
    Color titleColor = Colors.black87,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 11),
                      children: [subtitleRich],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTile({
    required String icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Color titleColor = Colors.black87,
    VoidCallback? onTap,
  }) {
    return _buildEcosystemTile(
      icon: icon,
      iconBgColor: iconBgColor,
      title: title,
      titleColor: titleColor,
      subtitleRich: TextSpan(
        text: subtitle,
        style: TextStyle(color: Colors.grey.shade500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildActivityCard({
    required String icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: AppColors.shadow,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 26,
                height: 1.1, // Adjust line height to center emojis properly
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}
}
