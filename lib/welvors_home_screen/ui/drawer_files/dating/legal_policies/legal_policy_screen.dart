import 'package:flutter/material.dart';
import 'all_page_legal/child_safety.dart';
import 'all_page_legal/community_guidelines.dart';
import 'all_page_legal/cookie_policy.dart';
import 'all_page_legal/data_rights.dart';
import 'all_page_legal/forever_love.dart';
import 'all_page_legal/grievance_officer.dart';
import 'all_page_legal/licenses.dart';
import 'all_page_legal/verification.dart';
import 'all_page_legal/privacy_policy.dart';
import 'all_page_legal/refund_cancelation.dart';
import 'all_page_legal/safety_dating_tips.dart';
import 'all_page_legal/wallet_coin_terms.dart';
import 'all_page_legal/terms_service.dart';

class LegalPoliciesScreen extends StatefulWidget {
  const LegalPoliciesScreen({super.key});

  @override
  State<LegalPoliciesScreen> createState() => _LegalPoliciesScreenState();
}

class _LegalPoliciesScreenState extends State<LegalPoliciesScreen> {
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Coming Soon!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Legal & Policies',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0F3), Color(0xFFFAFAFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.pink.shade100, width: 0.5),
              ),
              child: Text(
                'These documents explain how Welvors works, your rights, and how we keep you safe. Tap any to read.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // THE ESSENTIALS
            _buildSectionTitle('THE ESSENTIALS'),
            const SizedBox(height: 12),
            _buildSectionContainer([
              _buildPolicyItem(
                emoji: '📋',
                iconBgColor: Colors.blue.shade50,
                title: 'Terms of Service',
                subtitle: 'The rules for using Welvors',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsServiceScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '🔒',
                iconBgColor: Colors.green.shade50,
                title: 'Privacy Policy',
                subtitle: 'What data we collect & why',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '📜',
                iconBgColor: Colors.orange.shade50,
                title: 'Community Guidelines',
                subtitle: 'How to behave on Welvors',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityGuidelinesScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '🛡️',
                iconBgColor: Colors.red.shade50,
                title: 'Safety & Dating Tips',
                subtitle: 'Stay safe online & on dates',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SafetyDatingTipsScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 32),

            // SAFETY & PROTECTION
            _buildSectionTitle('SAFETY & PROTECTION'),
            const SizedBox(height: 12),
            _buildSectionContainer([
              _buildPolicyItem(
                emoji: '👶',
                iconBgColor: Colors.blue.shade50,
                title: 'Child Safety Standards',
                subtitle: 'Zero tolerance · CSAE policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChildSafetyScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '🔞',
                iconBgColor: Colors.red.shade50,
                title: '18+ Age Policy',
                subtitle: 'Age gate & verification',
                onTap: _showComingSoon,
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '⚖️',
                iconBgColor: Colors.grey.shade200,
                title: 'Content Moderation & Law Enforcement',
                subtitle: 'Reports, takedowns, legal requests',
                onTap: _showComingSoon,
              ),
            ]),
            const SizedBox(height: 32),

            // MONEY & PROGRAMMES
            _buildSectionTitle('MONEY & PROGRAMMES'),
            const SizedBox(height: 12),
            _buildSectionContainer([
              _buildPolicyItem(
                emoji: '💳',
                iconBgColor: Colors.purple.shade50,
                title: 'Refund & Cancellation Policy',
                subtitle: 'Plans, events, wallet withdrawals',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RefundCancellationScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '🪙',
                iconBgColor: Colors.yellow.shade100,
                title: 'Wallet & Coins Terms',
                subtitle: 'Earning, spending, 25% withdrawal fee',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalletCoinTermsScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '🔮',
                iconBgColor: Colors.pink.shade50,
                title: 'Forever Love Programme Terms',
                subtitle: '₹5 Lakh honeymoon conditions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForeverLoveScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 32),

            // YOUR DATA & RIGHTS
            _buildSectionTitle('YOUR DATA & RIGHTS'),
            const SizedBox(height: 12),
            _buildSectionContainer([
              _buildPolicyItem(
                emoji: '🍪',
                iconBgColor: Colors.brown.shade50,
                title: 'Cookie Policy',
                subtitle: 'Trackers & analytics',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CookiePolicyScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '📂',
                iconBgColor: Colors.indigo.shade50,
                title: 'Data & Your Rights',
                subtitle: 'Access, download, delete',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataRightsScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '✓',
                iconBgColor: Colors.teal.shade50,
                title: 'Verification & ID Policy',
                subtitle: 'How we handle your documents',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerificationPolicyScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '🗑️',
                iconBgColor: Colors.red.shade50,
                title: 'Delete Your Account & Data',
                subtitle: 'How to request erasure',
                onTap: _showComingSoon,
              ),
            ]),
            const SizedBox(height: 32),

            // ABOUT
            _buildSectionTitle('ABOUT'),
            const SizedBox(height: 12),
            _buildSectionContainer([
              _buildPolicyItem(
                emoji: '⚖️',
                iconBgColor: Colors.grey.shade100,
                title: 'Licenses & Acknowledgements',
                subtitle: 'Open-source & partners',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LicensesScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildPolicyItem(
                emoji: '📮',
                iconBgColor: Colors.cyan.shade50,
                title: 'Grievance Officer',
                subtitle: 'IT Rules 2021 contact',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrievanceOfficerScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'Welvors Technologies Pvt. Ltd.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CIN: U72900MH2024PTC000000 · Mumbai, India',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'v3.2.1 · Last updated 20 June 2026',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPolicyItem({
    required String emoji,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? _showComingSoon,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 72,
      endIndent: 16,
    );
  }
}
