import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
import 'welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'welvors_home_screen/bloc/home_bloc.dart';

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
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Welvors',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: const TopAndBottomNavScreen(),
      ),
    );
  }
}