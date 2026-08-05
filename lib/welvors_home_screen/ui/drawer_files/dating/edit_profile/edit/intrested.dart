import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/onbording_allpage/features/onboarding/interests_screen.dart'
    show Interest;
import 'package:velvors/onbording_allpage/services/api_service.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/services/edit_profile_api_service.dart';

class InterestsSection extends StatelessWidget {
  const InterestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Color(0xFFE43A6A), size: 16),
                SizedBox(width: 8),
                Text(
                  "INTERESTS & HOBBIES",
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...state.interests.map((interestText) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          interestText,
                          style: const TextStyle(
                            color: Color(0xFFE43A6A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            final newList = List<String>.from(state.interests)
                              ..remove(interestText);
                            context.read<ProfileEditCubit>().updateInterests(
                              newList,
                            );
                          },
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFFE43A6A),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (state.interests.length < 10)
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditInterestsPickerScreen(
                            initialSelected: state.interests,
                          ),
                        ),
                      );
                      if (result != null && context.mounted) {
                        context.read<ProfileEditCubit>().updateInterests(
                          result,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE43A6A).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Color(0xFFE43A6A), size: 16),
                          SizedBox(width: 4),
                          Text(
                            "Add interest",
                            style: TextStyle(
                              color: Color(0xFFE43A6A),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class EditInterestsPickerScreen extends StatefulWidget {
  final List<String> initialSelected;

  const EditInterestsPickerScreen({super.key, required this.initialSelected});

  @override
  State<EditInterestsPickerScreen> createState() =>
      _EditInterestsPickerScreenState();
}

class _EditInterestsPickerScreenState extends State<EditInterestsPickerScreen> {
  final Set<Interest> _selectedInterests = {};
  String _searchQuery = '';
  final Map<String, bool> _categoryExpanded = {};

  List<Interest> _allInterests = [];
  bool _isLoading = true;

  final Color _pinkDeep = const Color(0xFFE43A6A);
  final Color _pinkSoft = const Color(0xFFFDE8EF);

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
        
        for (var interest in _allInterests) {
          final formattedStr = '${interest.emoji} ${interest.label}';
          if (widget.initialSelected.contains(formattedStr)) {
            _selectedInterests.add(interest);
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'creativity':
        return _pinkDeep;
      case 'fan favorites':
        return Colors.amber;
      case 'food & drink':
        return Colors.green;
      case 'travel & outdoors':
        return Colors.blue;
      case 'gaming':
        return Colors.blueGrey;
      case 'wellness':
        return Colors.pinkAccent;
      default:
        return _pinkSoft;
    }
  }

  bool _hasUnsavedChanges() {
    final current = _selectedInterests
        .map((i) => '${i.emoji} ${i.label}')
        .toList();
    if (current.length != widget.initialSelected.length) return true;
    for (var val in current) {
      if (!widget.initialSelected.contains(val)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedInterests;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(context, 'Edit Interests', () async {
          if (_hasUnsavedChanges()) {
            final result = await showUnsavedChangesDialog(context);
            if (result == true) {
              // Save
              final savedResult = _selectedInterests
                  .map((i) => '${i.emoji} ${i.label}')
                  .toList();
              Navigator.pop(context, savedResult);
              return false;
            } else if (result == false) {
              // Discard
              Navigator.pop(context);
              return false;
            }
            return false; // Cancelled
          }
          return true;
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Container(
                height: 48, // Reduced height
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // Distinct from white background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 1.0),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  cursorColor: _pinkDeep,
                  decoration: InputDecoration(
                    hintText: 'Search for hobbies, sports, etc.',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        Icons.search_rounded,
                        color:
                            Colors.grey.shade500, // Kept grey for softer look
                        size: 20, // Slightly smaller icon
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ), // Reduced padding
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    'Selected ${_selectedInterests.length}/10',
                    style: TextStyle(
                      color: _selectedInterests.length == 10
                          ? Colors.red
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSelectedInterests(),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _pinkDeep,
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
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: GestureDetector(
                onTap: () async {
                  setState(() => _isLoading = true);
                  
                  // Group selected interests by questionKey
                  final Map<String, List<String>> patches = {};
                  for (var interest in _selectedInterests) {
                    if (!patches.containsKey(interest.questionKey)) {
                      patches[interest.questionKey] = [];
                    }
                    patches[interest.questionKey]!.add(interest.id);
                  }
                  
                  // Handle empty selections for categories that were unselected
                  final allCategoryKeys = _allInterests.map((e) => e.questionKey).toSet();
                  for (var key in allCategoryKeys) {
                    if (!patches.containsKey(key)) {
                      patches[key] = []; 
                    }
                  }

                  String? firstError;
                  for (var entry in patches.entries) {
                    final error = await EditProfileApiService.updateProfileAnswer(
                      questionKey: entry.key,
                      optionIds: entry.value,
                    );
                    if (error != null && firstError == null) {
                      firstError = error;
                    }
                  }
                  
                  if (mounted) {
                    setState(() => _isLoading = false);
                    if (firstError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(firstError)),
                      );
                    } else {
                      final result = _selectedInterests
                          .map((i) => '${i.emoji} ${i.label}')
                          .toList();
                      Navigator.pop(context, result);
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
                        color: _pinkDeep.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedInterests() {
    if (_selectedInterests.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: _selectedInterests.toList().reversed.map((interest) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _pinkDeep,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _pinkDeep.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(interest.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    interest.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedInterests.remove(interest)),
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
    );
  }

  Widget _buildCategory(String categoryName, List<Interest> items) {
    bool isExpanded = _categoryExpanded[categoryName] ?? false;
    int selectedCount = items
        .where((i) => _selectedInterests.contains(i))
        .length;

    return GestureDetector(
      onTap: () =>
          setState(() => _categoryExpanded[categoryName] = !isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isExpanded ? _pinkSoft.withOpacity(0.4) : Colors.white,
          border: Border.all(
            color: isExpanded || selectedCount > 0
                ? _pinkDeep
                : Colors.grey.shade200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isExpanded
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                      items.isNotEmpty ? items.first.emoji : '✨',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (selectedCount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$selectedCount selected',
                            style: TextStyle(
                              color: _pinkDeep,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isExpanded ? _pinkDeep : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items.map((interest) {
                    bool isSelected = _selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            if (_selectedInterests.length < 10) {
                              _selectedInterests.add(interest);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You can select up to 10 interests',
                                  ),
                                ),
                              );
                            }
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? _pinkDeep : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? _pinkDeep
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _pinkDeep.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          interest.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
