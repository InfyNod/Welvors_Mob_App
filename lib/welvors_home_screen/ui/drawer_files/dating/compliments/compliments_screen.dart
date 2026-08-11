import 'package:flutter/material.dart';
import 'get_compliments_drawer.dart';

class ComplimentsScreen extends StatefulWidget {
  static int availableCompliments = 5;

  const ComplimentsScreen({super.key});

  @override
  State<ComplimentsScreen> createState() => _ComplimentsScreenState();
}

class _ComplimentsScreenState extends State<ComplimentsScreen> {
  int _selectedPackageIndex = 1;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': '05',
      'subtitle': 'Compliments',
      'pricePerItem': '₹49 each',
      'totalPrice': '₹245',
      'extra': '+ 2 free weekly',
      'tag': null,
    },
    {
      'title': '15',
      'subtitle': 'Compliments',
      'pricePerItem': '₹37 each',
      'discount': 'Save 25%',
      'totalPrice': '₹549',
      'extra': '+ 2 free weekly',
      'tag': 'MOST POPULAR',
    },
    {
      'title': '30',
      'subtitle': 'Compliments',
      'pricePerItem': '₹29 each',
      'discount': 'Save 40%',
      'totalPrice': '₹899',
      'extra': '+ 2 free weekly',
      'tag': 'BEST VALUE',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Compliments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(),
            const SizedBox(height: 24),
            const Text(
              'YOUR IMPACT',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildImpactSection(),
            const SizedBox(height: 32),
            const Text(
              'GET MORE COMPLIMENTS',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_packages.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPackageCard(index),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'WHY COMPLIMENTS WORK',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildWhyComplimentsWorkSection(),
            const SizedBox(height: 16),
            _buildProTipBanner(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(252, 131, 160, 1.0), // Pink start
            Color(0xFFDE2957), // Darker pink end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDE2957).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic (Gift/Heart emoji)
          Positioned(
            right: -20,
            top: -20,
            child: Transform.rotate(
              angle: 5.9,
              child: Opacity(
                opacity: 0.2,
                child: const Text('💝', style: TextStyle(fontSize: 120)),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💌', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'SAY MORE WITH WORDS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Send a compliment.\nGet 4× more matches.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Stand out by adding a thoughtful note with\nyour like — on a photo or prompt.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Inner card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.2,
                    ), // Semi-transparent white
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${ComplimentsScreen.availableCompliments}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Compliments available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '2 free per week · Renews in 3 days',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.favorite, color: Colors.white, size: 22),
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

  Widget _buildImpactSection() {
    return Row(
      children: [
        Expanded(
          child: _buildImpactCard('12', 'SENT', const Color(0xFFDE2957)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImpactCard('8', 'REPLIED', const Color(0xFF34A853)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImpactCard('67%', 'REPLY RATE', const Color(0xFFF6B042)),
        ),
      ],
    );
  }

  Widget _buildImpactCard(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyComplimentsWorkSection() {
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
          _buildWhyComplimentsWorkItem(
            icon: Icons.favorite,
            iconColor: const Color(0xFFE94086),
            iconBgColor: const Color(0xFFFCE4EC),
            title: 'Words that work',
            subtitle: 'More than a swipe',
            isFirst: true,
          ),
          _buildWhyComplimentsWorkItem(
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFFE94086),
            iconBgColor: const Color(0xFFFCE4EC),
            title: '4× higher reply rate',
            subtitle:
                'Likes with a compliment get replies 4× more often\nthan plain likes.',
            tag: 'PROVEN',
            tagColor: const Color(0xFFE94086),
            tagBgColor: const Color(0xFFFCE4EC),
          ),
          _buildWhyComplimentsWorkItem(
            icon: Icons.star,
            iconColor: const Color(0xFFF6B042),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Up to 140 chars',
            subtitle:
                'Just enough to be witty, not enough to overshare.\nSweet spot for first impressions.',
            tag: 'NEW',
            tagColor: const Color(0xFFF6B042),
            tagBgColor: const Color(0xFFFFF3E0),
          ),
          _buildWhyComplimentsWorkItem(
            icon: Icons.remove_red_eye,
            iconColor: const Color(0xFF2383F6),
            iconBgColor: const Color(0xFFE3F0FF),
            title: 'Attached to a specific photo or prompt',
            subtitle:
                'Anchor your note to what caught your eye — much\nmore personal.',
          ),
          _buildWhyComplimentsWorkItem(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF34A853),
            iconBgColor: const Color(0xFFE6F4EA),
            title: 'Goes to their top notifications',
            subtitle:
                'Compliments skip the regular queue — your\nmessage lands at the top.',
          ),
          _buildWhyComplimentsWorkItem(
            icon: Icons.access_time,
            iconColor: const Color(0xFFE94086),
            iconBgColor: const Color(0xFFFCE4EC),
            title: 'Compliments never expire',
            subtitle:
                'Buy now, use anytime. Save them for the right\nperson — no rush.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyComplimentsWorkItem({
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            color: Colors.grey.withOpacity(0.15),
            indent: 56, // Align with text
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildProTipBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 245, 225),
            Color(0xFFFFF0F5),
            Color.fromARGB(255, 251, 226, 234),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6B042),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.format_quote,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro tip: Reference a specific detail',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Your Ladakh photo" beats "you look great" every time. Specificity = 2× reply rate.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
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

  Widget _buildPackageCard(int index) {
    final pkg = _packages[index];
    final bool isSelected = _selectedPackageIndex == index;
    final String? tag = pkg['tag'];

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDF0F3) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE43A6A)
                    : const Color(0xFFE5E5E5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE43A6A).withOpacity(0.1)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.mail,
                          color: isSelected
                              ? const Color(0xFFFA6A85).withOpacity(0.2)
                              : Colors.grey.shade300,
                          size: 28,
                        ),
                        Icon(
                          Icons.favorite,
                          color: isSelected
                              ? const Color(0xFFE43A6A)
                              : Colors.grey.shade400,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pkg['title'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pkg['subtitle'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            pkg['pricePerItem'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          if (pkg['discount'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pkg['discount'],
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 44, 171, 104),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pkg['totalPrice'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pkg['extra'],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (tag != null)
          Positioned(
            top: -10,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: tag == 'MOST POPULAR'
                      ? [const Color(0xFFFA6A85), const Color(0xFFDE2957)]
                      : [const Color(0xFFFFD54F), const Color(0xFFF6B042)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: tag == 'MOST POPULAR'
                        ? const Color(0xFFDE2957).withOpacity(0.3)
                        : const Color(0xFFF6B042).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: tag == 'BEST VALUE' ? Colors.black87 : Colors.white,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${int.parse(selectedPkg['title'])} COMPLIMENTS · ${selectedPkg['tag'] ?? 'TRY IT OUT'}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                selectedPkg['totalPrice'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                GetComplimentsDrawer.show(context, selectedPkg, () {
                  setState(() {});
                });
              },
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
                  Icon(Icons.favorite, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Get Compliments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Never expire · Use anytime',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
