import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';
import '../service/service_filter.dart';

class IncomeRangeScreen extends StatefulWidget {
  const IncomeRangeScreen({super.key});

  @override
  State<IncomeRangeScreen> createState() => _IncomeRangeScreenState();
}

class _IncomeRangeScreenState extends State<IncomeRangeScreen> {
  double _minIncome = 5.0;
  double _maxIncome = 200.0;
  List<Map<String, dynamic>> _apiRanges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<FilterBloc>().state;
    _minIncome = state.minIncome;
    _maxIncome = state.maxIncome;
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ServiceFilter.fetchFamilyIncomes();
    if (mounted) {
      setState(() {
        _apiRanges = data;
        // Sort by priority if needed
        _apiRanges.sort(
          (a, b) => (a['priority'] as int? ?? 0).compareTo(
            b['priority'] as int? ?? 0,
          ),
        );
        _isLoading = false;
      });
    }
  }

  String _formatIncome(double value) {
    if (value >= 100) {
      if (value == 200) {
        return '₹2 Cr';
      }
      return '₹${(value / 100).toStringAsFixed(value % 100 == 0 ? 0 : 1)} Cr';
    } else {
      return '₹${value.toInt()} L';
    }
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
          'Income range',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                context.read<FilterBloc>().add(
                  UpdateIncomeRange(_minIncome, _maxIncome),
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
            // Income Range Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Mycolor.purpleLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Mycolor.purple.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Text(
                    'THEIR ANNUAL INCOME',
                    style: TextStyle(
                      color: Mycolor.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatIncome(_minIncome)} - ${_formatIncome(_maxIncome)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Times New Roman',
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Show members earning ${_formatIncome(_minIncome)} - ${_formatIncome(_maxIncome)} a year',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFE43A6A),
                inactiveTrackColor: Colors.grey.shade100,
                trackHeight: 6.0,
                thumbColor: Colors.white,
                overlayColor: const Color(0xFFE43A6A).withOpacity(0.15),
                rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 11,
                  elevation: 4,
                  pressedElevation: 8,
                ),
              ),
              child: RangeSlider(
                values: RangeValues(_minIncome, _maxIncome),
                min: 5,
                max: 200,
                onChanged: (RangeValues values) {
                  setState(() {
                    _minIncome = values.start;
                    _maxIncome = values.end;
                  });
                },
              ),
            ),

            // Labels for slider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹5 L',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '₹1 Cr',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '₹2 Cr+',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // API Driven Chips
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                ),
              )
            else if (_apiRanges.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: _apiRanges.map((range) {
                  final String title = range['title'] ?? '';
                  final double minLakh = ((range['minAmount'] ?? 0) / 100000)
                      .toDouble();
                  // For maxAmount = null, set to 200
                  final double maxLakh = range['maxAmount'] != null
                      ? ((range['maxAmount']) / 100000).toDouble()
                      : 200.0;

                  final isSelected =
                      _minIncome == minLakh && _maxIncome == maxLakh;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _minIncome = minLakh.clamp(5.0, 200.0);
                        _maxIncome = maxLakh.clamp(5.0, 200.0);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
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
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE43A6A,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Info boxes
            _buildInfoBox(
              icon: Icons.lock,
              iconColor: const Color(0xFFF39C12),
              title: 'Never shown publicly',
              subtitle:
                  'Only the verified bracket is used for matching — the exact figure stays private.',
            ),
            const SizedBox(height: 12),
            _buildInfoBox(
              icon: Icons.check_circle,
              iconColor: Mycolor.green,
              title: 'Verified with documents',
              subtitle:
                  'Income verification needs salary slips or ITR and adds +8 to trust score.',
            ),
            const SizedBox(height: 12),
            _buildInfoBox(
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFFF39C12),
              title: 'Keep the band wide',
              subtitle:
                  'A narrow band removes many good matches who are early in their careers.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
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
