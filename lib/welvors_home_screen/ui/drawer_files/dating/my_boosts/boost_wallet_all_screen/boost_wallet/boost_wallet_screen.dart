import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../boost_bloc/boost_bloc.dart';
import '../../boost_bloc/boost_event.dart';
import '../../boost_bloc/boost_state.dart';
import '../live_boost_card_widget.dart';
import 'activate_drawer.dart';

class BoostWalletScreen extends StatefulWidget {
  const BoostWalletScreen({super.key});

  @override
  State<BoostWalletScreen> createState() => _BoostWalletScreenState();
}

class _BoostWalletScreenState extends State<BoostWalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BoostBloc>().add(FetchBoostWalletEvent());
    // Fetch history in the background to get expectedEndAt for the LiveBoostCardWidget
    context.read<BoostBloc>().add(FetchBoostHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoostBloc, BoostState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(state),
              const SizedBox(height: 24),
              const Text(
                'Ready to Shine?',
                style: TextStyle(
                  color: Color(0xFFE43A6A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Activate a 1 hour spotlight to put your profile in front of your most compatible matches instantly.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildActionCard(
                icon: Icons.timer_outlined,
                title: '1 hour Spotlight',
                buttonText: 'Activate',
                isBordered: true,
                onTap: () => showActivateBoostDrawer(context),
              ),
              const SizedBox(height: 12),
              const LiveBoostCardWidget(),
              if (!state.isActive && state.boostBalance == 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB6C1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFE43A6A)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You have 0 Spotlights. Get more from the Boost shop to shine again!',
                          style: TextStyle(
                            color: Color(0xFFE43A6A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              const Text(
                'Boost Benefits',
                style: TextStyle(
                  color: Color(0xFFE43A6A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitsRow(state.benefits),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BoostState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF16584), Color.fromRGBO(242, 142, 166, 1)],
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
              right: 30,
              top: -20,
              child: Icon(
                Icons.bolt,
                size: 70,
                color: Colors.white.withOpacity(0.15),
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
                            '${state.boostBalance}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Spotlights',
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
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
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
          color: isBordered ? const Color(0xFFE43A6A) : Colors.grey.shade200,
          width: isBordered ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE43A6A), size: 24),
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
                color: const Color(0xFFE43A6A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
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

  Widget _buildBenefitsRow(List<Map<String, dynamic>> benefits) {
    if (benefits.isEmpty) return const SizedBox.shrink();

    final icons = [
      Icons.trending_up,
      Icons.arrow_upward,
      Icons.chat_bubble_outline,
      Icons.track_changes,
      Icons.star,
      Icons.favorite,
    ];

    List<Widget> rows = [];
    for (int i = 0; i < benefits.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildBenefitCard(
                  icon: icons[i % icons.length],
                  title: benefits[i]['title'] ?? '',
                  subtitle: benefits[i]['description'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              if (i + 1 < benefits.length)
                Expanded(
                  child: _buildBenefitCard(
                    icon: icons[(i + 1) % icons.length],
                    title: benefits[i + 1]['title'] ?? '',
                    subtitle: benefits[i + 1]['description'] ?? '',
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
      if (i + 2 < benefits.length) {
        rows.add(const SizedBox(height: 12));
      }
    }
    return Column(children: rows);
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
          Icon(icon, color: const Color(0xFFE43A6A), size: 24),
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
