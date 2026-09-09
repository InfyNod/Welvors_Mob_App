import 'package:flutter/material.dart';
import 'get_compliments_drawer.dart';
import 'service_compliment.dart';

class ComplimentsScreen extends StatefulWidget {
  static int availableCompliments = 3;

  const ComplimentsScreen({super.key});

  @override
  State<ComplimentsScreen> createState() => _ComplimentsScreenState();
}

class _ComplimentsScreenState extends State<ComplimentsScreen> {
  int _selectedPackageIndex = 1;
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _infoList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final service = ComplimentApiService();
    final data = await service.getComplimentsData();
    if (data != null && mounted) {
      setState(() {
        ComplimentsScreen.availableCompliments = data['availableCompliments'] ?? 0;

        final packs = data['packs'] as List<dynamic>? ?? [];
        _packages = packs.map((p) {
          final quantity = p['quantity']?.toString() ?? '0';

          String? tagStr;
          final badge = p['badge']?.toString();
          if (badge != null && badge.isNotEmpty && badge != 'NONE') {
            tagStr = badge.replaceAll('_', ' ').toLowerCase();
            tagStr = tagStr.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
          }

          return {
            'id': p['id'],
            'title': quantity,
            'subtitle': 'Compliments',
            'pricePerItem': '₹${p['pricePerUnit']} each',
            'totalPrice': '₹${p['totalPrice']}',
            'tag': tagStr,
          };
        }).toList();

        _infoList = List<Map<String, dynamic>>.from(data['info'] ?? []);
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 190),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBanner(),

                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'GET MORE COMPLIMENTS',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: List.generate(_packages.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildPackageCard(index),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (_infoList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'WHY COMPLIMENTS WORK',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildWhyComplimentsWorkSection(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildProTipCard(),
                    ),
                  ],
                ],
              ),
            ),
      bottomSheet: _isLoading ? null : _buildBottomBar(),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/compliment_img.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              const Color(0xFF632EB7).withOpacity(0.45),
              const Color(0xFF632EB7).withOpacity(0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  'SAY MORE WITH WORDS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
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
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stand out by adding a thoughtful note with your like — on a photo or prompt.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.chat_bubble_outline_outlined,
                    Colors.white,
                    'Note on\nany photo',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.trending_up,
                    Colors.white,
                    '4× more\nmatches',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.auto_awesome,
                    Colors.white,
                    'Shows in\ntheir likes',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.card_giftcard,
                    Colors.white,
                    '2 free\neach week',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // COMPLIMENTS AVAILABLE
            const Text(
              'COMPLIMENTS AVAILABLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${ComplimentsScreen.availableCompliments}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'compliments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Text(
              '2 free every week · renews in 3 days',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsideBannerCard(
    IconData iconData,
    Color iconColor,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: iconColor, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyComplimentsWorkSection() {
    if (_infoList.isEmpty) return const SizedBox.shrink();

    final iconsData = [
      {'icon': Icons.favorite, 'iconColor': const Color(0xFF632EB7), 'iconBgColor': const Color(0xFFF3E5F5)},
      {'icon': Icons.chat_bubble_outline, 'iconColor': const Color(0xFF632EB7), 'iconBgColor': const Color(0xFFF3E5F5)},
      {'icon': Icons.star, 'iconColor': const Color(0xFFF09B59), 'iconBgColor': const Color(0xFFFFF2E8)},
      {'icon': Icons.remove_red_eye_outlined, 'iconColor': const Color(0xFF63A4FF), 'iconBgColor': const Color(0xFFEAF2FF)},
      {'icon': Icons.check, 'iconColor': const Color(0xFF6FCF97), 'iconBgColor': const Color(0xFFEAFAF1)},
      {'icon': Icons.access_time, 'iconColor': const Color(0xFF632EB7), 'iconBgColor': const Color(0xFFF3E5F5)},
    ];

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
        children: List.generate(_infoList.length, (index) {
          final info = _infoList[index];
          final iconMap = iconsData[index % iconsData.length];
          return _buildWhyComplimentsWorkItem(
            icon: iconMap['icon'] as IconData,
            iconColor: iconMap['iconColor'] as Color,
            iconBgColor: iconMap['iconBgColor'] as Color,
            title: info['title'] ?? '',
            subtitle: info['description'] ?? '',
            tag: info['tag'],
            tagColor: iconMap['iconColor'] as Color,
            tagBgColor: iconMap['iconBgColor'] as Color,
            isFirst: index == 0,
            isLast: index == _infoList.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildProTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFEF5E3), // rgba(254, 245, 227)
            Color(0xFFFCE2EB), // rgba(252, 226, 235)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5B667), // Solid warm amber
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Your Ladakh photo" beats "you look great" every time. Specificity = 2× reply rate.',
                  style: TextStyle(
                    color: Colors.black54,
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

  Widget _buildWhyComplimentsWorkItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    List<String>? bulletPoints,
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
                    if (bulletPoints != null && bulletPoints.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...bulletPoints.map(
                        (bp) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5, right: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: Colors.black54,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  bp,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ] else ...[
                      const SizedBox(height: 4),
                    ],
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
            thickness: 1,
            color: Colors.grey.withOpacity(0.15),
            indent: 16,
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
                  'Pro tip: Send Compliments between 8–10 PM',
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

    Color themeColor = const Color(0xFF632EB7); // Red/Pink for all
    Color themeBgColor = const Color(0xFFF3E5F5);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 18,
              bottom: 12,
              left: 8,
              right: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? themeBgColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? themeColor : const Color(0xFFEAEAEA),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pkg['title'],
                  style: TextStyle(
                    color: isSelected ? themeColor : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Compliments',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pkg['pricePerItem'].toString().replaceFirst(' each', '/each'),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pkg['totalPrice']} total',
                  style: const TextStyle(color: Colors.black45, fontSize: 9),
                ),
                const SizedBox(height: 8),
                // Radio button circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? themeColor : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (tag != null && tag.isNotEmpty)
            Positioned(
              top: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: index == 0
                        ? [
                            const Color(0xFFFFD54F),
                            const Color(0xFFF6B042),
                          ] // Gold
                        : index == 2
                        ? [const Color(0xFF434343), Colors.black] // Black/Dark
                        : [
                            const Color(0xFFB388FF),
                            const Color(0xFF632EB7),
                          ], // Red/Pink
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (index == 0
                                  ? const Color(0xFFF6B042)
                                  : index == 2
                                  ? Colors.black
                                  : const Color(0xFF632EB7))
                              .withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_packages.isEmpty) return const SizedBox.shrink();

    int index = _selectedPackageIndex;
    if (index >= _packages.length) index = 0;

    final selectedPkg = _packages[index];

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
                backgroundColor: const Color(0xFF632EB7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Get ${int.parse(selectedPkg['title'])} Compliments for ${selectedPkg['totalPrice']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Compliments never expire · Used anytime',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
