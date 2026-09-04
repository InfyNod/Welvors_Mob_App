import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../date_api_service/date_now_api_service.dart';

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
  bool _isActivating = false;
  bool _isLoading = true;
  String _boostTitle = "Boost to top of feed";
  String _boostDescription = "Pin your plan above every other plan nearby.\nBoosted plans get up to 5x more requests.";
  List<dynamic> _options = [];

  String? get _selectedBoostOptionId {
    for (var opt in _options) {
      if (opt['durationHours'] == _selectedDuration) {
        return opt['id']?.toString();
      }
    }
    return null;
  }

  final Map<int, int> _prices = {3: 149, 6: 279, 9: 399};

  @override
  void initState() {
    super.initState();
    _fetchBoosts();
  }

  Future<void> _fetchBoosts() async {
    final response = await DateNowApiService.getDatePlanBoosts();
    if (response != null && response['success'] == true && response['data'] != null) {
      final data = response['data'];
      setState(() {
        _boostTitle = data['title'] ?? _boostTitle;
        _boostDescription = data['description'] ?? _boostDescription;
        _walletBalance = data['walletBalance'] ?? _walletBalance;
        
        if (data['options'] != null) {
          _options = List.from(data['options']);
          _options.sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));
          
          _prices.clear();
          for (var opt in _options) {
            int duration = opt['durationHours'];
            int price = opt['price'];
            _prices[duration] = price;
            if (opt['isPopular'] == true) {
              _selectedDuration = duration;
            }
          }
          if (!_prices.containsKey(_selectedDuration) && _prices.isNotEmpty) {
            _selectedDuration = _prices.keys.first;
          }
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(242, 127, 66, 1),
                ),
              ),
            )
          else if (!_isReviewing)
            _buildSelectionView()
          else
            _buildReviewView(),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    final title = widget.plan['title'] ?? 'Date Plan';
    final price = _prices[_selectedDuration] ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _boostTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                text: ' ',
              ),
              TextSpan(
                text: _boostDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _prices.keys.toList().asMap().entries.map((entry) {
            int idx = entry.key;
            int duration = entry.value;
            bool isLast = idx == _prices.keys.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
                child: _buildDurationOption(duration),
              ),
            );
          }).toList(),
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
    int price = _prices[hours] ?? 0;

    return GestureDetector(
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
          onTap: _isActivating ? null : () async {
            final optionId = _selectedBoostOptionId;
            final planId = widget.plan['id']?.toString();
            
            if (optionId == null || planId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Missing plan or boost ID')),
              );
              return;
            }

            setState(() {
              _isActivating = true;
            });

            final response = await DateNowApiService.activateDatePlanBoost(planId, optionId);

            if (mounted) {
              setState(() {
                _isActivating = false;
              });

              if (response != null && response['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? 'Boost activated successfully!')),
                );
                Navigator.pop(context, _selectedDuration);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response?['message'] ?? 'Failed to activate boost')),
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isActivating 
                  ? [Colors.grey.shade400, Colors.grey.shade400]
                  : [
                      const Color.fromRGBO(252, 168, 85, 1),
                      const Color.fromRGBO(242, 127, 66, 1),
                    ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _isActivating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
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
