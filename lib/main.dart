import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/firebase_options.dart';
import 'package:velvors/utils/notification_service.dart';
import 'onbording_allpage/theme/app_theme.dart';
import 'onbording_allpage/blocs/onboarding/onboarding_bloc.dart';
import 'welvors_home_screen/home_bloc/home_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
import 'welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'welvors_home_screen/ui/event/events_bloc/events_bloc.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

import 'package:velvors/welvors_home_screen/services/network_connectivity_service.dart';
import 'package:velvors/utils/navigation/app_router.dart';

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
    runApp(const WelvorsApp());
  });
}

// Global navigatorKey referencing AppRouter navigatorKey for backward compatibility
final GlobalKey<NavigatorState> navigatorKey = AppRouter.navigatorKey;

class WelvorsApp extends StatefulWidget {
  final String initialRoute;

  const WelvorsApp({super.key, this.initialRoute = '/splash'});

  @override
  State<WelvorsApp> createState() => _WelvorsAppState();
}

class _WelvorsAppState extends State<WelvorsApp> {
  bool _notificationInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize notifications once context is available
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

      child: MaterialApp.router(
        title: 'Welvors',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
