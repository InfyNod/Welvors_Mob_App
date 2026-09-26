import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

enum SwipeDirection { none, reply, delete }

class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const SwipeToReply({super.key, 
    required this.child,
    required this.onReply,
    this.onDelete,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;

  double _dragX = 0;
  double _startX = 0;

  SwipeDirection _direction = SwipeDirection.none;

  bool _actionTriggered = false;

  static const double _maxDrag = 82;
  static const double _replyThreshold = 58;
  static const double _deleteThreshold = -58;

  @override
  void initState() {
    super.initState();

    _resetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 180),
        )..addListener(() {
          if (!mounted) return;

          setState(() {
            _dragX = _startX * (1 - _resetController.value);
          });
        });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _resetController.stop();

    _startX = _dragX;

    // New gesture
    _direction = SwipeDirection.none;
    _actionTriggered = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_actionTriggered) return;

    final dx = details.delta.dx;

    // First movement decides direction.
    if (_direction == SwipeDirection.none) {
      if (dx > 0) {
        _direction = SwipeDirection.reply;
      } else if (dx < 0) {
        _direction = SwipeDirection.delete;
      }
    }

    double nextX = _dragX;

    if (_direction == SwipeDirection.reply) {
      // Reply can ONLY move right.
      nextX = (_dragX + dx).clamp(0.0, _maxDrag);
    } else if (_direction == SwipeDirection.delete) {
      // Delete can ONLY move left.
      nextX = (_dragX + dx).clamp(-_maxDrag, 0.0);
    }

    if (nextX == _dragX) return;

    setState(() {
      _dragX = nextX;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_actionTriggered) {
      _animateBack();
      return;
    }

    // ============================================================
    // REPLY
    // ============================================================

    if (_direction == SwipeDirection.reply && _dragX >= _replyThreshold) {
      _actionTriggered = true;

      AppLogger.d('SwipeToReply', '↩️ REPLY ONLY');

      widget.onReply();

      _animateBack();
      return;
    }

    // ============================================================
    // DELETE
    // ============================================================

    if (_direction == SwipeDirection.delete && _dragX <= _deleteThreshold) {
      _actionTriggered = true;

      AppLogger.d('SwipeToReply', '🗑️ DELETE ONLY');

      widget.onDelete?.call();

      _animateBack();
      return;
    }

    _animateBack();
  }

  void _onDragCancel() {
    _animateBack();
  }

  void _animateBack() {
    _startX = _dragX;

    _resetController
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted) return;

        setState(() {
          _dragX = 0;
          _startX = 0;
          _direction = SwipeDirection.none;
          _actionTriggered = false;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT:
    // Only show Reply icon when current gesture is Reply.
    final double replyProgress = _direction == SwipeDirection.reply
        ? (_dragX / _replyThreshold).clamp(0.0, 1.0)
        : 0.0;

    // IMPORTANT:
    // Only show Delete icon when current gesture is Delete.
    final double deleteProgress = _direction == SwipeDirection.delete
        ? (-_dragX / -_deleteThreshold).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ========================================================
          // REPLY
          // ========================================================
          Positioned(
            left: 16,
            child: IgnorePointer(
              child: Opacity(
                opacity: replyProgress,
                child: Transform.scale(
                  scale: 0.75 + (0.25 * replyProgress),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.reply_rounded,
                      size: 21,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ========================================================
          // MESSAGE
          // ========================================================
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: _onDragCancel,
            child: Transform.translate(
              offset: Offset(_dragX, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
