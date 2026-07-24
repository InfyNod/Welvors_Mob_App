import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../boost_bloc/boost_bloc.dart';
import '../../boost_bloc/boost_state.dart';
import '../../boost_all_screen/boost_top_nav.dart';
import '../live_boost_card_widget.dart';
import 'super_activate_drawer.dart';

class SuperBoostWalletScreen extends StatelessWidget {
  const SuperBoostWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 24),
          const Text(
            'Ready to Shine?',
            style: TextStyle(
              color: Color(0xFF2C2C2C), // Faint Black
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activate a 3 hour Super Boost for maximum visibility to all compatible matches in your city.',
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildActionCard(
            icon: Icons.timer_outlined,
            title: '3 hour Super Boost',
            buttonText: 'Activate',
            isBordered: true,
            onTap: () => showSuperActivateBoostDrawer(context),
          ),
          const SizedBox(height: 12),
          const LiveBoostCardWidget(),
          _buildBuyMoreCard(context),
          const SizedBox(height: 32),
          const Text(
            'Super Boost Benefits',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitsRow(),
          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<BoostBloc, BoostState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // Faint black gradient
            gradient: const LinearGradient(
              colors: [Color(0xFF4A4A4A), Color(0xFF2C2C2C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned(
                  right: 40,
                  top: -10,
                  child: Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 60,
                      color: const Color(0xFFFFC107).withOpacity(0.15),
                      height: 1.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT BALANCE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${state.superBoostBalance}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Super Boosts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFC107,
                              ).withOpacity(0.2), // Yellow tint
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Color(0xFFFFC107), // Yellow text
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String buttonText,
    bool isBordered = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBordered ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
          width: isBordered ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2C2C2C), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Color(0xFFFFC107), // Yellow text on black button
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyMoreCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C), // Black background
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star,
              color: Color(0xFFFFC107), // Yellow icon
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buy More Super Boosts',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Top up your wallet anytime',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context, 1); // Pop with tab index 1 (Super Boost)
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C), // Black button
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Activate',
                style: TextStyle(
                  color: Color(0xFFFFC107), // Yellow text
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsRow() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildBenefitCard(
                  icon: Icons.trending_up,
                  title: '10x More Views',
                  subtitle:
                      'Super Boost gives your profile maximum visibility.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBenefitCard(
                  icon: Icons.arrow_upward,
                  title: 'Always on Top',
                  subtitle: 'Stay at the top of search results for longer.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildBenefitCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'More Conversations',
                  subtitle: '5× higher reply rate from matches during boost.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBenefitCard(
                  icon: Icons.track_changes,
                  title: 'Smart Targeting',
                  subtitle: 'Reach your most compatible matches in your area.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2C2C2C), size: 24), // Black icon
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
