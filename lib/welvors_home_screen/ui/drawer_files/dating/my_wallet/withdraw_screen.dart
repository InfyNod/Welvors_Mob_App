import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController =
      TextEditingController(text: '3240');
  final int _walletBalance = 3240;
  String _selectedAccount = 'HDFC';

  String _selectedHistoryFilter = 'All';

  final List<Map<String, dynamic>> _mockHistory = [
    {
      'month': 'THIS MONTH',
      'items': [
        {
          'title': 'Withdrawn to bank',
          'subtitle': '14 Aug · HDFC •••• 1234',
          'amount': '−₹2,000',
          'status': 'PROCESSING',
          'icon': Icons.account_balance,
          'iconColor': Colors.orange.shade700,
          'iconBg': const Color(0xFFFFF3E0),
          'txnId': 'WDR-1204471',
          'hasDetails': true,
          'withdrawalAmount': '₹2,000',
          'serviceCharge': '−₹500',
          'receivedLabel': 'You will receive',
          'receivedAmount': '₹1,500',
        },
        {
          'title': 'Withdrawn to UPI',
          'subtitle': '5 Aug · tanishka@oksbi',
          'amount': '−₹1,500',
          'status': 'PROCESSED',
          'icon': Icons.phone_android,
          'iconColor': const Color(0xFF2CAF6B),
          'iconBg': const Color(0xFFE9F6ED),
          'txnId': 'WDR-1180093',
          'hasDetails': true,
          'withdrawalAmount': '₹1,500',
          'serviceCharge': '−₹375',
          'receivedLabel': 'Received in bank',
          'receivedAmount': '₹1,125',
        },
      ],
    },
    {
      'month': 'JULY 2026',
      'items': [
        {
          'title': 'Withdrawn to bank',
          'subtitle': '22 Jul · HDFC •••• 1234',
          'amount': '−₹1,000',
          'status': 'PROCESSED',
          'icon': Icons.account_balance,
          'iconColor': const Color(0xFF2CAF6B),
          'iconBg': const Color(0xFFE9F6ED),
          'txnId': 'WDR-1098742',
          'hasDetails': true,
          'withdrawalAmount': '₹1,000',
          'serviceCharge': '−₹250',
          'receivedLabel': 'Received in bank',
          'receivedAmount': '₹750',
        },
        {
          'title': 'Withdrawal reversed',
          'subtitle': '9 Jul · bank rejected · refunded to wallet',
          'amount': '−₹800',
          'status': 'REVERSED',
          'icon': Icons.account_balance,
          'iconColor': Colors.grey.shade600,
          'iconBg': Colors.grey.shade100,
          'txnId': 'WDR-1041338',
          'hasDetails': false,
        },
      ],
    },
    {
      'month': 'JUNE 2026',
      'items': [
        {
          'title': 'Withdrawn to UPI',
          'subtitle': '18 Jun · tanishka@oksbi',
          'amount': '−₹1,200',
          'status': 'PROCESSED',
          'icon': Icons.phone_android,
          'iconColor': const Color(0xFF2CAF6B),
          'iconBg': const Color(0xFFE9F6ED),
          'txnId': 'WDR-0977215',
          'hasDetails': true,
          'withdrawalAmount': '₹1,200',
          'serviceCharge': '−₹300',
          'receivedLabel': 'Received in bank',
          'receivedAmount': '₹900',
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
          'Withdraw',
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
                const Tab(text: 'Withdraw'),
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
                          '5',
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
          _buildWithdrawTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildWithdrawTab() {
    final serviceCharge = (_currentAmount * 0.25).toInt();
    final youReceive = _currentAmount - serviceCharge;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdraw to bank',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Move wallet balance to your bank or UPI.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  'Available balance: ₹$_walletBalance',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2CAF6B),
                  ),
                ),
                const SizedBox(height: 24),

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
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              if (newValue.text.isEmpty) return newValue;
                              final int? value = int.tryParse(newValue.text);
                              if (value != null && value > _walletBalance) {
                                return oldValue;
                              }
                              return newValue;
                            }),
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 244, 224, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'A 25% service charge',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(138, 90, 0, 1),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'applies to all withdrawals. Tip: use your balance for gifts, boosts & plans to get full value.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(138, 90, 0, 1),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Breakdown section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(239, 234, 226, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildBreakdownRow(
                        'Withdrawal amount',
                        '₹$_currentAmount',
                        Colors.black87,
                      ),
                      const SizedBox(height: 8),
                      _buildBreakdownRow(
                        'Service charge (25%)',
                        '-₹$serviceCharge',
                        const Color(0xFFE85A7A),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 8),
                      _buildBreakdownRow(
                        'You receive',
                        '₹$youReceive',
                        const Color(0xFF2CAF6B),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bank accounts
                _buildAccountItem('HDFC', '🏦', 'HDFC •••• 1234'),
                const SizedBox(height: 8),
                _buildAccountItem('UPI', '📱', 'tanishka@oksbi'),
                const SizedBox(height: 12),
                
                // Add Account Button
                GestureDetector(
                  onTap: () {
                    // Logic to add a new account
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Add new account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _currentAmount > 0
                      ? () {
                          // Withdraw Logic
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
                        ? 'Withdraw ₹$youReceive'
                        : 'Enter amount to withdraw',
                    style: TextStyle(
                      color: _currentAmount > 0
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem(String id, String icon, String title) {
    final isSelected = _selectedAccount == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAccount = id),
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
                    color: Colors.black.withOpacity(0.04),
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
                    ? Colors.white.withOpacity(0.6)
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
          // Total Received Banner (Premium Design)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFBE4E7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE85A7A).withOpacity(0.08),
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
                    Icons.account_balance,
                    size: 90,
                    color: const Color(0xFFE85A7A).withOpacity(0.05),
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
                            color: const Color(0xFFFBE4E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Color(0xFFE85A7A),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'TOTAL RECEIVED IN BANK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE85A7A),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '₹2,775',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD84B6D),
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lifetime successfully processed',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFD84B6D).withOpacity(0.7),
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
                _buildFilterChip('All', 5),
                const SizedBox(width: 8),
                _buildFilterChip('Processed', 3),
                const SizedBox(width: 8),
                _buildFilterChip('Processing', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Reversed', 1),
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
              if (_selectedHistoryFilter == 'Processed') return item['status'] == 'PROCESSED';
              if (_selectedHistoryFilter == 'Processing') return item['status'] == 'PROCESSING';
              if (_selectedHistoryFilter == 'Reversed') return item['status'] == 'REVERSED';
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
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      iconBg: item['iconBg'],
                      txnId: item['txnId'],
                      hasDetails: item['hasDetails'] ?? false,
                      withdrawalAmount: item['withdrawalAmount'],
                      serviceCharge: item['serviceCharge'],
                      receivedLabel: item['receivedLabel'],
                      receivedAmount: item['receivedAmount'],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
              ],
            ),
            );
          }).toList(),
          
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
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String txnId,
    bool hasDetails = false,
    String? withdrawalAmount,
    String? serviceCharge,
    String? receivedLabel,
    String? receivedAmount,
  }) {
    Color statusColor;
    if (status == 'PROCESSED') {
      statusColor = const Color(0xFF1EA85A);
    } else if (status == 'PROCESSING') {
      statusColor = Colors.amber.shade800;
    } else {
      statusColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
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
                  borderRadius: BorderRadius.circular(10),
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
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
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
            _buildDetailRow('Withdrawal amount', withdrawalAmount ?? ''),
            const SizedBox(height: 4),
            _buildDetailRow('Service charge (25%)', serviceCharge ?? '', isRed: true),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  receivedLabel ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                Text(
                  receivedAmount ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1EA85A),
                  ),
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

  Widget _buildDetailRow(String label, String value, {bool isRed = false}) {
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
            color: isRed ? Colors.red.shade600 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
