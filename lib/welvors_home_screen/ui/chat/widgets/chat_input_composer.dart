import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import '../chat_bloc/chat_state.dart';
import '../composer_extras_panel.dart';
import 'chat_reply_composer_preview.dart';

/// Single message composer widget including text input, actions, reply preview, and extras panel.
class ChatInputComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode messageFocusNode;
  final GlobalKey textFieldKey;
  final String userName;
  final ChatMessage? replyingTo;
  final VoidCallback onCancelReply;
  final bool showExtrasPanel;
  final int extrasInitialTab;
  final VoidCallback onToggleExtrasPanel;
  final VoidCallback onCloseExtrasPanel;
  final VoidCallback onRemoveFocus;
  final VoidCallback onOpenShareSheet;
  final VoidCallback onOpenGiftPanel;
  final VoidCallback onOpenSaySomethingBetter;
  final VoidCallback onOpenCamera;
  final VoidCallback onStartRecording;
  final VoidCallback onSendText;
  final ValueChanged<String> onTypingChanged;
  final ValueChanged<String> onEmojiSelected;
  final ValueChanged<String> onStickerSelected;
  final void Function(String emoji, String label) onMemeSelected;
  final void Function(String emoji, String label) onEffectSelected;
  final void Function(String url, String category) onGifSelected;
  final void Function(GiftItem gift) onGiftSelected;

  const ChatInputComposer({
    super.key,
    required this.controller,
    required this.messageFocusNode,
    required this.textFieldKey,
    required this.userName,
    required this.replyingTo,
    required this.onCancelReply,
    required this.showExtrasPanel,
    required this.extrasInitialTab,
    required this.onToggleExtrasPanel,
    required this.onCloseExtrasPanel,
    required this.onRemoveFocus,
    required this.onOpenShareSheet,
    required this.onOpenGiftPanel,
    required this.onOpenSaySomethingBetter,
    required this.onOpenCamera,
    required this.onStartRecording,
    required this.onSendText,
    required this.onTypingChanged,
    required this.onEmojiSelected,
    required this.onStickerSelected,
    required this.onMemeSelected,
    required this.onEffectSelected,
    required this.onGifSelected,
    required this.onGiftSelected,
  });

  int _getLineCount() {
    final ctx = textFieldKey.currentContext;
    if (ctx == null) return 1;

    final renderBox = ctx.findRenderObject();
    if (renderBox is! RenderBox) return 1;

    final height = renderBox.size.height;
    const double singleLineHeight = 48.0;

    if (height <= singleLineHeight + 5) return 1;

    final double extraHeight = height - singleLineHeight;
    final int lines = 1 + (extraHeight / 24).round();
    return lines.clamp(1, 6);
  }

  Widget _smallAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 35,
        height: 30,
        child: Icon(icon, color: AppColors.ink60, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = controller.text.trim().isEmpty;

    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // REPLY PREVIEW
              if (replyingTo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChatReplyComposerPreview(
                    replyingTo: replyingTo!,
                    userName: userName,
                    onCancelReply: onCancelReply,
                  ),
                ),

              // SINGLE MESSAGE COMPOSER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          TextField(
                            key: textFieldKey,
                            controller: controller,
                            focusNode: messageFocusNode,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: isEmpty
                                ? TextInputAction.send
                                : TextInputAction.newline,
                            keyboardType: isEmpty
                                ? TextInputType.text
                                : TextInputType.multiline,
                            onTap: onCloseExtrasPanel,
                            onSubmitted: (_) {
                              if (controller.text.trim().isNotEmpty) {
                                onSendText();
                              }
                            },
                            onChanged: onTypingChanged,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: AppText.body.copyWith(
                                color: AppColors.muted,
                              ),
                              filled: isEmpty,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              counterText: '',
                              contentPadding: isEmpty
                                  ? const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                      top: 20,
                                      bottom: 10,
                                    )
                                  : const EdgeInsets.only(
                                      left: 0,
                                      right: 4,
                                      top: 20,
                                      bottom: 10,
                                    ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  right: 2,
                                ),
                                child: Opacity(
                                  opacity: isEmpty ? 1 : 0,
                                  child: IgnorePointer(
                                    ignoring: !isEmpty,
                                    child: _smallAction(
                                      showExtrasPanel
                                          ? Icons.keyboard_alt_outlined
                                          : Icons.emoji_emotions_outlined,
                                      () {
                                        onRemoveFocus();
                                        onToggleExtrasPanel();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              suffixIcon: isEmpty
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // TRY
                                        GestureDetector(
                                          onTap: onOpenSaySomethingBetter,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primarySoft,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  '💡',
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Try',
                                                  style: AppText.pill.copyWith(
                                                    color: AppColors.primary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // ATTACH
                                        _smallAction(
                                          Icons.attach_file_rounded,
                                          onOpenShareSheet,
                                        ),

                                        const SizedBox(width: 6),

                                        // GIFT BUTTON
                                        GestureDetector(
                                          onTap: onOpenGiftPanel,
                                          child: Material(
                                            elevation: 4,
                                            shadowColor:
                                                Colors.black.withValues(alpha: 0.25),
                                            shape: const CircleBorder(),
                                            color: Mycolor.white,
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Mycolor.white,
                                              child: Image.asset(
                                                "assets/gift.png",
                                                height: 25,
                                                width: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                    )
                                  : null,
                            ),
                          ),

                          // TYPING STATE LEFT ACTION STACK
                          if (!isEmpty)
                            Positioned(
                              left: 4.7,
                              bottom: 4,
                              child: Builder(
                                builder: (context) {
                                  final int lineCount = _getLineCount();

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (lineCount >= 3)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 0,
                                            left: 0,
                                          ),
                                          child: _smallAction(
                                            Icons.camera_alt_outlined,
                                            onOpenCamera,
                                          ),
                                        ),
                                      if (lineCount >= 2)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 0,
                                            left: 0,
                                          ),
                                          child: _smallAction(
                                            Icons.attach_file_rounded,
                                            onOpenShareSheet,
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                          left: 1,
                                        ),
                                        child: _smallAction(
                                          showExtrasPanel
                                              ? Icons.keyboard_alt_outlined
                                              : Icons.emoji_emotions_outlined,
                                          onToggleExtrasPanel,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // MIC / SEND
                    GestureDetector(
                      onTap: isEmpty ? onStartRecording : onSendText,
                      child: Container(
                        width: 35,
                        height: 35,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: isEmpty
                            ? const Icon(
                                Icons.mic_none_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Transform.rotate(
                                  angle: -0.7,
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // EXTRAS PANEL
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: showExtrasPanel
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ComposerExtrasPanel(
                          initialTab: extrasInitialTab,
                          onEmojiSelected: onEmojiSelected,
                          onStickerSelected: onStickerSelected,
                          onMemeSelected: onMemeSelected,
                          onEffectSelected: onEffectSelected,
                          onGifSelected: onGifSelected,
                          onGiftSelected: onGiftSelected,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
