import 'package:flutter/material.dart';

void showInvoiceBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Invoice Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F0EA), // Beige-like color
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welvors',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'INFYNOD TECH PRIVATE LIMITED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6EF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PAID',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1CB569),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dashed Divider
                    Row(
                      children: List.generate(
                        40,
                        (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Details Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCol('INVOICE NO.', 'INV-2025-1002'),
                        ),
                        Expanded(
                          child: _buildDetailCol('DATE', '02 Oct 2025'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCol('BILLED TO', 'Tanishka Sharma'),
                        ),
                        Expanded(
                          child: _buildDetailCol('GSTIN', '27AAJCI0350F1ZU'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Items
                    _buildRow('Premium+ membership · 1 month', '₹847', isBoldAmount: true),
                    const SizedBox(height: 8),
                    _buildRow('GST (18%)', '₹152', isBoldAmount: true),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black, thickness: 1.5),
                    const SizedBox(height: 8),
                    _buildRow('Total paid', '₹999', isBoldLabel: true, isBoldAmount: true, amountSize: 16),
                    const SizedBox(height: 20),
                    _buildRow('Paid via', 'Wallet · 🪙 999', labelColor: Colors.black45, amountSize: 12, isBoldAmount: true),
                    const SizedBox(height: 20),
                    // Footer disclaimer
                    Text(
                      'Digital service · SAC 998439 · This is a computer-generated invoice.\nRegistered office: Office No. 307, Amanora Chamber, Hadapsar,\nPune 411028',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 18),
                  label: const Text(
                    'Download PDF',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDetailCol(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

Widget _buildRow(
  String label,
  String amount, {
  bool isBoldLabel = false,
  bool isBoldAmount = false,
  double amountSize = 13,
  Color labelColor = Colors.black87,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBoldLabel ? FontWeight.bold : FontWeight.normal,
          color: labelColor,
        ),
      ),
      Text(
        amount,
        style: TextStyle(
          fontSize: amountSize,
          fontWeight: isBoldAmount ? FontWeight.bold : FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    ],
  );
}
