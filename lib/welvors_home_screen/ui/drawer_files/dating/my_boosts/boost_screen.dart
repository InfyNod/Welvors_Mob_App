import 'package:flutter/material.dart';

class BoostScreen extends StatefulWidget {
  const BoostScreen({super.key});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  int _selectedPackageIndex = 1; // 10 Boosts is selected by default

  final List<Map<String, dynamic>> _packages = [
    {
      'title': '20',
      'subtitle': 'Boosts',
      'pricePerItem': '₹175/each',
      'discount': 'Save 51%',
      'oldPrice': '₹356/each',
      'totalPrice': '₹3,500 total',
      'tag': 'BEST VALUE',
    },
    {
      'title': '10',
      'subtitle': 'Boosts',
      'pricePerItem': '₹215/each',
      'discount': 'Save 40%',
      'oldPrice': '₹356/each',
      'totalPrice': '₹2,150 total',
      'tag': 'POPULAR',
    },
    {
      'title': '03',
      'subtitle': 'Boosts',
      'pricePerItem': '₹356/each',
      'discount': null,
      'oldPrice': null,
      'totalPrice': '₹1,068 total',
      'tag': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 24),
            const Text(
              'CHOOSE YOUR PACK',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_packages.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPackageCard(index),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'WHY BOOST WORKS',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildWhyBoostWorksSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(252, 131, 160, 1.0), Color(0xFFDE2957)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Faint lightning bolt background
          Positioned(
            right: -20,
            top: -20,
            child: Transform.rotate(
              angle: 5.9,
              child: Opacity(
                opacity: 0.2,
                child: const Text('⚡️', style: TextStyle(fontSize: 120)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20), // reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⚡️', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text(
                        '30 MINUTES • NEARBY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Be a top profile\nin your area',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get 5x more profile views and stand out to\nyour most compatible matches instantly.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12, // slightly smaller to save space
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('5x', 'MORE VIEWS'),
                    _buildStatItem('3x', 'MORE MATCHES'),
                    _buildStatItem('30m', 'DURATION'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(int index) {
    final isSelected = _selectedPackageIndex == index;
    final package = _packages[index];
    final hasTag = package['tag'] != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPackageIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDF0F3) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Count
                    Text(
                      package['title'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      package['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          package['pricePerItem'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        if (package['totalPrice'] != null)
                          Text(
                            package['totalPrice'].split(' ')[0] + ' total',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Dotted Divider
                LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 4.0;
                    final dashCount = (boxWidth / (2 * dashWidth)).floor();
                    return Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: List.generate(dashCount, (_) {
                        return SizedBox(
                          width: dashWidth,
                          height: 1.5,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFE5E5E5)),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (package['discount'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(232, 249, 240, 1.0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          package['discount'],
                          style: const TextStyle(
                            color: Color.fromRGBO(44, 175, 107, 1.0),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        package['oldPrice'],
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Checkmark (always visible now)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFE43A6A) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (hasTag)
          Positioned(
            left: 16,
            top: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: package['tag'] == 'BEST VALUE'
                      ? [const Color(0xFFFFD54F), const Color(0xFFF6B042)]
                      : [const Color(0xFFFA6A85), const Color(0xFFDE2957)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: package['tag'] == 'BEST VALUE'
                        ? const Color(0xFFF6B042).withOpacity(0.3)
                        : const Color(0xFFDE2957).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                package['tag'],
                style: TextStyle(
                  color: package['tag'] == 'BEST VALUE' ? Colors.black87 : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final selectedPkg = _packages[_selectedPackageIndex];
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedPkg['title']} BOOSTS · 30 MIN EACH',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                selectedPkg['totalPrice'].split(' ')[0], // gets just the amount like ₹2,150
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Boosts never expire · Use anytime',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyBoostWorksSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWhyBoostWorkItem(
            icon: Icons.bolt,
            iconColor: const Color(0xFFE43A6A),
            iconBgColor: const Color(0xFFFDF0F3),
            title: 'Boost · 30 min',
            subtitle: 'Quick visibility lift',
            tag: '⚡ INSTANT',
            tagColor: const Color(0xFFE43A6A),
            tagBgColor: const Color(0xFFFDF0F3),
            isFirst: true,
          ),
          _buildWhyBoostWorkItem(
            icon: Icons.bolt,
            iconColor: const Color(0xFFE43A6A),
            iconBgColor: const Color(0xFFFDF0F3),
            title: 'Top of nearby decks',
            subtitle:
                'Your profile jumps to position 1 in the discovery\ndeck within 2 km of you.',
            tag: 'INSTANT',
            tagColor: const Color(0xFFE43A6A),
            tagBgColor: const Color(0xFFFDF0F3),
          ),
          _buildWhyBoostWorkItem(
            icon: Icons.trending_up,
            iconColor: const Color(0xFF34A853),
            iconBgColor: const Color(0xFFE6F4EA),
            title: '5× more profile views',
            subtitle:
                'On average, boosted profiles receive 245% more\nviews than regular ones in the same window.',
            tag: '+245%',
            tagColor: const Color(0xFFE43A6A),
            tagBgColor: const Color(0xFFFDF0F3),
          ),
          _buildWhyBoostWorkItem(
            icon: Icons.favorite,
            iconColor: const Color(0xFFF6B042),
            iconBgColor: const Color(0xFFFFF3E0),
            title: '3× higher match rate',
            subtitle:
                'Better signal to compatible users means 3× more\nright-swipes during your boost.',
          ),
          _buildWhyBoostWorkItem(
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF2383F6),
            iconBgColor: const Color(0xFFE3F0FF),
            title: '3× faster replies',
            subtitle:
                'Boosted profiles are seen as more active — your\nmessages get replies sooner.',
          ),
          _buildWhyBoostWorkItem(
            icon: Icons.search,
            iconColor: const Color(0xFF8E24AA),
            iconBgColor: const Color(0xFFF3E5F5),
            title: 'Smart audience targeting',
            subtitle:
                'Algorithm prioritizes showing you to people who\nmatch your filters and intent.',
          ),
          _buildWhyBoostWorkItem(
            icon: Icons.monitor_heart,
            iconColor: const Color(0xFFE43A6A),
            iconBgColor: const Color(0xFFFDF0F3),
            title: 'Live performance dashboard',
            subtitle:
                'Watch views, likes and visibility lift update in\nreal-time during your boost.',
            tag: 'NEW',
            tagColor: const Color(0xFFE43A6A),
            tagBgColor: const Color(0xFFFDF0F3),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyBoostWorkItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    String? tag,
    Color? tagColor,
    Color? tagBgColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tagBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 56, // Align with text
            endIndent: 16,
          ),
      ],
    );
  }
}
