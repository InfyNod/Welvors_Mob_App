import 'package:flutter/material.dart';

class ReceivedRosesScreen extends StatefulWidget {
  const ReceivedRosesScreen({super.key});

  @override
  State<ReceivedRosesScreen> createState() => _ReceivedRosesScreenState();
}

class _ReceivedRosesScreenState extends State<ReceivedRosesScreen> {
  int _selectedTab = 0; // 0 for Received, 1 for Sent

  // Local state to track which cards have been matched
  final Map<int, bool> _matchedCards = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggle(),
          const SizedBox(height: 16),
          _selectedTab == 0 ? _buildReceivedContent() : _buildSentPlaceholder(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReceivedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 16),
          _buildRoseCard(
            id: 0,
            name: 'Dev',
            age: '27',
            distance: '3 km',
            message: '"Your trekking photos are amazing — Ladakh next year?"',
            imageUrl:
                'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=500&q=80',
          ),
          const SizedBox(height: 12),
          _buildRoseCard(
            id: 1,
            name: 'Arjun',
            age: '28',
            distance: '6 km',
            message: '"Fellow IIM grad here — chai > coffee, agree?"',
            imageUrl:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
          ),
          const SizedBox(height: 12),
          _buildRoseCard(
            id: 2,
            name: 'Kabir',
            age: '30',
            distance: '11 km',
            message:
                '"Saw you love indie music — Prateek Kuhad gig next month?"',
            imageUrl:
                'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=500&q=80',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              alignment: _selectedTab == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _selectedTab == 0
                            ? const Color(0xFFE85A7A)
                            : Colors.grey.shade600,
                        fontWeight: _selectedTab == 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 15,
                      ),
                      child: const Text('Received'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _selectedTab == 1
                            ? const Color(0xFFE85A7A)
                            : Colors.grey.shade600,
                        fontWeight: _selectedTab == 1
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 15,
                      ),
                      child: const Text('Sent'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No sent roses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF4), // rgba(255, 239, 244)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌹', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFFE85A7A), // pink text
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Roses are always visible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' — these people really want to meet you. They get 3× more matches.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoseCard({
    required int id,
    required String name,
    required String age,
    required String distance,
    required String message,
    required String imageUrl,
  }) {
    final isMatched = _matchedCards[id] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFFFF0F5),
          ], // white to soft pink gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF8C6D1), // rgba(248, 198, 209)
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8C6D1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image with Rose Icon
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 72,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Square with rounded corners
                  border: Border.all(
                    color: const Color(0xFFF8C6D1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFE85A7A,
                      ).withOpacity(0.4), // Pink glow
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text('🌹', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Card Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85A7A), // Pink background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌹', style: TextStyle(fontSize: 8)),
                      SizedBox(width: 4),
                      Text(
                        'SENT YOU A ROSE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Name, Age, Distance
                Text(
                  '$name, $age · $distance',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    key: ValueKey<bool>(isMatched),
                    children: [
                      // Like Back / Matched Button
                      GestureDetector(
                        onTap: isMatched
                            ? null
                            : () {
                                setState(() {
                                  _matchedCards[id] = true;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, // Increased horizontal padding
                            vertical: 10, // Increased height
                          ),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors
                                      .white // Unique matched style (white bg)
                                : const Color(0xFFE85A7A), // Pink for Like back
                            borderRadius: BorderRadius.circular(24),
                            border: isMatched
                                ? Border.all(
                                    color: const Color(0xFFE85A7A),
                                    width: 1.5,
                                  ) // Pink outline
                                : null,
                            boxShadow: isMatched
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFE85A7A)
                                          .withOpacity(
                                            0.25,
                                          ), // Pink glow when matched
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE85A7A,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isMatched)
                                const Text(
                                  '❤️',
                                  style: TextStyle(fontSize: 14),
                                ),
                              if (!isMatched) const SizedBox(width: 6),
                              Text(
                                isMatched ? 'Matched ✓' : 'Like back',
                                style: TextStyle(
                                  color: isMatched
                                      ? const Color(0xFFE85A7A)
                                      : Colors.white, // Pink text when matched
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Pass Button (hidden when matched)
                      if (!isMatched) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10, // Increased height
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Pass',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
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
