import 'package:flutter/material.dart';

class TrustScreen extends StatelessWidget {
  const TrustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
                  color: const Color(0xFFF05C91).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF966EB4).withOpacity(0.10),
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
        title: const Text(
          'Trust Score',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildMainTrustCard(),
            const SizedBox(height: 16),
            _buildInfoBanner(),
            const SizedBox(height: 32),
            _buildVerificationSection(
              title: '1  Basic verification',
              progress: '2/2 ✓',
              items: [
                _buildVerificationItem(
                  title: 'Mobile & Email',
                  subtitle: 'Confirmed real contact details',
                  score: '+10',
                  emoji: '📱',
                  iconBgColor: Colors.blue.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Location check',
                  subtitle: 'City-level authenticity confirmed',
                  score: '+10',
                  emoji: '📍',
                  iconBgColor: Colors.orange.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildVerificationSection(
              title: '2  Identity verification',
              progress: '3/3 ✓',
              items: [
                _buildVerificationItem(
                  title: 'Government ID',
                  subtitle: 'A real person, matched to official ID',
                  score: '+10',
                  emoji: '🪪',
                  iconBgColor: Colors.purple.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Face match (selfie)',
                  subtitle: 'Selfie matched the ID photo',
                  score: '+5',
                  emoji: '🤳',
                  iconBgColor: Colors.pink.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Video liveness',
                  subtitle: 'Live video confirmed a present person',
                  score: '+5',
                  emoji: '🎥',
                  iconBgColor: Colors.red.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildVerificationSection(
              title: '3  High-trust verification',
              progress: '3/4',
              isComplete: false,
              items: [
                _buildVerificationItem(
                  title: 'Relationship intent',
                  subtitle: 'Confirmed she’s here for something serious',
                  score: '+7',
                  emoji: '💬',
                  iconBgColor: Colors.pinkAccent.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Education',
                  subtitle: 'College & qualification verified',
                  score: '+7',
                  emoji: '🎓',
                  iconBgColor: Colors.indigo.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Profession',
                  subtitle: 'Job & company verified',
                  score: '+8',
                  emoji: '💼',
                  iconBgColor: Colors.brown.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Income',
                  subtitle: 'Declared income bracket confirmed',
                  score: 'Not yet',
                  emoji: '💰',
                  isVerified: false,
                  iconBgColor: Colors.green.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildVerificationSection(
              title: '4  Platinum verification',
              progress: '1/2',
              isComplete: false,
              items: [
                _buildVerificationItem(
                  title: 'Criminal background',
                  subtitle: 'Court & police records — clean history',
                  score: '+12',
                  emoji: '🔍',
                  iconBgColor: Colors.teal.withOpacity(0.1),
                ),
                _buildVerificationItem(
                  title: 'Emergency contact',
                  subtitle: 'A trusted person registered for safety',
                  score: 'Not yet',
                  emoji: '📞',
                  isVerified: false,
                  iconBgColor: Colors.deepOrange.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trust Score is built from independent identity, safety and intent checks. The more verified, the higher the score — capped at 100.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTrustCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2144), Color(0xFF1E1730)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Aanya, 24',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '8 of 11 checks verified',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Trust Score Circle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 0.98),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE85A7A).withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background track
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 6.5,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ),
                        // Animated Gradient Stroke
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CustomPaint(
                              painter: _GradientArcPainter(progress: value),
                            ),
                          ),
                        ),
                        // Inner content
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(8.5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF2B2144),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (value * 100).toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const Text(
                                    'TRUST',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Platinum verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2BC57),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('👑', style: TextStyle(fontSize: 12)),
                SizedBox(width: 6),
                Text(
                  'Platinum verified',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Description
          const Text(
            'A high Trust Score means more of Aanya\'s identity has been independently checked — you can message with confidence.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1730), // Dark background for contrast
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1730).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF2CB864), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(text: 'You only see the '),
                  TextSpan(
                    text: 'verified result',
                    style: TextStyle(
                      color: Color(0xFF2CB864),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' — never the documents. They stay private and encrypted.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection({
    required String title,
    required String progress,
    required List<Widget> items,
    bool isComplete = true,
  }) {
    List<Widget> separatedItems = [];
    for (int i = 0; i < items.length; i++) {
      separatedItems.add(items[i]);
      if (i < items.length - 1) {
        separatedItems.add(const Divider(height: 1, color: Color(0xFFF0F0F0)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Number badge (like '1' or '2')
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF1E1730),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                title.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.substring(2).trim(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 40,
                child: Text(
                  progress,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isComplete
                        ? const Color(0xFF2CB864)
                        : const Color(0xFFE9A63F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: separatedItems),
        ),
      ],
    );
  }

  Widget _buildVerificationItem({
    required String title,
    required String subtitle,
    required String score,
    required String emoji,
    bool isVerified = true,
    Color? iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 8.0,
        top: 14.0,
        bottom: 14.0,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor ?? const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
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
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.cancel,
                  color: isVerified
                      ? const Color(0xFF2CB864)
                      : Colors.grey.shade400,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  score,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isVerified
                        ? const Color(0xFF2CB864)
                        : Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double progress;

  _GradientArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE85A7A), Color(0xFFFF9B70)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(6.5 / 2),
      -1.5707963267948966, // -pi/2 (starts at top center)
      progress * 2 * 3.1415926535897932,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
