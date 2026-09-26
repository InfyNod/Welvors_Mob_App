import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../top_and_bottom_nav_screen.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../boost_bloc/boost_bloc.dart';
import '../boost_bloc/boost_state.dart';
import '../service_all_flow.dart';

class PerformanceScreen extends StatefulWidget {
  final BoostHistoryItem item;

  const PerformanceScreen({super.key, required this.item});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  Timer? _timer;
  bool _isCompleted = false;
  Duration _remaining = Duration.zero;
  bool _isLoading = true;
  Map<String, dynamic>? _performanceData;

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  Future<void> _fetchPerformanceData() async {
    if (widget.item.id == null) {
      setState(() => _isLoading = false);
      return;
    }
    final data = await BoostAllApiService().getBoostPerformance(widget.item.id!);
    if (mounted) {
      setState(() {
        _performanceData = data;
        _isLoading = false;
        
        // Use backend's remainingSeconds if available
        if (data != null && data['remainingSeconds'] != null) {
          final int rem = data['remainingSeconds'];
          if (rem > 0) {
            _remaining = Duration(seconds: rem);
            _isCompleted = false;
            _timer?.cancel();
            _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickTimer());
          } else {
            _remaining = Duration.zero;
            _isCompleted = true;
          }
        } else {
          _isCompleted = true; // Fallback if no remaining time
        }
      });
    }
  }

  void _tickTimer() {
    setState(() {
      if (_remaining.inSeconds > 0) {
        _remaining -= const Duration(seconds: 1);
      } else {
        _isCompleted = true;
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatReach(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Performance',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                    ))
                  : Column(
                      children: [
                        _buildStatusCard(),
                  const SizedBox(height: 12),
                  _buildMetricsGrid(),
                  const SizedBox(height: 12),
                  _buildChartCard(),
                  const SizedBox(height: 12),
                  _buildDemographicsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _buildExploreMoreButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreMoreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const TopAndBottomNavScreen(),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE43A6A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Explore More Profiles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(232, 249, 240, 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF57D38C), size: 16),
                SizedBox(width: 8),
                Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Color(0xFF57D38C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'This boost has ended',
              style: TextStyle(
                color: Color(0xFF57D38C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    String timerText;
    if (_remaining.inHours > 0) {
      final h = _remaining.inHours.toString().padLeft(2, '0');
      final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
      final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
      timerText = '$h:$m:$s';
    } else {
      final m = _remaining.inMinutes.toString().padLeft(2, '0');
      final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
      timerText = '$m:$s';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE43A6A).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE43A6A), width: 4)),
            gradient: LinearGradient(
              colors: [Color(0xFFFFF0F5), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE43A6A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE NOW',
                        style: TextStyle(
                          color: Color(0xFFE43A6A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your profile visibility is boosted',
                    style: TextStyle(
                      color: const Color(0xFFE43A6A).withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timerText,
                    style: const TextStyle(
                      color: Color(0xFFE43A6A),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'REMAINING',
                    style: TextStyle(
                      color: const Color(0xFFE43A6A).withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final perf = _performanceData?['performance'] ?? {};
    final reachTotal = perf['reach']?['total'] ?? widget.item.reach;
    final reachInc = perf['reach']?['increasePercentage'] ?? 0;
    
    final viewsTotal = perf['views']?['total'] ?? (widget.item.reach ~/ 40); // fallback mock
    
    final interestsTotal = perf['interests']?['total'] ?? widget.item.interests;
    final interestsInc = perf['interests']?['increasePercentage'] ?? 0;
    
    final likesTotal = perf['likes']?['total'] ?? widget.item.likes;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMetricCard(
                icon: Icons.rocket_launch,
                iconColor: const Color(0xFFE43A6A),
                label: 'REACH',
                value: _formatReach(reachTotal),
                badgeText: '+$reachInc%',
                badgeColor: const Color(0xFFFDE4A3),
                badgeTextColor: const Color(0xFFD99026),
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                icon: Icons.visibility,
                iconColor: const Color(0xFFE43A6A),
                label: 'VIEWS',
                value: viewsTotal.toString(),
                badgeText: 'Peak',
                badgeColor: const Color(0xFFFDE4A3),
                badgeTextColor: const Color(0xFFD99026),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildMetricCard(
                icon: Icons.chat_bubble,
                iconColor: const Color(0xFF57D38C),
                label: 'INTERESTS',
                value: interestsTotal.toString(),
                badgeText: '+$interestsInc%',
                badgeColor: const Color(0xFFE8F9F0),
                badgeTextColor: const Color(0xFF57D38C),
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                icon: Icons.favorite,
                iconColor: const Color(0xFFE43A6A),
                label: 'LIKES',
                value: likesTotal.toString(),
                badgeText: 'Hot',
                badgeColor: const Color(0xFFFFF0F5),
                badgeTextColor: const Color(0xFFE43A6A),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    int h = time.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    final m = time.minute.toString().padLeft(2, '0');
    return m == '00' ? '$h $ampm' : '$h:$m $ampm';
  }

  Widget _buildChartCard() {
    final start = widget.item.date;
    final int intervalMinutes = widget.item.isSuperBoost ? 60 : 15;
    final t1 = _formatTime(start);
    final t2 = _formatTime(start.add(Duration(minutes: intervalMinutes)));
    final t3 = _formatTime(start.add(Duration(minutes: intervalMinutes * 2)));
    final t4 = _formatTime(start.add(Duration(minutes: intervalMinutes * 3)));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visibility Surge',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hourly traffic comparison',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendDot(const Color(0xFFEBB14E), 'Boosted'),
                  const SizedBox(width: 8),
                  _buildLegendDot(const Color(0xFFF3F2EE), 'Regular'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBarGroup(40, 20),
                _buildBarGroup(30, 20),
                _buildBarGroup(20, 10),
                _buildBarGroup(50, 25),
                _buildBarGroup(70, 30),
                _buildBarGroup(85, 35),
                _buildBarGroup(100, 40),
                _buildBarGroup(60, 30),
                _buildBarGroup(45, 25),
                _buildBarGroup(35, 15),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t1,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
              Text(
                t2,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
              Text(
                t3,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
              Text(
                t4,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBarGroup(double boostedHeight, double regularHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: boostedHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFEBB14E),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 8,
          height: regularHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2EE),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicsSection() {
    final demos = _performanceData?['demographics'] ?? {};

    String getTopName(String key, String fallback) {
      final top = demos[key]?['top'];
      if (top is Map) return top['name']?.toString() ?? fallback;
      if (top is String) return top;
      return fallback;
    }

    double getTopPercentage(String key) {
      final total = (demos[key]?['total'] as num?)?.toDouble() ?? 0.0;
      if (total <= 0) return 0.0;
      final top = demos[key]?['top'];
      final count = (top is Map ? (top['count'] as num?) : 0)?.toDouble() ?? 0.0;
      return count / total;
    }
    
    final locName = getTopName('location', 'N/A');
    final locPct = getTopPercentage('location');

    final profName = getTopName('profession', 'N/A');
    final profPct = getTopPercentage('profession');

    final ageName = getTopName('age_group', 'N/A');
    final agePct = getTopPercentage('age_group');

    final verifiedName = getTopName('verified', 'N/A');
    final verifiedPct = getTopPercentage('verified');
    
    final religionName = getTopName('religion', 'N/A');
    final religionPct = getTopPercentage('religion');

    final communityName = getTopName('community', 'N/A');
    final communityPct = getTopPercentage('community');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Engagement Demographics',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildIndividualDemoCard(
                icon: Icons.location_on,
                title: 'Location',
                label: locName,
                percentage: '${(locPct * 100).toInt()}%',
                progress: locPct,
                color: const Color(0xFFE43A6A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIndividualDemoCard(
                icon: Icons.work,
                title: 'Profession',
                label: profName,
                percentage: '${(profPct * 100).toInt()}%',
                progress: profPct,
                color: const Color(0xFFE43A6A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people, color: Color(0xFFE43A6A), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Religion / Community',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressBar(religionName, '${(religionPct * 100).toInt()}%', religionPct, const Color(0xFFE43A6A)),
              const SizedBox(height: 12),
              _buildProgressBar(communityName, '${(communityPct * 100).toInt()}%', communityPct, const Color(0xFFF5C5AE)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildIndividualDemoCard(
                icon: Icons.person,
                title: 'Age',
                label: ageName,
                percentage: '${(agePct * 100).toInt()}%',
                progress: agePct,
                color: const Color(0xFFE43A6A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIndividualDemoCard(
                icon: Icons.check_circle,
                title: 'Verified',
                label: verifiedName,
                percentage: '${(verifiedPct * 100).toInt()}%',
                progress: verifiedPct,
                color: const Color(0xFFE43A6A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIndividualDemoCard({
    required IconData icon,
    required String title,
    required String label,
    required String percentage,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE43A6A), size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(label, percentage, progress, color),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    String percentage,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF3F2EE),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
