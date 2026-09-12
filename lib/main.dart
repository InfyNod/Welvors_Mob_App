// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:velvors/onbording_allpage/features/onboarding/completion_screen.dart';
// import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
// import 'onbording_allpage/theme/app_theme.dart';
// import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
// import 'welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
// import 'welvors_home_screen/home_bloc/home_bloc.dart';
// import 'welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
// import 'welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
// import 'welvors_home_screen/ui/event/events_bloc/events_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Set the test token provided by the backend team for testing
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString(
//     'auth_token',
//     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs',
//   );

//   runApp(const WelvorsApp());
// }

// class WelvorsApp extends StatelessWidget {
//   const WelvorsApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<OnboardingBloc>(create: (context) => OnboardingBloc()),
//         BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
//         BlocProvider<BoostBloc>(create: (context) => BoostBloc()),
//         BlocProvider<ProfileEditCubit>(create: (context) => ProfileEditCubit()),
//         BlocProvider<EventsBloc>(create: (context) => EventsBloc()),
//       ],
//       child: MaterialApp(
//         title: 'Welvors',
//         theme: buildTheme(),
//         debugShowCheckedModeBanner: false,
//         home: const TopAndBottomNavScreen(),
//         // home: const LandingScreen(),
//         // home: const CompletionScreen(),
//       ),
//     );
//   }
// }555

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/splash_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/trust_verification_screen.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
import 'welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'welvors_home_screen/home_bloc/home_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'welvors_home_screen/ui/event/events_bloc/events_bloc.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove grey shadow from Android status bar and make it transparent with dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WelvorsApp(initialRoute: '/splash'));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class WelvorsApp extends StatelessWidget {
  final String initialRoute;
  const WelvorsApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(create: (context) => OnboardingBloc()),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
        BlocProvider<BoostBloc>(create: (context) => BoostBloc()),
        BlocProvider<ProfileEditCubit>(create: (context) => ProfileEditCubit()),
        BlocProvider<EventsBloc>(create: (context) => EventsBloc()),
      ],
      child: MaterialApp(
        title: 'Welvors',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        initialRoute: initialRoute,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const TopAndBottomNavScreen(),
          '/landing': (context) => const LandingScreen(),
          '/TrustVerificationScreen': (context) =>
              const TrustVerificationScreen(),
        },
      ),
    );
  }
}
