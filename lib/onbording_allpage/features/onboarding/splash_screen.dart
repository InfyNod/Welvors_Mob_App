import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'package:velvors/welvors_home_screen/home_bloc/home_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Immediately check token and start prefetching
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    
    final bool isLoggedIn = authToken != null && authToken.isNotEmpty;

    if (isLoggedIn && mounted) {
      context.read<HomeBloc>().add(const LoadHomeDataEvent(isRefresh: true));
    }

    // 2. Ensure the splash animation plays for 3 seconds
    await Future.delayed(const Duration(milliseconds: 3000));

    // 3. Navigate
    final String targetRoute = isLoggedIn ? '/home' : '/landing';

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        targetRoute,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas, // Native app theme background
      body: Stack(
        children: [
          // Background subtle radial glow (Native Theme)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    AppColors.pinkSoft.withOpacity(0.8), // Soft pink glow matching theme
                    AppColors.canvas,
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
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to',
                        style: AppText.sub.copyWith(
                          color: AppColors.ink60,
                          fontSize: 16,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            AppColors.pinkDeep, 
                            AppColors.pink,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'WELVORS',
                          style: AppText.display.copyWith(
                            color: Colors.white, // Required for ShaderMask
                            fontSize: 40,
                            letterSpacing: 8.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Elegant Tagline
                      const _PremiumTagline(),
                      const SizedBox(height: 36),
                      // Lottie Loading Animation
                      Lottie.asset(
                        'assets/loading.json',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ],
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

class _PremiumTagline extends StatefulWidget {
  const _PremiumTagline();

  @override
  State<_PremiumTagline> createState() => _PremiumTaglineState();
}

class _PremiumTaglineState extends State<_PremiumTagline> {
  final List<String> _words = ['DATE', 'WITH', 'CLASS'];
  int _visibleIndex = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Wait for the main text to start fading in, then reveal words quickly
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (mounted) {
            setState(() {
              _visibleIndex++;
            });
            if (_visibleIndex >= _words.length - 1) {
              timer.cancel();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppText.body.copyWith(
      color: Colors.white, // Required for ShaderMask
      fontSize: 10,
      letterSpacing: 4.0,
      fontWeight: FontWeight.w800,
    );

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AppColors.pinkDeep,
          AppColors.gold,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_words.length, (index) {
          final isVisible = _visibleIndex >= index;
          return AnimatedScale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            scale: isVisible ? 1.0 : 0.7,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isVisible ? 1.0 : 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_words[index], style: style),
                  if (index < _words.length - 1)
                    Text(' ', style: style),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
