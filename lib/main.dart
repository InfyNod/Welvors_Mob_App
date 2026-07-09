import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import 'features/onboarding/landing_screen.dart';
import 'blocs/onboarding/onboarding_bloc.dart';

void main() {
  runApp(const VelvorsApp());
}

class VelvorsApp extends StatelessWidget {
  const VelvorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Velvors',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: const LandingScreen(),
      ),
    );
  }
}