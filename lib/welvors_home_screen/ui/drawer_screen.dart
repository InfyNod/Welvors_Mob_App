import 'package:flutter/material.dart';
import 'marriage_screen.dart';
import 'mature_dating_screen.dart';

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
      color: const Color(0xFFFCF9F5),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopTabs(context),
            Expanded(
              child: _selectedTabIndex == 1
                  ? _buildDatingContent()
                  : (_selectedTabIndex == 0
                        ? const MarriageScreen()
                        : const MatureDatingScreen()),
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
      indicatorWidth = 65.0; // Width of 'Marriage'
      indicatorLeft =
          35.0 - (indicatorWidth / 2); // Centered at ~35px from left
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10), // Reduced top spacing as requested
          _buildProfileSection(),
          const SizedBox(height: 24),
          _buildProfileCompletionCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('MY BALANCES'),
          const SizedBox(height: 12),
          _buildBalancesSection(),
          const SizedBox(height: 24),
          _buildDatePlansCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('PRIVACY & SAFETY'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.pink.shade100.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Column(
          children: [
            // Avatar with % pill
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE5A88B), Color(0xFFC7846B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.pinkAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFE5A88B), Color(0xFFC7846B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '62%',
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
            const SizedBox(height: 20),
            // Name and Age
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tanishka',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '26',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
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
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA7E6D), Color(0xFFEB5076)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'PLATINUM MEMBER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F8EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1EAD5D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '98% Trust Score',
                        style: TextStyle(
                          color: Color(0xFF1EAD5D),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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

  Widget _buildProfileCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
              const Text(
                '75%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.pinkAccent,
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
                width: 250, // Roughly 75%
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
          Container(
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
        _buildBalanceCard(
          icon: Icons.star,
          iconColor: Colors.amber.shade300,
          value: '3',
          label: 'Roses',
          hasDot: true,
        ),
        _buildBalanceCard(
          icon: Icons.favorite,
          iconColor: Colors.pinkAccent.shade100,
          value: '5',
          label: 'Compliments',
          hasDot: true,
        ),
        _buildBalanceCard(
          icon: Icons.rocket_launch,
          iconColor: Colors.blueAccent.shade100,
          value: '1',
          label: 'My Boosts',
          hasDot: true,
        ),
        _buildBalanceCard(
          icon: Icons.account_balance_wallet,
          iconColor: Colors.pink.shade200,
          value: '₹3,240',
          label: 'My Wallet',
          hasDot: false,
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool hasDot,
  }) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (hasDot)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePlansCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.paste, color: Colors.brown.shade300),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date Plans',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
                '3',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange.shade400,
                ),
              ),
              Text(
                'left ›',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
