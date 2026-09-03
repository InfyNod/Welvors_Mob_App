import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../onbording_allpage/theme/app_colors.dart';
import '../../../../../../onbording_allpage/theme/app_text.dart';

class SplashLogout extends StatefulWidget {
  const SplashLogout({super.key});

  @override
  State<SplashLogout> createState() => _SplashLogoutState();
}

class _SplashLogoutState extends State<SplashLogout> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    // Step 1: Saving your session
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _currentStep = 1);

      // Step 2: Clearing local data
      _timer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _currentStep = 2);

        // Step 3: Signing out securely
        _timer = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _currentStep = 3);

          // Step 4: Navigate to landing and clear session
          _timer = Timer(const Duration(milliseconds: 800), () async {
            if (mounted) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
              }
            }
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildChecklistItem(String text, bool isVisible) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, isVisible ? 0 : 10, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isVisible ? AppColors.green : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: AppText.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isVisible ? AppColors.ink : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Slight off-white like the image
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide default back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () {
              // Might want to block back navigation during logout
              // But to match the UI screenshot exactly, we add it.
            },
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
        title: Text('Log out', style: AppText.h2.copyWith(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Progress Indicator (Red/Pink)
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: AppColors.pink,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Signing you out...',
                style: AppText.h1.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Clearing this device's session.",
                style: AppText.sub.copyWith(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 40),

              // Checklist
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklistItem('Saving your session', _currentStep >= 1),
                  _buildChecklistItem('Clearing local data', _currentStep >= 2),
                  _buildChecklistItem('Signing out securely', _currentStep >= 3),
                ],
              ),
              const SizedBox(height: 60), // Push slightly up from exact center
            ],
          ),
        ),
      ),
    );
  }
}
