import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';

class ProfessionScreen extends StatefulWidget {
  const ProfessionScreen({super.key});

  @override
  State<ProfessionScreen> createState() => _ProfessionScreenState();
}

class _ProfessionScreenState extends State<ProfessionScreen> {
  final List<String> _selectedProfession = [];

  final Map<String, List<String>> _professionCategories = {
    'TECH & PRODUCT': [
      'Software engineer', 'Tech lead', 'Engineering manager', 'Product manager', 
      'Data scientist', 'Data analyst', 'DevOps engineer', 'QA engineer', 
      'UI / UX designer', 'Civil engineer', 'Mechanical engineer', 'Electrical engineer'
    ],
    'HEALTHCARE': [
      'Doctor (MBBS)', 'Surgeon', 'Dentist', 'Physiotherapist', 'Nurse', 
      'Psychologist', 'Pharmacist', 'Veterinarian'
    ],
    'FINANCE & BUSINESS': [
      'Chartered accountant', 'Company secretary', 'Investment banker', 
      'Financial analyst', 'Auditor', 'Management consultant', 
      'Business analyst', 'Founder / entrepreneur', 'Marketing manager', 
      'Sales manager', 'HR manager', 'Operations manager'
    ],
    'LAW & PUBLIC SERVICE': [
      'Lawyer / advocate', 'Judge', 'IAS / IPS officer', 'Armed forces officer', 
      'Police officer', 'Government officer', 'Social worker'
    ],
    'CREATIVE': [
      'Graphic designer', 'Interior designer', 'Architect', 'Fashion designer', 
      'Photographer', 'Filmmaker', 'Content writer', 'Journalist', 
      'Musician', 'Actor'
    ],
    'ACADEMIA & OTHER': [
      'Professor', 'School teacher', 'Scientist / researcher', 'Pilot', 
      'Cabin crew', 'Chef', 'Hotel manager', 'Fitness trainer', 
      'Sportsperson', 'Freelancer', 'Student', 'Between jobs'
    ],
  };

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _selectedProfession.addAll(currentState.profession);
  }

  void _onDone() {
    context.read<FilterBloc>().add(UpdateProfession(_selectedProfession.toList()));
    Navigator.pop(context);
  }

  void _toggleProfession(String item) {
    setState(() {
      if (_selectedProfession.contains(item)) {
        _selectedProfession.remove(item);
      } else {
        _selectedProfession.add(item);
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
              _selectedProfession.isEmpty ? 'ANY' : '${_selectedProfession.length} SELECTED',
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

  Widget _buildCategory(String categoryName, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
          child: Text(
            categoryName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 12.0,
            children: items.map((item) {
              final isSelected = _selectedProfession.contains(item);
              return GestureDetector(
                onTap: () => _toggleProfession(item),
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
                    item,
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
        ),
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
          'Profession',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(),
              ..._professionCategories.entries.map((entry) => _buildCategory(entry.key, entry.value)),
              const SizedBox(height: 12),
              _buildInfoCard(
                '💼',
                'Verified employers show a badge',
                'Profession verification adds +8 to a member’s trust score.',
              ),
              _buildInfoCard(
                '✨',
                'Keep it broad',
                'Pick a field or two — filtering on one role hides good matches.',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
