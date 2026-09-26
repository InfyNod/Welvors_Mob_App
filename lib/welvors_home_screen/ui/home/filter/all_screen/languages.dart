import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';
import '../service/service_filter.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final List<String> _selectedLanguages = [];

  bool _isLoading = true;

  // We'll store parsed categories here for rendering
  final Map<String, List<Map<String, dynamic>>> _parsedCategories = {};

  Future<void> _fetchOptions() async {
    final data = await ServiceFilter.fetchLanguages();
    if (data != null && mounted) {
      _parseData(data);
      setState(() {
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseData(List<dynamic> data) {
    _parsedCategories.clear();

    // Attempt to guess the structure
    // Case 1: List of categories with nested options (like lookingFor)
    if (data.isNotEmpty &&
        data[0] is Map &&
        (data[0].containsKey('options') || data[0].containsKey('languages'))) {
      for (var category in data) {
        String catName =
            category['title'] ??
            category['name'] ??
            category['category'] ??
            'Languages';
        List options = category['options'] ?? category['languages'] ?? [];
        List<Map<String, dynamic>> parsedOptions = [];

        for (var opt in options) {
          if (opt is Map) {
            String id = opt['id']?.toString() ?? '';
            String name =
                opt['name'] ??
                opt['title'] ??
                opt['option'] ??
                opt['language'] ??
                'Unknown';
            parsedOptions.add({'id': id, 'name': name});
          }
        }
        if (parsedOptions.isNotEmpty) {
          _parsedCategories[catName.toUpperCase()] = parsedOptions;
        }
      }
    }
    // Case 2: Flat list of languages
    else if (data.isNotEmpty && data[0] is Map) {
      List<Map<String, dynamic>> parsedOptions = [];
      for (var opt in data) {
        String id = opt['id']?.toString() ?? '';
        String name =
            opt['name'] ??
            opt['title'] ??
            opt['option'] ??
            opt['language'] ??
            'Unknown';
        parsedOptions.add({'id': id, 'name': name});
      }
      _parsedCategories[''] = parsedOptions;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();
    final currentState = context.read<FilterBloc>().state;
    _selectedLanguages.addAll(currentState.languages);
  }

  void _onDone() {
    context.read<FilterBloc>().add(
      UpdateLanguages(_selectedLanguages.toList()),
    );
    Navigator.pop(context);
  }

  void _toggleLanguage(String language) {
    setState(() {
      if (_selectedLanguages.contains(language)) {
        _selectedLanguages.remove(language);
      } else {
        _selectedLanguages.add(language);
      }
    });
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Select all that apply',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          if (_selectedLanguages.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 2), // visually align with text
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6), // Soft gold bg for badge
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_selectedLanguages.length} SELECTED',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageChips(List<Map<String, dynamic>> languages) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 12.0,
      children: languages.map((lang) {
        // Store as ID|Name for FilterState parsing
        final id = lang['id'] as String;
        final name = lang['name'] as String;
        final optionStr = '$id|$name';

        final isSelected = _selectedLanguages.contains(optionStr);
        return GestureDetector(
          onTap: () => _toggleLanguage(optionStr),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
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
                        color: const Color(0xFFE43A6A).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard(String icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Languages',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
            )
          : _parsedCategories.isEmpty
          ? const Center(child: Text("No languages found."))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(),
                    ..._parsedCategories.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.key.isNotEmpty) ...[
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            _buildLanguageChips(entry.value),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      '🗣️',
                      'Shared language, easier start',
                      'Members who share a mother tongue reply noticeably more often.',
                    ),
                    _buildInfoCard(
                      '✨',
                      'Pick two or three',
                      'Too many selections makes the filter meaningless — too few narrows the pool.',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
