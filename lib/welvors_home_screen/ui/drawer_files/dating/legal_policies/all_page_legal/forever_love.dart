import 'package:flutter/material.dart';

class ForeverLoveScreen extends StatelessWidget {
  const ForeverLoveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
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
                    color: Colors.black.withOpacity(0.04),
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
          'Forever Love Programme Terms',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.pink.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.update, size: 14, color: Colors.pink.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Last updated 20 June 2026',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.pink.shade600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'How it works',
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Match on Welvors, add a commitment tag, and enrol with a one-time '),
                    TextSpan(
                      text: '₹10,000',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade600),
                    ),
                    const TextSpan(text: ' fee. Stay active for '),
                    TextSpan(
                      text: '3 years',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade600),
                    ),
                    const TextSpan(text: ' with monthly check-ins, then marry to unlock a '),
                    TextSpan(
                      text: '₹5,00,000 honeymoon.',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Eligibility',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                      'Both partners must be verified members (Trust Level 2+)'),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                      'Monthly check-ins must be completed for the full 3 years'),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                      'Marriage must be legally registered & verified by our team'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Reward',
              child: Text(
                'The honeymoon reward is provided as a booked trip (not cash) after marriage verification, including a live video verification call.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3), // light pink
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pink.shade100, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Missing check-ins or providing false marriage proof forfeits eligibility. Fraud leads to a ban.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink.shade500,
                        height: 1.4,
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

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.pink.shade400,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
