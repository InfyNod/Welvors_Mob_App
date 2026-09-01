import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'choose_prompt_screen.dart';

class PromptItem {
  final String id;
  final String question;
  String? answer;

  PromptItem({required this.id, required this.question, this.answer});
}

class PromptsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const PromptsScreen({super.key, required this.onNext});

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {
  bool _isSubmitting = false;
  final List<PromptItem> _prompts = [];

  Future<void> _editPrompt(int index) async {
    final prompt = _prompts[index];
    final TextEditingController controller = TextEditingController(
      text: prompt.answer,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppDimens.pad,
            right: AppDimens.pad,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt.question,
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.pinkDeep,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                cursorColor: AppColors.pinkDeep,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  hintStyle: AppText.body.copyWith(color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.canvas,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.pinkDeep),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                'Save',
                onTap: () {
                  setState(() {
                    prompt.answer = controller.text.trim().isEmpty
                        ? null
                        : controller.text.trim();
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        if (prompt.answer == null || prompt.answer!.trim().isEmpty) {
          if (index < _prompts.length && _prompts[index] == prompt) {
            _prompts.removeAt(index);
          }
        }
      });
    }
  }

  Widget _buildPromptCard(int index) {
    final prompt = _prompts[index];
    final bool isAnswered = prompt.answer != null && prompt.answer!.isNotEmpty;

    return GestureDetector(
      onTap: () => _editPrompt(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDEBED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.pinkDeep.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    prompt.question,
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.pinkDeep,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _editPrompt(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.pinkSoft.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppColors.pinkDeep,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _prompts.removeAt(index);
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prompt.answer ?? 'Tap to answer',
              style: AppText.body.copyWith(
                fontSize: 14,
                color: isAnswered ? AppColors.ink : AppColors.muted,
                fontStyle: isAnswered ? FontStyle.normal : FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPromptCard() {
    if (_prompts.length >= 3) return const SizedBox.shrink();

    final isFirst = _prompts.isEmpty;
    return GestureDetector(
      onTap: () async {
        final selectedPrompt = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChoosePromptScreen(
              addedPromptIds: _prompts.map((p) => p.id).toList(),
            ),
          ),
        );

        if (selectedPrompt != null && selectedPrompt is PromptItem) {
          setState(() {
            _prompts.add(selectedPrompt);
          });
          // Add small delay to let the UI build the new card, then show edit sheet
          Future.delayed(const Duration(milliseconds: 100), () {
            _editPrompt(_prompts.length - 1);
          });
        }
      },
      child: DottedBorder(
        color: AppColors.pinkDeep.withOpacity(0.3),
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.pinkDeep,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFirst ? 'Choose a prompt' : 'Add another prompt',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  if (!isFirst) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${_prompts.length}/3 selected',
                      style: AppText.sub.copyWith(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPTIONAL',
                            style: AppText.eyebrow.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a prompt or two.',
                            style: AppText.display.copyWith(fontSize: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A little personality goes a long way. Pick a\nprompt you like and answer it your way.',
                            style: AppText.sub.copyWith(
                              color: AppColors.ink60,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          ...List.generate(
                            _prompts.length,
                            (index) => _buildPromptCard(index),
                          ),
                          _buildAddPromptCard(),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pad,
                      16,
                      AppDimens.pad,
                      0,
                    ),
                    child: Column(
                      children: [
                        PrimaryButton(
                          _isSubmitting ? 'Saving...' : 'Continue',
                          onTap: _isSubmitting
                              ? null
                              : () async {
                                  final answeredPrompts = _prompts
                                      .where(
                                        (p) =>
                                            p.answer != null &&
                                            p.answer!.trim().isNotEmpty,
                                      )
                                      .toList();

                                  if (answeredPrompts.isEmpty) {
                                    widget.onNext();
                                    return;
                                  }

                                  setState(() => _isSubmitting = true);

                                  // Format the prompts payload
                                  List<Map<String, String>> payload =
                                      answeredPrompts.map((p) {
                                        return {
                                          "promptId": p.id,
                                          "answer": p.answer!.trim(),
                                        };
                                      }).toList();

                                  final error = await ApiService.submitPrompts(
                                    payload,
                                  );

                                  setState(() => _isSubmitting = false);

                                  if (error != null) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    }
                                  } else {
                                    widget.onNext();
                                  }
                                },
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isSubmitting ? null : widget.onNext,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink60,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(
                            'Skip for now',
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink60,
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
      },
    );
  }
}
