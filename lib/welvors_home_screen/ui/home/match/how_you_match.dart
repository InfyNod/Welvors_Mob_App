import 'package:flutter/material.dart';

class HowYouMatchSection extends StatelessWidget {
  const HowYouMatchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'HOW YOU MATCH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE85A7A),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 5),
        _buildStrongestMatchCard(),
        const SizedBox(height: 16),
        _buildMatchesGrid(),
      ],
    );
  }

  Widget _buildStrongestMatchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDF3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE85A7A).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Progress
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFE85A7A).withOpacity(0.2),
                  ),
                ),
                const CircularProgressIndicator(
                  value: 1.0, // 100%
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE85A7A)),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE85A7A),
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text(
                      '🎯 Relationship intent',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF242424),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85A7A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'STRONGEST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'You both want a serious, long-term relationship — no mixed signals.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6D6D78),
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

  Widget _buildMatchesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridItem(
                '💖',
                '96%',
                'Values & love language',
                0.96,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridItem('🎂', '95%', 'Age & life stage', 0.95),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGridItem('🏡', '94%', 'Family & roots', 0.94),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridItem('📞', '92%', 'Communication style', 0.92),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildGridItem('🌿', '90%', 'Lifestyle', 0.90)),
            const SizedBox(width: 12),
            Expanded(child: _buildGridItem('🥾', '88%', 'Hobbies', 0.88)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGridItem('🎓', '85%', 'Education & ambition', 0.85),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridItem('📍', '82%', 'Location', 0.82),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String emoji,
    String percentage,
    String title,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE85A7A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF242424),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F5), // Light grey track for visibility
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB6C1), Color(0xFFE85A7A)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
