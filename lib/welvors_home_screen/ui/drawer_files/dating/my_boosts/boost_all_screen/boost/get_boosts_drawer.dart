import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../boost_bloc/boost_bloc.dart';
import '../../boost_bloc/boost_event.dart';
// import 'boost_screen.dart';
import 'boost_payment_processing_dialog.dart';
import '../../service_all_flow.dart';

class GetBoostsDrawer extends StatefulWidget {
  final Map<String, dynamic> selectedPackage;
  final VoidCallback onPurchased;

  const GetBoostsDrawer({
    super.key,
    required this.selectedPackage,
    required this.onPurchased,
  });

  static void show(BuildContext context, Map<String, dynamic> package, VoidCallback onPurchased) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GetBoostsDrawer(
        selectedPackage: package,
        onPurchased: onPurchased,
      ),
    );
  }

  @override
  State<GetBoostsDrawer> createState() => _GetBoostsDrawerState();
}

class _GetBoostsDrawerState extends State<GetBoostsDrawer> {
  String _selectedPaymentMethod = 'wallet';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review your pack and choose how to pay.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              
              // Package Summary Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Text('⚡️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${int.parse(widget.selectedPackage['title'])} Boosts',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Never expire · use anytime',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.selectedPackage['totalPrice'] != null ? widget.selectedPackage['totalPrice'].split(' ')[0] : '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              const Text(
                'PAY USING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              // Payment Methods
              _buildPaymentOption(
                id: 'wallet',
                title: 'Wallet coins',
                subtitle: 'Balance ₹2,480',
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                id: 'upi',
                title: 'UPI',
                subtitle: 'GPay, PhonePe, Paytm',
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                id: 'card',
                title: 'Card',
                subtitle: 'Credit / Debit',
              ),
              
              const SizedBox(height: 20),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final apiService = BoostAllApiService();
                    final raw = widget.selectedPackage['raw'];
                    final packId = widget.selectedPackage['id']?.toString() ?? 
                                   widget.selectedPackage['_id']?.toString() ?? 
                                   raw?['id']?.toString() ?? 
                                   raw?['_id']?.toString() ?? 
                                   '';
                    
                    final success = await apiService.buyBoostPack(packId);
                    
                    if (!mounted) return;
                    
                    if (success) {
                      final rootContext = Navigator.of(context).context;
                      final boostBloc = context.read<BoostBloc>();
                      final itemsToAdd = int.parse(widget.selectedPackage['title'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
                      final newBalance = boostBloc.state.boostBalance + itemsToAdd;
                      
                      Navigator.pop(context); // Close the bottom sheet
                      
                      BoostPaymentProcessingDialog.show(
                        context: rootContext,
                        selectedPackage: widget.selectedPackage,
                        newBalance: newBalance,
                        onDone: () {
                          boostBloc.add(AddBoostEvent(itemsToAdd));
                          widget.onPurchased();
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to top up wallet. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A), // Brand Pink
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Pay ${widget.selectedPackage['totalPrice'] != null ? widget.selectedPackage['totalPrice'].split(' ')[0] : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
