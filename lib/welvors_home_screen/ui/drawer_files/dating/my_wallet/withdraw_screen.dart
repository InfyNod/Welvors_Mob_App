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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
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
    // Placeholder for history tab, matching the UI style
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No withdrawals yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
