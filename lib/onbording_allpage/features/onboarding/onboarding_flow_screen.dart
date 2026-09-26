import 'package:flutter/material.dart';
import '../../theme/app_dimens.dart';
import '../../widgets/onboarding_app_bar.dart';
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
  final int initialStep;
  const OnboardingFlowScreen({super.key, this.initialStep = 1});

  static int mapNextStepToScreenIndex(String? nextStep) {
    if (nextStep == null) return 1; // Default to basics if not specified
    switch (nextStep) {
      case 'BASIC_INFO': return 1;
      case 'INTERESTED_IN': return 2;
      case 'LOOKING_FOR': return 3;
      case 'LIFESTYLE': return 4;
      case 'CAREER_AMBITION': return 5;
      case 'INTEREST': return 6;
      case 'PHOTOS': return 7;
      case 'STORY': return 8;
      case 'PROMPT': return 9;
      case 'LOCATION': return 10;
      case 'REVIEW_FINISH': return 11;
      default: return 1;
    }
  }

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late int _currentStep;
  final int _totalSteps = 11; 
  
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController(initialPage: _currentStep - 1);
  }

  String get _currentTitle {
    switch (_currentStep) {
      case 1:
        return 'The basics';
      case 2:
        return 'Who you\'re seeing';
      case 3:
        return 'Your intentions';
      case 4:
        return 'Lifestyle';
      case 5:
        return 'Career & ambition';
      case 6:
        return 'Your interests';
      case 7:
        return 'Your photos';
      case 8:
        return 'About you';
      case 9:
        return 'Prompts';
      case 10:
        return 'Location';
      case 11:
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
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
