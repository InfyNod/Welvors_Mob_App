import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
// import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_wallet/benefits_drawer.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_wallet/add_money_and_withraw_drawer.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_wallet/transactions_drawer.dart';
import 'package:velvors/onbording_allpage/features/onboarding/refer_and_earn_screen.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWalletCard(),
              const SizedBox(height: 16),
              _buildTopUpCard(),
              const SizedBox(height: 32),
              _buildTransactionsHeader(),
              const SizedBox(height: 16),
              _buildTransactionsList(),
              const SizedBox(height: 40), // Added bottom space
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
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
        'My Wallet',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: InkWell(
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
                Icons.question_mark_rounded,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD84B6D), // rgba(216, 75, 109)
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD84B6D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background subtle curve (Made smaller)
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Card Content (Reduced padding & spacing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.grey.shade300, // Silver coin color
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'WELVORS WALLET',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => WalletBenefitsBottomSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 0.5,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Benefits',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '₹3,240',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use coins for gifts, roses, boosts & plans',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AddMoneyBottomSheet.show(context);
                          },
                          icon: const Icon(
                            Icons.add,
                            color: AppColors.pinkDeep,
                            size: 18,
                          ),
                          label: const Text(
                            'Add Money',
                            style: TextStyle(
                              color: AppColors.pinkDeep,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.pinkDeep,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            WithdrawBottomSheet.show(context);
                          },
                          icon: const Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Withdraw',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReferAndEarnScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE9F6ED), // rgba(233, 246, 237)
            Color.fromARGB(255, 248, 255, 250),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFCDEBD8), // rgba(205, 235, 216)
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
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
            decoration: BoxDecoration(
              color: const Color(0xFF2CAF6B), // rgba(44, 175, 107)
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CAF6B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // Padding added to visually center the emoji perfectly
            child: const Padding(
              padding: EdgeInsets.only(bottom: 2.0),
              child: Text(
                '🎁',
                style: TextStyle(fontSize: 22, height: 1.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top up your wallet — refer friends',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Earn ₹100 when a friend joins + ₹500 when they buy a plan, straight to your wallet',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.green.shade700, size: 24),
        ],
      ),
    ),
    );
  }

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'TRANSACTIONS',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          children: [
            _buildFilterChip('All', _selectedFilter == 'All'),
            const SizedBox(width: 6),
            _buildFilterChip('In', _selectedFilter == 'In'),
            const SizedBox(width: 6),
            _buildFilterChip('Out', _selectedFilter == 'Out'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pinkDeep : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pinkDeep.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final List<Map<String, dynamic>> allTransactions = [
      {
        'icon': '🎁',
        'iconBg': const Color(0xFFFBE4E7),
        'title': 'Gift received from Aanya',
        'time': 'Today · 2:14 PM',
        'amount': '+₹500',
        'isPositive': true,
      },
      {
        'icon': '📋',
        'iconBg': const Color(0xFFFFF3E0),
        'title': 'Date Plans topped up · 3 plans',
        'time': 'Today · 3:20 PM',
        'amount': '-₹270',
        'isPositive': false,
      },
      {
        'icon': '⭐',
        'iconBg': const Color(0xFFFFF9C4),
        'title': 'Rose sent',
        'time': 'Today · 11:02 AM',
        'amount': '-₹50',
        'isPositive': false,
      },
      {
        'icon': '🎁',
        'iconBg': const Color(0xFFE8F5E9),
        'title': 'Refer & Earn — Rahul joined',
        'time': 'Yesterday · 6:40 PM',
        'amount': '+₹100',
        'isPositive': true,
      },
      {
        'icon': '🌹',
        'iconBg': const Color(0xFFFBE4E7),
        'title': 'Premium Rose sent to Aanya',
        'time': 'Yesterday · 9:18 PM',
        'amount': '-₹500',
        'isPositive': false,
      },
      {
        'icon': '➕',
        'iconBg': const Color(0xFFE3F2FD),
        'title': 'Money added · UPI',
        'time': '2 days ago · 1:05 PM',
        'amount': '+₹2,000',
        'isPositive': true,
      },
      {
        'icon': '🚀',
        'iconBg': const Color(0xFFF3E5F5),
        'title': 'Boost activated',
        'time': '3 days ago',
        'amount': '-₹300',
        'isPositive': false,
      },
      {
        'icon': '🎁',
        'iconBg': const Color(0xFFE8F5E9),
        'title': 'Refer & Earn — Sneha bought VIP',
        'time': '4 days ago',
        'amount': '+₹500',
        'isPositive': true,
      },
      {
        'icon': '💌',
        'iconBg': const Color(0xFFFBE4E7),
        'title': 'Compliment sent',
        'time': '5 days ago',
        'amount': '-₹80',
        'isPositive': false,
      },
      {
        'icon': '⬇️',
        'iconBg': const Color(0xFFECEFF1),
        'title': 'Withdrawal to bank',
        'time': '1 week ago',
        'amount': '-₹1,500',
        'isPositive': false,
      },
    ];

    final filteredTransactions = allTransactions.where((tx) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'In') return tx['isPositive'] == true;
      if (_selectedFilter == 'Out') return tx['isPositive'] == false;
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: filteredTransactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          : Column(
              children: filteredTransactions.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> tx = entry.value;
                final bool isLast = index == filteredTransactions.length - 1;

                return Column(
                  children: [
                    _buildTransactionItem(
                      context: context,
                      tx: tx,
                      isLast: isLast,
                    ),
                    if (!isLast)
                      Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                        indent: 68,
                        endIndent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required Map<String, dynamic> tx,
    bool isLast = false,
  }) {
    final String icon = tx['icon'];
    final Color iconBg = tx['iconBg'];
    final String title = tx['title'];
    final String time = tx['time'];
    final String amount = tx['amount'];
    final bool isPositive = tx['isPositive'];

    return GestureDetector(
      onTap: () => TransactionDetailsBottomSheet.show(context, tx),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Reduced vertical padding from 14 to 11 for less up/down gap
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 1.6),
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700, // Slightly more premium weight
                      letterSpacing: -0.2, // Tighter premium letter spacing
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: isPositive ? const Color(0xFF2CAF6B) : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w800, // Bolder numbers
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
