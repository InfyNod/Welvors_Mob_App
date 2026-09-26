import 'package:flutter/material.dart';
import 'get_super_boosts_drawer.dart';
import 'service_super.dart';

class SuperBoostScreen extends StatefulWidget {
  static int availableSuperBoosts = 0;

  const SuperBoostScreen({super.key});

  @override
  State<SuperBoostScreen> createState() => _SuperBoostScreenState();
}

class _SuperBoostScreenState extends State<SuperBoostScreen> {
  int _selectedPackageIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];
  List<dynamic> _whyBoostWorks = [];
  Map<String, dynamic>? _boostVsSuperBoost;
  String _title = 'Be the top profile\nin your city';
  String _description = 'Get 10× more views, advanced targeting and\nverified-only mode for 3 full hours.';
  int _timePerBoost = 180; // Default 3 hours = 180 min
  String _durationText = '3 HOURS';
  String _durationShortText = '3hr';

  @override
  void initState() {
    super.initState();
    _fetchBoostsData();
  }

  Future<void> _fetchBoostsData() async {
    setState(() => _isLoading = true);
    final data = await SuperBoostApiService().getSuperBoostsData();
    if (data != null && data['boosts'] != null && data['boosts'].isNotEmpty) {
      final boostData = data['boosts'][0];
      final options = boostData['options'] as List<dynamic>? ?? [];
      
      _packages = options.map((opt) {
        return {
          'title': opt['boostCount'].toString(),
          'subtitle': 'Super Boosts',
          'pricePerItem': '₹${opt['discounted_price']}/each',
          'discount': opt['discount_percent'] != null && opt['discount_percent'] > 0 
              ? 'Save ${opt['discount_percent']}%' 
              : null,
          'oldPrice': opt['discount_percent'] != null && opt['discount_percent'] > 0 
              ? '₹${opt['pricePerBoost']}/each' 
              : null,
          'totalPrice': '₹${opt['totalPrice']} total',
          'tag': opt['is_popular'] == true ? 'POPULAR' : (opt['is_best_value'] == true ? 'BEST VALUE' : null),
          'raw': opt,
        };
      }).toList();
      
      _whyBoostWorks = boostData['whyBoostWorks'] as List<dynamic>? ?? [];
      _boostVsSuperBoost = boostData['boostVsSuperBoost'] as Map<String, dynamic>?;
      SuperBoostScreen.availableSuperBoosts = data['availableBoost'] ?? 0;
      
      if (boostData['title'] != null && boostData['title'].toString().isNotEmpty) {
        _title = boostData['title'];
      }
      if (boostData['description'] != null && boostData['description'].toString().isNotEmpty) {
        _description = boostData['description'];
      }
      if (boostData['timePerBoost'] != null) {
        _timePerBoost = int.tryParse(boostData['timePerBoost'].toString()) ?? 180;
        if (_timePerBoost >= 60 && _timePerBoost % 60 == 0) {
          int hours = _timePerBoost ~/ 60;
          _durationText = '$hours HOUR${hours > 1 ? 'S' : ''}';
          _durationShortText = '${hours}hr';
        } else {
          _durationText = '$_timePerBoost MIN';
          _durationShortText = '${_timePerBoost}min';
        }
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A))) 
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'WHY SUPER BOOST WORKS',
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
              child: _buildWhySuperBoostWorksSection(),
            ),
            const SizedBox(height: 24),
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
      bottomNavigationBar: _isLoading || _packages.isEmpty ? null : _buildBottomBar(),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/super.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.3),
              const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.65),
              const Color.fromARGB(255, 22, 22, 22).withValues(alpha: 0.75),
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✦', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$_durationText • CITYWIDE',
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
                  _buildStatItem('10×', 'MORE VIEWS'),
                  _buildStatItem('5×', 'MORE MATCHES'),
                  _buildStatItem(_durationShortText, 'DURATION'),
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
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                label.replaceFirst(' ', '\n'),
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

    Color themeColor = Colors.black;
    Color themeBgColor = const Color.fromRGBO(255, 253, 246, 1.0);

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
                        color: themeColor.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
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
                        ? [Colors.black87, Colors.black]
                        : [const Color(0xFFFA6A85), const Color(0xFFDE2957)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: tag == 'BEST VALUE'
                          ? Colors.black.withValues(alpha: 0.4)
                          : const Color(0xFFDE2957).withValues(alpha: 0.4),
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

  Widget _buildWhySuperBoostWorksSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_whyBoostWorks.isNotEmpty)
            ..._whyBoostWorks.asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic item = entry.value;
              final bool isLast = index == _whyBoostWorks.length - 1;
              
              IconData iconData = Icons.star;
              if (item['icon'] == 'zap') iconData = Icons.bolt;
              if (item['icon'] == 'trending-up') iconData = Icons.trending_up;
              if (item['icon'] == 'heart') iconData = Icons.favorite;
              if (item['icon'] == 'verified') iconData = Icons.verified;
              if (item['icon'] == 'settings') iconData = Icons.settings;
              if (item['icon'] == 'activity') iconData = Icons.monitor_heart_sharp;
              if (item['icon'] == 'message-circle') iconData = Icons.chat_bubble_outline;
              if (item['icon'] == 'clock') iconData = Icons.access_time;

              Color iconColor = const Color(0xFFF6B042);
              Color iconBgColor = const Color(0xFFFFF8E1);
              
              if (item['icon'] == 'trending-up') {
                iconColor = const Color(0xFFE43A6A);
                iconBgColor = const Color(0xFFFDF0F3);
              } else if (item['icon'] == 'heart' || item['icon'] == 'clock') {
                iconColor = const Color(0xFF34A853);
                iconBgColor = const Color(0xFFE6F4EA);
              } else if (item['icon'] == 'settings') {
                iconColor = const Color(0xFF8E24AA);
                iconBgColor = const Color(0xFFF3E5F5);
              } else if (item['icon'] == 'activity') {
                iconColor = const Color(0xFF2383F6);
                iconBgColor = const Color(0xFFE3F0FF);
              } else if (item['icon'] == 'message-circle') {
                iconColor = const Color(0xFFE43A6A);
                iconBgColor = const Color(0xFFFDF0F3);
              }

              Color tagColor = const Color.fromRGBO(138, 96, 16, 1.0);
              Color tagBgColor = const Color.fromRGBO(255, 244, 224, 1.0);
              
              if (item['tagColor'] != null) {
                tagColor = Color(int.parse(item['tagColor'].toString().replaceFirst('#', '0xFF')));
              } else if (item['icon'] == 'trending-up' || item['icon'] == 'message-circle') {
                tagColor = const Color(0xFFE43A6A);
              }

              if (item['tagBgColor'] != null) {
                tagBgColor = Color(int.parse(item['tagBgColor'].toString().replaceFirst('#', '0xFF')));
              } else if (item['icon'] == 'trending-up' || item['icon'] == 'message-circle') {
                tagBgColor = const Color(0xFFFDF0F3);
              }

              return _buildWhySuperBoostWorkItem(
                icon: iconData,
                iconColor: iconColor,
                iconBgColor: iconBgColor,
                title: item['title'] ?? '',
                subtitle: item['description'] ?? item['subtitle'] ?? '',
                tag: item['tag'],
                tagColor: tagColor,
                tagBgColor: tagBgColor,
                isFirst: index == 0,
                isLast: isLast,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWhySuperBoostWorkItem({
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
          if (_boostVsSuperBoost != null && _boostVsSuperBoost!['features'] != null)
            ...(_boostVsSuperBoost!['features'] as List<dynamic>).asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic featureObj = entry.value;
              final bool isLast = index == (_boostVsSuperBoost!['features'] as List<dynamic>).length - 1;
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
                  '1 free boost every month ·\nUnlimited likes · Verified badge',
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
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${int.parse(selectedPkg['title'])} SUPER BOOSTS · $_durationText EACH',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                selectedPkg['totalPrice'].split(' ')[0],
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
                GetSuperBoostsDrawer.show(context, selectedPkg, () {
                  setState(() {});
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Boosts never expire · Use anytime',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
