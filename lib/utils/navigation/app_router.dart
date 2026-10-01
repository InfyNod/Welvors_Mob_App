import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/login_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/onboarding_flow_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/payment_success_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/refer_and_earn_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/splash_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/verify_number_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/waitlist_confirmed_screen.dart';
import 'package:velvors/utils/app_update_helper.dart';
import 'package:velvors/utils/app_update_screen.dart';
import 'package:velvors/utils/navigation/app_routes.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_state.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_detail_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_media_links_docs_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/video_call_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/voice_call_screen.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/post_a_plan/activity_1.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/requests_sent/requests_sent_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/bank_upi.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/membership_plan/membership_plan.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/personal_info.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/privacy_controls/blocked_users.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/privacy_controls/mute_account.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/privacy_controls/privacy_controls_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/privacy_controls/who_message.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_pages/push_notification.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/account_setting/account_setting._screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/commitment_management.dart/commitment_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/compliments/compliments_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/trust_verification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/date_plans/date_plan_wallet.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/top_bottom_nav_editscreen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/help_support/all_screen_help/call_back.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/help_support/all_screen_help/live_chat.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/help_support/help_support_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/legal_policy_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/logout/logout_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/logout/splash_logout.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/model/membership_plan_model.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/choose_plan_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_all_screen/boost_top_nav.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_bloc/boost_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_history.dart/boost_history.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_history.dart/performance_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost_wallet_all_screen/boost_wallet_top_nav.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_wallet/add_money_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_wallet/my_wallet_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/my_wallet/withdraw_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/roses/roses_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/marriage/drawer_marriage_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/mature_dating/drawer_mature_dating_screen.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/cancel/track_refund_status.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/my_ticket.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/ticket_screen.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/booking_confirm.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/check_out.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/event_details.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/splash_screen_book.dart';
import 'package:velvors/welvors_home_screen/ui/home/filter/filter_bloc/filter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/home/filter/filter_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/match/match_analysis_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/notification/notification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/trust_score/trust_screen.dart';
import 'package:velvors/welvors_home_screen/ui/network/no_internet_screen.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';

