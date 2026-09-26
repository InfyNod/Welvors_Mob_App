import 'package:flutter/material.dart';

class MatchDialog extends StatelessWidget {
  final String matchedUserName;
  final String matchedUserImageUrl;
  final VoidCallback onMessage;
  final VoidCallback onSendRose;
  final VoidCallback onKeepBrowsing;

  const MatchDialog({
    super.key,
    required this.matchedUserName,
    required this.matchedUserImageUrl,
    required this.onMessage,
    required this.onSendRose,
    required this.onKeepBrowsing,
  });

  static void show(
    BuildContext context, {
    required String matchedUserName,
    required String matchedUserImageUrl,
    required VoidCallback onMessage,
    required VoidCallback onSendRose,
    required VoidCallback onKeepBrowsing,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: MatchDialog(
              matchedUserName: matchedUserName,
              matchedUserImageUrl: matchedUserImageUrl,
              onMessage: onMessage,
              onSendRose: onSendRose,
              onKeepBrowsing: onKeepBrowsing,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.7],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD1DC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD1DC).withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WELVORS text
          const Text(
            'WELVORS',
            style: TextStyle(
              color: Color(0xFFC73A5E),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          const Text(
            'It\'s a match!',
            style: TextStyle(
              color: Color(0xFFC73A5E),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'You and $matchedUserName liked each other',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6A655F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          // Avatars
          SizedBox(
            height: 110,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Current User (Left)
                Positioned(
                  left: 40,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC73A5E).withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/dummyphoto.jpeg',
                        ), // Fallback for current user
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Sparkle on Left Avatar
                Positioned(
                  left: 30,
                  top: 50,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),

                // Matched User (Right)
                Positioned(
                  right: 40,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC73A5E).withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/dummyphoto.jpeg',
                        ), // Dummy for matched user
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Rose on Right Avatar
                Positioned(
                  right: 45,
                  top: 10,
                  child: Text('🌹', style: TextStyle(fontSize: 16)),
                ),

                // Heart in Middle
                const Positioned(child: _BeatingHeart()),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description
          const Text(
            'Two hearts beating to the same rhythm. Your connection is already written in the stars. ✨',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6A655F),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE43A6A).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onSendRose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFFD1DC),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Send rose',
                        style: TextStyle(
                          color: Color(0xFFC73A5E),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Keep Browsing
          GestureDetector(
            onTap: onKeepBrowsing,
            child: const Text(
              'Keep browsing',
              style: TextStyle(
                color: Color(0xFF6A655F),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatingHeart extends StatefulWidget {
  const _BeatingHeart();

  @override
  State<_BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<_BeatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE43A6A),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE43A6A).withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 18),
      ),
    );
  }
}
