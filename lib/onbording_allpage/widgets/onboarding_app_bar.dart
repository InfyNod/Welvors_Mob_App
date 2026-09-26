import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class OnboardingAppBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final VoidCallback? onBack;
  final bool showProgress;

  const OnboardingAppBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.onBack,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    double targetProgress = showProgress ? currentStep / totalSteps : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetProgress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        int percentage = (progress * 100).toInt();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
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
                
                // Center Titles
                Column(
                  children: [
                    if (showProgress)
                      Text(
                        'STEP $currentStep OF $totalSteps',
                        style: AppText.eyebrow.copyWith(color: AppColors.pinkDeep, fontSize: 10, letterSpacing: 1.5),
                      ),
                    if (showProgress) ...[
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppText.h2.copyWith(fontSize: 16),
                      ),
                    ],
                  ],
                ),
                
                // Progress Circle or Placeholder
                if (showProgress)
                  SizedBox(
                    width: 44, height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: AppColors.line,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pinkDeep),
                        ),
                        Text(
                          '$percentage%',
                          style: AppText.body.copyWith(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 44, height: 44),
              ],
            ),
            const SizedBox(height: 16),
            // Linear Progress Bar
            if (showProgress) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.line,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pinkDeep),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              const SizedBox(height: 16), // Placeholder for linear progress
            ],
          ],
        );
      },
    );
  }
}
