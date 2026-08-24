import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';

/// Full-screen "rain" style effect (confetti, hearts, rose petals, etc.)
/// that plays once over the whole chat screen and then removes itself.
///
/// Motion mirrors the reference recording:
///   - particles spawn in a staggered stream (not all at once) near the
///     top of the screen, already at full size
///   - they drift down with a gentle side-to-side sway (not a straight line)
///   - there's a brief "float / hover" pause around the middle of the
///     journey before they continue falling — not a constant-speed drop
///   - they fade in quickly, hold, then fade out only in the last stretch
///     as they approach the bottom of the screen
///
/// Usage:
///   EffectRainOverlay.play(context, emoji: '❤️', count: 22);
class EffectRainOverlay {
  EffectRainOverlay._();
  static void play(
    BuildContext context, {
    required String emoji,
    int count = 20,
    Duration duration = const Duration(milliseconds: 3200),
    bool burstFromCenter = false,
  }) {
    final overlayState = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;

    entry = OverlayEntry(
      opaque: false,
      maintainState: false,
      builder: (ctx) {
        return _EffectRainView(
          emoji: emoji,
          count: count,
          duration: duration,
          burstFromCenter: burstFromCenter,
          onFinished: () {
            if (entry.mounted) {
              entry.remove();
            }
          },
        );
      },
    );

    overlayState.insert(entry);
  }
}

class _EffectRainView extends StatefulWidget {
  final String emoji;
  final int count;
  final Duration duration;
  final bool burstFromCenter;
  final VoidCallback onFinished;

  const _EffectRainView({
    required this.emoji,
    required this.count,
    required this.duration,
    required this.burstFromCenter,
    required this.onFinished,
  });

  @override
  State<_EffectRainView> createState() => _EffectRainViewState();
}

class _Particle {
  final double startX; // 0..1 fraction of width
  final double delay; // 0..1 fraction of total duration, when it spawns
  final double size;
  final double wiggle; // horizontal sway amplitude
  final double wiggleSpeed; // how many sway cycles over the fall
  final double bob; // small vertical flutter amplitude (butterfly hover)
  final double bobSpeed;
  final double spin;
  final double angle; // for burst effects
  final double distance; // for burst effects
  final double pausePoint; // 0..1, where along the fall it hovers

  _Particle({
    required this.startX,
    required this.delay,
    required this.size,
    required this.wiggle,
    required this.wiggleSpeed,
    required this.bob,
    required this.bobSpeed,
    required this.spin,
    required this.angle,
    required this.distance,
    required this.pausePoint,
  });
}

class _EffectRainViewState extends State<_EffectRainView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    final rnd = math.Random();

    _particles = List.generate(widget.count, (i) {
      return _Particle(
        startX: rnd.nextDouble(),
        // Spawns are staggered across roughly the first 45% of the
        // animation, so new particles keep entering while earlier ones
        // are already mid-fall — matches the "stream" look in the video.
        delay: rnd.nextDouble() * 0.45,
        size: 20 + rnd.nextDouble() * 18,
        wiggle: 12 + rnd.nextDouble() * 22,
        wiggleSpeed: 1.2 + rnd.nextDouble() * 1.1,
        bob: 4 + rnd.nextDouble() * 6,
        bobSpeed: 3.0 + rnd.nextDouble() * 3.0,
        spin: (rnd.nextBool() ? 1 : -1) * (0.3 + rnd.nextDouble() * 0.6),
        angle: rnd.nextDouble() * math.pi * 2,
        distance: 60 + rnd.nextDouble() * 140,
        pausePoint: 0.30 + rnd.nextDouble() * 0.20,
      );
    });

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Vertical fall progress with a brief float/hover pause partway down,
  /// instead of a constant-speed drop.
  ///
  ///  0 ─────► quick settle in ─────► HOVER (barely moves) ─────► falls
  ///  the rest of the way and fades near the bottom.
  double _fallCurve(double t, double pausePoint) {
    final settleEnd = pausePoint * 0.55;
    final hoverEnd = pausePoint + 0.16;

    if (t < settleEnd) {
      // fast initial drop into place
      final local = t / settleEnd;
      return Curves.easeOut.transform(local) * (pausePoint * 0.85);
    } else if (t < hoverEnd) {
      // hover / float pause — near-stationary with a tiny wobble
      final local = (t - settleEnd) / (hoverEnd - settleEnd);
      final base = pausePoint * 0.85;
      final target = pausePoint;
      return base + (target - base) * local;
    } else {
      // continue falling the rest of the way, easing in
      final local = ((t - hoverEnd) / (1 - hoverEnd)).clamp(0.0, 1.0);
      return pausePoint + Curves.easeIn.transform(local) * (1 - pausePoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: _particles.map((p) {
                // local progress for this particle, 0..1
                final raw = ((_controller.value - p.delay) / (1 - p.delay))
                    .clamp(0.0, 1.0);

                double left;
                double top;
                double opacity;

                if (widget.burstFromCenter) {
                  final progress = Curves.easeOut.transform(raw);
                  final dx = math.cos(p.angle) * p.distance * progress;
                  final dy =
                      math.sin(p.angle) * p.distance * progress -
                      (40 * progress);
                  left = size.width / 2 + dx;
                  top = size.height / 2 + dy;
                  opacity = (1 - progress).clamp(0.0, 1.0);
                } else {
                  final fall = _fallCurve(raw, p.pausePoint);

                  final sway =
                      math.sin(raw * math.pi * 2 * p.wiggleSpeed) * p.wiggle;
                  final flutter =
                      math.sin(raw * math.pi * 2 * p.bobSpeed) * p.bob;

                  left = p.startX * size.width + sway;
                  top = -40 + fall * (size.height + 80) + flutter;

                  // Fade in fast, hold, fade out only near the very end
                  // as the particle approaches the bottom of the screen.
                  opacity = raw < 0.08
                      ? raw / 0.08
                      : raw > 0.82
                      ? (1 - raw) / 0.18
                      : 1.0;
                }

                return Positioned(
                  left: left,
                  top: top,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: raw * math.pi * 2 * p.spin,
                      child: Text(
                        widget.emoji,
                        style: TextStyle(
                          fontSize: p.size,
                          color: Mycolor.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
