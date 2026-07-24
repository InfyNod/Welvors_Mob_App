import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../boost_bloc/boost_bloc.dart';
import '../boost_bloc/boost_state.dart';

class BoostHistoryScreen extends StatelessWidget {
  const BoostHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
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
          'Boost History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<BoostBloc, BoostState>(
        builder: (context, state) {
          int totalReach = 0;
          int totalLikes = 0;
          int totalInterests = 0;
          for (final item in state.history) {
            totalReach += item.reach;
            totalLikes += item.likes;
            totalInterests += item.interests;
          }

          String formatReach(int value) {
            if (value >= 1000) {
              return '${(value / 1000).toStringAsFixed(1)}k';
            }
            return value.toString();
          }

          String formatDate(DateTime date) {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final day = date.day.toString().padLeft(2, '0');
            final month = months[date.month - 1];
            return '$day $month, ${date.year}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLifetimeImpactCard(
                  totalReach: formatReach(totalReach),
                  totalLikes: totalLikes.toString(),
                  totalInterests: totalInterests.toString(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recent Boost Events',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...state.history.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildEventCard(
                        date: formatDate(item.date),
                        title: item.title,
                        reach: formatReach(item.reach),
                        likes: item.likes.toString(),
                        interests: item.interests.toString(),
                        duration: item.duration,
                        isSuperBoost: item.isSuperBoost,
                      ),
                    )),
                const SizedBox(height: 8),
                _buildReadyForMoreCard(context),
                const SizedBox(height: 40), // Extra space at bottom
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLifetimeImpactCard({
    required String totalReach,
    required String totalLikes,
    required String totalInterests,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5F6D), Color(0xFFE43A6A), Color(0xFFB51540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIFETIME IMPACT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your profile\nis glowing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildImpactMetric(totalReach, 'Total Reach')),
              const SizedBox(width: 8),
              Expanded(child: _buildImpactMetric(totalLikes, 'New Likes')),
              const SizedBox(width: 8),
              Expanded(child: _buildImpactMetric(totalInterests, 'Interests')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetric(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String date,
    required String title,
    required String reach,
    required String likes,
    required String interests,
    required String duration,
    bool isSuperBoost = false,
  }) {
    Widget card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSuperBoost ? const Color(0xFFFFFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSuperBoost ? const Color(0xFFFFD54F) : Colors.grey.shade200,
          width: isSuperBoost ? 1.5 : 1.0,
        ),
        boxShadow: isSuperBoost
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 249, 240, 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '• COMPLETED',
                  style: TextStyle(
                    color: Color(0xFF57D38C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isSuperBoost
                  ? const Color(0xFFD99026)
                  : const Color(0xFFE43A6A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          _buildDashedDivider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEventMetricRow(
                Icons.rocket_launch_outlined,
                reach,
                'REACH',
                isSuperBoost
                    ? const Color(0xFFD99026)
                    : const Color(0xFFE43A6A),
              ),
              _buildVerticalDivider(),
              _buildEventMetricRow(
                Icons.favorite_border,
                likes,
                'LIKES',
                isSuperBoost
                    ? const Color(0xFFD99026)
                    : const Color(0xFFFFB74D),
              ),
              _buildVerticalDivider(),
              _buildEventMetricRow(
                Icons.auto_awesome,
                interests,
                'INTERESTS',
                isSuperBoost
                    ? const Color(0xFFD99026)
                    : const Color(0xFFE43A6A),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.black45,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    duration,
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'View Report',
                    style: TextStyle(
                      color: isSuperBoost
                          ? const Color(0xFFD99026)
                          : const Color(0xFFE43A6A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isSuperBoost
                        ? const Color(0xFFD99026)
                        : const Color(0xFFE43A6A),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (isSuperBoost) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -10, // Move up to overlap the border exactly
            right: 24, // Align with the completed badge
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFEBB14E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEBB14E).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'SUPER BOOST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return card;
  }

  Widget _buildReadyForMoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)], // Soft pink gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB6C1).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE43A6A).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE43A6A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Color(0xFFE43A6A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ready for more?',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Put your profile in front of 10,000+\npotential matches right now.',
            style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, // Full width button for better visibility
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                elevation: 4,
                shadowColor: const Color(0xFFE43A6A).withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Boost Profile Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  Widget _buildEventMetricRow(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade300),
              ),
            );
          }),
        );
      },
    );
  }
}
