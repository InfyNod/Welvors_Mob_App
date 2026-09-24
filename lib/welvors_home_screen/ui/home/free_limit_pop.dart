import 'package:flutter/material.dart';

class FreeLimitPopup extends StatefulWidget {
  const FreeLimitPopup({super.key});

  @override
  State<FreeLimitPopup> createState() => _FreeLimitPopupState();
}

class _FreeLimitPopupState extends State<FreeLimitPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rippleScaleAnimation;
  late Animation<double> _rippleOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rippleScaleAnimation = Tween<double>(begin: 0.6, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _rippleOpacityAnimation = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close button
              Padding(
                padding: const EdgeInsets.only(top: 0.0, right: 4.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Rocket Icon
              _buildRocketIcon(),
              const SizedBox(height: 0),
              // PRE-TITLE
              const Text(
                'PREMIUM+ · 8 OF 8 SEEN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF702EDC),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              // Title
              const Text(
                'Let the right people find you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'You\'ve seen today\'s 8 picks. Now put your profile in front of ',
                    ),
                    TextSpan(
                      text: 'hundreds of verified singles',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: ' near you — while they\'re online tonight.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 3 Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('10×', 'more views'),
                  _buildStatCard('3×', 'more matches'),
                  _buildStatCard('30', 'min live'),
                ],
              ),
              const SizedBox(height: 16),
              // Why boost now
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WHY BOOST NOW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF702EDC),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildBenefitItem(
                      '👀',
                      'Up to 10× more profile views',
                      'Top of the feed in your city',
                      true,
                    ),
                    _buildBenefitItem(
                      '❤️',
                      '3× more likes & matches',
                      'Serious profiles see you first',
                      true,
                    ),
                    _buildBenefitItem(
                      '⚡',
                      'Live for 30 minutes',
                      'Peak-hour boost, when most people are online',
                      true,
                    ),
                    _buildBenefitItem(
                      '📊',
                      'See your boost results',
                      'Views, likes and matches — tracked live',
                      false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Button
              Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B49ED), Color(0xFF702EDC)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF702EDC).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🚀', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text(
                            'Boost my profile now ›',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Timer
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  children: const [
                    TextSpan(text: 'Your next 8 picks unlock in '),
                    TextSpan(
                      text: '06:06:43',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRocketIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;
        final breatheScale = 1.0 + (value < 0.5 ? value : 1.0 - value) * 0.1;

        return SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ripple
              Transform.scale(
                scale: _rippleScaleAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF702EDC,
                    ).withOpacity(_rippleOpacityAnimation.value),
                  ),
                ),
              ),
              // Inner Ripple
              Transform.scale(
                scale: _rippleScaleAnimation.value * 0.8,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF702EDC).withOpacity(
                      _rippleOpacityAnimation.value * 1.5 > 1.0
                          ? 1.0
                          : _rippleOpacityAnimation.value * 1.5,
                    ),
                  ),
                ),
              ),
              // Breathing Rocket Center
              Transform.scale(
                scale: breatheScale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B49ED), Color(0xFF702EDC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF702EDC).withOpacity(0.4),
                            blurRadius: 8 * breatheScale,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🚀', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String subtitle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF702EDC).withOpacity(0.08), // Very light purple
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF702EDC),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    String emoji,
    String title,
    String subtitle,
    bool showDivider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
            indent: 52,
            endIndent: 12,
          ),
      ],
    );
  }
}
