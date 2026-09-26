import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';

class DistanceScreen extends StatefulWidget {
  const DistanceScreen({super.key});

  @override
  State<DistanceScreen> createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  double _currentDistance = 100.0;
  final List<double> _predefinedDistances = [5, 10, 25, 50, 100];
  double _selectedDistanceChip = 100.0;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _currentDistance = currentState.distance;
    if (_predefinedDistances.contains(_currentDistance)) {
      _selectedDistanceChip = _currentDistance;
    } else {
      _selectedDistanceChip = -1;
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
          'Distance',
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
              onPressed: () {
                context.read<FilterBloc>().add(UpdateDistance(_currentDistance));
                Navigator.pop(context);
              },
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Radar UI
              _buildRadarUI(),
              const SizedBox(height: 10),

              // Premium Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFE43A6A),
                  inactiveTrackColor: Colors.grey.shade100,
                  trackHeight: 6.0,
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFFE43A6A).withValues(alpha: 0.15),
                  trackShape: const RoundedRectSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                    elevation: 4,
                    pressedElevation: 8,
                  ),
                ),
                child: Slider(
                  value: _currentDistance,
                  min: 1,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      _currentDistance = value;
                      // Sync slider with chips
                      if (_predefinedDistances.contains(
                        value.roundToDouble(),
                      )) {
                        _selectedDistanceChip = value.roundToDouble();
                      } else {
                        _selectedDistanceChip = -1;
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
                      '1 km',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '50 km',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '100+ km',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                        constraints.maxWidth / _predefinedDistances.length;
                    final selectedIndex = _predefinedDistances.indexOf(
                      _selectedDistanceChip,
                    );

                    return Stack(
                      children: [
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
                                  color: const Color(
                                    0xFFE43A6A,
                                  ), // Pink background
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE43A6A,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Row(
                          children: _predefinedDistances.map((dist) {
                            final isSelected = _selectedDistanceChip == dist;
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    _selectedDistanceChip = dist;
                                    _currentDistance = dist;
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
                                    child: Text('${dist.round()} km'),
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
                icon: Icons.location_on,
                iconColor: const Color(0xFFE43A6A),
                title: 'Only your area is shown',
                subtitle:
                    'Members see "Koregaon Park" — never your exact location.',
              ),
              const SizedBox(height: 12),

              // Info Card 2
              _buildInfoCard(
                icon: Icons.auto_awesome,
                iconColor: Colors.amber.shade600,
                title: 'Wider radius, more matches',
                subtitle:
                    'Under 10 km narrows the pool a lot in smaller cities.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarUI() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF0F5),
            const Color(0xFFFCE4EC).withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE43A6A).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE43A6A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Dynamic Premium Radar circles
            ...List.generate(5, (index) {
              // Scale size based on _currentDistance
              final scale = 0.3 + (_currentDistance / 100.0) * 1.2;
              final baseSize = 400.0 * scale;
              final size = baseSize - (index * (baseSize / 5));

              // Inner rings are brighter, outer rings fade out
              final opacity = (1.0 - (index * 0.15)).clamp(0.0, 1.0);
              final thickness = index == 0 ? 2.0 : 1.0;
              final ringColor = const Color.fromARGB(255, 227, 158, 176);

              return Positioned(
                bottom: -size / 2 + 10,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack, // Premium spring/bouncy effect
                  width: size > 0 ? size : 0,
                  height: size > 0 ? size : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor.withValues(alpha: opacity * 0.3),
                      width: thickness,
                    ),
                    boxShadow: [
                      if (index ==
                          0) // Soft glowing effect on the innermost ring
                        BoxShadow(
                          color: ringColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                ),
              );
            }),

            // Text Content
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'SEARCH RADIUS',
                    style: TextStyle(
                      color: const Color(0xFFE43A6A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_currentDistance.round()}',
                        style: const TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'km',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDistanceDescription(_currentDistance),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
            color: Colors.black.withValues(alpha: 0.02),
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

  String _getDistanceDescription(double distance) {
    if (distance <= 5) {
      return 'Walking distance';
    } else if (distance <= 10) {
      return 'Nearby neighborhoods';
    } else if (distance <= 25) {
      return 'Your side of the city';
    } else if (distance <= 50) {
      return 'Across the city';
    } else {
      return 'Anywhere / Out of town';
    }
  }
}
