import 'dart:async';
import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Navigate to Home after 3 seconds
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TopAndBottomNavScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Premium dark background
      body: Stack(
        children: [
          // Background subtle radial glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    AppColors.pinkDeep.withOpacity(0.5), // Stronger pink glow
                    Colors.black,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          // Main Animated Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to',
                      style: AppText.sub.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF), // Pure white
                          Color(0xFFF48FB1), // Soft Pink
                          Color(0xFFE91E63), // Deep Pink
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        'WELVORS',
                        style: AppText.display.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                          letterSpacing: 8.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Small elegant divider
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.pinkDeep,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pinkDeep.withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ],
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
  }
}
