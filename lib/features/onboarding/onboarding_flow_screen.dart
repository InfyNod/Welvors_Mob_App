import 'package:flutter/material.dart';
import '../../theme/app_dimens.dart';
import '../../widgets/onboarding_app_bar.dart';
import 'verify_number_screen.dart';
import 'basics_screen.dart';
import 'preferences_screen.dart';
import 'intentions_screen.dart';
import 'lifestyle_screen.dart';
import 'career_screen.dart';
import 'interests_screen.dart';
import 'photos_screen.dart';
import 'about_screen.dart';
import 'prompts_screen.dart';
import 'location_screen.dart';
import 'review_screen.dart';
import 'completion_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 1;
  final int _totalSteps = 12; 
  
  final PageController _pageController = PageController();

  String get _currentTitle {
    switch (_currentStep) {
      case 1:
        return 'Verify your number';
      case 2:
        return 'The basics';
      case 3:
        return 'Who you\'re seeing';
      case 4:
        return 'Your intentions';
      case 5:
        return 'Lifestyle';
      case 6:
        return 'Career & ambition';
      case 7:
        return 'Your interests';
      case 8:
        return 'Your photos';
      case 9:
        return 'About you';
      case 10:
        return 'Prompts';
      case 11:
        return 'Location';
      case 12:
        return 'Review & finish';
      default:
        return 'Setup';
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.pad, 16, AppDimens.pad, 0),
              child: OnboardingAppBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                title: _currentTitle,
                onBack: _previousStep,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  VerifyNumberScreen(onVerifySuccess: _nextStep),
                  BasicsScreen(onNext: _nextStep),
                  PreferencesScreen(onNext: _nextStep),
                  IntentionsScreen(onNext: _nextStep),
                  LifestyleScreen(onNext: _nextStep),
                  CareerScreen(onNext: _nextStep),
                  InterestsScreen(onNext: _nextStep),
                  PhotosScreen(onNext: _nextStep),
                  AboutScreen(onNext: _nextStep),
                  PromptsScreen(onNext: _nextStep),
                  LocationScreen(onNext: _nextStep),
                  ReviewScreen(onFinish: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompletionScreen()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
