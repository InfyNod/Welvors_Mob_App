import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service_account_Setting.dart';

void showCancelAutoRenewBottomSheet(BuildContext context, String planName, VoidCallback onCancelled) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _CancelAutoRenewSheet(planName: planName, onCancelled: onCancelled);
    },
  );
}

class _CancelAutoRenewSheet extends StatefulWidget {
  final String planName;
  final VoidCallback onCancelled;
  const _CancelAutoRenewSheet({required this.planName, required this.onCancelled});

  @override
  State<_CancelAutoRenewSheet> createState() => _CancelAutoRenewSheetState();
}

class _CancelAutoRenewSheetState extends State<_CancelAutoRenewSheet> {
  final List<String> _reasons = [
    'Too expensive',
    'I found someone 💕',
    'Taking a break from dating',
    'Not getting enough matches',
    'Missing features I wanted',
    'Something else',
  ];

  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
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
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F3), // Light pink
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('💔', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'Before you go...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tell us why you\'re cancelling — it helps us fix what matters.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Options List
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE43A6A).withValues(alpha: 0.05) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedReason != null
                    ? () {
                        Navigator.pop(context);
                        showCancelWarningBottomSheet(context, _selectedReason!, widget.planName, widget.onCancelled);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE43A6A),
                  disabledBackgroundColor: const Color(0xFFE43A6A).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Keep my VIP Button
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
                child: Text(
                  'Keep my ${widget.planName}',
                  style: const TextStyle(
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
  }
}

void showCancelWarningBottomSheet(BuildContext context, String reason, String planName, VoidCallback onCancelled) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _CancelWarningSheet(reason: reason, planName: planName, onCancelled: onCancelled);
    },
  );
}

class _CancelWarningSheet extends StatefulWidget {
  final String reason;
  final String planName;
  final VoidCallback onCancelled;
  const _CancelWarningSheet({required this.reason, required this.planName, required this.onCancelled});

  @override
  State<_CancelWarningSheet> createState() => _CancelWarningSheetState();
}

class _CancelWarningSheetState extends State<_CancelWarningSheet> {
  bool _isLoading = false;
  bool _isFetchingPreview = true;
  String _expiryDateStr = 'the end of your cycle';
  String _rawExpiryDateStr = '12 Aug 2026';
  List<dynamic> _features = [];
  String _previewError = '';

  @override
  void initState() {
    super.initState();
    _fetchPreviewData();
  }

  Future<void> _fetchPreviewData() async {
    try {
      final response = await AccountSettingService.getAutoRenewOffPreview();
      if (mounted) {
        if (response != null && response['success'] == true) {
          final data = response['data'];
          setState(() {
            _rawExpiryDateStr = _formatDate(data['expiryDate']);
            _expiryDateStr = _rawExpiryDateStr;
            final allFeatures = (data['features'] as List<dynamic>?) ?? [];
            _features = allFeatures.take(5).toList();
            _isFetchingPreview = false;
          });
        } else {
           setState(() {
             _isFetchingPreview = false;
             _previewError = 'Failed to load preview data';
           });
        }
      }
    } catch(e) {
      if(mounted) {
        setState(() {
           _isFetchingPreview = false;
           _previewError = e.toString();
        });
      }
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'end of your billing cycle';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy').format(date);
    } catch(e) {
      return 'end of your billing cycle';
    }
  }

  String _getEmoji(String iconName) {
    switch (iconName) {
      case 'concierge-bell': return '👑';
      case 'crown': return '👑';
      case 'users': return '👥';
      case 'target': return '🎯';
      case 'briefcase': return '💼';
      case 'globe': return '🌎';
      case 'zap': return '🚀';
      case 'message-circle': return '💬';
      case 'sparkles': return '✨';
      case 'plane': return '✈️';
      case 'badge-check': return '✅';
      case 'eye': return '👁️';
      case 'calendar': return '📅';
      case 'rose': return '🌹';
      case 'shield-check': return '🛡️';
      case 'network': return '🌐';
      case 'image-off': return '🙈';
      case 'building': return '🏢';
      case 'map-pin': return '📍';
      case 'heart': return '❤️';
      case 'rotate-ccw': return '🔄';
      case 'camera': return '📸';
      case 'coins': return '🪙';
      case 'calendar-heart': return '🗓️';
      default: return '💎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
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
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7E6), // Light yellow/orange
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('⚠️', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'You\'ll lose these on $_expiryDateStr',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Auto-renew off means your VIP benefits stop after $_rawExpiryDateStr.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Benefits list container
            if (_isFetchingPreview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFE9), // Beige
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A))),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFE9), // Beige
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _features.isEmpty
                      ? [
                          _buildBenefitRow('👑', 'VIP-only discovery pool'),
                          const SizedBox(height: 8),
                          _buildBenefitRow('🔎', 'Income & verified-degree filters'),
                          const SizedBox(height: 8),
                          _buildBenefitRow('🚀', '1 free boost every week'),
                          const SizedBox(height: 8),
                          _buildBenefitRow('🌹', '5 free roses every week'),
                          const SizedBox(height: 8),
                          _buildBenefitRow('🥂', 'Member-only events access'),
                        ]
                      : _features.map((f) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildBenefitRow(_getEmoji(f['icon'] ?? ''), f['title'] ?? ''),
                          );
                        }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            // Cancel anyway
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        
                        final success = await AccountSettingService.turnOffAutoRenew(widget.reason);
                        
                        if (!mounted || !context.mounted) return;
                        setState(() {
                          _isLoading = false;
                        });
                        
                        if (success) {
                          Navigator.pop(context);
                          showCancelConfirmationBottomSheet(context, widget.reason, widget.planName, _rawExpiryDateStr, widget.onCancelled);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to cancel auto-renew. Please try again.')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDF5A5A), // Softer Red
                  disabledBackgroundColor: const Color(0xFFDF5A5A).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Cancel auto-renew anyway',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Never mind Button
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
                  'Never mind',
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
  }

  Widget _buildBenefitRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

void showCancelConfirmationBottomSheet(BuildContext context, String reason, String planName, String expiryDate, VoidCallback onCancelled) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _CancelConfirmationSheet(reason: reason, planName: planName, expiryDate: expiryDate, onCancelled: onCancelled);
    },
  );
}

class _CancelConfirmationSheet extends StatelessWidget {
  final String reason;
  final String planName;
  final String expiryDate;
  final VoidCallback onCancelled;
  const _CancelConfirmationSheet({required this.reason, required this.planName, required this.expiryDate, required this.onCancelled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
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
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F6EF), // Light green
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, color: Colors.black87, size: 28),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'Auto-renew cancelled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: 'Your $planName stays active until '),
                    TextSpan(text: expiryDate, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const TextSpan(text: '. After that your account moves to Free — nothing is charged again.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Details Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFE9), // Beige
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDetailCol('REASON NOTED', reason)),
                      Expanded(child: _buildDetailCol('ACCESS UNTIL', expiryDate)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDetailCol('NEXT CHARGE', 'None')),
                      Expanded(child: _buildDetailCol('REFUND', 'Not applicable')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Done Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.pop(context);
                   onCancelled();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE43A6A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
}
