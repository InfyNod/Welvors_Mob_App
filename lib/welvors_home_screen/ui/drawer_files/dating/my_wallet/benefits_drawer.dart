import 'package:flutter/material.dart';

class WalletBenefitsBottomSheet extends StatelessWidget {
  const WalletBenefitsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WalletBenefitsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final benefits = [
      {
        'icon': '🎁',
        'iconBg': const Color(0xFFFBE4E7),
        'title': 'Send Gifts',
        'desc': 'Surprise your match with roses, rings & gifts in chat',
        'price': 'from 250'
      },
      {
        'icon': '⭐',
        'iconBg': const Color(0xFFFFF9C4),
        'title': 'Roses',
        'desc': 'Stand out instantly and get 3x more replies',
        'price': '50 coins'
      },
      {
        'icon': '💙',
        'iconBg': const Color(0xFFE3F2FD),
        'title': 'Likes',
        'desc': 'See who likes you and like back to match',
        'price': '20 coins'
      },
      {
        'icon': '💌',
        'iconBg': const Color(0xFFFBE4E7),
        'title': 'Compliments',
        'desc': 'Send a warm note even before you match',
        'price': '80 coins'
      },
      {
        'icon': '🚀',
        'iconBg': const Color(0xFFF3E5F5),
        'title': 'Boosts',
        'desc': 'Become a top profile and get seen by more people',
        'price': 'from 300'
      },
      {
        'icon': '💎',
        'iconBg': const Color(0xFFE3F2FD),
        'title': 'Activate Plans',
        'desc': 'Unlock Premium+, VIP & Elite memberships',
        'price': 'from 499'
      },
      {
        'icon': '🎟️',
        'iconBg': const Color(0xFFFBE4E7),
        'title': 'Event Tickets',
        'desc': 'Book your spot at official Welvors events',
        'price': 'from 950'
      },
      {
        'icon': '📅',
        'iconBg': const Color(0xFFFFF3E0),
        'title': 'Date Plans',
        'desc': 'Post or join live Date Now plans nearby',
        'price': 'from 100'
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wallet benefits',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'One wallet powers everything on Welvors. Earn coins from gifts & referrals, and use them across the app:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1, // Increased ratio makes cards shorter and more compact
                    ),
                    itemCount: benefits.length,
                    itemBuilder: (context, index) {
                      final item = benefits[index];
                      return _buildBenefitCard(item);
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: true,
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the bottom sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85A7A), // Updated pink color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Removed border to make it look cleaner and more professional
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10), // Darkened for more visibility
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Darkened for more visibility
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item['iconBg'] as Color,
              borderRadius: BorderRadius.circular(12), // Slightly softer square
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 2.0, bottom: 0.5), // Shifted slightly right to center emoji perfectly
              child: Text(
                item['icon'] as String,
                style: const TextStyle(fontSize: 20, height: 1.1), // Increased icon size
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8), // Reduced gap
          Text(
            item['title'] as String,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2), // Reduced gap
          Expanded(
            child: Text(
              item['desc'] as String,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.25, // Tighter line height
              ),
              maxLines: 2, // 2 lines max to save vertical space
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4), // Reduced gap
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 1.0),
                child: Text('🪙', style: TextStyle(fontSize: 12, height: 1.0)),
              ),
              const SizedBox(width: 4),
              Text(
                item['price'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
