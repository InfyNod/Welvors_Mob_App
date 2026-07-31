import 'package:flutter/material.dart';
import '../../../../onbording_allpage/theme/app_colors.dart';
import '../marriage/drawer_marriage_screen.dart';
import '../mature_dating/drawer_mature_dating_screen.dart';
import 'ecosytem_history_support.dart';
import 'privacy_safety_and_membership_plan.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/compliments/compliments_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_boosts/boost_bloc/boost_bloc.dart';
import 'my_boosts/boost_bloc/boost_state.dart';
import 'my_wallet/my_wallet_screen.dart';
import 'roses/roses_screen.dart';
import 'date_plans/date_plan_wallet.dart';
import 'my_boosts/boost_all_screen/boost_top_nav.dart';
import 'edit_profile/top_bottom_nav_editscreen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  int _selectedTabIndex = 1; // 0 = Marriage, 1 = Dating, 2 = Mature Dating

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopTabs(context),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  MarriageScreen(
                    onNavigateToDating: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                  ),       // Index 0
                  _buildDatingContent(),        // Index 1
                  MatureDatingScreen(
                    onNavigateToDating: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                  ),   // Index 2
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabs(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final stackWidth = screenWidth - 40;

    double indicatorLeft;
    double indicatorWidth;
    if (_selectedTabIndex == 0) {
      indicatorWidth = 65.0;
      indicatorLeft = 35.0 - (indicatorWidth / 2);
    } else if (_selectedTabIndex == 1) {
      indicatorWidth = 50.0; // Width of 'Dating'
      indicatorLeft =
          (stackWidth / 2) - (indicatorWidth / 2); // Perfectly centered
    } else {
      indicatorWidth = 105.0; // Width of 'Mature Dating'
      indicatorLeft =
          stackWidth -
          52.5 -
          (indicatorWidth / 2); // Centered at ~52.5px from right
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 0,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 0,
                ), // Padding removed so indicator sits on the grey line

                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        behavior: HitTestBehavior.opaque,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildTabItem('Marriage', 0),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      behavior: HitTestBehavior.opaque,
                      child: _buildTabItem('Dating', 1),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 2),
                        behavior: HitTestBehavior.opaque,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildTabItem('Mature Dating', 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ), // End Padding inside Stack
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                bottom: 0,
                left: indicatorLeft,
                width: indicatorWidth,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ], // End Stack children
          ), // End Stack
        ), // End Padding
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey.shade200,
        ),
      ], // End Column children
    ); // End Column
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7), // Space for the indicator line
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSelected ? 16 : 15,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          color: isSelected ? Colors.black87 : Colors.grey.shade400,
          letterSpacing: isSelected ? 0.3 : 0.0,
        ),
      ),
    );
  }

  Widget _buildDatingContent() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(), // Re-locking the scroll as requested
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Top Section (Gradient + White Background)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF5EC), Colors.white],
                    stops: [0.0, 0.6], // Fades from peach to white
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000), // Very subtle shadow for separation
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(
                  top: 36,
                  bottom: 24,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    _buildProfileSection(animValue),
                    const SizedBox(height: 24),
                    _buildProfileCompletionCard(animValue),
                  ],
                ),
              ),

          // Bottom Section (Grey Background)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionTitle('MY BALANCES'),
                const SizedBox(height: 12),
                _buildBalancesSection(),
                const SizedBox(height: 24),
                _buildDatePlansCard(),
                const SizedBox(height: 24),
                const PrivacySafetyAndMembership(),
                const SizedBox(height: 24),
                const EcosystemHistorySupport(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      );
    },
  ),
);
  }

  Widget _buildProfileSection(double animValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect behind avatar (pink type flow)
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.pinkSoft.withOpacity(1.0), // Stronger pink glow
                AppColors.pinkSoft.withOpacity(0.0),
              ],
              stops: const [0.3, 1.0],
            ),
          ),
        ),
        Column(
          children: [
            // Avatar with % pill and progress ring
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // Circular progress ring
                SizedBox(
                  width: 106,
                  height: 106,
                  child: CircularProgressIndicator(
                    value: 0.75 * animValue,
                    strokeWidth: 5, // Made thicker as requested
                    color: AppColors.pink, // Lighter pink
                    backgroundColor: Colors.white, // Remaining circle is white
                  ),
                ),
                // Inner Avatar Image
                Container(
                  width: 92, // Leave space for gap and stroke
                  height: 92,
                  margin: const EdgeInsets.all(7), // Center it inside the ring
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE5A88B), Color(0xFFC7846B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Percentage Pill
                Positioned(
                  bottom: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pink, // Lighter pink
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ), // White border like screenshot
                    ),
                    child: Text(
                      '${(75 * animValue).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Name and Age
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tanishka',
                  style: TextStyle(
                    fontSize: 24, // slightly larger
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '26',
                  style: TextStyle(
                    fontSize: 24, // slightly larger
                    fontWeight: FontWeight.bold, // made bolder
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Mumbai, India',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold, // bolded
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, // increased width
                    vertical: 10, // increased height
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA7E6D), Color(0xFFEB5076)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEB5076).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Colors.white,
                      ), // Sparkle icon like ✦
                      const SizedBox(width: 6),
                      const Text(
                        'PLATINUM MEMBER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F8EA),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF1EAD5D).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1EAD5D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(98 * animValue).toInt()}% Trust Score',
                        style: const TextStyle(
                          color: Color(0xFF1EAD5D),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard(double animValue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line,
          width: 1.5,
        ), // nice grey border
        boxShadow: AppColors.shadow, // use theme shadow
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(75 * animValue).toInt()}%',
                style: const TextStyle(
                  fontSize: 18, // slightly larger
                  fontWeight: FontWeight.w900,
                  color: AppColors.pink, // lighter pink
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: 250 * animValue, // Roughly 75% mapped to width 250
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF7B466), Color(0xFFE94E78)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildBalancesSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildBalanceCard(
            emoji: '⭐️',
            bgColor: const Color(0xFFFFF4E0),
            value: '${RosesScreen.availableRoses}',
            label: 'Roses',
            hasDot: true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RosesScreen(),
                ),
              );
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildBalanceCard(
            emoji: '💌',
            bgColor: const Color(0xFFFBE4E7),
            value: '${ComplimentsScreen.availableCompliments}',
            label: 'Compliments',
            hasDot: true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComplimentsScreen(),
                ),
              );
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: BlocBuilder<BoostBloc, BoostState>(
            builder: (context, state) {
              final totalBoosts = state.boostBalance + state.superBoostBalance;
              return _buildBalanceCard(
                emoji: '🚀',
                bgColor: const Color(0xFFE5F1FB),
                value: '$totalBoosts',
                label: 'My Boosts',
                hasDot: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BoostTopNav(),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildBalanceCard(
            emoji: '👛',
            bgColor: const Color(0xFFFBE4E7),
            value: '₹3,240',
            label: 'My Wallet',
            hasDot: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyWalletScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required String emoji,
    required Color bgColor,
    required String value,
    required String label,
    required bool hasDot,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded corners
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Soft elegant shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              if (hasDot)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.pink, // The pink color from the image
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4), // Reduced spacing from image
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 0), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDatePlansCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DatePlanWallet(),
          ),
        );
        // Refresh the drawer to show the updated plan count
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4E0), // Soft cream/orange background
              shape: BoxShape.circle,
            ),
            child: const Text('📋', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date Plans',
                  style: TextStyle(
                    fontSize: 16, // larger
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Post dates on Date Now · any activity type',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${DatePlanWallet.availablePlans}',
                style: const TextStyle(
                  fontSize: 22, // larger
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold, // premium gold
                ),
              ),
              Row(
                children: [
                  Text(
                    'left',
                    style: TextStyle(
                      fontSize: 12, // larger
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
