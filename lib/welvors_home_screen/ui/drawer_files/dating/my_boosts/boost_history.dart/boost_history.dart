import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../boost_bloc/boost_event.dart';
import '../boost_bloc/boost_bloc.dart';
import '../boost_bloc/boost_state.dart';
import 'performance_screen.dart';

class BoostHistoryScreen extends StatefulWidget {
  const BoostHistoryScreen({super.key});

  @override
  State<BoostHistoryScreen> createState() => _BoostHistoryScreenState();
}

class _BoostHistoryScreenState extends State<BoostHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BoostBloc>().add(FetchBoostHistoryEvent());
  }

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
                    color: Colors.black.withValues(alpha: 0.04),
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

          if (state.isLoading && state.history.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLifetimeImpactCard(
                  totalReach: formatReach(state.totalReach),
                  totalLikes: state.newLikes.toString(),
                  totalInterests: state.interests.toString(),
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
                        context: context,
                        item: item,
                        date: formatDate(item.date),
                        title: item.title,
                        reach: formatReach(item.reach),
                        likes: item.likes.toString(),
                        interests: item.interests.toString(),
                        duration: item.duration,
                        isSuperBoost: item.isSuperBoost,
                      ),
                    )),
                const SizedBox(height: 16),
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
        color: Colors.white.withValues(alpha: 0.2),
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
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required BoostHistoryItem item,
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
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
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
              _BoostStatusBadge(item: item),
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerformanceScreen(item: item),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
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
                ),
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
                    color: const Color(0xFFEBB14E).withValues(alpha: 0.3),
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

class _BoostStatusBadge extends StatefulWidget {
  final BoostHistoryItem item;

  const _BoostStatusBadge({required this.item});

  @override
  State<_BoostStatusBadge> createState() => _BoostStatusBadgeState();
}

class _BoostStatusBadgeState extends State<_BoostStatusBadge> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.item.status == 'COMPLETED' || widget.item.status == 'INACTIVE';
    _updateStatus();
    if (!_isCompleted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateStatus());
    }
  }

  void _updateStatus() {
    if (_isCompleted) return;

    if (widget.item.expectedEndAt != null) {
      final diff = widget.item.expectedEndAt!.difference(DateTime.now());
      if (diff.inSeconds <= 0) {
        setState(() => _isCompleted = true);
        _timer?.cancel();
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    } else {
      // Fallback if no expectedEndAt is provided but status is active
      final totalDuration = widget.item.isSuperBoost ? const Duration(hours: 3) : const Duration(hours: 1);
      final diff = DateTime.now().difference(widget.item.date);
      if (diff >= totalDuration) {
        setState(() => _isCompleted = true);
        _timer?.cancel();
      } else {
        setState(() {
          _remaining = totalDuration - diff;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      );
    } else {
      String timerText;
      if (_remaining.inHours > 0) {
        final h = _remaining.inHours;
        final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
        final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
        timerText = '$h:$m:$s';
      } else {
        final m = _remaining.inMinutes.toString().padLeft(2, '0');
        final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
        timerText = '$m:$s';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '• ACTIVE ($timerText)',
          style: const TextStyle(
            color: Color(0xFFE43A6A),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}

