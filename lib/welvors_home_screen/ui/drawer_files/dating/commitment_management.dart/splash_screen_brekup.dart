import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreenBreakup extends StatelessWidget {
  const SplashScreenBreakup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0F5), // Lavender blush
            Color(0xFFFFD1DC), // Pastel pink
            Color(0xFFFFE4E1), // Misty rose
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(10, 0),
              child: Lottie.asset(
                'assets/Rude_couple.json',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Taking a break...",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDF2C59),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Updating your commitment status.",
              style: TextStyle(fontSize: 14, color: Color(0xFF6A655F)),
            ),
          ],
        ),
      ),
    );
  }
}
