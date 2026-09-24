import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';
import 'package:http/http.dart' as __http;
import 'dart:convert' as dart_convert;
import '../service/service_filter.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class LookingForScreen extends StatefulWidget {
  const LookingForScreen({super.key});

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  final Set<String> _selectedOptions = {};
  List<Map<String, dynamic>> _options = [];

  bool _isLoading = true;
  String _headerTitle = "What are you here for?";
  String _headerSubtitle = "However you love, you belong here";

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _selectedOptions.addAll(currentState.lookingFor);
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final data = await ServiceFilter.fetchLookingForOptions();
      
      if (data != null) {
        if (mounted) {
          setState(() {
            _headerTitle = data['title'];
            _headerSubtitle = data['subtitle'];
            _options = data['options'];
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      AppLogger.e('LookingForScreen', '====== [LOOKING FOR API ERROR] ======');
      AppLogger.e('LookingForScreen', e);
    }
    
    // Fallback if failed
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDone() {
    context.read<FilterBloc>().add(UpdateLookingFor(_selectedOptions.toList()));
    Navigator.pop(context);
  }

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1FD), // Light purple bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFECD9F5), // Light purple border from RGBA(236, 217, 245)
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🌐', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free & Premium pool',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6E3191),
                  ),
                ),
                Text(
                  'Matched only with Free & Premium members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _headerTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PICK ANY',
              style: TextStyle(
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

  Widget _buildOptionCard(Map<String, dynamic> option) {
    final id = option['id'] as String;
    final title = option['title'] as String;
    final subtitle = option['subtitle'] as String;
    final iconText = option['icon'] as String;
    final iconBgColor = option['iconBgColor'] as Color;
    
    final optionKey = '$id|$title';
    final isSelected = _selectedOptions.contains(optionKey);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedOptions.remove(optionKey);
          } else {
            _selectedOptions.add(optionKey);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE43A6A).withOpacity(0.04) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFE43A6A).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                iconText,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 8),
            child: Text('💬', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Honesty gets better matches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Members with matching intent reply nearly twice as often.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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
          'Looking for',
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
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopCard(),
              const SizedBox(height: 16),
              _buildSectionHeader(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A))),
                )
              else if (_options.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text("No options found")),
                )
              else
                ..._options.map((opt) => _buildOptionCard(opt)).toList(),
              _buildInfoCard(),
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
