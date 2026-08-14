import 'package:flutter/material.dart';

class SentLikesScreen extends StatelessWidget {
  const SentLikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Row(
            children: [
              Text('❤️', style: TextStyle(fontSize: 12)),
              SizedBox(width: 6),
              Text(
                'LIKES YOU SENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSentCard(
            name: 'Elena',
            age: '23',
            timeInfo: '3h ago · 95% Match',
            imageUrl:
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=500&q=80',
            statusText: '✓ Matched · Chat',
            statusTextColor: const Color(0xFF2CAF6B),
            statusBgColor: const Color(0xFFE9F7EF),
          ),
          const SizedBox(height: 12),
          _buildSentCard(
            name: 'Shraddha',
            age: '21',
            timeInfo: 'Yesterday · 74% Match',
            imageUrl:
                'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
            statusText: '○ Pending',
            statusTextColor: Colors.grey.shade600,
            statusBgColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          _buildSentCard(
            name: 'Tanya',
            age: '25',
            timeInfo: '2 days ago · 81% Match',
            imageUrl:
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80',
            statusText: '• Seen',
            statusTextColor: const Color(0xFF3F8CFF),
            statusBgColor: const Color(0xFFEBF3FF),
          ),
        ],
      ),
    );
  }

  Widget _buildSentCard({
    required String name,
    required String age,
    required String timeInfo,
    required String imageUrl,
    required String statusText,
    required Color statusTextColor,
    required Color statusBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image with small heart
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(imageUrl),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE43A6A), // Pink
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name, $age',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusTextColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
