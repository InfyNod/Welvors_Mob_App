import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MarriageScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDating;

  const MarriageScreen({super.key, this.onNavigateToDating});

  @override
  State<MarriageScreen> createState() => _MarriageScreenState();
}

class _MarriageScreenState extends State<MarriageScreen> {
  bool _isNotified = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/couple.json',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 0),

            // Coming Soon Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFFF8E1,
                ), // Light yellowish/orange background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(
                  color: Color(0xFFF57C00), // Orange text
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Title
            const Text(
              'Marriage Mode',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'A dedicated space for serious, marriage-\nminded matches — with family-friendly\nprofiles, intent verification and curated\nintroductions. We’re building it right now.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Notify me Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isNotified
                      ? [
                          const Color(0xFFFF9800), // Orange
                          const Color(0xFFE85A7A), // Pink
                        ]
                      : [
                          const Color(0xFF1E1E1E), // Dark near black
                          const Color(0xFF1E1E1E),
                        ],
                ),
                boxShadow: _isNotified
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE85A7A).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isNotified = !_isNotified;
                  });
                  if (_isNotified && widget.onNavigateToDating != null) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        widget.onNavigateToDating!();
                      }
                    });
                  }
                },
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                icon: Icon(
                  _isNotified
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  size: 24,
                ),
                label: Text(
                  _isNotified ? 'Notified!' : 'Notify me at launch',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
