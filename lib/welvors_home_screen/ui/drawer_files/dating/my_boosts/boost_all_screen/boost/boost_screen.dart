import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';
import 'get_boosts_drawer.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_all_screen/boost/service_boost.dart';

class BoostScreen extends StatefulWidget {
  static int availableBoosts = 0;

  const BoostScreen({super.key});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  int _selectedPackageIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];
  List<dynamic> _whyBoostWorks = [];
  Map<String, dynamic>? _boostVsSuperBoost;
  String _title = 'Be a top profile\nin your area';
  String _description =
      'Get 5× more profile views and stand out to\nyour most compatible matches instantly.';
  int _timePerBoost = 30;

  @override
  void initState() {
    super.initState();
    _fetchBoostsData();
  }

  Future<void> _fetchBoostsData() async {
    setState(() => _isLoading = true);
    final data = await BoostApiService().getBoostsData();
    if (data != null && data['boosts'] != null && data['boosts'].isNotEmpty) {
      final boostData = data['boosts'][0];
      final options = boostData['options'] as List<dynamic>? ?? [];

      _packages = options.map((opt) {
        return {
          'title': opt['boostCount'].toString(),
          'subtitle': 'Boosts',
          'pricePerItem': '₹${opt['discounted_price']}/each',
          'discount':
              opt['discount_percent'] != null && opt['discount_percent'] > 0
              ? 'Save ${opt['discount_percent']}%'
              : null,
          'oldPrice':
              opt['discount_percent'] != null && opt['discount_percent'] > 0
              ? '₹${opt['pricePerBoost']}/each'
              : null,
          'totalPrice': '₹${opt['totalPrice']} total',
          'tag': opt['is_popular'] == true
              ? 'POPULAR'
              : (opt['is_best_value'] == true ? 'BEST VALUE' : null),
          'raw': opt,
        };
      }).toList();

      _whyBoostWorks = boostData['whyBoostWorks'] as List<dynamic>? ?? [];
      _boostVsSuperBoost =
          boostData['boostVsSuperBoost'] as Map<String, dynamic>?;
      BoostScreen.availableBoosts = data['availableBoost'] ?? 0;

      if (boostData['title'] != null &&
          boostData['title'].toString().isNotEmpty) {
        _title = boostData['title'];
      }
      if (boostData['description'] != null &&
          boostData['description'].toString().isNotEmpty) {
        _description = boostData['description'];
      }
      if (boostData['timePerBoost'] != null) {
        _timePerBoost =
            int.tryParse(boostData['timePerBoost'].toString()) ?? 30;
      }

      int selectedIdx = _packages.indexWhere((p) => p['tag'] == 'POPULAR');
      _selectedPackageIndex = selectedIdx == -1 ? 0 : selectedIdx;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBanner(),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'CHOOSE YOUR PACK',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPackageSelection(),
                  const SizedBox(height: 24),

                  if (_whyBoostWorks.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'WHY BOOST WORKS',
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
                      child: _buildWhyBoostWorksSection(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_boostVsSuperBoost != null &&
                      _boostVsSuperBoost!['features'] != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'BOOST VS SUPER BOOST',
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
                      child: _buildComparisonSection(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR GET PREMIUM',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPremiumBanner(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: _isLoading || _packages.isEmpty
          ? null
          : _buildBottomBar(),
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
          image: AssetImage('assets/boost.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              const Color(0xFFDE2957).withOpacity(0.45),
              const Color(0xFFDE2957).withOpacity(0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$_timePerBoost MIN • NEARBY',
                    style: const TextStyle(
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
            Text(
              _title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('5×', 'MORE VIEWS'),
                  _buildStatItem('3×', 'MORE MATCHES'),
                  _buildStatItem('${_timePerBoost}min', 'DURATION'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label.replaceFirst(' ', '\n'), // Splits MORE VIEWS to 2 lines
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_packages.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPackageCard(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPackageCard(int index) {
    final pkg = _packages[index];
    final bool isSelected = _selectedPackageIndex == index;
    final String? tag = pkg['tag'];

    Color themeColor = const Color(0xFFDE2957);
    Color themeBgColor = const Color(0xFFFDF0F3);

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
                color: isSelected ? themeColor : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: themeColor.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                Text(
                  pkg['subtitle'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
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
                  pkg['totalPrice'],
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
                    colors: tag == 'BEST VALUE'
                        ? [const Color(0xFFFA6A85), const Color(0xFFDE2957)]
                        : [const Color(0xFF4A4A4A), const Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (tag == 'BEST VALUE'
                                  ? const Color(0xFFDE2957)
                                  : Colors.black)
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
                '${selectedPkg['title']} BOOSTS · $_timePerBoost MIN EACH',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                selectedPkg['totalPrice'].split(
                  ' ',
                )[0], // gets just the amount like ₹2,150
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
              onPressed: () {
                GetBoostsDrawer.show(context, selectedPkg, () {
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
        children: _whyBoostWorks.asMap().entries.map((entry) {
          final int index = entry.key;
          final dynamic item = entry.value;
          final bool isLast = index == _whyBoostWorks.length - 1;

          IconData iconData = Icons.star;
          if (item['icon'] == 'zap') iconData = Icons.bolt;
          if (item['icon'] == 'trending-up') iconData = Icons.trending_up;
          if (item['icon'] == 'heart') iconData = Icons.favorite;

          Color iconColor = const Color(0xFFE43A6A);
          Color iconBgColor = const Color(0xFFFDF0F3);

          if (item['icon'] == 'trending-up') {
            iconColor = const Color(0xFF34A853);
            iconBgColor = const Color(0xFFE6F4EA);
          } else if (item['icon'] == 'heart') {
            iconColor = const Color(0xFFF6B042);
            iconBgColor = const Color(0xFFFFF3E0);
          }

          return _buildWhyBoostWorkItem(
            icon: iconData,
            iconColor: iconColor,
            iconBgColor: iconBgColor,
            title: item['title'] ?? '',
            subtitle: item['description'] ?? '',
            tag: item['tag'],
            tagColor: const Color(0xFFE43A6A),
            tagBgColor: const Color(0xFFFDF0F3),
            isFirst: index == 0,
            isLast: isLast,
          );
        }).toList(),
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

  Widget _buildComparisonSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "What's the difference?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFAFAFA),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'FEATURE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'BOOST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'SUPER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_boostVsSuperBoost != null &&
              _boostVsSuperBoost!['features'] != null)
            ...(_boostVsSuperBoost!['features'] as List<dynamic>)
                .asMap()
                .entries
                .map((entry) {
                  final int index = entry.key;
                  final dynamic featureObj = entry.value;
                  final bool isLast =
                      index ==
                      (_boostVsSuperBoost!['features'] as List<dynamic>)
                              .length -
                          1;
                  return _buildComparisonRow(
                    featureObj['feature'] ?? '',
                    featureObj['boost'] ?? '',
                    featureObj['super'] ?? '',
                    isLast: isLast,
                  );
                }),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String boostValue,
    String superValue, {
    bool isLast = false,
  }) {
    final boostColor = const Color(0xFFE43A6A); // Pink
    final superColor = const Color(0xFFE69A2B); // Orange

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    boostValue,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: boostColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    superValue,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: superColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Go Premium+',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '1 free boost every month ·\nUnlimited likes - Verified badge',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  'View ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.white, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
