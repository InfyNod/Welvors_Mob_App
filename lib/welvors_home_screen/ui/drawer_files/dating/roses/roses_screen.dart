import 'package:flutter/material.dart';
import 'get_roses_drawer.dart';
import 'service_rose.dart';

class RosesScreen extends StatefulWidget {
  static int availableRoses = 3;

  const RosesScreen({super.key});

  @override
  State<RosesScreen> createState() => _RosesScreenState();
}

class _RosesScreenState extends State<RosesScreen> {
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
    final service = RoseApiService();
    final data = await service.getRosesData();
    if (data != null && mounted) {
      setState(() {
        RosesScreen.availableRoses = data['availableRoses'] ?? 0;

        final packs = data['packs'] as List<dynamic>? ?? [];
        _packages = packs.map((p) {
          final title = p['title'].toString();
          // Extract just the number for the large text
          final numberMatch = RegExp(r'\d+').firstMatch(title);
          final numberStr = numberMatch != null ? numberMatch.group(0) : '0';

          String? tagStr;
          final badge = p['badge']?.toString();
          if (badge == 'MOST_POPULAR') {
            tagStr = 'Save 22%';
          } else if (badge == 'BEST_VALUE') {
            tagStr = 'Save 38%';
          }

          return {
            'id': p['id'],
            'title': numberStr!.padLeft(2, '0'),
            'subtitle': 'Roses',
            'pricePerItem': '₹${p['pricePerUnit']} each',
            'totalPrice': '₹${p['totalPrice']}',
            'extra':
                '+ 1 free daily', // Mocked extra info since API doesn't provide it
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
          'Roses',
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
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'GET MORE ROSES',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_packages.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _buildPackageCard(index),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Most popular · best value picks save you up to 38% per rose',
                      style: TextStyle(color: Colors.black45, fontSize: 11),
                    ),
                  ),
                  if (_infoList.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'WHY ROSES WORK',
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
                      child: _buildWhyRosesWorkSection(),
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
          image: AssetImage('assets/rose_send.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              const Color(0xFFE94057).withOpacity(0.65),
              const Color(0xFFE94057).withOpacity(0.75),
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
                const Icon(Icons.star, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  'STAND OUT',
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
              'Make the first\nmove count',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Roses get 3× more replies. Your profile\nshows on top with a blue star.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // The 4 info tiles row
            if (_infoList.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _infoList.length > 4 ? 4 : _infoList.length,
                  (index) {
                    final info = _infoList[index];
                    IconData iconData = Icons.star;
                    if (index == 1) iconData = Icons.trending_up;
                    if (index == 2) iconData = Icons.chat_bubble_outline;
                    if (index == 3) iconData = Icons.bolt;

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right:
                              index ==
                                  (_infoList.length > 4
                                      ? 3
                                      : _infoList.length - 1)
                              ? 0
                              : 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconData, color: Colors.white, size: 16),
                            const SizedBox(height: 4),
                            Text(
                              info['title'] ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            // ROSES AVAILABLE
            const Text(
              'ROSES AVAILABLE',
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
                  '${RosesScreen.availableRoses}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'roses',
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
              'Each rose puts your profile on top with a star · never expires',
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

    Color themeColor = const Color(0xFFE94057); // Red/Pink for all
    Color themeBgColor = const Color(0xFFFFF0F3);

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
            width: 105,
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
                  'Roses',
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
                            const Color(0xFFFF6575),
                            const Color(0xFFE94057),
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
                                  : const Color(0xFFE94057))
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
              onPressed: () {
                GetRosesDrawer.show(context, selectedPkg, () {
                  setState(() {});
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94057),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Get ${int.parse(selectedPkg['title'])} Roses for ${selectedPkg['totalPrice']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
