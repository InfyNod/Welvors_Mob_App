import 'package:flutter/material.dart';
import 'package:velvors/config/app_cached_image.dart';

class VipSendScreen extends StatelessWidget {
  const VipSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Aanya, 25 - Accepted
          _buildSentCard(
            name: 'Aanya',
            age: '25',
            subtitle: 'Sent 2h ago · 92% Match',
            pillIcon: '💍',
            pillText: 'Exclusively Dating',
            statusWidget: _buildStatusPill(
              text: '✓ Accepted',
              textColor: const Color(0xFF2E7D32), // Green text
              bgColor: const Color(0xFFE8F5E9), // Light green bg
            ),
            imageUrl:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=500&q=80',
          ),
          const SizedBox(height: 12),
          // Elena, 23 - Pending
          _buildSentCard(
            name: 'Elena',
            age: '23',
            subtitle: 'Sent yesterday · 95% Match',
            pillIcon: '❤️',
            pillText: 'In a Relationship',
            statusWidget: _buildStatusPill(
              text: '○ Pending',
              textColor: Colors.grey.shade700,
              bgColor: Colors.grey.shade200,
            ),
            imageUrl:
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=500&q=80',
          ),
          const SizedBox(height: 12),
          // Shraddha, 21 - Seen
          _buildSentCard(
            name: 'Shraddha',
            age: '21',
            subtitle: 'Sent 2 days ago · 74% Match',
            pillIcon: '💍',
            pillText: 'Girlfriend / Boyfriend',
            statusWidget: _buildStatusPill(
              text: '• Seen',
              textColor: const Color(0xFF1565C0), // Blue text
              bgColor: const Color(0xFFE3F2FD), // Light blue bg
            ),
            imageUrl:
                'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildSentCard({
    required String name,
    required String age,
    required String subtitle,
    required String pillIcon,
    required String pillText,
    required Widget statusWidget,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCachedImage(
            imageUrl: imageUrl,
            width: 48,
            height: 48,
            borderRadius: 24,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                // Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFF4), // Light pink bg
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pillIcon, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        pillText,
                        style: const TextStyle(
                          color: Color(0xFFE85A7A), // pink text
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          statusWidget,
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required String text,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
