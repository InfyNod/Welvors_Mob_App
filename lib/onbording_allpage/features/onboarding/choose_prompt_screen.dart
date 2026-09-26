import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import 'package:lottie/lottie.dart';
import '../../services/api_service.dart';
import 'prompts_screen.dart'; // To get PromptItem

class ChoosePromptScreen extends StatefulWidget {
  final List<String> addedPromptIds;
  const ChoosePromptScreen({super.key, required this.addedPromptIds});

  @override
  State<ChoosePromptScreen> createState() => _ChoosePromptScreenState();
}

class _ChoosePromptScreenState extends State<ChoosePromptScreen> {
  bool _isLoading = true;
  List<dynamic> _categoriesData = [];
  String? _selectedCategoryId;
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.fetchPromptsCategories();
    if (mounted) {
      setState(() {
        // Only keep categories that actually have prompts
        _categoriesData = data.where((cat) {
          final prompts = cat['prompts'] as List?;
          return prompts != null && prompts.isNotEmpty;
        }).toList();

        if (_categoriesData.isNotEmpty) {
          _selectedCategoryId = _categoriesData.first['id'];
        }
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
    final currentCategory = _categoriesData.firstWhere(
      (cat) => cat['id'] == _selectedCategoryId,
      orElse: () => null,
    );
    final promptsList = currentCategory?['prompts'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.chevron_left, color: AppColors.ink),
              ),
            ),
          ),
        ),
        title: Text(
          'Choose a prompt',
          style: AppText.body.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pinkDeep),
            )
          : _categoriesData.isEmpty
          ? Center(
              child: Text(
                'No prompts available',
                style: AppText.body.copyWith(color: AppColors.ink60),
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pad,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pinkSoft,
                        AppColors.pinkSoft.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.pinkDeep.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Lottie.asset(
                      'assets/Choose.json',
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pad,
                    vertical: 8,
                  ),
                  child: Row(
                    children: _categoriesData.map((cat) {
                      final String catId = cat['id'] ?? '';
                      final key = _categoryKeys.putIfAbsent(catId, () => GlobalKey());
                      final isSelected = _selectedCategoryId == catId;
                      final catName = cat['name'] ?? 'Other';
                      return GestureDetector(
                        key: key,
                        onTap: () {
                          setState(() => _selectedCategoryId = catId);
                          Scrollable.ensureVisible(
                            key.currentContext!,
                            alignment: 0.5,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pinkDeep
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.pinkDeep
                                  : AppColors.line,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.pinkDeep.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            '${_getCategoryEmoji(catName)}  $catName',
                            style: AppText.body.copyWith(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.ink60,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.line, height: 1, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pad,
                      24,
                      AppDimens.pad,
                      40,
                    ),
                    itemCount: promptsList.length,
                    itemBuilder: (context, index) {
                      final promptMap = promptsList[index];
                      final String promptId = promptMap['id'] ?? '';
                      final String promptText = promptMap['question'] ?? '';
                      final isAdded = widget.addedPromptIds.contains(promptId);

                      return GestureDetector(
                        onTap: isAdded
                            ? null
                            : () {
                                final item = PromptItem(
                                  id: promptId,
                                  question: promptText,
                                );
                                Navigator.pop(context, item);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isAdded ? AppColors.canvas : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAdded
                                  ? AppColors.line
                                  : AppColors.pinkDeep.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ink.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  promptText,
                                  style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isAdded
                                        ? AppColors.muted
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                              if (isAdded)
                                Text(
                                  'Added',
                                  style: AppText.body.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                      0xFF8DC6A2,
                                    ), // Light green matching the image
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.pinkDeep,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
