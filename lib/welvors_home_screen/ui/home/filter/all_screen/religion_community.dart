import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';
import '../service/service_filter.dart';

class ReligionCommunityScreen extends StatefulWidget {
  const ReligionCommunityScreen({super.key});

  @override
  State<ReligionCommunityScreen> createState() => _ReligionCommunityScreenState();
}

class _ReligionCommunityScreenState extends State<ReligionCommunityScreen> {
  final List<String> _selectedReligion = [];

  bool _isLoading = true;
  List<dynamic> _apiData = [];
  
  // Example structure we might build:
  // _parsedReligions = [{'id': '1', 'name': 'Hindu', 'communities': [{'id':'2', 'name':'Brahmin'}]}]
  final List<Map<String, dynamic>> _parsedReligions = [];
  
  // We'll store religion IDs without prefix for easier checking
  // _selectedReligion will contain things like 'R|id|name' or 'C|id|name'


  Future<void> _fetchOptions() async {
    final data = await ServiceFilter.fetchReligionOptions();
    if (data != null && mounted) {
      _parseData(data);
      setState(() {
        _apiData = data;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseData(List<dynamic> data) {
    _parsedReligions.clear();
    // For now just dumping the structure to help understand it:
    debugPrint('====== RELIGION PARSER INPUT ======');
    debugPrint(data.toString());
    
    // We will assume the API returns a list of objects with 'name' and possibly nested 'community' or 'caste' or 'options'
    for (var rel in data) {
      if (rel is Map) {
        String id = rel['id']?.toString() ?? '';
        String name = rel['name'] ?? rel['title'] ?? rel['label'] ?? 'Unknown';
        
        List communities = rel['communities'] ?? rel['community'] ?? rel['options'] ?? rel['castes'] ?? rel['caste'] ?? [];
        List<Map<String, dynamic>> parsedCommunities = [];
        for (var c in communities) {
          if (c is Map) {
            String cid = c['id']?.toString() ?? '';
            String cname = c['name'] ?? c['title'] ?? c['label'] ?? 'Unknown';
            parsedCommunities.add({'id': cid, 'name': cname});
          }
        }
        
        _parsedReligions.add({
          'id': id,
          'name': name,
          'communities': parsedCommunities
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();
    final currentState = context.read<FilterBloc>().state;
    _selectedReligion.addAll(currentState.religion);
  }

  void _onDone() {
    context.read<FilterBloc>().add(UpdateReligion(_selectedReligion.toList()));
    Navigator.pop(context);
  }

  void _toggleReligion(String option) {
    setState(() {
      if (_selectedReligion.contains(option)) {
        _selectedReligion.remove(option);
      } else {
        _selectedReligion.add(option);
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
              _selectedReligion.isEmpty ? 'ANY' : '${_selectedReligion.length} SELECTED',
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

  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 12.0,
        children: _parsedReligions.map((rel) {
          final id = rel['id']?.toString() ?? '';
          final name = rel['name'] as String;
          final optionStr = 'R|$id|$name';
          
          final isSelected = _selectedReligion.contains(optionStr);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedReligion.remove(optionStr);
                  // Also remove all communities belonging to this religion
                  final comms = rel['communities'] as List;
                  for (var c in comms) {
                    final cid = c['id']?.toString() ?? '';
                    final cname = c['name'] as String;
                    _selectedReligion.remove('C|$cid|$cname');
                  }
                } else {
                  _selectedReligion.add(optionStr);
                }
              });
            },
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
                          color: const Color(0xFFE43A6A).withOpacity(0.3),
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
      ),
    );
  }

  Widget _buildCommunitiesSection() {
    // Find all selected religions that have communities
    final List<Map<String, dynamic>> selectedReligionsWithComms = [];
    for (var rel in _parsedReligions) {
      final id = rel['id']?.toString() ?? '';
      final name = rel['name'] as String;
      final optionStr = 'R|$id|$name';
      if (_selectedReligion.contains(optionStr)) {
        final comms = rel['communities'] as List;
        if (comms.isNotEmpty) {
          selectedReligionsWithComms.add(rel);
        }
      }
    }

    if (selectedReligionsWithComms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Caste / community',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'OPTIONAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...selectedReligionsWithComms.map((rel) {
          final relName = rel['name'] as String;
          final comms = rel['communities'] as List;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 12.0,
                  children: comms.map((c) {
                    final cid = c['id']?.toString() ?? '';
                    final cname = c['name'] as String;
                    final commOptionStr = 'C|$cid|$cname';
                    
                    final isSelected = _selectedReligion.contains(commOptionStr);

                    return GestureDetector(
                      onTap: () => _toggleReligion(commOptionStr),
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
                                    color: const Color(0xFFE43A6A).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          cname,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
                      color: Colors.black.withOpacity(0.04),
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
          'Religion & community',
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
        : _parsedReligions.isEmpty
            ? const Center(child: Text("No religions found."))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader(),
                      _buildChips(),
                      _buildCommunitiesSection(),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        '🕊️',
                        'Pick a religion to add community',
                        'Caste or sect options appear once you choose Hindu, Muslim, Sikh, Christian, Jain or Buddhist.',
                      ),
                      _buildInfoCard(
                        '🕊️',
                        'Faith is optional to share',
                        'Many members keep this private — select more than one if you are open.',
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }
}
