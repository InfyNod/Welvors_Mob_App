import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/features/onboarding/landing_screen.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';

void main() {
  runApp(const WelvorsApp());
}

class WelvorsApp extends StatelessWidget {
  const WelvorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Welvors',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: const LandingScreen(),
      ),
    );
  }
}