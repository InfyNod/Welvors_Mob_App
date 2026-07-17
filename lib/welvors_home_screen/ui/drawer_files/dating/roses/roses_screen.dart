import 'package:flutter/material.dart';

class RosesScreen extends StatefulWidget {
  const RosesScreen({super.key});

  @override
  State<RosesScreen> createState() => _RosesScreenState();
}

class _RosesScreenState extends State<RosesScreen> {
  int _selectedPackageIndex = 0;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': '05',
      'subtitle': 'Roses',
      'pricePerItem': '₹59 each',
      'totalPrice': '₹295',
      'extra': '+ 1 free daily',
      'tag': null,
    },
    {
      'title': '15',
      'subtitle': 'Roses',
      'pricePerItem': '₹46 each',
      'discount': 'Save 22%',
      'totalPrice': '₹699',
      'extra': '+ 1 free daily',
      'tag': 'MOST POPULAR',
    },
    {
      'title': '30',
      'subtitle': 'Roses',
      'pricePerItem': '₹39 each',
      'discount': 'Save 33%',
      'totalPrice': '₹1,170',
      'extra': '+ 1 free daily',
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
          'Roses',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 40,
                    height: 40,
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
                      Icons.chat_bubble_outline,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              'GET MORE ROSES',
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
              'WHY ROSES WORK',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildWhyRosesWorkSection(),
            const SizedBox(height: 16),
            _buildProTipBanner(),
            const SizedBox(height: 2),
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
            Color.fromRGBO(57, 162, 250, 1.0),
            Color.fromRGBO(23, 113, 202, 1.0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(23, 113, 202, 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic (stars)
          Positioned(
            right: 10,
            top: 15,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.star,
                size: 90,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            right: 100,
            top: 90,
            child: Transform.rotate(
              angle: -0.8,
              child: Icon(
                Icons.star,
                size: 20,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 120,
            child: Transform.rotate(
              angle: 0.8,
              child: Icon(
                Icons.auto_awesome,
                size: 28,
                color: Colors.white.withOpacity(0.3),
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
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'STAND OUT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Make the first\nmove count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Roses get 3× more replies. Your profile\nshows on top with a blue star.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
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
                    color: const Color.fromRGBO(77, 152, 229, 1.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '3',
                            style: TextStyle(
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
                                'Roses available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '1 free per day · Renews in 14h 22m',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.star, color: Colors.white, size: 20),
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
          child: _buildImpactCard('24', 'SENT', const Color(0xFF2383F6)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImpactCard('9', 'MATCHED', const Color(0xFF34A853)),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildImpactCard('37%', 'SUCCESS RATE', Colors.black)),
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
            color: Colors.black.withOpacity(0.08),
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
              fontSize: 24,
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

  Widget _buildWhyRosesWorkSection() {
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
          _buildWhyRosesWorkItem(
            icon: Icons.star,
            iconColor: const Color(0xFF2383F6),
            iconBgColor: const Color(0xFFE3F0FF),
            title: 'Stand out instantly',
            subtitle: 'When you really like someone',
            isFirst: true,
          ),
          _buildWhyRosesWorkItem(
            icon: Icons.star,
            iconColor: const Color(0xFF2383F6),
            iconBgColor: const Color(0xFFE3F0FF),
            title: 'They see you first',
            subtitle:
                'Your profile jumps to the top of their deck with a blue star.',
            tag: 'PRIORITY',
            tagColor: const Color(0xFF2383F6),
            tagBgColor: const Color(0xFFE3F0FF),
          ),
          _buildWhyRosesWorkItem(
            icon: Icons.trending_up,
            iconColor: const Color(0xFF34A853),
            iconBgColor: const Color(0xFFE6F4EA),
            title: '3× more likely to match',
            subtitle: 'Showing interest first triples your chances of a match.',
          ),
          _buildWhyRosesWorkItem(
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFFF6B042),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Add a note with your like',
            subtitle: 'Up to 140 characters to break the ice and stand out.',
            tag: 'NEW',
            tagColor: const Color(0xFFF6B042),
            tagBgColor: const Color(0xFFFFF3E0),
          ),
          _buildWhyRosesWorkItem(
            icon: Icons.favorite,
            iconColor: const Color(0xFFE94086),
            iconBgColor: const Color(0xFFFCE4EC),
            title: '3× faster replies',
            subtitle: 'Rosed matches reply much faster than regular ones.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyRosesWorkItem({
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
              Icons.wb_sunny_rounded,
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
                  'Pro tip: Send Roses between 8–10 PM',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "That's when match rates are highest — 2× higher than mornings.",
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
              color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2383F6)
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
                // Star Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [
                              const Color(0xFF2383F6),
                              const Color(0xFF6FB1FF), // lighter blue
                            ]
                          : [
                              const Color(0xFFD6E9FF),
                              const Color(0xFFEAF4FF), // lighter greyish blue
                            ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star,
                    color: isSelected ? Colors.white : const Color(0xFF2383F6),
                    size: 24,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                        fontSize: 11,
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
                      ? [
                          const Color.fromARGB(255, 56, 154, 231),
                          const Color.fromARGB(255, 85, 170, 240),
                        ]
                      : [const Color(0xFFFFD54F), const Color(0xFFF6B042)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: tag == 'MOST POPULAR'
                        ? const Color(0xFF4598F7).withOpacity(0.3)
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
                '${int.parse(selectedPkg['title'])} ROSES · ${selectedPkg['tag'] ?? 'TRY IT OUT'}',
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(61, 169, 255, 1.0),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Get Roses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Roses never expire · Used anytime',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
