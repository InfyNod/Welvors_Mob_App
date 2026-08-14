import 'package:flutter/material.dart';
import '../../../drawer_files/dating/roses/roses_screen.dart';

class RoseSendScreen extends StatefulWidget {
  const RoseSendScreen({super.key});

  @override
  State<RoseSendScreen> createState() => _RoseSendScreenState();
}

class _RoseSendScreenState extends State<RoseSendScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text('🌹', style: TextStyle(fontSize: 12)),
                SizedBox(width: 8),
                Text(
                  'ROSES YOU SENT',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Sent Item 1: Matched
          _buildSentCard(
            imageUrl:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=500&q=80',
            name: 'Aanya',
            age: '25',
            subtitle: '2h ago · Matched within 14 min 🎉',
            statusWidget: _buildStatusPill(
              text: '✓ Matched · Chat',
              color: const Color(0xFF2CAF6B),
              bgColor: const Color(0xFFE8F5E9),
            ),
          ),
          const SizedBox(height: 12),

          // Sent Item 2: Seen
          _buildSentCard(
            imageUrl:
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=500&q=80',
            name: 'Chloe',
            age: '26',
            subtitle: 'Yesterday · Viewed your profile',
            statusWidget: _buildStatusPill(
              text: '• Seen',
              color: const Color(0xFF4285F4),
              bgColor: const Color(0xFFE3F2FD),
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Promotional Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      218,
                      61,
                      61,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text('🌹', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${RosesScreen.availableRoses} Roses left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Roses get 3× more replies',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Get More Button
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RosesScreen(),
                      ),
                    );
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(61, 169, 255, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Get more →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentCard({
    required String imageUrl,
    required String name,
    required String age,
    required String subtitle,
    required Widget statusWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          // Profile Image with small rose icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌹', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name, $age',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status Pill
          statusWidget,
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
