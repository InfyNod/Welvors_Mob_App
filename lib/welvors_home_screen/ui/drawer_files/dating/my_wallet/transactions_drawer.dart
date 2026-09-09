import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsBottomSheet({super.key, required this.transaction});

  static void show(BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TransactionDetailsBottomSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = transaction['isPositive'] ?? false;
    final Color amountColor = isPositive
        ? const Color(0xFF2CAF6B)
        : Colors
              .black87; // Usually negative is black or red, let's keep black like UI standard or red if deduction.
    // Actually, in screenshot, positive is green.
    final String amountText = transaction['amount'] ?? '';
    
    final Map<String, dynamic>? rawTx = transaction['rawTx'];
    final String txnId = rawTx?['referenceId']?.toString() ?? 'TXN-982${(transaction['title']?.hashCode ?? 0).abs() % 1000 + 100}';
    
    String dateTimeStr = transaction['time'] ?? '';
    if (rawTx != null && rawTx['createdAt'] != null) {
      try {
        final DateTime dt = DateTime.parse(rawTx['createdAt'].toString()).toLocal();
        dateTimeStr = DateFormat('d MMM yyyy, h:mm a').format(dt);
      } catch (_) {}
    }
    String? toastMessage;

    return StatefulBuilder(
      builder: (context, setState) {
        void showToast(String message) {
          setState(() {
            toastMessage = message;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              setState(() {
                if (toastMessage == message) toastMessage = null;
              });
            }
          });
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: transaction['iconBg'] ?? const Color(0xFFFBE4E7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      transaction['icon'] ?? '💰',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    transaction['title'] ?? 'Transaction',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  if (!(transaction['title']?.toString().contains('Withdrawal') ?? false)) ...[
                    // Amount
                    Text(
                      amountText,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (transaction['title']?.toString().contains('Withdrawal') ?? false)
                    _buildWithdrawalBreakdown(amountText),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(244, 239, 231, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Type', rawTx?['type']?.toString() ?? _getType(transaction['title'])),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Source',
                          rawTx?['source']?.toString() ?? _getFrom(transaction['title']),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Date & time',
                          dateTimeStr,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Transaction ID',
                          txnId,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Status',
                          (transaction['title']?.toString().contains('Withdrawal') ?? false) ? '✓ Processed' : '✓ Completed',
                          valueColor: const Color(0xFF2CAF6B),
                        ),
                      ],
                    ),
                  ),

                  // Optional Memo
                  _buildMemo(transaction['title']?.toString(), isPositive),

                  // Action Buttons
                  _buildActionButton('Download receipt', () {
                    showToast('Receipt downloaded');
                  }),
                  const SizedBox(height: 12),
                  _buildActionButton('Report an issue', () {
                    showToast('Reported - Our team will check');
                  }),

                  // Bottom safe area spacing
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    if (toastMessage != null)
      Positioned(
        bottom: 32 + MediaQuery.of(context).padding.bottom,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              toastMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ],
  );
},
);
}

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 16),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getType(String? title) {
    if (title == null) return 'Transaction';
    if (title.contains('Gift')) return 'Gift';
    if (title.contains('Date Plans')) return 'Date Plan';
    if (title.contains('Premium Rose')) return 'Gift';
    if (title.contains('Rose')) return 'Rose';
    if (title.contains('Refer')) return 'Referral';
    if (title.contains('Boost')) return 'Boost';
    if (title.contains('Compliment')) return 'Compliment';
    if (title.contains('added')) return 'Top-up';
    if (title.contains('Withdrawal')) return 'Withdrawal';
    return 'Payment';
  }

  String _getFrom(String? title) {
    if (title == null) return '-';
    if (title.contains('Date Plans')) return '3 plans @ 90 each';
    if (title.contains('Premium Rose')) return 'To Aanya, 25';
    if (title.contains('Rose sent')) return 'To Jordan';
    if (title.contains('Withdrawal')) return 'HDFC •••• 1234';
    if (title.contains('Rahul joined')) return 'Rahul M. signed up';
    if (title.contains('Sneha bought VIP')) return 'Sneha K. activated VIP';
    if (title.contains('Compliment')) return 'To Elena, 23';
    if (title.contains('from Aanya')) return 'Aanya, 25';
    if (title.contains('Money added')) return 'UPI · tanishka@oksbi';
    if (title.contains('Boost activated')) return '30-min Boost';
    if (title.contains('Rahul')) return 'Rahul, 26';
    if (title.contains('Sneha')) return 'Sneha, 23';
    return 'Self';
  }

  Widget _buildMemo(String? title, bool isPositive) {
    if (title == null) return const SizedBox(height: 16);

    if (title.contains('Gift') && isPositive) {
      return _buildMemoBox(
        '📝 "Sent with love 💕"',
        const Color.fromRGBO(255, 231, 236, 1),
        const Color(0xFFD84B6D),
      );
    } else if (title.contains('Date Plans')) {
      return _buildMemoBox(
        '📝 Used to post dates on Date Now',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      );
    } else if (title.contains('Rahul joined')) {
      return _buildMemoBox(
        '📝 ₹100 join reward · ₹500 pending on his plan',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      );
    } else if (title.contains('Money added')) {
      return _buildMemoBox(
        '📝 Includes ₹100 bonus on ₹2,000 top-up',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      );
    } else if (title.contains('Boost activated')) {
      return _buildMemoBox(
        '📝 You were a top profile for 30 minutes',
        const Color(0xFFF3E5F5),
        const Color(0xFF7B1FA2),
      );
    } else if (title.contains('Sneha bought VIP')) {
      return _buildMemoBox(
        '📝 ₹500 plan-activation reward',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      );
    }

    return const SizedBox(height: 16);
  }

  Widget _buildMemoBox(String text, Color bgColor, Color textColor) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawalBreakdown(String amountStr) {
    // Extract numbers, remove negative sign for calculation
    final amountText = amountStr.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(amountText) ?? 1500;
    final double charge = amount * 0.25;
    final double receive = amount - charge;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(244, 239, 231, 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildDetailRow('Withdrawal amount', '₹${amount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _buildDetailRow('Service charge (25%)', '-₹${charge.toStringAsFixed(0)}', valueColor: const Color(0xFFE85A7A)),
            const SizedBox(height: 8),
            _buildDetailRow('Received in bank', '₹${receive.toStringAsFixed(0)}', valueColor: const Color(0xFF2CAF6B)),
          ],
        ),
      ),
    );
  }
}
