import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MatureDatingScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDating;
  
  const MatureDatingScreen({super.key, this.onNavigateToDating});

  @override
  State<MatureDatingScreen> createState() => _MatureDatingScreenState();
}

class _MatureDatingScreenState extends State<MatureDatingScreen> {
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
            // Icon with Glow
            Lottie.asset(
              'assets/old.json',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 0),
            
            // Coming Soon Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6), // Light purple background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD1C4E9), width: 1.5),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(
                  color: Color(0xFF673AB7), // Deep purple text
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Title
            const Text(
              'Mature Dating',
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
              'A refined space for 40+ singles seeking\nmeaningful companionship — with age-\nverified profiles, slower-paced matching and\nprivacy-first controls. Coming soon.',
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
                          const Color(0xFF3F51B5), // Indigo
                          const Color(0xFF9C27B0), // Purple
                        ]
                      : [
                          const Color(0xFF1E1E1E), // Dark near black
                          const Color(0xFF1E1E1E),
                        ],
                ),
                boxShadow: _isNotified
                    ? [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
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
                style: ElevatedButton.styleFrom(
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
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                icon: Icon(
                  _isNotified ? Icons.notifications_active : Icons.notifications_none,
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
