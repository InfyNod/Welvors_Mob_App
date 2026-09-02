import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';

class Interest {
  final String id;
  final String questionId;
  final String questionKey;
  final String label;
  final String emoji;
  final String category;

  Interest({
    required this.id,
    required this.questionId,
    required this.questionKey,
    required this.label,
    required this.emoji,
    required this.category,
  });
}

// We will fetch these from the backend instead of hardcoding.

class InterestsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const InterestsScreen({super.key, required this.onNext});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> with AutomaticKeepAliveClientMixin  {
  final Set<Interest> _selectedInterests = {};
  String _searchQuery = '';
  final Map<String, bool> _categoryExpanded = {};

  List<Interest> _allInterests = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.fetchInterests();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data.isNotEmpty) {
          _allInterests = [];
          for (var category in data) {
            final catTitle = category['title'] ?? 'Other';
            final questionId = category['id']?.toString() ?? '';
            final questionKey = category['key']?.toString() ?? '';
            final options = category['options'] as List<dynamic>? ?? [];
            for (var option in options) {
              _allInterests.add(
                Interest(
                  id: option['id'].toString(),
                  questionId: questionId,
                  questionKey: questionKey,
                  label: option['label']?.toString() ?? '',
                  emoji: _getEmojiForCategoryKey(
                    category['key']?.toString() ?? '',
                  ),
                  category: catTitle,
                ),
              );
            }
          }
        }
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchOnboardingDetails('INTEREST');
    if (data != null && data is List && mounted) {
      setState(() {
        userData.interests.clear(); // Prevent duplicates on reload
        for (var item in data) {
          if (item['option'] != null) {
            String optLabel = item['option']['label'].toString();
            try {
              final interest = _allInterests.firstWhere((i) => i.label == optLabel);
              _selectedInterests.add(interest);
              
              // Map to user data
              userData.interests.add({
                'label': interest.label,
                'emoji': interest.emoji,
              });
            } catch (e) {
              // Ignore if not found
            }
          }
        }
      });
    }
  }

  String _getEmojiForCategoryKey(String key) {
    switch (key.toLowerCase()) {
      case 'creativity':
        return '🎨';
      case 'favorites':
        return '🎬';
      case 'food_drink':
        return '🍔';
      case 'travel_outdoors':
        return '✈️';
      case 'gaming':
        return '🎮';
      case 'wellness':
        return '🧘';
      default:
        return '✨';
    }
  }

  Map<String, List<Interest>> get _groupedInterests {
    final filtered = _allInterests
        .where(
          (i) => i.label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
    final Map<String, List<Interest>> grouped = {};
    for (var interest in filtered) {
      if (!grouped.containsKey(interest.category)) {
        grouped[interest.category] = [];
      }
      grouped[interest.category]!.add(interest);
    }
    return grouped;
  }

  Widget _buildSelectedInterests() {
    if (_selectedInterests.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pad),
        child: Row(
          children: _selectedInterests.toList().reversed.map((interest) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pinkDeep,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(interest.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      interest.label,
                      style: AppText.body.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedInterests.remove(interest);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'creativity':
        return '🎨';
      case 'fan favorites':
        return '🎬';
      case 'food & drink':
        return '🍔';
      case 'travel & outdoors':
        return '✈️';
      case 'gaming':
        return '🎮';
      case 'wellness':
        return '🧘';
      default:
        return '✨';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'creativity':
        return AppColors.pinkDeep;
      case 'fan favorites':
        return AppColors.gold;
      case 'food & drink':
        return AppColors.green;
      case 'travel & outdoors':
        return AppColors.blue;
      case 'gaming':
        return AppColors.ink60;
      case 'wellness':
        return AppColors.pink;
      default:
        return AppColors.pinkSoft;
    }
  }

  Widget _buildCategory(String categoryName, List<Interest> items) {
    bool isExpanded = _categoryExpanded[categoryName] ?? false;

    int selectedCount = items
        .where((i) => _selectedInterests.contains(i))
        .length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _categoryExpanded[categoryName] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isExpanded
              ? AppColors.pinkSoft.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: isExpanded || selectedCount > 0
                ? AppColors.pinkDeep
                : AppColors.line,
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
                      color: _getCategoryColor(categoryName).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _getCategoryEmoji(categoryName),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryName,
                          style: AppText.body.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isExpanded || selectedCount > 0
                                ? AppColors.pinkDeep
                                : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedCount > 0
                              ? '$selectedCount selected'
                              : 'Select interests',
                          style: AppText.sub.copyWith(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selectedCount > 0
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: selectedCount > 0
                        ? AppColors.pinkDeep
                        : AppColors.line,
                    size: 24,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppColors.pinkDeep.withOpacity(0.2),
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: items.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest,
                        );
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest);
                              } else {
                                if (_selectedInterests.length < 10) {
                                  _selectedInterests.add(interest);
                                }
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.pinkDeep
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.pinkDeep
                                    : AppColors.line,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.pinkDeep.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  interest.emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  interest.label,
                                  style: AppText.body.copyWith(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.ink60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

    @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final grouped = _groupedInterests;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            AppDimens.pad,
            AppDimens.pad,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'YOUR INTERESTS',
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
                      '${_selectedInterests.length}/10',
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
                'Interests',
                style: AppText.display.copyWith(fontSize: 32),
              ),
              if (_selectedInterests.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE7DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Nothing picked yet — tap the interests below.',
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(
                        color: AppColors.ink60,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _buildSelectedInterests(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            16,
            AppDimens.pad,
            8,
          ),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              cursorColor: AppColors.pinkDeep,
              decoration: InputDecoration(
                hintText: 'Search interests...',
                hintStyle: AppText.body.copyWith(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.muted,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.line,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.pinkDeep,
                    width: 1.5,
                  ),
                ),
              ),
              style: AppText.body.copyWith(fontSize: 15),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                else if (grouped.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No interests found.',
                        style: AppText.body.copyWith(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  ...grouped.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCategory(entry.key, entry.value),
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
            20,
          ),
          child: PrimaryButton(
            _isSubmitting ? 'Saving...' : 'Continue',
            onTap: _selectedInterests.length >= 5 && !_isSubmitting
                ? () async {
                    setState(() => _isSubmitting = true);

                    // Save interests
                    userData.interests = _selectedInterests
                        .map((i) => {'label': i.label, 'emoji': i.emoji})
                        .toList();

                    // Simulate API
                    await Future.delayed(const Duration(seconds: 1));

                    if (mounted) {
                      setState(() => _isSubmitting = false);
                      widget.onNext();
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
