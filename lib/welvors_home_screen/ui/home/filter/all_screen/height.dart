import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _currentRangeValues = RangeValues(
      (currentState.minHeight ?? 152.0).clamp(91.0, 244.0),
      (currentState.maxHeight ?? 183.0).clamp(91.0, 244.0),
    );
  }

  String _formatHeight(double cm) {
    int totalInches = (cm / 2.54).round();
    int feet = totalInches ~/ 12;
    int inches = totalInches % 12;
    return "$feet'$inches\"";
  }

  void _onUseThisRange() {
    context.read<FilterBloc>().add(
      UpdateHeightRange(_currentRangeValues.start, _currentRangeValues.end),
    );
    Navigator.pop(context);
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Row(
        children: [
          const Text(
            'Set your range',
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
              color: const Color(0xFFFFF9E6), // Soft gold bg for badge
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'CUSTOM',
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

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6F4), // Light peach/pink background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF3D7DF), // Pink border
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${_formatHeight(_currentRangeValues.start)} – ${_formatHeight(_currentRangeValues.end)}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Times New Roman',
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentRangeValues.start.round()} - ${_currentRangeValues.end.round()} cm',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 0),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFE43A6A),
              inactiveTrackColor: Colors.grey.shade300,
              trackHeight: 6.0,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFFE43A6A).withValues(alpha: 0.15),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 11,
                elevation: 4,
                pressedElevation: 8,
              ),
            ),
            child: RangeSlider(
              values: _currentRangeValues,
              min: 91.0,
              max: 244.0,
              divisions: 153, // 244 - 91
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),

          // Slider Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3\'0"',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  '5\'6"',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  '8\'0"',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onUseThisRange,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Use this range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
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
          'Height',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(),
              _buildMainCard(),
              const SizedBox(height: 24),
              _buildInfoCard(
                '📏',
                'Drag both ends',
                'Set the shortest and tallest height you are open to — in feet or cm.',
              ),
              _buildInfoCard(
                '✨',
                'Keep it a little wide',
                'A 6-8 inch window shows far more profiles than an exact height.',
              ),
              _buildInfoCard(
                '🔒',
                'Self-reported',
                'Height is not verified, so treat it as a guide, not a rule.',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
