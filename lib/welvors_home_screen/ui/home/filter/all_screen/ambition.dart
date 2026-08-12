import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';

class AmbitionScreen extends StatefulWidget {
  const AmbitionScreen({super.key});

  @override
  State<AmbitionScreen> createState() => _AmbitionScreenState();
}

class _AmbitionScreenState extends State<AmbitionScreen> {
  final List<String> _selectedAmbition = [];

  final List<String> _ambitionOptions = [
    'Founder', 'Executive', 'Creator', 'Investor'
  ];

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _selectedAmbition.addAll(currentState.ambition);
  }

  void _onDone() {
    context.read<FilterBloc>().add(UpdateAmbition(_selectedAmbition.toList()));
    Navigator.pop(context);
  }

  void _toggleAmbition(String item) {
    setState(() {
      if (_selectedAmbition.contains(item)) {
        _selectedAmbition.remove(item);
      } else {
        _selectedAmbition.add(item);
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
              _selectedAmbition.isEmpty ? 'ANY' : '${_selectedAmbition.length} SELECTED',
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
          'Ambition',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 12.0,
                  children: _ambitionOptions.map((item) {
                    final isSelected = _selectedAmbition.contains(item);
                    return GestureDetector(
                      onTap: () => _toggleAmbition(item),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
