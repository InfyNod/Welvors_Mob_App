import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController =
      TextEditingController(text: '500');
  String _selectedMethod = 'UPI';

  final List<Map<String, dynamic>> predefinedAmounts = [
    {'amount': 200, 'bonus': 0},
    {'amount': 500, 'bonus': 0},
    {'amount': 1000, 'bonus': 0},
    {'amount': 2000, 'bonus': 100},
    {'amount': 5000, 'bonus': 250},
    {'amount': 10000, 'bonus': 500},
  ];

  String _selectedHistoryFilter = 'All';

  final List<Map<String, dynamic>> _mockHistory = [
    {
      'month': 'THIS MONTH',
      'items': [
        {
          'title': 'Added via UPI',
          'subtitle': '12 Aug · tanishka@oksbi',
          'amount': '+₹2,000',
          'status': 'SUCCESS',
          'isSuccess': true,
          'icon': Icons.phone_android,
          'iconColor': const Color(0xFF2CAF6B),
          'iconBg': const Color(0xFFE9F6ED),
          'txnId': 'TOP-4471209',
          'hasDetails': true,
          'amountPaid': '₹2,000',
          'bonusCoins': '+₹100',
          'credited': '2,100',
        },
        {
          'title': 'Added via Card',
          'subtitle': '6 Aug · HDFC •••• 4821',
          'amount': '+₹1,000',
          'status': 'SUCCESS',
          'isSuccess': true,
          'icon': Icons.credit_card,
          'iconColor': Colors.orange,
          'iconBg': const Color(0xFFFFF4E0),
          'txnId': 'TOP-4409866',
        },
        {
          'title': 'Add money failed',
          'subtitle': '3 Aug · UPI timed out · not charged',
          'amount': '+₹500',
          'status': 'FAILED',
          'isSuccess': false,
          'icon': Icons.phone_android,
          'iconColor': Colors.red.shade600,
          'iconBg': const Color(0xFFFBE4E7),
          'txnId': 'TOP-4388120',
        },
      ],
    },
    {
      'month': 'JULY 2026',
      'items': [
        {
          'title': 'Added via UPI',
          'subtitle': '24 Jul · tanishka@oksbi',
          'amount': '+₹5,000',
          'status': 'SUCCESS',
          'isSuccess': true,
          'icon': Icons.phone_android,
          'iconColor': const Color(0xFF2CAF6B),
          'iconBg': const Color(0xFFE9F6ED),
          'txnId': 'TOP-4188735',
          'hasDetails': true,
          'amountPaid': '₹5,000',
          'bonusCoins': '+₹250',
          'credited': '5,250',
        },
        {
          'title': 'Added via Net banking',
          'subtitle': '11 Jul · HDFC Bank',
          'amount': '+₹1,500',
          'status': 'SUCCESS',
          'isSuccess': true,
          'icon': Icons.account_balance,
          'iconColor': Colors.blue.shade700,
          'iconBg': const Color(0xFFE8F1FA),
          'txnId': 'TOP-4092214',
        },
        {
          'title': 'Added via UPI',
          'subtitle': '2 Jul · tanishka@oksbi',
          'amount': '+₹500',
          'status': 'SUCCESS',
          'isSuccess': true,
          'icon': Icons.phone_android,
          'iconColor': const Color(0xFF2CAF6B),
          'iconBg': const Color(0xFFE9F6ED),
          'txnId': 'TOP-4001558',
        },
      ],
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int get _currentAmount {
    return int.tryParse(_amountController.text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
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
          'Add money',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              indicatorColor: const Color(0xFFE85A7A),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.grey.shade200,
              tabAlignment: TabAlignment.start,
              tabs: [
                const Tab(text: 'Add money'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('History'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1 ? const Color(0xFFFBE4E7) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '6',
                          style: TextStyle(
                            fontSize: 10,
                            color: _tabController.index == 1 ? const Color(0xFFE85A7A) : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddMoneyTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildAddMoneyTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add money',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Top up your Welvors wallet — instant, secure.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Grid of amounts
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: predefinedAmounts.map((item) {
                    final amount = item['amount'] as int;
                    final bonus = item['bonus'] as int;
                    final isSelected = _currentAmount == amount;

                    return GestureDetector(
                      onTap: () {
                        _amountController.text = amount.toString();
                      },
                      child: Container(
                        width:
                            (MediaQuery.of(context).size.width - 48 - 24) / 3,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? const Color(0xFFFBE4E7) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFFE85A7A),
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: isSelected
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '₹$amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFFE85A7A)
                                    : Colors.black87,
                              ),
                            ),
                            if (bonus > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+$bonus bonus',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2CAF6B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Custom amount input
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '₹ ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_arrow_up, size: 16, color: Colors.black54),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Payment methods
                const Text(
                  'PAY USING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPaymentMethod(
                  'UPI',
                  '📱',
                  'UPI · GPay, PhonePe, Paytm',
                ),
                const SizedBox(height: 8),
                _buildPaymentMethod('Card', '💳', 'Credit / Debit Card'),
                const SizedBox(height: 8),
                _buildPaymentMethod('NetBanking', '🏦', 'Net Banking'),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentAmount > 0
                    ? () {
                        // Payment Logic
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentAmount > 0
                      ? const Color(0xFFE85A7A)
                      : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentAmount > 0
                      ? 'Add ₹$_currentAmount'
                      : 'Enter amount to add',
                  style: TextStyle(
                    color:
                        _currentAmount > 0 ? Colors.white : Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String id, String icon, String title) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE4E7) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE85A7A) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 1.0, bottom: 0.5),
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE85A7A)
                      : Colors.grey.shade300,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Added Banner (Premium Design)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)], // Light mint greens
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CAF6B).withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 90,
                    color: const Color(0xFF2CAF6B).withValues(alpha: 0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            color: Color(0xFF2CAF6B),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'TOTAL ADDED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF166534), // Darker green
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '₹10,350',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF14532D), // Very dark green
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lifetime wallet top-ups',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF166534).withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 16),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChip('All', 6),
                const SizedBox(width: 8),
                _buildFilterChip('Success', 5),
                const SizedBox(width: 8),
                _buildFilterChip('Failed', 1),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // History List
          ..._mockHistory.map((monthData) {
            final month = monthData['month'] as String;
            final items = monthData['items'] as List<Map<String, dynamic>>;
            
            // Filter items
            final filteredItems = items.where((item) {
              if (_selectedHistoryFilter == 'All') return true;
              if (_selectedHistoryFilter == 'Success') return item['isSuccess'] == true;
              if (_selectedHistoryFilter == 'Failed') return item['isSuccess'] == false;
              return false;
            }).toList();
            
            if (filteredItems.isEmpty) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...filteredItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildHistoryCard(
                      title: item['title'],
                      subtitle: item['subtitle'],
                      amount: item['amount'],
                      status: item['status'],
                      isSuccess: item['isSuccess'],
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      iconBg: item['iconBg'],
                      txnId: item['txnId'],
                      hasDetails: item['hasDetails'] ?? false,
                      amountPaid: item['amountPaid'],
                      bonusCoins: item['bonusCoins'],
                      credited: item['credited'],
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
            );
          }),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterType, int count) {
    final bool isSelected = _selectedHistoryFilter == filterType;
    final String label = '$filterType $count';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHistoryFilter = filterType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE4E7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE85A7A) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE85A7A) : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required bool isSuccess,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String txnId,
    bool hasDetails = false,
    String? amountPaid,
    String? bonusCoins,
    String? credited,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10), // Rounded square
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSuccess ? const Color(0xFF1EA85A) : Colors.red.shade600, // Strong red
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSuccess ? const Color(0xFF1EA85A) : Colors.red.shade600, // Strong red
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (hasDetails) ...[
            const SizedBox(height: 12),
            // Custom dashed line
            Row(
              children: List.generate(
                35,
                (index) => Expanded(
                  child: Container(
                    height: 1.5,
                    color: index.isEven ? Colors.grey.shade200 : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Amount paid', amountPaid ?? ''),
            const SizedBox(height: 4),
            _buildDetailRow('Bonus coins', bonusCoins ?? '', isGreen: true),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credited to wallet',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      credited ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 10),
          Text(
            txnId,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFF1EA85A) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
