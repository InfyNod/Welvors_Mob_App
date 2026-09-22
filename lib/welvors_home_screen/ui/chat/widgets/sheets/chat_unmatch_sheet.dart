import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import '../../chat_repository.dart';

/// Bottom sheet dialog for confirming unmatching with another user.
class ChatUnmatchSheet extends StatefulWidget {
  final String userName;
  final String userAge;
  final String otherUserId;
  final VoidCallback onUnmatched;
  final void Function(String message) showToast;

  const ChatUnmatchSheet({
    super.key,
    required this.userName,
    required this.userAge,
    required this.otherUserId,
    required this.onUnmatched,
    required this.showToast,
  });

  static void show(
    BuildContext context, {
    required String userName,
    required String userAge,
    required String otherUserId,
    required VoidCallback onUnmatched,
    required void Function(String message) showToast,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatUnmatchSheet(
        userName: userName,
        userAge: userAge,
        otherUserId: otherUserId,
        onUnmatched: onUnmatched,
        showToast: showToast,
      ),
    );
  }

  @override
  State<ChatUnmatchSheet> createState() => _ChatUnmatchSheetState();
}

class _ChatUnmatchSheetState extends State<ChatUnmatchSheet> {
  final List<String> reasons = const [
    'No connection',
    'Chat went cold',
    'Met someone else',
    'They were rude',
    'Different intentions',
    'Too far away',
    'Felt unsafe',
    'Something else',
  ];

  final ValueNotifier<String?> selectedReason = ValueNotifier<String?>(null);
  final TextEditingController unmatchNoteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    selectedReason.dispose();
    unmatchNoteController.dispose();
    super.dispose();
  }

  Future<void> _handleUnmatch() async {
    final reason = selectedReason.value;
    if (reason == null || reason.trim().isEmpty) return;

    final note = unmatchNoteController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('💔 UNMATCH API CALL');
      debugPrint('Other User ID: ${widget.otherUserId}');
      debugPrint('Reason: $reason');
      debugPrint('Note: $note');

      await ChatRepository().unmatchUser(
        otherUserId: widget.otherUserId,
        reason: reason,
        note: note.isEmpty ? null : note,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onUnmatched();
      widget.showToast('User unmatched successfully');
    } catch (e) {
      debugPrint('❌ UNMATCH API ERROR: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      widget.showToast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Unmatch with ${widget.userName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This removes the match and deletes the chat for both of you.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Mycolor.pinkffeef2,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Unmatching: ${widget.userName}, ${widget.userAge} • this can\'t be undone',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE85D7D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Why are you unmatching? *',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Only used to improve your matches — never shown to her.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<String?>(
                        valueListenable: selectedReason,
                        builder: (context, current, _) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: reasons.map((reason) {
                              final isSelected = current == reason;
                              return ChoiceChip(
                                label: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? const Color(0xFFE85D7D)
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) {
                                  selectedReason.value = reason;
                                },
                                backgroundColor: Colors.white,
                                showCheckmark: false,
                                selectedColor: const Color(0xFFFCEAF0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFFE85D7D)
                                        : Colors.grey.shade300,
                                    width: 1.2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Anything else?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Optional — tell us more so we show you better people.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: unmatchNoteController,
                          minLines: 3,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Add a note...',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EFEA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Note:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Gifts and roses already sent aren’t refunded. You won’t see each other in discovery again.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: selectedReason,
                      builder: (context, reason, _) {
                        final enabled = reason != null && !_isLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: enabled ? _handleUnmatch : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE85D7D),
                              disabledBackgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                              shadowColor: const Color(
                                0xFFE85D7D,
                              ).withValues(alpha: 0.25),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Unmatch',
                                    style: TextStyle(
                                      color: enabled
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Keep the match',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
