import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/services/edit_profile_api_service.dart';

class NetworkingIntentSection extends StatelessWidget {
  const NetworkingIntentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.diversity_3, // A networking-like icon
                      color: Color(0xFFE43A6A),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NETWORKING INTENT',
                      style: TextStyle(
                        color: Color(0xFFE43A6A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE43A6A), Color(0xFF5E2750)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'VIP & VIP Elite only',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WHAT YOU\'RE OPEN TO',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Shown only to VIP & VIP Elite members — never on the free & Premium side.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected Chips
                  if (state.networkingIntents.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: state.networkingIntents.map((intent) {
                        return _buildSelectedChip(
                          context,
                          intent,
                          state.networkingIntents,
                        );
                      }).toList(),
                    ),

                  if (state.networkingIntents.isNotEmpty)
                    const SizedBox(height: 16),
                    
                  if (state.networkingInYourWords.isNotEmpty) ...[
                    Text(
                      'IN YOUR WORDS',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        state.networkingInYourWords,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Add Button
                  GestureDetector(
                    onTap: () => _openNetworkingEditor(context, state),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.grey.shade700, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedChip(
    BuildContext context,
    String title,
    List<String> currentIntents,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F8), // Faint pink background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE43A6A).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE43A6A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              final newList = List<String>.from(currentIntents)..remove(title);
              context.read<ProfileEditCubit>().updateNetworkingIntents(newList);
            },
            child: const Icon(Icons.close, color: Color(0xFFE43A6A), size: 14),
          ),
        ],
      ),
    );
  }

  void _openNetworkingEditor(BuildContext context, ProfileEditState state) {
    final cubit = context.read<ProfileEditCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: _NetworkingEditorSheet(
            initialIntents: state.networkingIntents,
            initialWords: state.networkingInYourWords,
          ),
        ),
      ),
    );
  }
}

class _NetworkingEditorSheet extends StatefulWidget {
  final List<String> initialIntents;
  final String initialWords;

  const _NetworkingEditorSheet({
    required this.initialIntents,
    required this.initialWords,
  });

  @override
  State<_NetworkingEditorSheet> createState() => _NetworkingEditorSheetState();
}

class _NetworkingEditorSheetState extends State<_NetworkingEditorSheet> {
  late List<String> _selectedIntents;
  late TextEditingController _wordsController;
  bool _isLoading = true;

  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _rawSectionsData = [];

  @override
  void initState() {
    super.initState();
    _selectedIntents = List<String>.from(widget.initialIntents);
    _wordsController = TextEditingController(text: widget.initialWords);
    _fetchNetworkingIntents();
  }

  Future<void> _fetchNetworkingIntents() async {
    final data = await EditProfileApiService.getNetworkingIntents();
    if (data != null && mounted) {
      List<Map<String, dynamic>> parsedSections = [];
      for (var section in data) {
        final title = section['title']?.toString().toUpperCase() ?? '';
        final options = section['options'] as List<dynamic>? ?? [];
        List<String> items = [];
        for (var opt in options) {
          items.add(opt['label']?.toString() ?? '');
        }
        parsedSections.add({
          'title': title,
          'items': items,
        });
      }
      setState(() {
        _sections = parsedSections;
        _rawSectionsData = data;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _wordsController.dispose();
    super.dispose();
  }

  void _toggleIntent(String intent) {
    if (_selectedIntents.contains(intent)) {
      setState(() {
        _selectedIntents.remove(intent);
      });
    } else {
      if (_selectedIntents.length < 10) {
        setState(() {
          _selectedIntents.add(intent);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can select up to 10 intents.'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool _hasChanges() {
    if (_selectedIntents.length != widget.initialIntents.length) return true;
    for (var i in _selectedIntents) {
      if (!widget.initialIntents.contains(i)) return true;
    }
    if (_wordsController.text.trim() != widget.initialWords) return true;
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) {
        // Map selected labels back to option IDs and find questionKey
        List<String> selectedIds = [];
        String questionKey = 'favorites'; // fallback
        
        for (var section in _rawSectionsData) {
          if (section['key'] != null) {
             questionKey = section['key'].toString();
          } else if (section['questionKey'] != null) {
             questionKey = section['questionKey'].toString();
          }
          final options = section['options'] as List<dynamic>? ?? [];
          for (var opt in options) {
            final label = opt['label']?.toString() ?? '';
            final id = opt['id']?.toString() ?? '';
            if (_selectedIntents.contains(label) && id.isNotEmpty) {
              selectedIds.add(id);
            }
          }
        }

        debugPrint('🚀 Sending Networking Intent: questionKey=$questionKey, optionIds=$selectedIds, desc=${_wordsController.text.trim()}');

        // Call the PATCH API
        await EditProfileApiService.updateAnswers(
          questionKey: questionKey,
          optionIds: selectedIds,
          description: _wordsController.text.trim(),
        );

        if (!mounted) return false;

        context.read<ProfileEditCubit>().updateNetworkingIntents(
          _selectedIntents,
        );
        context.read<ProfileEditCubit>().updateNetworkingInYourWords(
          _wordsController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Color(0xFFE43A6A),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
      return false; // Already handled pop
    }
    return result == false; // Pop without saving
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () async {
                if (await _onWillPop()) {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 16,
                ),
              ),
            ),
          ),
          title: const Text(
            'Networking intent',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading 
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE43A6A),
                ),
              )
            : ListView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: bottomInset > 0 ? bottomInset + 24 : 40,
          ),
          children: [
            ..._sections.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: (section['items'] as List<String>).map((item) {
                      final isSelected = _selectedIntents.contains(item);
                      return GestureDetector(
                        onTap: () => _toggleIntent(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE43A6A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE43A6A)
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE43A6A,
                                      ).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            }).toList(),

            // In Your Words Section
            Text(
              'IN YOUR WORDS (OPTIONAL)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wordsController,
              maxLines: 4,
              maxLength: 120,
              cursorColor: const Color(0xFFE43A6A),
              decoration: InputDecoration(
                hintText:
                    'e.g. Happy to swap notes on building a brand - coffee over pitch decks.',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
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
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileEditCubit>().updateNetworkingIntents(
                    _selectedIntents,
                  );
                  context.read<ProfileEditCubit>().updateNetworkingInYourWords(
                    _wordsController.text.trim(),
                  );


                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE43A6A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
