import 'package:flutter/material.dart';

class PopMsgForUpdate extends StatefulWidget {
  const PopMsgForUpdate({super.key});

  @override
  State<PopMsgForUpdate> createState() => _PopMsgForUpdateState();
}

class _PopMsgForUpdateState extends State<PopMsgForUpdate>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  // Entrance animations
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  // Staggered lists animations
  late List<Animation<Offset>> _featureSlideAnimations;
  late List<Animation<double>> _featureFadeAnimations;

  // Button pulse
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Card pop in (0.0 to 0.4)
    _cardScaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    // Icon pop in (0.2 to 0.5)
    _iconScaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOutBack),
    );

    // Content slide and fade (0.3 to 0.6)
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ));

    _contentFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    );

    // Feature Rows Staggered Animations (0.5 to 1.0)
    _featureSlideAnimations = [];
    _featureFadeAnimations = [];
    for (int i = 0; i < 3; i++) {
      final startTime = 0.5 + (i * 0.15);
      final endTime = startTime + 0.2;
      
      _featureSlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: Interval(startTime, endTime > 1.0 ? 1.0 : endTime, curve: Curves.easeOutCubic),
        )),
      );
      
      _featureFadeAnimations.add(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(startTime, endTime > 1.0 ? 1.0 : endTime, curve: Curves.easeIn),
        ),
      );
    }

    // 2. Pulse Controller for the Update Button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start entrance animation, then start pulse when done
    _entranceController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildFeatureRow(int index, IconData icon, String title, String description) {
    return FadeTransition(
      opacity: _featureFadeAnimations[index],
      child: SlideTransition(
        position: _featureSlideAnimations[index],
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE43A6A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFE43A6A), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE43A6A).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE43A6A).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: ScaleTransition(
                  scale: _cardScaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE43A6A).withValues(alpha: 0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rocket / Update Icon
                        ScaleTransition(
                          scale: _iconScaleAnimation,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B8B), Color(0xFFE43A6A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE43A6A).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.rocket_launch_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Tag and Title fading and sliding in
                        FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: SlideTransition(
                            position: _contentSlideAnimation,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Version 2.0 is here',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Update Velvors',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Staggered Features
                        _buildFeatureRow(
                          0,
                          Icons.speed_rounded,
                          'Faster & Smoother',
                          'We have optimized the app to load profiles instantly.',
                        ),
                        _buildFeatureRow(
                          1,
                          Icons.security_rounded,
                          'Enhanced Security',
                          'Your privacy and data are now protected with advanced encryption.',
                        ),
                        _buildFeatureRow(
                          2,
                          Icons.auto_awesome_rounded,
                          'New UI Enhancements',
                          'A fresh new look for a more premium dating experience.',
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Update Button (Staggered fade in + Continuous Pulse)
                        FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: ScaleTransition(
                            scale: _buttonPulseAnimation,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE43A6A).withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle update logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent, 
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ).copyWith(
                                  backgroundColor: WidgetStateProperty.resolveWith(
                                    (states) => const Color(0xFFE43A6A),
                                  ),
                                ),
                                child: const Text(
                                  'Update Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Later Button
                        FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Remind me later',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
