import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';

class EcosystemHistorySupport extends StatelessWidget {
  const EcosystemHistorySupport({super.key});

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
                        style: TextStyle(color: Colors.grey.shade500)),
                    const TextSpan(
                        text: '5 Lakh Status',
                        style: TextStyle(
                            color: Color(0xFFE85A7A), // Deep pink
                            fontWeight: FontWeight.bold)),
                  ],
                ),
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
                        style: TextStyle(color: Colors.grey.shade500)),
                    const TextSpan(
                        text: 'Priya',
                        style: TextStyle(
                            color: Color(0xFFE85A7A), // Deep pink
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' · requests',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildEcosystemTile(
                icon: '🛡️',
                iconBgColor: const Color(0xFFFBE4E7), // Light red
                title: 'Trust Centre',
                subtitleRich: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Trust Score ',
                        style: TextStyle(color: Colors.grey.shade500)),
                    const TextSpan(
                        text: '20/100',
                        style: TextStyle(
                            color: Color(0xFFE85A7A), // Deep pink
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' · Verify to boost & get more matches',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
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
              child: _buildActivityCard(
                icon: '📅',
                iconBgColor: const Color(0xFFFBE4E7), // Light red
                title: 'My Bookings',
                subtitle: '2 UPCOMING EVENTS',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActivityCard(
                icon: '⏱️',
                iconBgColor: const Color(0xFFF5F5F5), // Light grey
                title: 'My Dates',
                subtitle: '8 PAST DATES',
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
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '⚙️',
                iconBgColor: const Color(0xFFE3F2FD), // Light blue
                title: 'Account Settings',
                subtitle: 'Privacy, Notifications, Security',
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '❓',
                iconBgColor: const Color(0xFFFBE4E7), // Light red
                title: 'Help & Support',
                subtitle: 'FAQ, Chat with Support',
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '⚖️',
                iconBgColor: const Color(0xFFF5F5F5), // Light grey
                title: 'Legal & Policies',
                subtitle: 'Terms, Privacy, Refunds & more',
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildSimpleTile(
                icon: '🚪',
                iconBgColor: const Color(0xFFFFF3E0), // Light orange
                title: 'Logout',
                subtitle: 'Sign out of your account',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
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
  }) {
    return Padding(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
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
    );
  }

  Widget _buildSimpleTile({
    required String icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return _buildEcosystemTile(
      icon: icon,
      iconBgColor: iconBgColor,
      title: title,
      subtitleRich: TextSpan(
        text: subtitle,
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildActivityCard({
    required String icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
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
    );
  }
}
