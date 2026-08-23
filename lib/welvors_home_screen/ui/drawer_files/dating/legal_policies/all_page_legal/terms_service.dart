import 'package:flutter/material.dart';

class TermsServiceScreen extends StatelessWidget {
  const TermsServiceScreen({super.key});

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
          'Terms of Service',
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
                color: const Color(0xFFFFF0F3), // light pink
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
            _buildTermItem(
              number: '1',
              title: 'Who can use Welvors',
              description:
                  'You must be 18 or older and legally able to enter a contract. One account per person. You agree to give accurate information and keep your login secure.',
              highlightText: '18 or older',
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              number: '2',
              title: 'Your account',
              description:
                  'You are responsible for activity on your account. Impersonation, fake profiles, and accounts created on someone else\'s behalf are prohibited and will be removed.',
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              number: '3',
              title: 'Acceptable use',
              description:
                  'Don\'t use Welvors to harass, scam, solicit money, post illegal content, or contact minors. We may suspend or ban accounts that break these rules.',
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              number: '4',
              title: 'Paid features',
              description:
                  'Plans (Premium+, VIP, Elite), coins, Date Plan credits, Boosts and the Forever Love Programme are billed as shown at purchase. See the Refund Policy for cancellations.',
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              number: '5',
              title: 'Content you post',
              description:
                  'You keep ownership of your photos and text, but grant Welvors a licence to display them within the app to operate the service.',
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              number: '6',
              title: 'Liability',
              description:
                  'Welvors helps you meet people but is not responsible for the conduct of other users, online or offline. Always follow our Safety guidance.',
            ),
            const SizedBox(height: 20),

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
              child: Text(
                'By using Welvors you accept these Terms. If you disagree, please stop using the app.',
                textAlign: TextAlign.center,
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
    );
  }

  Widget _buildTermItem({
    required String number,
    required String title,
    required String description,
    String? highlightText,
  }) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        number,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.pink.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (highlightText != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      children: _buildHighlightedText(
                        description,
                        highlightText,
                      ),
                    ),
                  )
                else
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String highlight) {
    final parts = text.split(highlight);
    if (parts.length != 2) return [TextSpan(text: text)];
    return [
      TextSpan(text: parts[0]),
      TextSpan(
        text: highlight,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      TextSpan(text: parts[1]),
    ];
  }
}
