import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/onbording_allpage/services/api_service.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/services/edit_profile_api_service.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class PromptsSection extends StatelessWidget {
  const PromptsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFE43A6A),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  "PROFILE PROMPTS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFFE43A6A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...state.prompts.asMap().entries.map((entry) {
              final index = entry.key;
              final prompt = entry.value;
              return _buildPromptCard(context, prompt, index, state.prompts);
            }),
            if (state.prompts.length < 3)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditChoosePromptScreen(
                        alreadyAddedQuestions: state.prompts
                            .map((p) => p['question'] ?? '')
                            .toList(),
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    final newList = List<Map<String, String>>.from(
                      state.prompts,
                    )..add(result);
                    context.read<ProfileEditCubit>().updatePrompts(newList);
                  }
                },
                child: DottedBorder(
                  color: const Color.fromARGB(
                    255,
                    244,
                    167,
                    187,
                  ).withValues(alpha: 0.5),
                  strokeWidth: 1.5,
                  dashPattern: const [6, 4],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Color(0xFFE43A6A), size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Add a prompt",
                          style: TextStyle(
                            color: Color(0xFFE43A6A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPromptCard(
    BuildContext context,
    Map<String, String> prompt,
    int index,
    List<Map<String, String>> allPrompts,
  ) {
    return GestureDetector(
      onTap: () => _editExistingPrompt(context, prompt, index, allPrompts),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(
            0xFFFFF6F8,
          ), // Faint blush background like reference image
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE43A6A).withValues(alpha: 0.15), // Softer border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      prompt['question'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFFE43A6A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        _editExistingPrompt(context, prompt, index, allPrompts),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: const Color(0xFFE43A6A).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      final promptId = prompt['promptId'] ?? '';
                      if (promptId.isNotEmpty) {
                        final response =
                            await EditProfileApiService.deletePrompt(promptId);

                        if (response['error'] != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response['error'])),
                          );
                          return;
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Debug: Missing IDs! Data: $prompt',
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      if (context.mounted) {
                        final newList = List<Map<String, String>>.from(
                          allPrompts,
                        )..removeAt(index);
                        context.read<ProfileEditCubit>().updatePrompts(newList);
                      }
                    },
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                prompt['answer'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _resolveCategoryId(String promptId) async {
    try {
      final categories = await ApiService.fetchPromptsCategories();
      for (var cat in categories) {
        if (cat['prompts'] != null) {
          for (var p in cat['prompts']) {
            final pId = p['id']?.toString() ?? p['promptId']?.toString();
            if (pId == promptId) {
              return cat['id']?.toString() ?? '';
            }
          }
        }
      }
    } catch (e) {
      AppLogger.e('PromptsSection', "Error resolving categoryId: $e");
    }
    return '';
  }

  void _editExistingPrompt(
    BuildContext context,
    Map<String, String> prompt,
    int index,
    List<Map<String, String>> allPrompts,
  ) {
    final controller = TextEditingController(text: prompt['answer']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 24,
                  right: 24,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Prompt',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      prompt['question'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFFE43A6A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLines: 4,
                      cursorColor: const Color(0xFFE43A6A),
                      decoration: InputDecoration(
                        hintText: 'Type your answer here...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE43A6A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              final text = controller.text.trim();
                              final newList = List<Map<String, String>>.from(
                                allPrompts,
                              );

                              var categoryId = prompt['categoryId'] ?? '';
                              final promptId = prompt['promptId'] ?? '';

                              if (categoryId.isEmpty && promptId.isNotEmpty) {
                                categoryId = await _resolveCategoryId(promptId);
                              }

                              if (text.isEmpty) {
                                if (categoryId.isNotEmpty &&
                                    promptId.isNotEmpty) {
                                  await EditProfileApiService.updatePrompt(
                                    categoryId: categoryId,
                                    promptId: promptId,
                                    answer: '',
                                    displayOrder: index + 1,
                                  );
                                }

                                if (context.mounted) {
                                  newList.removeAt(index);
                                  context
                                      .read<ProfileEditCubit>()
                                      .updatePrompts(newList);
                                  Navigator.pop(context);
                                }
                              } else {
                                if (categoryId.isNotEmpty &&
                                    promptId.isNotEmpty) {
                                  final response =
                                      await EditProfileApiService.updatePrompt(
                                        categoryId: categoryId,
                                        promptId: promptId,
                                        answer: text,
                                        displayOrder: index + 1,
                                      );
                                  if (response['error'] != null &&
                                      context.mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(response['error']),
                                      ),
                                    );
                                    return;
                                  }
                                } else {
                                  if (context.mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Debug Edit: Missing IDs! Data: $prompt',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                if (context.mounted) {
                                  newList[index] = {
                                    'question': prompt['question']!,
                                    'answer': text,
                                    'promptId': promptId,
                                    'categoryId': categoryId,
                                  };
                                  context
                                      .read<ProfileEditCubit>()
                                      .updatePrompts(newList);
                                  Navigator.pop(context);
                                }
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isLoading
                              ? Colors.grey.shade400
                              : const Color(0xFFE43A6A),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            if (!isLoading)
                              BoxShadow(
                                color: const Color(0xFFE43A6A).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EditChoosePromptScreen extends StatefulWidget {
  final List<String> alreadyAddedQuestions;
  const EditChoosePromptScreen({
    super.key,
    required this.alreadyAddedQuestions,
  });

  @override
  State<EditChoosePromptScreen> createState() => _EditChoosePromptScreenState();
}

class _EditChoosePromptScreenState extends State<EditChoosePromptScreen> {
  final Color _pinkDeep = const Color(0xFFE43A6A);

  List<dynamic> _categoriesData = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.fetchPromptsCategories();
    if (mounted) {
      setState(() {
        _categoriesData = data.where((cat) {
          final prompts = cat['prompts'] as List?;
          return prompts != null && prompts.isNotEmpty;
        }).toList();

        _isLoading = false;
      });
    }
  }

  String _getCategoryEmoji(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('about')) return '👋';
    if (lower.contains('story')) return '📖';
    if (lower.contains('type')) return '💘';
    if (lower.contains('food')) return '🍔';
    if (lower.contains('lifestyle') || lower.contains('love')) return '🧘';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(context, 'Choose a prompt', () async => true),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
            )
          : _categoriesData.isEmpty
          ? const Center(child: Text('No prompts available'))
          : Row(
              children: [
                // Left Sidebar (Categories)
                Container(
                  width: 80, // Reduced width to save space
                  color: const Color(0xFFFFF6F8), // Premium soft blush color
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    itemCount: _categoriesData.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      final cat = _categoriesData[index];
                      final catName = cat['name'] ?? 'Other';
                      final catEmoji = _getCategoryEmoji(catName);
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategoryIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic, // smoother easing
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              // Fully opaque color to prevent "dark fading" interpolation bug
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFFFF6F8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE43A6A).withValues(alpha: 0.2)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE43A6A,
                                        ).withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  catEmoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  catName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? _pinkDeep
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right Side (Prompts List)
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          (_categoriesData[_selectedCategoryIndex]['prompts']
                                  as List)
                              .length,
                      itemBuilder: (context, index) {
                        final promptMap =
                            _categoriesData[_selectedCategoryIndex]['prompts'][index];
                        final promptText = promptMap['question'] ?? '';
                        final promptId =
                            promptMap['id'] ?? promptMap['promptId'] ?? '';
                        final categoryId =
                            _categoriesData[_selectedCategoryIndex]['id'] ?? '';

                        final isAdded = widget.alreadyAddedQuestions.contains(
                          promptText,
                        );

                        return GestureDetector(
                          onTap: () {
                            if (!isAdded) {
                              _showAnswerSheet(
                                context,
                                promptText,
                                categoryId,
                                promptId,
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isAdded
                                  ? Colors.grey.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAdded
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade200,
                                width: 1.5,
                              ),
                              boxShadow: isAdded
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    promptText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isAdded
                                          ? Colors.grey.shade400
                                          : Colors.black87,
                                      fontWeight: isAdded
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isAdded)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                else
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey.shade300,
                                    size: 14,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAnswerSheet(
    BuildContext context,
    String question,
    String categoryId,
    String promptId,
  ) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _pinkDeep,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 4,
                  cursorColor: _pinkDeep,
                  decoration: InputDecoration(
                    hintText: 'Type your answer here...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _pinkDeep, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    final answer = controller.text.trim();
                    if (answer.isNotEmpty) {
                      // Call API
                      final response = await EditProfileApiService.updatePrompt(
                        categoryId: categoryId,
                        promptId: promptId,
                        answer: answer,
                        displayOrder: 1, // Will be appended at the end
                      );

                      if (response['error'] != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response['error'])),
                        );
                        return;
                      }

                      if (context.mounted) {
                        // Close sheet
                        Navigator.pop(context);
                        // Return full result to parent
                        Navigator.pop(context, {
                          'question': question,
                          'answer': answer,
                          'categoryId': categoryId,
                          'promptId': promptId,
                        });
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _pinkDeep,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: _pinkDeep.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Answer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
