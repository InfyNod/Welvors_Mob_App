import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
import 'welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'welvors_home_screen/home_bloc/home_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';

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
        BlocProvider<BoostBloc>(
          create: (context) => BoostBloc(),
        ),
        BlocProvider<ProfileEditCubit>(
          create: (context) => ProfileEditCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Welvors',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: const TopAndBottomNavScreen(),
        // home: const LandingScreen(),
      ),
    );
  }
}