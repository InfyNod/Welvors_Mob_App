import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';

/// App Update Screen & Dialog UI
///
/// Designed with Welvors brand guidelines:
/// - Warm canvas background
/// - Welvors Pink (#E33A69) accent & gradient
/// - Clean card layout with "What\'s New" notes
/// - Support for both Optional and Force Update modes
class AppUpdateScreen extends StatelessWidget {
  /// Installed current version of the app (e.g. "1.0.0")
  final String currentVersion;

  /// Latest version available on Play Store (e.g. "1.0.1")
  final String latestVersion;

  /// Release notes retrieved from Play Store or custom
  final String? releaseNotes;

  /// If true, user cannot skip/dismiss the update
  final bool isForceUpdate;

  /// Callback when user taps "Update Now"
  final VoidCallback onUpdate;

  /// Callback when user taps "Later" (null if force update)
  final VoidCallback? onLater;

  const AppUpdateScreen({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes,
    this.isForceUpdate = false,
    required this.onUpdate,
    this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpdate,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: AppUpdateContent(
                currentVersion: currentVersion,
                latestVersion: latestVersion,
                releaseNotes: releaseNotes,
                isForceUpdate: isForceUpdate,
                onUpdate: onUpdate,
                onLater: onLater,
                isDialog: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The core visual update widget used in both Full Screen and Dialog modals
class AppUpdateContent extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String? releaseNotes;
  final bool isForceUpdate;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;
  final bool isDialog;

  const AppUpdateContent({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes,
    this.isForceUpdate = false,
    required this.onUpdate,
    this.onLater,
    this.isDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.line.withValues(alpha: 0.8), width: 1),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDialog ? 20.0 : 24.0,
        vertical: 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Graphic / Illustration Badge
          _buildIllustration(),

          const SizedBox(height: 18),

          // 2. Badge "NEW UPDATE"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.pinkSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.pink,
                ),
                const SizedBox(width: 6),
                Text(
                  isForceUpdate ? 'CRITICAL UPDATE' : 'NEW VERSION AVAILABLE',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.pink,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Title & Subtitle
          Text(
            isForceUpdate ? 'Update Required' : 'Time to Update!',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isForceUpdate
                ? 'A critical update is required to continue enjoying Welvors seamlessly. Please update now.'
                : 'A newer and better version of Welvors is ready for you on Google Play Store with latest features & fixes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.ink60,
            ),
          ),

          const SizedBox(height: 18),

          // 4. Version Comparison Row
          _buildVersionPill(),

          const SizedBox(height: 18),

          // 5. What's New Box
          _buildReleaseNotesBox(),

          const SizedBox(height: 22),

          // 6. Primary Action: "Update Now"
          _buildUpdateButton(),

          // 7. Secondary Action: "Later" (only if optional)
          if (!isForceUpdate) ...[
            const SizedBox(height: 10),
            _buildLaterButton(context),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppColors.muted.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 5),
                Text(
                  'Update is required to proceed',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Top animated-style circular icon
  Widget _buildIllustration() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pinkSoft,
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE33A69),
                Color(0xFFFF527B),
              ],
            ),
          ),
          child: const Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  /// Version badges: Current -> Latest
  Widget _buildVersionPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Current Version
          Column(
            children: [
              Text(
                'Installed',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currentVersion.isNotEmpty ? 'v$currentVersion' : 'Current',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink60,
                ),
              ),
            ],
          ),

          const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: AppColors.pink,
          ),

          // Latest Version
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Available',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                latestVersion.isNotEmpty ? 'v$latestVersion' : 'Latest',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// What's New Container
  Widget _buildReleaseNotesBox() {
    final hasNotes = releaseNotes != null && releaseNotes!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Text(
                "What's New:",
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: SingleChildScrollView(
              child: hasNotes
                  ? Text(
                      releaseNotes!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors.ink60,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureBullet('⚡ Faster and smoother app performance'),
                        const SizedBox(height: 4),
                        _buildFeatureBullet('💖 Improved matchmaking & instant notifications'),
                        const SizedBox(height: 4),
                        _buildFeatureBullet('🔒 Security updates and bug fixes'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              height: 1.35,
              color: AppColors.ink60,
            ),
          ),
        ),
      ],
    );
  }

  /// Update Now Primary CTA Button
  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE33A69),
            Color(0xFFFF4876),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38E33A69),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onUpdate,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shop_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Update Now',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maybe Later secondary action
  Widget _buildLaterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink60,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onLater ?? () => Navigator.of(context).pop(),
        child: Text(
          'Maybe Later',
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ),
    );
  }
}
