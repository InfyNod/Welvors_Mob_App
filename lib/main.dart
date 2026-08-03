import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
import 'welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'welvors_home_screen/home_bloc/home_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the test token provided by the backend team for testing
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIzNWJlOTAxYS04ODQwLTQxYjYtYWRlMi05NzVkZGVkNWQ4YmMiLCJpYXQiOjE3ODU3MzkxNDAsImV4cCI6MTc4NjM0Mzk0MH0.ECs9pmBaKND8GXsT0u-4aBL9jtzphdCGGv9I_ROuIpg');

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