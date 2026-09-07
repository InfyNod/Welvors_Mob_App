import 'package:flutter/material.dart';
import '../../../date_now/profile/profile_detail.dart';

class AdmirerProfileView extends StatelessWidget {
  final Map<String, dynamic> userCard;
  final Function(dynamic id, String actionText) onAction;

  const AdmirerProfileView({
    super.key,
    required this.userCard,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // Real backend MongoDB ObjectIDs are used
    final String userIdStr = userCard['userId']?.toString() ?? userCard['id'].toString();

    return ProfileDetailScreen(
      userId: userIdStr,
      profileImageUrl: userCard['imageUrl'],
      profileName: userCard['name'],
      customBottomWidget: _buildAdmirerActions(context),
    );
  }

  Widget _buildAdmirerActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Reject Button
            _buildActionButton(
              icon: Icons.close_rounded,
              color: Colors.black87,
              backgroundColor: Colors.grey.shade100,
              onTap: () {
                onAction(userCard['id'], 'Rejected ❌');
                Navigator.pop(context); // Go back after action
              },
            ),
            
            // Like Button
            _buildActionButton(
              icon: Icons.favorite_rounded,
              color: Colors.white,
              backgroundColor: const Color(0xFFE43A6A), // Pink
              iconSize: 32,
              padding: 20,
              onTap: () {
                onAction(userCard['id'], 'Liked back 💖');
                Navigator.pop(context); // Go back after action
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
    double iconSize = 28,
    double padding = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
