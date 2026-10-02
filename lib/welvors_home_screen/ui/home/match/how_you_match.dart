import 'package:flutter/material.dart';

class HowYouMatchSection extends StatelessWidget {
  final Map<String, dynamic>? howYouMatch;
  final List<dynamic>? dimensions;

  const HowYouMatchSection({super.key, this.howYouMatch, this.dimensions});

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
        if (howYouMatch != null) ...[
          _buildStrongestMatchCard(),
          const SizedBox(height: 16),
        ],
        _buildMatchesGrid(dimensions ?? []),
      ],
    );
  }

  Widget _buildStrongestMatchCard() {
    final title = howYouMatch?['title']?.toString() ?? 'Match';
    final icon = howYouMatch?['icon']?.toString() ?? '🎯';
    final score = howYouMatch?['score'] as num? ?? 100;
    final description = howYouMatch?['description']?.toString() ?? '';
    final isStrongest = howYouMatch?['strongest'] == true;

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
                CircularProgressIndicator(
                  value: (score.toDouble() / 100.0).clamp(0.0, 1.0),
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE85A7A)),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      '${score.toInt()}%',
                      style: const TextStyle(
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
                    Text(
                      '$icon $title',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF242424),
                      ),
                    ),
                    if (isStrongest)
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
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6D6D78),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesGrid(List<dynamic> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    final List<Widget> rows = [];
    for (int i = 0; i < matches.length; i += 2) {
      final first = matches[i];
      final second = i + 1 < matches.length ? matches[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildItemFromData(first)),
            const SizedBox(width: 12),
            Expanded(child: second != null ? _buildItemFromData(second) : const SizedBox()),
          ],
        ),
      );
      if (i + 2 < matches.length) {
        rows.add(const SizedBox(height: 12));
      }
    }
    
    return Column(
      children: rows,
    );
  }

  Widget _buildItemFromData(dynamic data) {
    final title = data['title'] ?? '';
    final icon = data['icon'] ?? '';
    final score = data['score'] as num?;
    
    final percentage = score != null ? '${score.toInt()}%' : '-';
    final progress = score != null ? (score.toDouble() / 100.0).clamp(0.0, 1.0) : 0.0;
    
    return _buildGridItem(icon, percentage, title, progress);
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
  final List<dynamic>? sharedInterests;
  const WhatYouShareSection({super.key, this.sharedInterests});

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
          children: (sharedInterests != null && sharedInterests!.isNotEmpty) 
            ? sharedInterests!.map((interest) {
                final name = interest['name']?.toString() ?? '';
                // Since user asked for default icon, we can just use a default star or generic icon
                // Or map some words if desired. A generic check mark or heart works too.
                return _buildSharePill(Icons.favorite_rounded, name);
              }).toList()
            : [
                _buildSharePill(Icons.park, 'Trekking'),
                _buildSharePill(Icons.local_cafe, 'Coffee'),
                _buildSharePill(Icons.flight, 'Travel'),
                _buildSharePill(Icons.menu_book, 'Books'),
                _buildSharePill(Icons.music_note, 'Live music'),
                _buildSharePill(Icons.fitness_center, 'Fitness'),
              ],
        ),
      ],
    );
  }

  Widget _buildSharePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDF3), // Light pink background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE85A7A)),
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
  final List<dynamic>? differences;

  const AFewDifferencesSection({super.key, this.differences});

  @override
  Widget build(BuildContext context) {
    if (differences == null || differences!.isEmpty) {
      return const SizedBox.shrink();
    }

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
        ...differences!.map((diff) {
          final title = diff['title'] ?? '';
          final you = diff['you'];
          final them = diff['them'];
          
          final emoji = _getEmojiForDifference(diff['key'] ?? '');
          final circleColor = _getColorForDifference(diff['key'] ?? '');
          
          String description;
          if (you != null && them != null && you.toString().isNotEmpty && them.toString().isNotEmpty) {
             description = "You're $you - they're $them.";
          } else {
             description = "You both have different perspectives here.";
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildDifferenceCard(
              emoji,
              title,
              description,
              circleColor,
            ),
          );
        }),
      ],
    );
  }

  String _getEmojiForDifference(String key) {
    switch (key) {
      case 'RELATIONSHIP_INTENT': return '🎯';
      case 'RELIGION': return '🙏';
      case 'COMMUNITY': return '🤝';
      case 'NATIVE_PLACE': return '🏠';
      case 'COMMUNICATION_STYLE': return '💬';
      case 'LOVE_LANGUAGE': return '💝';
      case 'FAMILY_TYPE': return '👨‍👩‍👧‍👦';
      case 'DRINKING': return '🥂';
      case 'DRINKS': return '🥂';
      case 'DIET': return '🍽️';
      case 'DAILY_RHYTHM': return '🌙';
      case 'VALUES': return '💞';
      case 'AGE_LIFE_STAGE': return '🎂';
      case 'FAMILY_ROOTS': return '🏡';
      case 'COMMUNICATION': return '📞';
      case 'LIFESTYLE': return '🌿';
      case 'INTERESTS': return '🥾';
      case 'EDUCATION_AMBITION': return '🎓';
      case 'LOCATION': return '📍';
      default: return '💡';
    }
  }

  Color _getColorForDifference(String key) {
    switch (key) {
      case 'RELATIONSHIP_INTENT': return const Color(0xFFFFEAEA); // Light Pink
      case 'RELIGION': return const Color(0xFFFFF4E5); // Light Orange
      case 'COMMUNITY': return const Color(0xFFE5F9E5); // Light Green
      case 'NATIVE_PLACE': return const Color(0xFFE5F3FF); // Light Blue
      case 'COMMUNICATION_STYLE': return const Color(0xFFF3E5FF); // Light Purple
      case 'LOVE_LANGUAGE': return const Color(0xFFFFEBF3); // Soft Rose
      case 'FAMILY_TYPE': return const Color(0xFFFFF0E6); // Soft Peach
      case 'DRINKING': return const Color(0xFFF5E6E6); // Light Wine
      case 'DRINKS': return const Color(0xFFF5E6E6); // Light Wine
      case 'DIET': return const Color(0xFFFFF3E0);
      case 'DAILY_RHYTHM': return const Color(0xFFE1F5FE);
      default: return const Color(0xFFFFF9E6); // Light Yellow default
    }
  }

  Widget _buildDifferenceCard(String emoji, String title, String description, Color circleColor) {
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
            decoration: BoxDecoration(
              color: circleColor,
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
  final List<dynamic>? sideBySide;
  final String matchName;

  const SideBySideSection({
    super.key,
    this.sideBySide,
    required this.matchName,
  });

  @override
  Widget build(BuildContext context) {
    if (sideBySide == null || sideBySide!.isEmpty) {
      return const SizedBox.shrink();
    }

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
                _buildHeaderRow(matchName),
                ...sideBySide!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  final attribute = item['attribute'] ?? '';
                  final you = item['you'] ?? '-';
                  final them = item['them'] ?? '-';
                  final isMatch = item['matched'] == true;
                  final isLast = index == sideBySide!.length - 1;
                  
                  return _buildRow(
                    attribute,
                    you.toString(),
                    them.toString(),
                    isMatch: isMatch,
                    isLast: isLast,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(String name) {
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
          Expanded(
            flex: 1,
            child: Text(
              name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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