/// Centralized GoRouter Navigation Configuration for Welvors
///
/// Designed with Bloc architecture principles:
/// - Stateless route definitions
/// - Deep linking & URI query/path parameters support
/// - Push notification payload redirection handler
/// - Global navigation without needing BuildContext
/// - Smooth customized page transitions
class AppRouter {
  // Global Navigator Key for navigation outside BuildContext
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'WelvorsRootNavigator');

  /// Custom Smooth Transition Page Builder (Fade Transition)
  static CustomTransitionPage<T> customTransitionPage<T>({
    required Widget child,
    LocalKey? key,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide Transition Page Builder
  static CustomTransitionPage<T> slideTransitionPage<T>({
    required Widget child,
    LocalKey? key,
    Offset begin = const Offset(1.0, 0.0),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// GoRouter Instance
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    routes: [
      // ========================================================
      // SPLASH & ONBOARDING
      // ========================================================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const LandingScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.verifyNumber,
        name: 'verifyNumber',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const VerifyNumberScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.onboardingFlow,
        name: 'onboardingFlow',
        pageBuilder: (context, state) {
          final stepParam = state.uri.queryParameters['step'];
          final initialStep = int.tryParse(stepParam ?? '1') ?? 1;

          return customTransitionPage(
            key: state.pageKey,
            child: OnboardingFlowScreen(initialStep: initialStep),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.paymentSuccess,
        name: 'paymentSuccess',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const PaymentSuccessScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.waitlistConfirmed,
        name: 'waitlistConfirmed',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const WaitlistConfirmedScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.referAndEarn,
        name: 'referAndEarn',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const ReferAndEarnScreen(),
        ),
      ),

      // ========================================================
      // HOME & CORE NAVIGATION
      // ========================================================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'] ??
              state.uri.queryParameters['index'];
          final initialIndex = int.tryParse(tabParam ?? '0') ?? 0;
          final isPreview =
              state.uri.queryParameters['isPreview'] == 'true';

          return customTransitionPage(
            key: state.pageKey,
            child: TopAndBottomNavScreen(
              initialIndex: initialIndex,
              isPreview: isPreview,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.matchAnalysis,
        name: 'matchAnalysis',
        pageBuilder: (context, state) {
          final name = state.extra is String
              ? state.extra as String
              : state.uri.queryParameters['name'] ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: MatchAnalysisScreen(matchName: name),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.trustScreen,
        name: 'trustScreen',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const TrustScreen(),
        ),
      ),

      // ========================================================
      // CHAT & CALLING
      // ========================================================
      GoRoute(
        path: AppRoutes.chatDetail,
        name: 'chatDetail',
        pageBuilder: (context, state) {
          ChatUser? user;
          ChatBloc? passedBloc;

          if (state.extra is ChatUser) {
            user = state.extra as ChatUser;
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            if (map['user'] is ChatUser) {
              user = map['user'] as ChatUser;
            } else {
              user = ChatUser.fromConversationJson(map);
            }
            if (map['bloc'] is ChatBloc) {
              passedBloc = map['bloc'] as ChatBloc;
            }
          } else {
            final params = state.uri.queryParameters;
            final convId = params['conversationId'] ?? params['id'] ?? '';
            final userId = params['userId'] ?? '';
            final name = params['name'] ?? 'User';
            final age = int.tryParse(params['age'] ?? '0') ?? 0;
            final image = params['image'] ?? '';

            user = ChatUser(
              id: convId.isNotEmpty ? convId : userId,
              conversationId: convId,
              userId: userId,
              name: name,
              age: age,
              image: image,
              preview: '',
              time: '',
              match: '',
              trust: '',
              online: false,
              unread: 0,
              progress: '',
              reward: '',
              progressCurrent: 0,
              progressTarget: 0,
              progressPercentage: 0.0,
              progressLabel: '',
              progressType: '',
              giftName: '',
              progressExpiresAt: null,
            );
          }

          Widget child = ChatDetailScreen(user: user);
          if (passedBloc != null) {
            child = BlocProvider.value(
              value: passedBloc,
              child: child,
            );
          }

          return slideTransitionPage(
            key: state.pageKey,
            child: child,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.chatMedia,
        name: 'chatMedia',
        pageBuilder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;
          final userName = extra['userName']?.toString() ?? 'User';
          final conversationId = extra['conversationId']?.toString() ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: ChatMediaLinksDocsScreen(
              userName: userName,
              conversationId: conversationId,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.videoCall,
        name: 'videoCall',
        pageBuilder: (context, state) {
          final data = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;

          final user = data['user'] as ChatUser;
          final currentUserId = data['currentUserId']?.toString() ?? '';
          final currentUserName = data['currentUserName']?.toString() ?? '';
          final callId = data['callId']?.toString() ?? '';

          return customTransitionPage(
            key: state.pageKey,
            child: VideoCallScreen(
              user: user,
              currentUserId: currentUserId,
              currentUserName: currentUserName,
              callId: callId,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.voiceCall,
        name: 'voiceCall',
        pageBuilder: (context, state) {
          final data = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;

          final user = data['user'] as ChatUser;
          final currentUserId = data['currentUserId']?.toString() ?? '';
          final currentUserName = data['currentUserName']?.toString() ?? '';
          final callId = data['callId']?.toString() ?? '';

          return customTransitionPage(
            key: state.pageKey,
            child: VoiceCallScreen(
              user: user,
              currentUserId: currentUserId,
              currentUserName: currentUserName,
              callId: callId,
            ),
          );
        },
      ),

      // ========================================================
      // NOTIFICATIONS & FILTERS
      // ========================================================
      GoRoute(
        path: AppRoutes.notification,
        name: 'notification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const NotificationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.filter,
        name: 'filter',
        pageBuilder: (context, state) {
          Widget child = const FilterScreen();
          try {
            context.read<FilterBloc>();
          } catch (_) {
            child = BlocProvider<FilterBloc>(
              create: (_) => FilterBloc(),
              child: child,
            );
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: child,
          );
        },
      ),

      // ========================================================
      // EVENTS
      // ========================================================
      GoRoute(
        path: AppRoutes.eventDetails,
        name: 'eventDetails',
        pageBuilder: (context, state) {
          Map<String, dynamic> extra = {};
          if (state.extra is Map<String, dynamic>) {
            extra = state.extra as Map<String, dynamic>;
          }
          final params = state.uri.queryParameters;

          final eventId =
              extra['eventId']?.toString() ?? params['eventId'] ?? '';
          final title =
              extra['title']?.toString() ?? params['title'] ?? 'Event';
          final date = extra['date']?.toString() ?? params['date'] ?? '';
          final location =
              extra['location']?.toString() ?? params['location'] ?? '';
          final imageUrl =
              extra['imageUrl']?.toString() ?? params['imageUrl'] ?? '';
          final status =
              extra['status']?.toString() ?? params['status'] ?? 'Available';
          final price = extra['price']?.toString() ?? params['price'] ?? 'Free';
          final spotsLeft = int.tryParse(
                  extra['spotsLeft']?.toString() ?? params['spotsLeft'] ?? '8') ??
              8;
          final categories = extra['categories'] as List<String>?;
          final featureTags = extra['featureTags'] as List<dynamic>?;

          return slideTransitionPage(
            key: state.pageKey,
            child: EventDetailsScreen(
              eventId: eventId,
              title: title,
              date: date,
              location: location,
              imageUrl: imageUrl,
              status: status,
              price: price,
              spotsLeft: spotsLeft,
              categories: categories,
              featureTags: featureTags,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.eventCheckout,
        name: 'eventCheckout',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return slideTransitionPage(
            key: state.pageKey,
            child: CheckoutScreen(
              eventId: extra['eventId']?.toString() ?? '',
              title: extra['title']?.toString() ?? '',
              date: extra['date']?.toString() ?? '',
              location: extra['location']?.toString() ?? '',
              imageUrl: extra['imageUrl']?.toString() ?? '',
              basePrice: (extra['basePrice'] is num)
                  ? (extra['basePrice'] as num).toDouble()
                  : 0.0,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.eventBookingSplash,
        name: 'eventBookingSplash',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return customTransitionPage(
            key: state.pageKey,
            child: SplashScreenBook(
              totalPayable: (extra['totalPayable'] is num)
                  ? (extra['totalPayable'] as num).toDouble()
                  : (extra['totalAmount'] is num)
                      ? (extra['totalAmount'] as num).toDouble()
                      : 0.0,
              title: extra['title']?.toString() ?? '',
              date: extra['date']?.toString() ?? '',
              location: extra['location']?.toString() ?? '',
              bookingId: extra['bookingId']?.toString() ?? '',
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.eventBookingConfirm,
        name: 'eventBookingConfirm',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return slideTransitionPage(
            key: state.pageKey,
            child: BookingConfirmationScreen(
              bookingId: extra['bookingId']?.toString() ?? '',
              title: extra['title']?.toString() ?? '',
              date: extra['date']?.toString() ?? '',
              location: extra['location']?.toString() ?? '',
              totalPayable: (extra['totalPayable'] is num)
                  ? (extra['totalPayable'] as num).toDouble()
                  : (extra['totalAmount'] is num)
                      ? (extra['totalAmount'] as num).toDouble()
                      : 1424.0,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.eventTicket,
        name: 'eventTicket',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return slideTransitionPage(
            key: state.pageKey,
            child: TicketScreen(
              title: extra['title']?.toString() ?? '',
              date: extra['date']?.toString() ?? '',
              location: extra['location']?.toString() ?? '',
              status: extra['status']?.toString() ?? '',
              bookingId: extra['bookingId']?.toString() ?? '',
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.trackRefund,
        name: 'trackRefund',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const TrackRefundScreen(),
        ),
      ),

      // ========================================================
      // DRAWER / DATING ECOSYSTEM
      // ========================================================
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.trustVerification,
        name: 'trustVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const TrustVerificationScreen(),
        ),
      ),

      // Backward compatible route for legacy TrustVerificationScreen
      GoRoute(
        path: AppRoutes.legacyTrustVerification,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const TrustVerificationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.boost,
        name: 'boost',
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab = int.tryParse(tabParam ?? '0') ?? 0;
          return slideTransitionPage(
            key: state.pageKey,
            child: BoostTopNav(initialTab: initialTab),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.boostWallet,
        name: 'boostWallet',
        pageBuilder: (context, state) {
          final indexParam = state.uri.queryParameters['index'];
          final initialIndex = int.tryParse(indexParam ?? '0') ?? 0;
          return slideTransitionPage(
            key: state.pageKey,
            child: BoostWalletTopNav(initialIndex: initialIndex),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.boostHistory,
        name: 'boostHistory',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const BoostHistoryScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.myWallet,
        name: 'myWallet',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const MyWalletScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.addMoney,
        name: 'addMoney',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const AddMoneyScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.withdraw,
        name: 'withdraw',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const WithdrawScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.roses,
        name: 'roses',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const RosesScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.compliments,
        name: 'compliments',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const ComplimentsScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.datePlanWallet,
        name: 'datePlans',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const DatePlanWallet(),
        ),
      ),

      GoRoute(
        path: AppRoutes.postDatePlan,
        name: 'postDatePlan',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const Activity1Screen(),
        ),
      ),

      // ========================================================
      // ACCOUNT SETTINGS
      // ========================================================
      GoRoute(
        path: AppRoutes.accountSettings,
        name: 'accountSettings',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const AccountSettingScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.personalInfo,
        name: 'personalInfo',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const PersonalInfoScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.membershipPlan,
        name: 'membershipPlan',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const MembershipPlanScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.choosePlan,
        name: 'choosePlan',
        pageBuilder: (context, state) {
          MembershipTier tier = MembershipTier.premiumPlus;
          if (state.extra is MembershipTier) {
            tier = state.extra as MembershipTier;
          } else if (state.uri.queryParameters['tier'] != null) {
            final t = state.uri.queryParameters['tier']!.toLowerCase();
            if (t == 'vip') tier = MembershipTier.vip;
            if (t == 'elite') tier = MembershipTier.elite;
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: ChoosePlanScreen(initialTier: tier),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.bankUpi,
        name: 'bankUpi',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const BankUpiScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.privacyControls,
        name: 'privacyControls',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const PrivacyControlsScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.pushNotifications,
        name: 'pushNotifications',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const PushNotificationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.whoMessage,
        name: 'whoMessage',
        pageBuilder: (context, state) {
          final option = state.extra is String
              ? state.extra as String
              : state.uri.queryParameters['option'] ?? 'everyone';
          return slideTransitionPage(
            key: state.pageKey,
            child: WhoMessageScreen(initialOption: option),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.blockedUsers,
        name: 'blockedUsers',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const BlockedUsersScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.muteAccount,
        name: 'muteAccount',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const MuteAccountScreen(),
        ),
      ),

      // ========================================================
      // HELP, SUPPORT & LEGAL
      // ========================================================
      GoRoute(
        path: AppRoutes.helpSupport,
        name: 'helpSupport',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const HelpSupportScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.liveChat,
        name: 'liveChat',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const LiveChatScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.callBack,
        name: 'callBack',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const CallBackScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.legalPolicy,
        name: 'legalPolicy',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const LegalPoliciesScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.marriage,
        name: 'marriage',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: MarriageScreen(
            onNavigateToDating: () => goToHome(tab: 0),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.matureDating,
        name: 'matureDating',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: MatureDatingScreen(
            onNavigateToDating: () => goToHome(tab: 0),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.myBookings,
        name: 'myBookings',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const MyTicketScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.myDates,
        name: 'myDates',
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTabIndex = int.tryParse(tabParam ?? '0') ?? 0;
          return slideTransitionPage(
            key: state.pageKey,
            child: RequestsSentScreen(initialTabIndex: initialTabIndex),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.commitment,
        name: 'commitment',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const CommitmentScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.logout,
        name: 'logout',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const LogoutScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.splashLogout,
        name: 'splashLogout',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const SplashLogout(),
        ),
      ),

      GoRoute(
        path: AppRoutes.performance,
        name: 'performance',
        pageBuilder: (context, state) {
          final item = state.extra as BoostHistoryItem;
          return slideTransitionPage(
            key: state.pageKey,
            child: PerformanceScreen(item: item),
          );
        },
      ),

      // ========================================================
      // SYSTEM & UPDATES
      // ========================================================
      GoRoute(
        path: AppRoutes.noInternet,
        name: 'noInternet',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const NoInternetScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.appUpdate,
        name: 'appUpdate',
        pageBuilder: (context, state) {
          final isForce = state.uri.queryParameters['isForce'] == 'true';

          return customTransitionPage(
            key: state.pageKey,
            child: AppUpdateScreen(
              currentVersion:
                  AppUpdateHelper.currentInstalledVersion ?? '1.0.0',
              latestVersion:
                  AppUpdateHelper.currentAppStoreVersion ?? '1.0.1',
              releaseNotes: AppUpdateHelper.releaseNotes,
              isForceUpdate: isForce,
              onUpdate: AppUpdateHelper.openPlayStore,
              onLater: () => pop(),
            ),
          );
        },
      ),
    ],

    // Fallback error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Route "${state.uri}" not found',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => goToHome(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // ============================================================
  // CONVENIENCE NAVIGATION METHODS (Globally Accessible)
  // ============================================================

  /// Push a route onto the navigation stack
  static Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return router.push<T>(location, extra: extra);
  }

  /// Replace the current route with a new route
  static void go(String location, {Object? extra}) {
    router.go(location, extra: extra);
  }

  /// Push replacement of current route
  static Future<T?> pushReplacement<T extends Object?>(String location,
      {Object? extra}) {
    return router.pushReplacement<T>(location, extra: extra);
  }

  /// Pop the top-most route
  static void pop<T extends Object?>([T? result]) {
    if (router.canPop()) {
      router.pop(result);
    } else {
      router.go(AppRoutes.home);
    }
  }

  /// Navigate to Home with optional tab selection
  /// 0 = Dating, 1 = Date Now, 2 = Admirers, 3 = Chat, 4 = Events
  static void goToHome({int tab = 0}) {
    router.go('${AppRoutes.home}?tab=$tab');
  }

  /// Navigate to Chat Detail Screen
  static void goToChat(ChatUser user) {
    router.push(AppRoutes.chatDetail, extra: user);
  }

  // ============================================================
  // PUSH NOTIFICATION & DEEP LINK REDIRECTION HANDLER
  // ============================================================

  /// Centralized Notification Destination Router
  /// Handles deep links and FCM payloads seamlessly
  static void handleNotificationRedirection(Map<String, dynamic> data) {
    AppLogger.d('AppRouter', 'Routing notification data: $data');

    try {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      if (payload['payload'] is String) {
        try {
          final decoded = jsonDecode(payload['payload'] as String);
          if (decoded is Map<String, dynamic>) {
            payload.addAll(decoded);
          }
        } catch (_) {}
      }

      // 1. Check if an explicit route or deeplink is provided
      final explicitRoute = payload['route']?.toString() ??
          payload['deeplink']?.toString() ??
          payload['path']?.toString();

      if (explicitRoute != null && explicitRoute.isNotEmpty) {
        if (explicitRoute.startsWith('/')) {
          router.push(explicitRoute);
        } else {
          router.push('/$explicitRoute');
        }
        return;
      }

      // 2. Identify notification type
      final type = (payload['type'] ?? payload['notificationType'] ?? '')
          .toString()
          .toUpperCase()
          .trim();

      switch (type) {
        case 'CHAT':
        case 'MESSAGE':
        case 'NEW_MESSAGE':
          final conversationId = payload['conversationId']?.toString() ??
              payload['id']?.toString() ??
              '';
          final userId = payload['userId']?.toString() ??
              payload['senderId']?.toString() ??
              '';
          final name = payload['name']?.toString() ??
              payload['senderName']?.toString() ??
              '';
          final image = payload['image']?.toString() ??
              payload['senderImage']?.toString() ??
              '';

          if (conversationId.isNotEmpty || userId.isNotEmpty) {
            final uri = Uri(
              path: AppRoutes.chatDetail,
              queryParameters: {
                if (conversationId.isNotEmpty)
                  'conversationId': conversationId,
                if (userId.isNotEmpty) 'userId': userId,
                if (name.isNotEmpty) 'name': name,
                if (image.isNotEmpty) 'image': image,
              },
            );
            router.push(uri.toString());
          } else {
            // Switch to Chat Tab in Home
            goToHome(tab: 3);
          }
          break;

        case 'NOTIFICATION':
        case 'NOTIFICATIONS':
          router.push(AppRoutes.notification);
          break;

        case 'EVENT':
        case 'EVENTS':
        case 'EVENT_BOOKING':
          final eventId = payload['eventId']?.toString();
          if (eventId != null && eventId.isNotEmpty) {
            final uri = Uri(
              path: AppRoutes.eventDetails,
              queryParameters: {
                'eventId': eventId,
                if (payload['title'] != null) 'title': payload['title'].toString(),
                if (payload['date'] != null) 'date': payload['date'].toString(),
                if (payload['location'] != null)
                  'location': payload['location'].toString(),
                if (payload['imageUrl'] != null)
                  'imageUrl': payload['imageUrl'].toString(),
                if (payload['price'] != null) 'price': payload['price'].toString(),
              },
            );
            router.push(uri.toString());
          } else {
            // Switch to Events Tab in Home
            goToHome(tab: 4);
          }
          break;

        case 'DATE_PLAN':
        case 'DATE_REQUEST':
        case 'DATE_ACCEPT':
          // Switch to Date Now tab in Home
          goToHome(tab: 1);
          break;

        case 'MATCH':
        case 'LIKE':
        case 'ROSE':
        case 'ADMIRER':
          // Switch to Admirers tab in Home
          goToHome(tab: 2);
          break;

        case 'BOOST':
        case 'SUPER_BOOST':
          router.push(AppRoutes.boost);
          break;

        case 'WALLET':
        case 'MONEY':
        case 'TRANSACTION':
          router.push(AppRoutes.myWallet);
          break;

        case 'TRUST':
        case 'VERIFICATION':
          router.push(AppRoutes.trustVerification);
          break;

        case 'UPDATE':
        case 'APP_UPDATE':
          router.push(AppRoutes.appUpdate);
          break;

        default:
          AppLogger.d(
            'AppRouter',
            'Unknown notification type ($type), routing to notifications screen',
          );
          router.push(AppRoutes.notification);
          break;
      }
    } catch (e, stack) {
      AppLogger.e('AppRouter', 'Failed to handle notification redirection: $e');
      debugPrint(stack.toString());
    }
  }
}
