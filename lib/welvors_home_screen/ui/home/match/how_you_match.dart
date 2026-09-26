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
              fontSize: 12,
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
          color: const Color(0xFFE85A7A).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                    const Color(0xFFE85A7A).withValues(alpha: 0.2),
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
            Expanded(child: _buildGridItem('📍', '82%', 'Location', 0.82)),
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
            color: Colors.black.withValues(alpha: 0.08),
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
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8), // Clear grey track for visibility
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

class WhatYouShareSection extends StatelessWidget {
  const WhatYouShareSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Text(
            'WHAT YOU SHARE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE85A7A),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            _buildSharePill('🧗‍♀️', 'Trekking'),
            _buildSharePill('☕', 'Coffee'),
            _buildSharePill('✈️', 'Travel'),
            _buildSharePill('📚', 'Books'),
            _buildSharePill('🎵', 'Live music'),
            _buildSharePill('🏋️‍♀️', 'Fitness'),
          ],
        ),
      ],
    );
  }

  Widget _buildSharePill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDF3), // Light pink background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE85A7A), // Dark pink text
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE85A7A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'BOTH',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AFewDifferencesSection extends StatelessWidget {
  const AFewDifferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'A FEW DIFFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE85A7A),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildDifferenceCard(
          '🍽️',
          'Diet',
          "You're vegetarian - Aanya eats everything. Easy to work around over dinner.",
        ),
        const SizedBox(height: 12),
        _buildDifferenceCard(
          '🌙',
          'Daily rhythm',
          "You're an early bird - she's more of a night owl. Brunch dates win.",
        ),
      ],
    );
  }

  Widget _buildDifferenceCard(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9E6), // Light yellow background
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF242424),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6D6D78),
                    height: 1.3,
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

class SideBySideSection extends StatelessWidget {
  const SideBySideSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'SIDE BY SIDE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE85A7A),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _buildHeaderRow(),
                _buildRow('Looking for', 'Serious', 'Serious', isMatch: true),
                _buildRow('Love language', 'Words', 'Words', isMatch: true),
                _buildRow('Age', '28', '24', isMatch: false),
                _buildRow('City', 'Pune', 'Pune', isMatch: true),
                _buildRow('Religion', 'Hindu', 'Hindu', isMatch: true),
                _buildRow('Mother tongue', 'Marathi', 'Marathi', isMatch: true),
                _buildRow(
                  'Profession',
                  'Engineer',
                  'Fashion designer',
                  isMatch: false,
                ),
                _buildRow('Diet', 'Veg', 'Non-veg', isMatch: false),
                _buildRow('Drinks', 'Socially', 'Socially', isMatch: true),
                _buildRow('Smoking', 'Non-smoker', 'Non-smoker', isMatch: true),
                _buildRow('Fitness', 'Active', 'Active', isMatch: true),
                _buildRow('Communication', 'Calls', 'Calls', isMatch: true),
                _buildRow('Wants kids', 'Someday', 'Someday', isMatch: true),
                _buildRow(
                  'Sleep',
                  'Early bird',
                  'Night owl',
                  isMatch: false,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFF7F7F7),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'ATTRIBUTE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'YOU',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3BA7F4), // Blue for you
                letterSpacing: 1.0,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'AANYA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE85A7A), // Pink for her
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String attribute,
    String you,
    String aanya, {
    required bool isMatch,
    bool isLast = false,
  }) {
    final bgColor = isMatch ? const Color(0xFFECF9F1) : Colors.white;
    final textColor = isMatch
        ? const Color(0xFF2CB864)
        : const Color(0xFF242424);
    final border = isLast
        ? null
        : Border(bottom: BorderSide(color: Colors.grey.shade300));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bgColor, border: border),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              attribute,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6D6D78),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              you,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              aanya,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
