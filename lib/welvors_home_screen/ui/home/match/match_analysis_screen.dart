import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/home/send_compliment/complimenting.dart';
import 'package:velvors/welvors_home_screen/ui/home/match/how_you_match.dart';

import 'package:velvors/welvors_home_screen/ui/home/match/service_match.dart';

class MatchAnalysisScreen extends StatefulWidget {
  final String userId;
  final String matchName;

  const MatchAnalysisScreen({
    super.key,
    required this.userId,
    this.matchName = 'Aanya',
  });

  @override
  State<MatchAnalysisScreen> createState() => _MatchAnalysisScreenState();
}

class _MatchAnalysisScreenState extends State<MatchAnalysisScreen> {
  Map<String, dynamic>? matchData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ServiceMatch.fetchMatchAnalysis(widget.userId);
    if (mounted) {
      setState(() {
        matchData = data?['data'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
                border: Border.all(
                  color: const Color(0xFFF05C91).withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF966EB4).withValues(alpha: 0.10),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF242424),
                size: 16,
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFB95FE8),
                  Color(0xFFF05C91),
                ],
              ).createShader(bounds),
              child: const Text(
                'Match Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              (matchData?['insight']?['title']?.toString() ??
                      'WELVORS AI ENGINE')
                  .toUpperCase(),
              style: TextStyle(
                color: Color(0xFF9B98A7),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainMatchCard(),
                      const SizedBox(height: 24),
                      _buildInsightCard(),
                      const SizedBox(height: 24),
                      HowYouMatchSection(
                        dimensions: matchData?['dimensions'] as List<dynamic>?,
                      ),
                      const SizedBox(height: 24),
                      const WhatYouShareSection(),
                      const SizedBox(height: 24),
                      AFewDifferencesSection(
                        differences: matchData?['differences'] as List<dynamic>?,
                      ),
                      const SizedBox(height: 24),
                      const SideBySideSection(),
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          '✨ Score is recalculated by Welvors AI as you both add more to your profiles — it only compares signals, never shares your private answers.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 117, 116, 116),
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                // Bottom Actions
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomActions(context),
                ),
              ],
            ),
    );
  }

  Widget _buildMainMatchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFF05C91).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF966EB4).withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatars
          SizedBox(
            height: 70,
            width: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: matchData?['users']?['you']?['photo'] != null
                          ? DecorationImage(
                              image: NetworkImage(
                                matchData!['users']['you']['photo'],
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF966EB4,
                          ).withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: matchData?['users']?['you']?['photo'] == null
                        ? const Icon(Icons.person, color: Colors.grey, size: 32)
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: matchData?['users']?['target']?['photo'] != null
                          ? DecorationImage(
                              image: NetworkImage(
                                matchData!['users']['target']['photo'],
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF966EB4,
                          ).withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: matchData?['users']?['target']?['photo'] == null
                        ? const Icon(Icons.person, color: Colors.grey, size: 32)
                        : null,
                  ),
                ),
                // Heart icon in middle
                const _BlinkingHeart(),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Match Percentage Circle
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF05C91).withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: ((matchData?['match']?['score'] as num?) ?? 0) / 100.0,
              ),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    // Background track
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 12,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFE8D9FF).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    // Highlight part of the circle (animating)
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFFB95FE8),
                              Color(0xFFF05C91),
                            ],
                          ).createShader(rect);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 12,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                    ),
                    // Center Text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF8B5CF6),
                                Color(0xFFB95FE8),
                                Color(0xFFF05C91),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '${(value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const Text(
                            'MATCH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9B98A7),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Texts
          Text(
            matchData?['match']?['headline'] ??
                'You & ${widget.matchName} are a strong match',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Welvors AI compared both profiles across every dimension — intent, values, lifestyle, family and more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6D6D78),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Stats Card
          _buildStatsCard(),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final signals =
        matchData?['summary']?['signalsCompared']?.toString() ?? '0';
    final dimensions =
        matchData?['summary']?['dimensionsCompared']?.toString() ?? '0';
    final totalDimensions =
        matchData?['summary']?['totalDimensions']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D9FF)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildStatColumn(signals, 'SIGNALS\nCOMPARED')),
            const VerticalDivider(
              color: Color(0xFFE8D9FF),
              width: 1,
              thickness: 1,
            ),
            Expanded(child: _buildStatColumn(dimensions, 'DIMENSIONS')),
            const VerticalDivider(
              color: Color(0xFFE8D9FF),
              width: 1,
              thickness: 1,
            ),
            Expanded(
              child: _buildStatColumn(totalDimensions, 'TOTAL\nDIMENSIONS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    final intValue = int.tryParse(value);

    Widget valueWidget;
    if (intValue != null) {
      valueWidget = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: intValue.toDouble()),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          return Text(
            val.toInt().toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8B5CF6),
            ),
          );
        },
      );
    } else {
      valueWidget = Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Color(0xFF8B5CF6),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            valueWidget,
            const SizedBox(height: 2),
            SizedBox(
              height: 28, // Fixed height for 1 or 2 lines
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9B98A7),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2FF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8D9FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF966EB4).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFB95FE8),
                      Color(0xFFF05C91),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    matchData?['insight']?['title'] ??
                        'Welvors AI · Match Insight',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 122, 75, 231),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    matchData?['insight']?['basedOn'] ??
                        'Based on both complete profiles',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 194, 175, 239),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            matchData?['insight']?['text'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6D6D78),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFC),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF966EB4).withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rose Button
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                ComplimentingBottomSheet.show(context, type: 'Match');
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE85A7A),
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌹', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Rose',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE85A7A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Say Hello Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                ComplimentingBottomSheet.show(context, type: 'Match');
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE85A7A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE85A7A).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Say hello',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingHeart extends StatefulWidget {
  const _BlinkingHeart();

  @override
  State<_BlinkingHeart> createState() => _BlinkingHeartState();
}

class _BlinkingHeartState extends State<_BlinkingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFB95FE8), Color(0xFFF05C91)],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF05C91).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 16),
      ),
    );
  }
}
