import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart'; // For GenericListPickerScreen
import 'package:velvors/onbording_allpage/services/api_service.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/services/edit_profile_api_service.dart';

class LifestyleSection extends StatefulWidget {
  const LifestyleSection({super.key});

  @override
  State<LifestyleSection> createState() => _LifestyleSectionState();
}

class _LifestyleSectionState extends State<LifestyleSection> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

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
                  Icons.wine_bar,
                  color: Color(0xFFE43A6A),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  "LIFESTYLE",
                  style: TextStyle(
                    color: Color(0xFFE43A6A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE43A6A))),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < _questions.length; i++) ...[
                          _buildDynamicListItem(context, state, _questions[i]),
                          if (i < _questions.length - 1) _buildDivider(),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDynamicListItem(
      BuildContext context, ProfileEditState state, Map<String, dynamic> q) {
    final String qId = q['id'];
    final String title = q['title'] ?? '';
    final bool isMulti = (q['isMulti'] == true) || (title.toLowerCase() == 'pets');
    final List<dynamic> options = q['options'] ?? [];

    // Find saved answers in state.lifestyle
    List<String> currentValues = [];
    for (var item in state.lifestyle) {
      if (item['question'] == title) {
        if (item['option'] != null) {
          currentValues.add(item['option'].toString());
        }
      }
    }

    final List<String> optionLabels =
        options.map((e) => e['label'].toString()).toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (isMulti) {
          final String qKey = q['key'] ?? '';
          _showMultiSelectBottomSheet(
              context, qKey, title, options, currentValues);
        } else {
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => GenericListPickerScreen(
                title: 'Select ${title.toLowerCase()}',
                headerText: title,
                subHeaderText: 'Please select one from the list',
                options: optionLabels,
                currentValue: currentValues.isNotEmpty ? currentValues.first : '',
              ),
            ),
          );
          if (result != null && mounted) {
            String? optionId;
            for (var opt in options) {
              if (opt['label'] == result) {
                optionId = opt['id'];
                break;
              }
            }
            if (optionId != null) {
              final String qKey = q['key'] ?? '';
              final error = await EditProfileApiService.updateProfileAnswer(
                  questionKey: qKey, optionIds: [optionId]);
              if (error == null && mounted) {
                context.read<ProfileEditCubit>().loadProfile();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error ?? 'Failed to save')));
              }
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isMulti && currentValues.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentValues.map((val) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE43A6A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            val,
                            style: const TextStyle(
                              color: Color(0xFFE43A6A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      currentValues.isEmpty
                          ? 'Add $title'
                          : currentValues.first,
                      style: TextStyle(
                        color: currentValues.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectBottomSheet(
      BuildContext context,
      String qKey,
      String title,
      List<dynamic> options,
      List<String> currentValues) {
    List<String> tempSelectedValues = List.from(currentValues);
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                  left: 24,
                  right: 24,
                  top: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Select $title',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMsg ?? 'Select up to 3 options.',
                      style: TextStyle(
                        fontSize: 14,
                        color: errorMsg != null ? Colors.red : Colors.black54,
                        fontWeight: errorMsg != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: options.map((opt) {
                        final String label = opt['label'];
                        final isSelected = tempSelectedValues.contains(label);
                        return GestureDetector(
                          onTap: () {
                            if (!isSelected && tempSelectedValues.length >= 3) {
                              setModalState(() {
                                errorMsg = 'You can only select up to 3 options.';
                              });
                              return;
                            }
                            setModalState(() {
                              errorMsg = null; // Clear error on valid action
                              if (isSelected) {
                                tempSelectedValues.remove(label);
                              } else {
                                tempSelectedValues.add(label);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE43A6A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE43A6A)
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE43A6A)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          List<String> optionIds = [];
                          for (var opt in options) {
                            if (tempSelectedValues.contains(opt['label'])) {
                              optionIds.add(opt['id']);
                            }
                          }
                          final error = await EditProfileApiService.updateProfileAnswer(
                              questionKey: qKey, optionIds: optionIds);
                          if (error == null && mounted) {
                            this.context.read<ProfileEditCubit>().loadProfile();
                          } else if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text(error ?? 'Failed to save')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE43A6A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }
}
