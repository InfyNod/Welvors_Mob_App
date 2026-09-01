import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';

class LifestyleScreen extends StatefulWidget {
  final VoidCallback onNext;
  const LifestyleScreen({super.key, required this.onNext});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String? _expandedCard;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Store answers as: Question ID -> List of selected values
  final Map<String, List<String>> _answers = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.fetchLifestyle();
    if (mounted) {
      setState(() {
        _questions = data;
        _isLoading = false;
      });
    }
  }

  String _getEmoji(String key) {
    switch (key.toLowerCase()) {
      case 'diet':
        return '🥗';
      case 'workout':
        return '💪';
      case 'drinking':
        return '🥂';
      case 'smoking':
        return '🚬';
      case 'pets':
        return '🐾';
      default:
        return '✨';
    }
  }

  Color _getEmojiBg(String key) {
    switch (key.toLowerCase()) {
      case 'diet':
        return AppColors.green;
      case 'workout':
        return AppColors.blue;
      case 'drinking':
        return AppColors.gold;
      case 'smoking':
        return AppColors.ink60;
      case 'pets':
        return AppColors.gold;
      default:
        return AppColors.pinkDeep;
    }
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String emoji,
    required Color emojiBg,
    required bool isExpanded,
    required bool hasValue,
    required VoidCallback onTap,
    Widget? expandedContent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isExpanded
              ? AppColors.pinkSoft.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: isExpanded || hasValue ? AppColors.pinkDeep : AppColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: emojiBg.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.body.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isExpanded || hasValue
                                ? AppColors.pinkDeep
                                : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppText.sub.copyWith(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    hasValue ? Icons.check_circle : Icons.circle_outlined,
                    color: hasValue ? AppColors.pinkDeep : AppColors.line,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (isExpanded && expandedContent != null) expandedContent,
          ],
        ),
      ),
    );
  }

  Widget _buildSubOptions({
    required List<String> chips,
    required String helperText,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.pinkDeep.withOpacity(0.2), height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                helperText,
                style: AppText.sub.copyWith(
                  color: AppColors.pinkDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips.map((c) {
                  final isSelected = selectedValue == c;
                  return GestureDetector(
                    onTap: () => onChanged(isSelected ? null : c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.pinkDeep : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.pinkDeep
                              : AppColors.line,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c,
                        style: AppText.body.copyWith(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSubOptions({
    required List<String> chips,
    required String helperText,
    required List<String> selectedValues,
    required int maxSelection,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.pinkDeep.withOpacity(0.2), height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                helperText,
                style: AppText.sub.copyWith(
                  color: AppColors.pinkDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips.map((c) {
                  final isSelected = selectedValues.contains(c);
                  return GestureDetector(
                    onTap: () {
                      final newList = List<String>.from(selectedValues);
                      if (isSelected) {
                        newList.remove(c);
                      } else {
                        if (newList.length < maxSelection) {
                          newList.add(c);
                        }
                      }
                      onChanged(newList);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.pinkDeep : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.pinkDeep
                              : AppColors.line,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c,
                        style: AppText.body.copyWith(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'LIFESTYLE',
                      style: AppText.eyebrow.copyWith(
                        color: AppColors.pinkDeep,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pinkSoft.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_answers.values.where((v) => v.isNotEmpty).length}/10',
                        style: AppText.sub.copyWith(
                          color: AppColors.pinkDeep,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Let’s talk lifestyle.',
                  style: AppText.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Habits meet harmony — you go first. This helps us match you on the things that shape everyday life.',
                  style: AppText.body.copyWith(
                    color: AppColors.ink60,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.pinkDeep,
                        ),
                      ),
                    ),
                  )
                else if (_questions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Failed to load lifestyle questions.',
                        style: AppText.body.copyWith(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  ..._questions.map((q) {
                    final questionId = q['id'].toString();
                    final title = q['title'] ?? '';
                    final subtitle = q['subtitle'] ?? '';
                    final isMulti = q['isMulti'] ?? false;
                    final List<dynamic> options = q['options'] ?? [];
                    final isExpanded = _expandedCard == questionId;
                    final selectedValues = _answers[questionId] ?? [];

                    return _buildCard(
                      title: title,
                      subtitle: subtitle,
                      emoji: _getEmoji(title),
                      emojiBg: _getEmojiBg(title),
                      isExpanded: isExpanded,
                      hasValue: selectedValues.isNotEmpty,
                      onTap: () {
                        setState(() {
                          _expandedCard = isExpanded ? null : questionId;
                        });
                      },
                      expandedContent: isMulti
                          ? _buildMultiSubOptions(
                              chips: options
                                  .map((e) => e['label'].toString())
                                  .toList(),
                              helperText: title.toLowerCase().contains('pet')
                                  ? 'Pick up to 3'
                                  : 'Pick as many as you like',
                              selectedValues: selectedValues,
                              maxSelection: title.toLowerCase().contains('pet')
                                  ? 3
                                  : 10,
                              onChanged: (newList) {
                                setState(() {
                                  int currentCount = _answers.values
                                      .where((v) => v.isNotEmpty)
                                      .length;
                                  bool isNewCategory =
                                      _answers[questionId] == null ||
                                      _answers[questionId]!.isEmpty;
                                  if (isNewCategory &&
                                      newList.isNotEmpty &&
                                      currentCount >= 10) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You can only select up to 10 lifestyles.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _answers[questionId] = newList;
                                });
                              },
                            )
                          : _buildSubOptions(
                              chips: options
                                  .map((e) => e['label'].toString())
                                  .toList(),
                              helperText: 'Pick one',
                              selectedValue: selectedValues.isNotEmpty
                                  ? selectedValues.first
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  if (val == null) {
                                    _answers[questionId] = [];
                                  } else {
                                    int currentCount = _answers.values
                                        .where((v) => v.isNotEmpty)
                                        .length;
                                    bool isNewCategory =
                                        _answers[questionId] == null ||
                                        _answers[questionId]!.isEmpty;
                                    if (isNewCategory && currentCount >= 10) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'You can only select up to 10 lifestyles.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    _answers[questionId] = [val];
                                    _expandedCard = null;
                                  }
                                });
                              },
                            ),
                    );
                  }),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                'Continue',
                isLoading: _isSubmitting,
                onTap: _isSubmitting
                    ? null
                    : () async {
                        setState(() => _isSubmitting = true);

                        // Collect local user data
                        List<String> selectedLabels = [];
                        for (final values in _answers.values) {
                          selectedLabels.addAll(values);
                        }
                        userData.lifestyle = selectedLabels;

                        // Simulate API delay
                        await Future.delayed(const Duration(seconds: 1));

                        if (mounted) {
                          setState(() => _isSubmitting = false);
                          widget.onNext();
                        }
                      },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  userData.lifestyle = [];
                  widget.onNext();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink60,
                  minimumSize: const Size(double.infinity, 36),
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }
}
