import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';
import '../service/service_filter.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final List<String> _selectedLifestyle = [];

  bool _isLoading = true;
  final Map<String, List<Map<String, dynamic>>> _parsedCategories = {};

  Future<void> _fetchOptions() async {
    final data = await ServiceFilter.fetchLifestyleOptions();
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
    
    if (data.isNotEmpty && data[0] is Map && (data[0].containsKey('options') || data[0].containsKey('lifestyle'))) {
      for (var category in data) {
        String catName = category['title'] ?? category['name'] ?? category['category'] ?? 'Lifestyle';
        List options = category['options'] ?? category['lifestyle'] ?? [];
        List<Map<String, dynamic>> parsedOptions = [];
        
        for (var opt in options) {
          if (opt is Map) {
            String id = opt['id']?.toString() ?? '';
            String name = opt['label'] ?? opt['name'] ?? opt['title'] ?? opt['option'] ?? opt['value'] ?? 'Unknown';
            parsedOptions.add({'id': id, 'name': name});
          }
        }
        if (parsedOptions.isNotEmpty) {
          _parsedCategories[catName.toUpperCase()] = parsedOptions;
        }
      }
    } 
    else if (data.isNotEmpty && data[0] is Map) {
      List<Map<String, dynamic>> parsedOptions = [];
      for (var opt in data) {
        String id = opt['id']?.toString() ?? '';
        String name = opt['label'] ?? opt['name'] ?? opt['title'] ?? opt['option'] ?? opt['value'] ?? 'Unknown';
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
    _selectedLifestyle.addAll(currentState.lifestyle);
  }

  void _onDone() {
    context.read<FilterBloc>().add(UpdateLifestyle(_selectedLifestyle.toList()));
    Navigator.pop(context);
  }

  void _toggleLifestyle(String item) {
    setState(() {
      if (_selectedLifestyle.contains(item)) {
        _selectedLifestyle.remove(item);
      } else {
        _selectedLifestyle.add(item);
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
          Container(
            margin: const EdgeInsets.only(top: 2), // visually align with text
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6), // Soft gold bg for badge
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _selectedLifestyle.isEmpty ? 'ANY' : '${_selectedLifestyle.length} SELECTED',
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

  Widget _buildLifestyleChips(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 12.0,
      children: items.map((item) {
        // Store as ID|Name for FilterState parsing
        final id = item['id'] as String;
        final name = item['name'] as String;
        final optionStr = '$id|$name';
        
        final isSelected = _selectedLifestyle.contains(optionStr);
        return GestureDetector(
          onTap: () => _toggleLifestyle(optionStr),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
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
          'Lifestyle',
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A)))
        : _parsedCategories.isEmpty
            ? const Center(child: Text("No lifestyle options found."))
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
                              _buildLifestyleChips(entry.value),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        '🥗',
                        'Be authentic',
                        'Sharing your lifestyle helps find people with similar habits.',
                      ),
                      _buildInfoCard(
                        '✨',
                        'Update anytime',
                        'Your lifestyle changes, and so can these filters.',
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }
}
