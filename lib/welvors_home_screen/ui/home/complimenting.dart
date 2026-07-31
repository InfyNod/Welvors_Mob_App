import 'package:flutter/material.dart';

class ComplimentingBottomSheet extends StatefulWidget {
  final String complimentingType;

  const ComplimentingBottomSheet({
    Key? key,
    this.complimentingType = 'Prompt',
  }) : super(key: key);

  static void show(BuildContext context, {String type = 'Prompt'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ComplimentingBottomSheet(complimentingType: type),
    );
  }

  @override
  State<ComplimentingBottomSheet> createState() => _ComplimentingBottomSheetState();
}

class _ComplimentingBottomSheetState extends State<ComplimentingBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedGiftType = 'None'; 

  final Color _primaryColor = const Color(0xFFE43A6A); 
  final Color _softGrey = const Color(0xFFF5F5F5);
  final Color _borderGrey = const Color(0xFFEBEBEB);

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {});
    });
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _buttonText {
    bool hasText = _textController.text.trim().isNotEmpty;
    bool hasRose = _selectedGiftType == 'Rose';
    bool hasGift = _selectedGiftType == 'Gift';

    if (hasText && hasRose) {
      return 'Send 💬 + 🌹';
    } else if (hasText && hasGift) {
      return 'Send 💬 + 🎁';
    } else if (hasText) {
      return 'Send 💬';
    } else if (hasRose) {
      return 'Send 🌹';
    } else if (hasGift) {
      return 'Send 🎁';
    } else {
      return 'Send Compliment';
    }
  }

  bool get _canSend {
    return _textController.text.trim().isNotEmpty || _selectedGiftType != 'None';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding > 0 ? bottomPadding : MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 14.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title Section
                Text(
                  'COMPLIMENTING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.complimentingType,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),

                // Stats Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildStatPill(emoji: '💬', text: '3 comments'),
                      const SizedBox(width: 8),
                      _buildStatPill(emoji: '🌹', text: '2 roses'),
                      const SizedBox(width: 8),
                      _buildStatPill(emoji: '🪙', text: '5,258 balance'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Text Input Area
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _focusNode.hasFocus ? Colors.white : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _focusNode.hasFocus ? _primaryColor : _borderGrey,
                      width: _focusNode.hasFocus ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: 4,
                        minLines: 2,
                        maxLength: 140,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write a sweet compliment...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 'Try' Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFB6C1).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 14, color: _primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Try',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Gift Selection Row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGiftType = _selectedGiftType == 'Rose' ? 'None' : 'Rose';
                        });
                      },
                      child: _buildGiftButton(
                        text: 'Rose',
                        emoji: '🌹',
                        isSelected: _selectedGiftType == 'Rose',
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGiftType = _selectedGiftType == 'Gift' ? 'None' : 'Gift';
                        });
                      },
                      child: _buildGiftButton(
                        text: 'Select Gift',
                        emoji: '🎁',
                        isSelected: _selectedGiftType == 'Gift',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_textController.text.length}/140',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Bottom Actions
                Row(
                  children: [
                    // Like Button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _primaryColor.withOpacity(0.3), width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: _primaryColor, size: 20),
                          const SizedBox(height: 2),
                          Text(
                            'Like',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Send Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _canSend ? () {
                          Navigator.pop(context);
                        } : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 50,
                          decoration: BoxDecoration(
                            color: _canSend ? _primaryColor : _primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _buttonText,
                                key: ValueKey(_buttonText),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required String emoji,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _softGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftButton({
    required String text,
    required String emoji,
    required bool isSelected,
  }) {
    // We can't access _primaryColor directly if this was static, but it's an instance method, so we can!
    final primaryPink = const Color(0xFFE43A6A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? primaryPink.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? primaryPink : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? primaryPink : Colors.black87,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: primaryPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Colors.white,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
