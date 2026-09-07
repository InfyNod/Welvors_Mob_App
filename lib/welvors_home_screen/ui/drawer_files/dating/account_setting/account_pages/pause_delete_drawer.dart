import 'package:flutter/material.dart';

void showPauseAccountBottomSheet(BuildContext context) {
  _showCustomBottomSheet(
    context: context,
    icon: '⏸️',
    iconBgColor: const Color(0xFFFBF4E4), // Light beige/yellowish
    title: 'Pause your account?',
    subtitle:
        'Your profile will be hidden from everyone. Your matches and chats stay safe. Unpause anytime.',
    primaryButtonText: 'Pause account',
    primaryButtonColor: const Color(0xFFE43A6A), // Pink
    onPrimaryPressed: () {
      // TODO: Implement pause logic
      Navigator.pop(context);
    },
  );
}

void showDeleteAccountBottomSheet(BuildContext context) {
  _showCustomBottomSheet(
    context: context,
    icon: '🗑️',
    iconBgColor: const Color(0xFFFCE8EE), // Light red
    title: 'Delete account permanently?',
    subtitle:
        'This erases your profile, matches, messages and wallet balance forever. This cannot be undone.',
    primaryButtonText: 'Delete everything',
    primaryButtonColor: const Color(0xFFE44E4E), // Red
    onPrimaryPressed: () {
      // TODO: Implement delete logic
      Navigator.pop(context);
    },
  );
}

void _showCustomBottomSheet({
  required BuildContext context,
  required String icon,
  required Color iconBgColor,
  required String title,
  required String subtitle,
  required String primaryButtonText,
  required Color primaryButtonColor,
  required VoidCallback onPrimaryPressed,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            // Primary Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  primaryButtonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Secondary Button (Cancel)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      );
    },
  );
}
