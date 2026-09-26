import 'dart:math' as math;

import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';

class RoseTwinkleOverlay extends StatefulWidget {
  const RoseTwinkleOverlay({super.key});

  @override
  State<RoseTwinkleOverlay> createState() => _RoseTwinkleOverlayState();
}

class _RoseTwinkleOverlayState extends State<RoseTwinkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 0 → 1 → 0
  double _pulse(double value) {
    return math.sin(value * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          // ----------------------------------------------------------
          // HEART
          // ----------------------------------------------------------

          final heartProgress = (t + 0.00) % 1.0;

          final heart = _pulse(heartProgress);

          final heartScale = 0.80 + (heart * 0.75);

          final heartY = -28 * Curves.easeOut.transform(heart);

          final heartOpacity = heartProgress < 0.15
              ? heartProgress / 0.15
              : heartProgress > 0.70
              ? (1 - heartProgress) / 0.30
              : 1.0;

          // ----------------------------------------------------------
          // FLOWER
          // ----------------------------------------------------------

          final flowerProgress = (t + 0.28) % 1.0;

          final flower = _pulse(flowerProgress);

          final flowerScale = 0.55 + (flower * 0.85);

          final flowerY = -32 * Curves.easeOut.transform(flower);

          final flowerOpacity = flowerProgress < 0.15
              ? flowerProgress / 0.15
              : flowerProgress > 0.70
              ? (1 - flowerProgress) / 0.30
              : 1.0;

          // ----------------------------------------------------------
          // SPARKLE
          // ----------------------------------------------------------

          final sparkleProgress = (t + 0.55) % 1.0;

          final sparkle = _pulse(sparkleProgress);

          final sparkleScale = 0.45 + (sparkle * 0.95);

          final sparkleY = -30 * Curves.easeOut.transform(sparkle);

          final sparkleOpacity = sparkleProgress < 0.15
              ? sparkleProgress / 0.15
              : sparkleProgress > 0.70
              ? (1 - sparkleProgress) / 0.30
              : 1.0;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ------------------------------------------------------
              // HEART
              // ------------------------------------------------------
              Positioned(
                top: 18 + heartY,
                child: Opacity(
                  opacity: heartOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: heartScale,
                    child: const Text('💗', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),

              // ------------------------------------------------------
              // FLOWER
              // ------------------------------------------------------
              Positioned(
                left: 108,
                top: 48 + flowerY,
                child: Opacity(
                  opacity: flowerOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: flowerScale,
                    child: const Text('🌸', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),

              // ------------------------------------------------------
              // SPARKLE
              // ------------------------------------------------------
              Positioned(
                right: 108,
                top: 52 + sparkleY,
                child: Opacity(
                  opacity: sparkleOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: sparkleScale,
                    child: const Text('✨', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
