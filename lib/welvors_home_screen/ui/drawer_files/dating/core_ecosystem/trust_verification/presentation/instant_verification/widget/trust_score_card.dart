import 'package:flutter/material.dart';
import '../../../utils/mycolor.dart';

class TrustScoreCardAdhar extends StatelessWidget {
  final int score;
  final String? scorebottomtest;

  const TrustScoreCardAdhar({
    super.key,
    required this.score,
    this.scorebottomtest,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Mycolor.pink, Mycolor.pink1],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR TRUST SCORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),

          const SizedBox(height: 7),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: '/100',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // LINEAR PROGRESS INDICATOR
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.white.withValues(alpha: 0.28),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 17),

          Text(
            scorebottomtest ?? "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
