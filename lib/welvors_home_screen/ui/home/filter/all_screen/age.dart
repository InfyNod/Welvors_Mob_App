import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  late RangeValues _currentRangeValues;
  final List<String> _predefinedRanges = ['24-30', '26-34', '28-38', '30-45'];
  String _selectedRange = '';

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _currentRangeValues = RangeValues(currentState.minAge, currentState.maxAge);

    final matchingRange =
        '${currentState.minAge.round()}-${currentState.maxAge.round()}';
    if (_predefinedRanges.contains(matchingRange)) {
      _selectedRange = matchingRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .white, // Or a very light grey if preferred, looks white in mockup
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
          'Age',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                context.read<FilterBloc>().add(
                  UpdateAgeRange(
                    _currentRangeValues.start,
                    _currentRangeValues.end,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Age Range Display Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F2), // Light peach/orange background
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Text(
                    'AGE RANGE',
                    style: TextStyle(
                      color: Color(0xFFE67E22), // Orange text
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentRangeValues.start.round()} – ${_currentRangeValues.end.round()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Times New Roman', // Mockup uses a serif font
                      color: Colors.black87,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_currentRangeValues.end - _currentRangeValues.start).round()}-year window · same life stage',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Slider
            // Premium Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFE43A6A),
                inactiveTrackColor: Colors.grey.shade100,
                trackHeight: 6.0, // Thicker premium track
                thumbColor: Colors.white,
                overlayColor: const Color(0xFFE43A6A).withOpacity(0.15),
                rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 11, // Smaller premium thumb
                  elevation: 4,
                  pressedElevation: 8,
                ),
              ),
              child: RangeSlider(
                values: _currentRangeValues,
                min: 18,
                max: 60,
                divisions: 42,
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                    final matchingRange = '${values.start.round()}-${values.end.round()}';
                    if (_predefinedRanges.contains(matchingRange)) {
                      _selectedRange = matchingRange;
                    } else {
                      _selectedRange = '';
                    }
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
                    '18',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                  Text(
                    '40',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                  Text(
                    '60+',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Predefined Chips
            // Premium Snake-Effect Segmented Chips
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth =
                      constraints.maxWidth / _predefinedRanges.length;
                  final selectedIndex = _predefinedRanges.indexOf(
                    _selectedRange,
                  );

                  return Stack(
                    children: [
                      // Sliding background (Snake effect)
                      if (selectedIndex != -1)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: selectedIndex * itemWidth,
                          top: 0,
                          bottom: 0,
                          width: itemWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE43A6A),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE43A6A,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Text Labels
                      Row(
                        children: _predefinedRanges.map((range) {
                          final isSelected = _selectedRange == range;
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _selectedRange = range;
                                  final parts = range.split('-');
                                  _currentRangeValues = RangeValues(
                                    double.parse(parts[0]),
                                    double.parse(parts[1]),
                                  );
                                });
                              },
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  child: Text(range),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Info Card 1
            _buildInfoCard(
              icon: Icons.auto_awesome,
              iconColor: Colors.amber.shade600,
              title: 'Most matches happen within 4 years',
              subtitle:
                  'Members with a similar age window reply far more often.',
            ),
            const SizedBox(height: 12),

            // Info Card 2
            _buildInfoCard(
              icon: Icons.lock,
              iconColor: Colors.grey.shade500,
              title: 'Your exact birth date stays private',
              subtitle:
                  'Only your age shows on your profile — never the full date.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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
}
