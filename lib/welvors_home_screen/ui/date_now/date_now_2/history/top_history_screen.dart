import 'package:flutter/material.dart';
import 'card_history.dart';

class TopHistoryScreen extends StatefulWidget {
  const TopHistoryScreen({super.key});

  @override
  State<TopHistoryScreen> createState() => _TopHistoryScreenState();
}

class _TopHistoryScreenState extends State<TopHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All 6',
    'Met 2',
    'Expired 2',
    'No-show 1',
    'Cancelled 1',
  ];

  late final List<GlobalKey> _filterKeys;
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.33).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Match the off-white background from image
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCard(),
            _buildStatCards(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 20),
            CardHistory(
              selectedFilter: _filters[_selectedFilterIndex].split(' ')[0],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF4EDFE), // Left
              Color(0xFFF7EFF5), // Right
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8D4F0), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '6 plans hosted',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1E24), // Darker text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2 turned into a real meeting',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Circular Progress
            SizedBox(
              width: 48,
              height: 48,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white,
                        color: const Color(0xFFE43A6A), // Pink
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE43A6A),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('649', 'VIEWS'),
          const SizedBox(width: 8),
          _buildStatCard('22', 'REQUESTS'),
          const SizedBox(width: 8),
          _buildStatCard('2', 'MET'),
          const SizedBox(width: 8),
          _buildStatCard('4.5★', 'AVG RATING'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1E24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;

          // Split the text into word and number
          final parts = _filters[index].split(' ');
          final word = parts[0];
          final number = parts.length > 1 ? parts[1] : '';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });

                // Animate to center
                Scrollable.ensureVisible(
                  _filterKeys[index].currentContext!,
                  alignment: 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                key: _filterKeys[index],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E1E24) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E1E24)
                        : Colors.grey.shade300,
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: word,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E1E24),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (number.isNotEmpty)
                        TextSpan(
                          text: ' $number',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
