import 'package:flutter/material.dart';
import 'get_date_plans_drawer.dart';
import 'service_date.dart';

class DatePlanWallet extends StatefulWidget {
  static int availablePlans = 0;

  const DatePlanWallet({super.key});

  @override
  State<DatePlanWallet> createState() => _DatePlanWalletState();
}

class _DatePlanWalletState extends State<DatePlanWallet> {
  int _selectedPackageIndex = 1;
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _howOnePlanWorks = [];
  List<Map<String, dynamic>> _whyPeopleBuyPlans = [];
  List<Map<String, dynamic>> _goodToKnow = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final service = DatePlanApiService();
    final data = await service.getDatePlansData();
    if (data != null && mounted) {
      setState(() {
        DatePlanWallet.availablePlans = data['availableDatePlan'] ?? 0;

        final packs = data['packages'] as List<dynamic>? ?? [];
        _packages = packs.map((p) {
          final planCount = p['planCount']?.toString() ?? '0';
          final discount = p['discount']?.toString() ?? '0';
          String saveTag = int.tryParse(discount) != null && int.parse(discount) > 0 ? 'Save $discount%' : '';
          
          String? topTag;
          if (p['isPopular'] == true) {
            topTag = 'MOST POPULAR';
          } else if (int.tryParse(discount) != null && int.parse(discount) >= 20) {
             topTag = 'BEST VALUE';
          }

          return {
            'id': p['id'],
            'title': planCount.padLeft(2, '0'),
            'subtitle': 'Date Plans',
            'pricePerItem': p['pricePerPlan']?.toString() ?? '0',
            'totalPrice': p['price']?.toString() ?? '0',
            'saveTag': saveTag.isNotEmpty ? saveTag : null,
            'topTag': topTag,
          };
        }).toList();

        final info = data['info'] ?? {};
        _howOnePlanWorks = List<Map<String, dynamic>>.from(info['howOnePlanWorks'] ?? []);
        _whyPeopleBuyPlans = List<Map<String, dynamic>>.from(info['whyPeopleBuyPlans'] ?? []);
        _goodToKnow = List<Map<String, dynamic>>.from(info['goodToKnow'] ?? []);
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
                    color: Colors.black.withValues(alpha: 0.04),
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
          'Date Plan Wallet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheet: _isLoading ? null : _buildBottomBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'BUY MORE PLANS',
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
            ),
            const SizedBox(height: 16),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  children: const [
                    TextSpan(
                      text: 'Plans are bought with your Welvors Wallet coins. ',
                    ),
                    TextSpan(
                      text: 'Top up wallet ›',
                      style: TextStyle(
                        color: Color(0xFFF18C28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'HOW ONE PLAN WORKS',
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
              child: _buildFeatureList(),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'WHY PEOPLE BUY PLANS',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWhyBuyPlansList(),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'GOOD TO KNOW',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildGoodToKnowList(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
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
          image: AssetImage('assets/dateplan.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.3),
              const Color(0xFF8B4513).withValues(alpha: 0.55),
              const Color(0xFFF18C28).withValues(alpha: 0.75),
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
                const Icon(Icons.assignment, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  'POST A DATE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Turn a planinto a real date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Each plan lets you post one date on Date Now - any activity type.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.location_on,
                    Colors.white,
                    'Any venueyou pick',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.calendar_today,
                    Colors.white,
                    'Today orthis weekend',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.handshake,
                    Colors.white,
                    'You approvewho joins',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsideBannerCard(
                    Icons.all_inclusive,
                    Colors.white,
                    'Plans neverexpire',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'DATE PLANS AVAILABLE',
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
                  '${DatePlanWallet.availablePlans}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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

  Widget _buildPackageCard(int index) {
    final pkg = _packages[index];
    final bool isSelected = _selectedPackageIndex == index;
    final String? topTag = pkg['topTag'];

    Color themeColor = const Color(0xFFF18C28); // Orange/Brown for all plans
    Color themeBgColor = const Color(0xFFFFF9F0);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
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
                        color: themeColor.withValues(alpha: 0.15),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.token, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Text(
                      '${pkg['pricePerItem']}/each',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.token, size: 10, color: Colors.grey.shade400),
                    const SizedBox(width: 2),
                    Text(
                      '${pkg['totalPrice']} total',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 9,
                      ),
                    ),
                  ],
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
          if (topTag != null)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: index == 1
                          ? [
                              const Color.fromARGB(255, 238, 161, 84),
                              const Color(0xFFF18C28),
                            ] // Gold/Orange for Most Popular
                          : [
                              const Color(0xFF434343),
                              Colors.black,
                            ], // Black/Dark for Best Value
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (index == 1
                                    ? const Color(0xFFF18C28)
                                    : Colors.black)
                                .withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    topTag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
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
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedPkg['title']} PLANS · ${selectedPkg['topTag'] ?? selectedPkg['saveTag'] ?? 'TRY IT OUT'}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
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
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                GetDatePlansDrawer.show(context, selectedPkg, () {
                  setState(() {});
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF18C28),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Get plans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Date Plans never expire. Unused plans stay in your wallet.',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    if (_howOnePlanWorks.isEmpty) return const SizedBox.shrink();

    final emojisData = [
      {'emoji': '📍', 'bgColor': const Color(0xFFFFF3E0)},
      {'emoji': '👀', 'bgColor': const Color(0xFFE3F2FD)},
      {'emoji': '✉️', 'bgColor': const Color(0xFFF5F5F5)},
      {'emoji': '🤝', 'bgColor': const Color(0xFFFFF8E1)},
      {'emoji': '💞', 'bgColor': const Color(0xFFFCE4EC)},
    ];

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
        children: List.generate(_howOnePlanWorks.length, (index) {
          final info = _howOnePlanWorks[index];
          final emojiMap = emojisData[index % emojisData.length];
          return _buildFeatureItem(
            emoji: emojiMap['emoji'] as String,
            emojiBgColor: emojiMap['bgColor'] as Color,
            number: '${index + 1}',
            title: info['title'] ?? '',
            subtitle: info['description'] ?? '',
            isFirst: index == 0,
            isLast: index == _howOnePlanWorks.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildWhyBuyPlansList() {
    if (_whyPeopleBuyPlans.isEmpty) return const SizedBox.shrink();

    final emojisData = [
      {'emoji': '⚡', 'bgColor': const Color(0xFFFFF9C4)},
      {'emoji': '🎯', 'bgColor': const Color(0xFFE1F5FE)},
      {'emoji': '🚀', 'bgColor': const Color(0xFFFFF3E0)},
      {'emoji': '♾️', 'bgColor': const Color(0xFFE8F5E9)},
    ];

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
        children: List.generate(_whyPeopleBuyPlans.length, (index) {
          final info = _whyPeopleBuyPlans[index];
          final emojiMap = emojisData[index % emojisData.length];
          return _buildFeatureItem(
            emoji: emojiMap['emoji'] as String,
            emojiBgColor: emojiMap['bgColor'] as Color,
            number: null,
            title: info['title'] ?? '',
            subtitle: info['description'] ?? '',
            isFirst: index == 0,
            isLast: index == _whyPeopleBuyPlans.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildGoodToKnowList() {
    if (_goodToKnow.isEmpty) return const SizedBox.shrink();

    final emojisData = [
      {'emoji': '🪙', 'bgColor': const Color(0xFFF5F5F5)},
      {'emoji': '📆', 'bgColor': const Color(0xFFFCE4EC)},
      {'emoji': '🛡️', 'bgColor': const Color(0xFFFFEBEE)},
    ];

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
        children: List.generate(_goodToKnow.length, (index) {
          final info = _goodToKnow[index];
          final emojiMap = emojisData[index % emojisData.length];
          return _buildFeatureItem(
            emoji: emojiMap['emoji'] as String,
            emojiBgColor: emojiMap['bgColor'] as Color,
            number: null,
            title: info['title'] ?? '',
            subtitle: info['description'] ?? '',
            isFirst: index == 0,
            isLast: index == _goodToKnow.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String emoji,
    required Color emojiBgColor,
    String? number,
    required String title,
    required String subtitle,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: emojiBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number != null ? '$number · $title' : title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
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
            color: Colors.grey.withValues(alpha: 0.15),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
