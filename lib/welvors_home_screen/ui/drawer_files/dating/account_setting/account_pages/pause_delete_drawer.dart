import 'package:flutter/material.dart';
import '../service_account_Setting.dart';
import '../../logout/splash_logout.dart';

Future<bool?> showPauseAccountBottomSheet(BuildContext context) {
  bool isLoading = false;
  
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return _buildCustomBottomSheetContent(
            context: modalContext,
            icon: '⏸️',
            iconBgColor: const Color(0xFFFBF4E4),
            title: 'Pause your account?',
            subtitle: 'Your profile will be hidden from everyone. Your matches and chats stay safe. Unpause anytime.',
            primaryButtonText: isLoading ? 'Pausing...' : 'Pause account',
            primaryButtonColor: const Color(0xFFE43A6A),
            isLoading: isLoading,
            onPrimaryPressed: () async {
              if (isLoading) return;
              setState(() => isLoading = true);
              
              bool success = await AccountSettingService.pauseAccount(reason: "Taking a break from dating");
              
              if (modalContext.mounted) {
                setState(() => isLoading = false);
                Navigator.pop(modalContext, success);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account paused successfully.')),
                  );
                  // Navigation logic if required (e.g., to login screen)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to pause account. Please try again.')),
                  );
                }
              }
            },
          );
        },
      );
    },
  );
}

Future<bool?> showResumeAccountBottomSheet(BuildContext context) {
  bool isLoading = false;
  
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return _buildCustomBottomSheetContent(
            context: modalContext,
            icon: '▶️',
            iconBgColor: const Color(0xFFE8F5E9), // Light green
            title: 'Resume your account?',
            subtitle: 'Your profile will be visible to everyone again. You can start matching and chatting.',
            primaryButtonText: isLoading ? 'Resuming...' : 'Resume account',
            primaryButtonColor: const Color(0xFF4CAF50), // Green
            isLoading: isLoading,
            onPrimaryPressed: () async {
              if (isLoading) return;
              setState(() => isLoading = true);
              
              String? error = await AccountSettingService.resumeAccount();
              bool success = error == null;
              
              if (modalContext.mounted) {
                setState(() => isLoading = false);
                Navigator.pop(modalContext, success);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account resumed successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $error')),
                  );
                }
              }
            },
          );
        },
      );
    },
  );
}

void showDeleteAccountBottomSheet(BuildContext context) {
  bool isLoading = false;
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return _buildCustomBottomSheetContent(
            context: modalContext,
            icon: '🗑️',
            iconBgColor: const Color(0xFFFCE8EE),
            title: 'Delete account permanently?',
            subtitle: 'This erases your profile, matches, messages and wallet balance forever. This cannot be undone.',
            primaryButtonText: isLoading ? 'Deleting...' : 'Delete everything',
            primaryButtonColor: const Color(0xFFE44E4E),
            isLoading: isLoading,
            onPrimaryPressed: () async {
              if (isLoading) return;
              setState(() => isLoading = true);
              
              bool success = await AccountSettingService.deleteAccount();
              
              if (modalContext.mounted) {
                setState(() => isLoading = false);
                Navigator.pop(modalContext);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully.')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashLogout()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete account. Please try again.')),
                  );
                }
              }
            },
          );
        },
      );
    },
  );
}

Widget _buildCustomBottomSheetContent({
  required BuildContext context,
  required String icon,
  required Color iconBgColor,
  required String title,
  required String subtitle,
  required String primaryButtonText,
  required Color primaryButtonColor,
  required VoidCallback onPrimaryPressed,
  bool isLoading = false,
}) {
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
}
