import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../boost_history.dart/boost_history.dart';

void showGoingLiveOverlay(BuildContext context, {bool isSuperBoost = false}) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _GoingLiveScreen(isSuperBoost: isSuperBoost);
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _GoingLiveScreen extends StatefulWidget {
  final bool isSuperBoost;

  const _GoingLiveScreen({required this.isSuperBoost});

  @override
  State<_GoingLiveScreen> createState() => _GoingLiveScreenState();
}

class _GoingLiveScreenState extends State<_GoingLiveScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 2 seconds and navigate to history
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close overlay
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BoostHistoryScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isSuperBoost
          ? const Color(0xFF2C2C2C)
          : const Color(0xFFE43A6A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/boost.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon in case lottie fails to load
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.isSuperBoost
                        ? const Color(0xFFFFC107).withOpacity(0.2)
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bolt,
                    color: widget.isSuperBoost
                        ? const Color(0xFFFFC107)
                        : Colors.white,
                    size: 50,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'You\'re going live...',
              style: TextStyle(
                color: widget.isSuperBoost
                    ? const Color(0xFFFFC107)
                    : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Putting your profile at the top right now.',
              style: TextStyle(
                color: widget.isSuperBoost
                    ? Colors.white70
                    : Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
