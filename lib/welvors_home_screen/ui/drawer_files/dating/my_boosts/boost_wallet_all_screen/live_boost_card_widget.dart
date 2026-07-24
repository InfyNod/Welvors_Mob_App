import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../boost_bloc/boost_bloc.dart';
import '../boost_bloc/boost_state.dart';
import '../boost_history.dart/performance_screen.dart';

class LiveBoostCardWidget extends StatefulWidget {
  const LiveBoostCardWidget({super.key});

  @override
  State<LiveBoostCardWidget> createState() => _LiveBoostCardWidgetState();
}

class _LiveBoostCardWidgetState extends State<LiveBoostCardWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoostBloc, BoostState>(
      builder: (context, state) {
        if (!state.isAnyBoostActive) return const SizedBox.shrink();
        
        final latest = state.history.first;
        final isSuperBoost = latest.isSuperBoost;
        final totalDuration = isSuperBoost 
            ? const Duration(hours: 3) 
            : const Duration(hours: 1);
        final elapsed = DateTime.now().difference(latest.date);
        final remaining = totalDuration - elapsed;

        if (remaining.isNegative) return const SizedBox.shrink();

        final bgColor = isSuperBoost ? const Color(0xFF2C2C2C) : const Color(0xFFFFF0F5);
        final iconBgColor = isSuperBoost ? const Color(0xFFFFC107).withOpacity(0.15) : const Color(0xFFE43A6A);
        final iconColor = isSuperBoost ? const Color(0xFFFFC107) : Colors.white;
        final textColor = isSuperBoost ? Colors.white : Colors.black87;
        final subTextColor = isSuperBoost ? Colors.white70 : Colors.black54;
        final chevronColor = isSuperBoost ? const Color(0xFFFFC107) : const Color(0xFFE43A6A);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PerformanceScreen(item: latest),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.trending_up, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSuperBoost ? 'Super Boost is live now' : 'Boost is live now',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_formatDuration(remaining)} remaining · View performance',
                              style: TextStyle(color: subTextColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: chevronColor, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
