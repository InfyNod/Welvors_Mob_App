import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// WhatsApp-style floating quick reaction bar that appears above a message on long-press.
class ChatReactionBar extends StatefulWidget {
  final ValueChanged<String> onSelectReaction;
  final VoidCallback onDismiss;
  final String? currentReaction;

  const ChatReactionBar({
    super.key,
    required this.onSelectReaction,
    required this.onDismiss,
    this.currentReaction,
  });

  static const List<String> defaultEmojis = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];

  static const List<String> extraEmojis = [
    '🔥',
    '🎉',
    '🥰',
    '👏',
    '💯',
    '✨',
    '🌹',
    '😍',
    '😎',
    '🥳',
    '👀',
    '💪',
    '🤩',
    '💖',
    '🤝',
    '🤗',
  ];

  @override
  State<ChatReactionBar> createState() => _ChatReactionBarState();
}

class _ChatReactionBarState extends State<ChatReactionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  bool _showMoreEmojis = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapEmoji(String emoji) {
    HapticFeedback.mediumImpact();
    widget.onSelectReaction(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFE43A6A).withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFFE43A6A).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...ChatReactionBar.defaultEmojis.map((emoji) {
                    final isSelected = widget.currentReaction == emoji;
                    return _buildEmojiButton(emoji, isSelected);
                  }),
                  const SizedBox(width: 4),
                  // Plus icon button for extra emojis
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _showMoreEmojis = !_showMoreEmojis;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _showMoreEmojis
                            ? const Color(0xFFFFF0F3)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _showMoreEmojis
                              ? const Color(0xFFE43A6A).withValues(alpha: 0.4)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Icon(
                        _showMoreEmojis ? Icons.keyboard_arrow_up_rounded : Icons.add_rounded,
                        size: 20,
                        color: _showMoreEmojis
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (_showMoreEmojis) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 290),
                  padding: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: ChatReactionBar.extraEmojis.map((emoji) {
                      final isSelected = widget.currentReaction == emoji;
                      return _buildEmojiButton(emoji, isSelected, size: 28);
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji, bool isSelected, {double size = 34}) {
    return GestureDetector(
      onTap: () => _onTapEmoji(emoji),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFFE43A6A), width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: size * 0.58,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
