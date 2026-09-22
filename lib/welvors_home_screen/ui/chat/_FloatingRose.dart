import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';

class FloatingRose extends StatefulWidget {
  const FloatingRose();

  @override
  State<FloatingRose> createState() => _FloatingRoseState();
}

class _FloatingRoseState extends State<FloatingRose>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = -6 * Curves.easeInOut.transform(_controller.value);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: const Text('🌹', style: TextStyle(fontSize: 70)),
    );
  }
}

class FloatingGift extends StatefulWidget {
  final String? imageUrl;

  const FloatingGift({this.imageUrl});

  @override
  State<FloatingGift> createState() => _FloatingGiftState();
}

class _FloatingGiftState extends State<FloatingGift>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = -6 * Curves.easeInOut.transform(_controller.value);

        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade200,
                ),
                errorWidget: (_, __, ___) {
                  return const Center(
                    child: Text('🎁', style: TextStyle(fontSize: 38)),
                  );
                },
              ),
            )
          : const Center(child: Text('🎁', style: TextStyle(fontSize: 38))),
    );
  }
}
