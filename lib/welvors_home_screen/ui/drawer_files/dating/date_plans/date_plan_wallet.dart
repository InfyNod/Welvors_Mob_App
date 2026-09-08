import 'package:flutter/material.dart';
import 'get_date_plans_drawer.dart';

class DatePlanWallet extends StatefulWidget {
  static int availablePlans = 3;

  const DatePlanWallet({super.key});

  @override
  State<DatePlanWallet> createState() => _DatePlanWalletState();
}

class _DatePlanWalletState extends State<DatePlanWallet> {
  int _selectedPackageIndex = 1;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': '03',
      'subtitle': 'Date Plans',
      'pricePerItem': '90',
      'totalPrice': '270',
      'saveTag': 'Save 10%',
      'topTag': null,
    },
    {
      'title': '05',
      'subtitle': 'Date Plans',
      'pricePerItem': '86',
      'totalPrice': '430',
      'saveTag': 'Save 14%',
      'topTag': 'MOST POPULAR',
    },
    {
      'title': '10',
      'subtitle': 'Date Plans',
      'pricePerItem': '80',
      'totalPrice': '800',
      'saveTag': 'Save 20%',
      'topTag': 'BEST VALUE',
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
          'Date Plan Wallet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheet: _buildBottomBar(),
      body: SingleChildScrollView(
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
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
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
            const SizedBox(height: 32),
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWhyBuyPlansList(),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildGoodToKnowList(),
            ),
            const SizedBox(height: 32),
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
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/date_plan.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              const Color(0xFF8B4513).withOpacity(0.55),
              const Color(0xFFF18C28).withOpacity(0.75),
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
                    color: Colors.white.withOpacity(0.9),
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
                color: Colors.white.withOpacity(0.9),
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

  Widget _buildPackageCard(int index) {
    final pkg = _packages[index];
    final bool isSelected = _selectedPackageIndex == index;
    final String? topTag = pkg['topTag'];
    final String saveTag = pkg['saveTag'];

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
                    color: index == 1
                        ? const Color(0xFFF18C28) // Orange for Most Popular
                        : const Color.fromARGB(
                            255,
                            36,
                            35,
                            31,
                          ), // Yellow for Best Value
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (index == 1
                                    ? const Color(0xFFF18C28)
                                    : const Color(0xFFFFD54F))
                                .withOpacity(0.4),
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
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedPkg['title']} PLANS · ${selectedPkg['topTag'] ?? selectedPkg['saveTag']}',
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
          _buildFeatureItem(
            emoji: '📍',
            emojiBgColor: const Color(0xFFFFF3E0),
            number: '1',
            title: 'You post a real plan',
            subtitle:
                'Pick the activity, venue, time and who pays — coffee, dinner, drinks, a walk. One plan covers one posting.',
            isFirst: true,
          ),
          _buildFeatureItem(
            emoji: '👀',
            emojiBgColor: const Color(0xFFE3F2FD),
            number: '2',
            title: 'Nearby people see it live',
            subtitle:
                'It goes into the Date Now feed for everyone matching your filters, until the time passes.',
          ),
          _buildFeatureItem(
            emoji: '✉️',
            emojiBgColor: const Color(0xFFF5F5F5),
            number: '3',
            title: 'They request to join',
            subtitle:
                'Requests arrive with a message and a bill suggestion. Nobody gets your exact location — only the venue.',
          ),
          _buildFeatureItem(
            emoji: '🤝',
            emojiBgColor: const Color(0xFFFFF8E1),
            number: '4',
            title: 'You approve who joins',
            subtitle:
                'Approve one person for a one-on-one, or a few for a small group meet — everyone approved drops straight into chat with the date details.',
          ),
          _buildFeatureItem(
            emoji: '💞',
            emojiBgColor: const Color(0xFFFCE4EC),
            number: '5',
            title: 'You meet in real life',
            subtitle:
                'Show up, enjoy the evening, and share how it went afterwards. Good dates lift your Trust Score and bring better people to your next plan.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyBuyPlansList() {
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
          _buildFeatureItem(
            emoji: '⚡',
            emojiBgColor: const Color(0xFFFFF9C4),
            number: null,
            title: 'Skip weeks of texting',
            subtitle:
                'You meet the same evening instead of chatting for three weeks and fading out.',
            isFirst: true,
          ),
          _buildFeatureItem(
            emoji: '🎯',
            emojiBgColor: const Color(0xFFE1F5FE),
            number: null,
            title: 'You set the terms',
            subtitle:
                'Your venue, your time, your bill preference, and which plans a Free, Premium, VIP or Elite member can see.',
          ),
          _buildFeatureItem(
            emoji: '🚀',
            emojiBgColor: const Color(0xFFFFF3E0),
            number: null,
            title: 'Boost-ready',
            subtitle:
                'Any live plan can be pinned to the top of the feed for 3 hours — more views, more requests.',
          ),
          _buildFeatureItem(
            emoji: '♾️',
            emojiBgColor: const Color(0xFFE8F5E9),
            number: null,
            title: 'Nothing is wasted',
            subtitle:
                'Plans never expire. If a plan gets no requests or you cancel before it starts, the plan returns to your wallet.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGoodToKnowList() {
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
          _buildFeatureItem(
            emoji: '🪙',
            emojiBgColor: const Color(0xFFF5F5F5),
            number: null,
            title: 'Paid with wallet coins',
            subtitle:
                '1 plan = 🪙 100 at single rate, less in a pack. Coins from referrals and gifts count too.',
            isFirst: true,
          ),
          _buildFeatureItem(
            emoji: '📆',
            emojiBgColor: const Color(0xFFFCE4EC),
            number: null,
            title: 'Up to 2 live at a time',
            subtitle:
                'You can host two plans simultaneously — one today, one for the weekend.',
          ),
          _buildFeatureItem(
            emoji: '🛡️',
            emojiBgColor: const Color(0xFFFFEBEE),
            number: null,
            title: 'Verified members only',
            subtitle:
                'Only ID-verified members can send you a request, and you can report anyone in one tap.',
            isLast: true,
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
