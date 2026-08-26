import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<int?> showBoostBottomSheet(BuildContext context, Map<String, dynamic> plan) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _BoostBottomSheetContent(plan: plan),
  );
}

class _BoostBottomSheetContent extends StatefulWidget {
  final Map<String, dynamic> plan;

  const _BoostBottomSheetContent({required this.plan});

  @override
  State<_BoostBottomSheetContent> createState() =>
      _BoostBottomSheetContentState();
}

class _BoostBottomSheetContentState extends State<_BoostBottomSheetContent> {
  int _selectedDuration = 3;
  int _walletBalance = 2480;
  bool _isReviewing = false;

  final Map<int, int> _prices = {3: 149, 6: 279, 9: 399};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Rocket Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 233, 214, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🚀', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),

          if (!_isReviewing) _buildSelectionView() else _buildReviewView(),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    final title = widget.plan['title'] ?? 'Date Plan';
    final price = _prices[_selectedDuration]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Boost to top of feed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'Pin '),
              TextSpan(
                text: title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    ' above every other plan nearby.\nBoosted plans get up to ',
              ),
              const TextSpan(
                text: '5x more requests.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDurationOption(3),
            const SizedBox(width: 8),
            _buildDurationOption(6),
            const SizedBox(width: 8),
            _buildDurationOption(9),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '₹$price per $_selectedDuration hrs · charged from your wallet\nyou can extend anytime',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(244, 239, 231, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet balance',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    NumberFormat('#,##0').format(_walletBalance),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            setState(() {
              _isReviewing = true;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(252, 168, 85, 1),
                  Color.fromRGBO(242, 127, 66, 1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Review · ₹$price',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(int hours) {
    bool isSelected = _selectedDuration == hours;
    int price = _prices[hours]!;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDuration = hours;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF7F2) : Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color.fromRGBO(242, 127, 66, 1)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '$hours hours',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? Colors.black87 : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹$price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected
                      ? const Color.fromRGBO(242, 127, 66, 1)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewView() {
    final title = widget.plan['title'] ?? 'Date Plan';
    final price = _prices[_selectedDuration]!;
    final walletAfter = _walletBalance - price;

    // Calculate end time
    final endTime = DateTime.now().add(Duration(hours: _selectedDuration));
    final timeFormat = DateFormat('h:mm a').format(endTime);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Confirm boost',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Review before we charge your wallet.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(244, 239, 231, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Plan', '🍸 $title', isBoldValue: true),
              const Divider(color: Colors.black12, height: 24),
              _buildSummaryRow(
                'Duration',
                '$_selectedDuration hours',
                isBoldValue: true,
              ),
              const Divider(color: Colors.black12, height: 24),
              _buildSummaryRow('Pinned until', timeFormat, isBoldValue: true),
              const Divider(color: Colors.black12, height: 24),
              _buildSummaryRow(
                'Placement',
                'Top of feed nearby',
                isBoldValue: true,
              ),
              const Divider(color: Colors.black12, height: 24),
              _buildSummaryRow(
                'Total',
                '₹$price',
                isBoldValue: true,
                valueColor: const Color.fromRGBO(242, 127, 66, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(244, 239, 231, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet after boost',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    NumberFormat('#,##0').format(walletAfter),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            // TODO: Call API to activate boost
            Navigator.pop(context, _selectedDuration);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(252, 168, 85, 1),
                  Color.fromRGBO(242, 127, 66, 1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Activate boost · ₹$price',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _isReviewing = false;
            });
          },
          child: Text(
            'Change duration',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
