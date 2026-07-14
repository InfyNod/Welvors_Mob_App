import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import 'waitlist_confirmed_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.pad),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Success Circle Animation
                  Lottie.asset(
                    'assets/Checkpayment.json',
                    width: 100,
                    height: 100,
                    repeat: false,
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Payment successful',
                    style: AppText.display.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 6),
                  
                  // Amount
                  Text(
                    '₹299',
                    style: AppText.display.copyWith(
                      fontSize: 38,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Subtitle
                  Text(
                    'Your spot on the Welvors founding list is confirmed.\nWelcome aboard, deeee!',
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.pinkDeep.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Paid for', 'Founding member spot'),
                        const SizedBox(height: 10),
                        _buildDetailRow('Name', 'deeee'),
                        const SizedBox(height: 10),
                        _buildDetailRow('Email', 'd@gmail.com'),
                        const SizedBox(height: 10),
                        _buildDetailRow('Payment method', 'UPI'),
                        const SizedBox(height: 10),
                        _buildDetailRow('Date & time', '10 Jul 2026, 12:38 PM'),
                        const SizedBox(height: 10),
                        _buildDetailRow('Transaction ID', 'TXN0982561XN'),
                        const SizedBox(height: 10),
                        _buildDetailRow('Waitlist ID', 'WLV-1XN6-8256'),
                        const SizedBox(height: 16),
                        
                        Divider(color: AppColors.line.withOpacity(0.5), height: 1),
                        const SizedBox(height: 16),
                        
                        // Amount Paid Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amount paid',
                              style: AppText.body.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '₹299',
                              style: AppText.body.copyWith(
                                color: AppColors.green,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Success Pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.greenSoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF28A76F),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Paid · Success',
                                    style: AppText.body.copyWith(
                                      color: AppColors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Black Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WaitlistConfirmedScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'View my confirmation',
                        style: AppText.button.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.body.copyWith(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: AppText.body.copyWith(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
