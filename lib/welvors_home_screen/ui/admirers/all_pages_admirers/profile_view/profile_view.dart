import 'package:flutter/material.dart';
import '../../../date_now/profile/profile_detail.dart';
import 'match_dialog.dart';

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
    final String userIdStr =
        userCard['userId']?.toString() ?? userCard['id'].toString();

    return ProfileDetailScreen(
      userId: userIdStr,
      profileImageUrl: userCard['imageUrl'],
      profileName: userCard['name'],
      customBottomWidget: _buildAdmirerActions(context),
    );
  }

  Widget _buildAdmirerActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, -10),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reject Button
            _PremiumActionButton(
              icon: Icons.close_rounded,
              label: 'Reject',
              iconColor: const Color(0xFF4A4A4A),
              backgroundColor: Colors.white,
              borderColor: const Color(0xFFEAEAEA),
              shadowColor: Colors.black.withOpacity(0.08),
              iconSize: 24,
              padding: 14,
              onTap: () {
                onAction(userCard['id'], 'Rejected ❌');
                Navigator.pop(context); // Go back after action
              },
            ),

            const SizedBox(width: 32), // Spacing between buttons
            // Like Button
            _PremiumActionButton(
              icon: Icons.favorite_rounded,
              label: 'Match',
              iconColor: Colors.white,
              backgroundColor: const Color(0xFFE43A6A), // Premium Pink
              shadowColor: const Color(0xFFE43A6A).withOpacity(0.4),
              iconSize: 26,
              padding: 16,
              onTap: () {
                MatchDialog.show(
                  context,
                  matchedUserName: userCard['name'] ?? 'User',
                  matchedUserImageUrl: userCard['imageUrl'] ?? '',
                  onMessage: () {
                    onAction(userCard['id'], 'Liked back 💖');
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back from profile
                  },
                  onSendRose: () {
                    onAction(userCard['id'], 'Sent Rose 🌹');
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back from profile
                  },
                  onKeepBrowsing: () {
                    onAction(userCard['id'], 'Liked back 💖');
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back from profile
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final Color shadowColor;
  final Color? borderColor;
  final double iconSize;
  final double padding;
  final VoidCallback onTap;

  const _PremiumActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.shadowColor,
    this.borderColor,
    required this.iconSize,
    required this.padding,
    required this.onTap,
  });

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: widget.padding * 1.5, vertical: widget.padding),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: widget.shadowColor.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
