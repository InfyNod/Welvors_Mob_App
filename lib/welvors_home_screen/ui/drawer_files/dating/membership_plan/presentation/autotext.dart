import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const AutoScrollText({super.key, required this.text, this.style});

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  double _textWidth = 0;
  double _availableWidth = 0;

  static const double _gap = 40;

  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(_scrollText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateText();
    });
  }

  void _calculateText() {
    if (!mounted) return;

    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = painter.width;

    _shouldScroll = _textWidth > _availableWidth && _availableWidth > 0;

    if (_shouldScroll) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      _animationController.stop();
      _animationController.reset();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _scrollText() {
    if (!_scrollController.hasClients || !_shouldScroll) {
      return;
    }

    final loopWidth = _textWidth + _gap;

    final offset = _animationController.value * loopWidth;

    final maxScroll = _scrollController.position.maxScrollExtent;

    if (maxScroll <= 0) return;

    _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
  }

  @override
  void didUpdateWidget(covariant AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _animationController.stop();
      _animationController.reset();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateText();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _availableWidth = constraints.maxWidth;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _calculateText();
          }
        });

        // Short text → Center
        if (!_shouldScroll) {
          return SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                widget.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: widget.style,
              ),
            ),
          );
        }

        // Long text → Continuous left direction
        return ClipRect(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  maxLines: 1,
                  softWrap: false,
                  style: widget.style,
                ),

                const SizedBox(width: _gap),

                Text(
                  widget.text,
                  maxLines: 1,
                  softWrap: false,
                  style: widget.style,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
