import 'package:flutter/material.dart';
import 'invoice_drawer.dart';
import 'cancel_auto_renew.dart';
import '../../service_account_Setting.dart';
import 'package:intl/intl.dart';

class MembershipPlanScreen extends StatefulWidget {
  const MembershipPlanScreen({super.key});

  @override
  State<MembershipPlanScreen> createState() => _MembershipPlanScreenState();
}

class _MembershipPlanScreenState extends State<MembershipPlanScreen> {
  bool isAutoRenewCancelled = false;
  Map<String, dynamic>? currentPlan;
  List<Map<String, dynamic>> history = [];
  Map<String, dynamic>? summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembershipPlan();
  }

  Future<void> _fetchMembershipPlan() async {
    final data = await AccountSettingService.getMembershipPlan();
    if (data != null && mounted) {
      setState(() {
        currentPlan = data['currentPlan'];
        if (data['history'] != null) {
          history = List<Map<String, dynamic>>.from(data['history']);
        }
        summary = data['summary'];
        
        if (currentPlan != null) {
          isAutoRenewCancelled = !(currentPlan!['autoRenew'] ?? false);
        }
        
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Membership Plan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : currentPlan == null 
              ? const Center(child: Text('No active plan'))
              : SafeArea(
                  child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Info Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      emoji: '💎',
                      bgColor: const Color(0xFFE6F9FA),
                      title: 'Current plan',
                      subtitle: currentPlan?['name'] ?? 'VIP',
                      trailingText: currentPlan?['status'] ?? 'Active',
                      trailingColor: currentPlan?['status'] == 'ACTIVE' ? Colors.green : Colors.black54,
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    _buildInfoRow(
                      emoji: '📅',
                      bgColor: const Color(0xFFEEF2F6),
                      title: isAutoRenewCancelled ? 'Access until' : 'Renews on',
                      subtitle: _formatDate(currentPlan?['endDate']),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    _buildInfoRow(
                      emoji: '💳',
                      bgColor: const Color(0xFFE8F6EF),
                      title: 'Payment method',
                      subtitle: currentPlan?['paymentMethod']?['displayValue'] ?? 'Online payment',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A), // Pinkish red
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Manage / Upgrade Plan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (isAutoRenewCancelled)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5), // Light beige
                    border: Border.all(color: const Color(0xFFF2D1A3)), // Soft brown/orange
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Auto-renew is off',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5E34), // Brown text
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your VIP benefits stay active until 12 Aug 2026, then your account moves to Free.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isAutoRenewCancelled = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFDCA76F)), // Orange-brown border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Turn auto-renew back on',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB07D46), // Or brownish
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      showCancelAutoRenewBottomSheet(context, () {
                        setState(() {
                          isAutoRenewCancelled = true;
                        });
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel auto-renew',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              // Plan History Title
              const Text(
                'PLAN HISTORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              // History List Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(history.length, (index) {
                    final item = history[index];
                    final emoji = item['slug'] == 'vip' ? '💎' : '⭐';
                    final bgColor = item['slug'] == 'vip' ? const Color(0xFFE6F0FA) : const Color(0xFFFFF7E6);
                    
                    Color statusColor;
                    Color statusBgColor;
                    if (item['status'] == 'ACTIVE') {
                      statusColor = const Color(0xFF1CB569);
                      statusBgColor = const Color(0xFFE8F6EF);
                    } else if (item['status'] == 'REFUNDED') {
                      statusColor = const Color(0xFFE43A6A);
                      statusBgColor = const Color(0xFFFDF0F3);
                    } else {
                      statusColor = Colors.black54;
                      statusBgColor = const Color(0xFFF2F2F2);
                    }

                    return Column(
                      children: [
                        _buildHistoryItem(
                          context: context,
                          item: item,
                        ),
                        if (index < history.length - 1)
                          const Divider(
                            height: 1,
                            indent: 70,
                            color: Color(0xFFF0F0F0),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      // Footer outside ScrollView
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EFE9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total paid to date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '₹${summary?['totalPaid'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Text('📧', style: TextStyle(fontSize: 16)),
                      label: const Text(
                        'Email all invoices',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String emoji,
    required Color bgColor,
    required String title,
    required String subtitle,
    String? trailingText,
    Color? trailingColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: trailingColor ?? Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) {
    final emoji = item['slug'] == 'vip' ? '💎' : '⭐';
    final bgColor = item['slug'] == 'vip' ? const Color(0xFFE6F0FA) : const Color(0xFFFFF7E6);
    final title = '${item['name']} · ${item['months']} months';
    final subtitle = '${_formatDate(item['purchasedAt'])} · ${item['paymentMethod']?['displayValue'] ?? 'Online payment'}';
    final status = item['status'] ?? 'UNKNOWN';
    final amount = '₹${item['amount']}';
    
    Color statusColor;
    Color statusBgColor;
    if (item['status'] == 'ACTIVE') {
      statusColor = const Color(0xFF1CB569);
      statusBgColor = const Color(0xFFE8F6EF);
    } else if (item['status'] == 'REFUNDED') {
      statusColor = const Color(0xFFE43A6A);
      statusBgColor = const Color(0xFFFDF0F3);
    } else {
      statusColor = Colors.black54;
      statusBgColor = const Color(0xFFF2F2F2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  showInvoiceBottomSheet(context, item);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE43A6A).withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFE43A6A).withValues(alpha: 0.05),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward,
                        size: 14,
                        color: Color(0xFFE43A6A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Invoice',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE43A6A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
