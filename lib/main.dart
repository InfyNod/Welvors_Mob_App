import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/firebase_options.dart';
import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/splash_screen.dart';
import 'package:velvors/utils/notification_service.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/trust_verification_screen.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
import 'welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'welvors_home_screen/home_bloc/home_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'welvors_home_screen/ui/event/events_bloc/events_bloc.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

import 'package:velvors/welvors_home_screen/services/network_connectivity_service.dart';
import 'package:velvors/welvors_home_screen/ui/network/no_internet_screen.dart';
import 'package:velvors/utils/app_update_helper.dart';
import 'package:velvors/utils/app_update_screen.dart';

// Firebase background message handler
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AppLogger.d("FCM", "Background message received: ${message.messageId}");
  AppLogger.d("FCM", "Background message data: ${message.data}");
}

void main() {
  AppLogger.runLoggingApp(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: '.env');
    if (EnvConfig.baseUrl.isEmpty || EnvConfig.apiBaseUrl.isEmpty) {
      throw StateError(
        'BASE_URL and API_BASE_URL must be set in the .env file.',
      );
    }

    // Remove grey shadow from Android status bar and make it transparent with dark icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize global network connectivity monitoring
    NetworkConnectivityService.instance.initialize();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    runApp(const WelvorsApp(initialRoute: '/splash'));
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class WelvorsApp extends StatefulWidget {
  final String initialRoute;

  const WelvorsApp({super.key, required this.initialRoute});

  @override
  State<WelvorsApp> createState() => _WelvorsAppState();
}

class _WelvorsAppState extends State<WelvorsApp> {
  bool _notificationInitialized = false;

  @override
  void initState() {
    super.initState();
    // Context available झाल्यानंतर notification initialize करतो
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }
  Future<void> _initializeNotifications() async {
    if (_notificationInitialized) {
      return;
    }
    _notificationInitialized = true;
    try {
      debugPrint('Initializing Notification Service...');
      final notificationService = NotificationService();
      await notificationService.initialize(context);
      debugPrint('Notification Service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Notification Service initialization failed: $e');
      debugPrint(stackTrace.toString());
    }
  }

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
        initialRoute: widget.initialRoute,
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
          '/no-internet': (context) => const NoInternetScreen(),
          '/app-update': (context) => AppUpdateScreen(
                currentVersion:
                    AppUpdateHelper.currentInstalledVersion ?? '1.0.0',
                latestVersion:
                    AppUpdateHelper.currentAppStoreVersion ?? '1.0.1',
                releaseNotes: AppUpdateHelper.releaseNotes,
                onUpdate: AppUpdateHelper.openPlayStore,
                onLater: () => Navigator.of(context).pop(),
              ),
        },
      ),
    );
  }
}
