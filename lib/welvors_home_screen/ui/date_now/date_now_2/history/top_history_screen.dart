import 'package:flutter/material.dart';

class TopHistoryScreen extends StatefulWidget {
  const TopHistoryScreen({super.key});

  @override
  State<TopHistoryScreen> createState() => _TopHistoryScreenState();
}

class _TopHistoryScreenState extends State<TopHistoryScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All 6',
    'Met 2',
    'Expired 2',
    'No-show 1',
    'Cancelled 1',
  ];
  
  late final List<GlobalKey> _filterKeys;

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());
  }

  final List<Map<String, dynamic>> _historyPlans = [
    {
      'title': '🍝 Pasta & Long Conversations',
      'date': 'Sat, 2 Aug · 8:00 – 10:30 PM',
      'location': 'Le Petit Bistro · Koregaon Park · 2.1 km',
      'image': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'MET',
      'partnerName': 'Aanya, 25',
      'partnerAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'partnerStatus': 'Met on this plan',
      'rating': 5,
      'note': 'You both showed up. Dinner ran 30 min over — she asked to meet again.',
      'views': 214,
      'requests': 7,
      'split': 'Split (TTMM)',
    },
    {
      'title': '🚶 Riverside Evening Walk',
      'date': 'Thu, 24 Jul · 6:30 – 8:00 PM',
      'location': 'Mula Riverfront · Baner · 4.6 km',
      'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'MET',
      'partnerName': 'Riya, 26',
      'partnerAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'partnerStatus': 'Met on this plan',
      'rating': 4,
      'note': '',
      'views': 120,
      'requests': 4,
      'split': 'I paid',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF9F6), // Match the off-white background from image
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCard(),
            _buildStatCards(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 32),
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
          color: const Color(0xFFF7EDFA), // Light purple background
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 0.33,
                    backgroundColor: Colors.white,
                    color: const Color(0xFFE43A6A), // Pink
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                  const Center(
                    child: Text(
                      '33%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE43A6A),
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E1E24) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E1E24) : Colors.grey.shade300,
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: word,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1E1E24),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (number.isNotEmpty)
                        TextSpan(
                          text: ' $number',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey.shade500,
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
