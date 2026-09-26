import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../boost_wallet_all_screen/boost_wallet_top_nav.dart';

class SuperBoostPaymentProcessingDialog extends StatefulWidget {
  final Map<String, dynamic> selectedPackage;
  final int newBalance;
  final VoidCallback onDone;

  const SuperBoostPaymentProcessingDialog({
    super.key,
    required this.selectedPackage,
    required this.newBalance,
    required this.onDone,
  });

  static void show({
    required BuildContext context,
    required Map<String, dynamic> selectedPackage,
    required int newBalance,
    required VoidCallback onDone,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SuperBoostPaymentProcessingDialog(
          selectedPackage: selectedPackage,
          newBalance: newBalance,
          onDone: onDone,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<SuperBoostPaymentProcessingDialog> createState() =>
      _SuperBoostPaymentProcessingDialogState();
}

class _SuperBoostPaymentProcessingDialogState
    extends State<SuperBoostPaymentProcessingDialog> {
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Processing payment...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please don\'t close this screen. This takes\njust a moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ] else ...[
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Lottie.asset(
                    'assets/Payment_Success_black.json',
                    width: 160,
                    height: 160,
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 0),
                const Text(
                  'Payment successful',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${int.parse(widget.selectedPackage['title'])} Super Boosts added to your wallet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '✦',
                          style: TextStyle(
                            color: Color(0xFFCBA164),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Super Boost balance now ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${widget.newBalance}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDone();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BoostWalletTopNav(initialIndex: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Activate a super boost now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
