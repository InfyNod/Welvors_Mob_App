import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:velvors/onbording_allpage/features/onboarding/landing_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/login_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/onboarding_flow_screen.dart';
import 'package:velvors/onbording_allpage/features/onboarding/completion_screen.dart';
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
import 'package:velvors/welvors_home_screen/ui/chat/all_new_matches_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_media_links_docs_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_pdf_viewer_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/location_map_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/custom_camera_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/YourJourneyScreen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/video_call_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/voice_call_screen.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/profile/profile_detail.dart';
import 'package:velvors/onbording_allpage/features/onboarding/choose_prompt_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/career_ambition.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/your_intentions.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/intrested.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/prompts.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/video.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/post_a_plan/activity_1.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/post_a_plan/map_selection_dialog.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/post_a_plan/bloc/post_plan_state.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/requests_sent/requests_sent_screen.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/my_plans/profile.dart';
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
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/bloc/government_verification/government_verification_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/bloc/government_verification/government_verification_event.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/data/government_verification_repository.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/government_Id/government_verification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/face_verification/face_verification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/video_verification/video_verification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/bloc/Education/education_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/bloc/Education/education_event.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/data/education_repository.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/education_id/education_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/bloc/professional_verfication_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/bloc/professional_verfication_evnt.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/data/professional_verication_repository.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/professional_verification.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/platinum_verification/bloc/platinum_verification_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/platinum_verification/data/platinum_verification_repository.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/platinum_verification/screens/platinum_contact_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/platinum_verification/platinum_verification_flow_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/platinum_verification/bloc/platinum_verification_event.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/education_id/education_Instant/education_instant.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/education_id/manually/education_manually.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/government_Id/upload_id/screens/upload_id_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/instant_verification/widget/instant_verification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/instant_verification/widget/aadhaarVerifiedScreen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/face_verification/FaceVerifiedScreen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/presentation/screens/professional_email_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/presentation/screens/professional_code_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/presentation/bloc/professional_bloc.dart';

import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/professional_manually/professional_manually_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/date_plans/date_plan_wallet.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/top_bottom_nav_editscreen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/help_support/all_screen_help/call_back.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/help_support/all_screen_help/live_chat.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/help_support/help_support_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/legal_policy_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/18+_age_policy.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/child_safety.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/content_moderation_law.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/delete_your_account.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/community_guidelines.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/cookie_policy.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/data_rights.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/forever_love.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/grievance_officer.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/licenses.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/verification.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/privacy_policy.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/refund_cancelation.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/safety_dating_tips.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/wallet_coin_terms.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/legal_policies/all_page_legal/terms_service.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/logout/logout_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/logout/splash_logout.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/model/membership_plan_model.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/choose_plan_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/membership_plan/presentation/checkout_screen.dart';
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
import 'package:velvors/welvors_home_screen/ui/event/all_screen/cancel/cancel_confirm.dart';
import 'package:velvors/welvors_home_screen/ui/event/filter_events.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/my_ticket.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/ticket_screen.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/booking_confirm.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/check_out.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/event_details.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/Invite_screen.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/splash_screen_book.dart';
import 'package:velvors/welvors_home_screen/ui/home/filter/filter_bloc/filter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/home/filter/filter_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/match/match_analysis_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/send_compliment/gift_selection_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/send_compliment/try_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/notification/notification_screen.dart';
import 'package:velvors/welvors_home_screen/ui/home/trust_score/trust_screen.dart';
import 'package:velvors/welvors_home_screen/ui/network/no_internet_screen.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';

import '../../welvors_home_screen/ui/admirers/all_pages_admirers/profile_view/profile_view.dart';
import '../../welvors_home_screen/ui/chat/chat_image_pdf_viewer_screen.dart' hide ChatPdfViewerScreen;
import '../../welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/presentation/professional_verification/domain/repositories/professional_repository_impl.dart';
import '../../welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/about_you.dart';

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
        path: AppRoutes.onboardingCompletion,
        name: 'onboardingCompletion',
        pageBuilder: (context, state) => customTransitionPage(
          key: state.pageKey,
          child: const CompletionScreen(),
        ),
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
          String userId = '';
          String name = 'User';
          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            userId = map['userId']?.toString() ?? '';
            name = map['matchName']?.toString() ?? map['name']?.toString() ?? 'User';
          } else {
            userId = state.uri.queryParameters['userId'] ?? '';
            name = state.uri.queryParameters['name'] ?? 'User';
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: MatchAnalysisScreen(userId: userId, matchName: name),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.trustScreen,
        name: 'trustScreen',
        pageBuilder: (context, state) {
          final userId = state.extra is String
              ? state.extra as String
              : (state.extra is Map<String, dynamic>)
                  ? (state.extra as Map<String, dynamic>)['userId']?.toString() ?? ''
                  : state.uri.queryParameters['userId'] ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: TrustScreen(userId: userId),
          );
        },
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
        path: AppRoutes.allNewMatches,
        name: 'allNewMatches',
        pageBuilder: (context, state) {
          final bloc = state.extra is ChatBloc ? state.extra as ChatBloc : null;
          Widget child = const AllNewMatchesScreen();
          if (bloc != null) {
            child = BlocProvider.value(
              value: bloc,
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
        path: AppRoutes.chatImageViewer,
        name: 'chatImageViewer',
        pageBuilder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;
          final imageUrl = extra['imageUrl']?.toString() ?? (state.extra is String ? state.extra as String : '');
          final heroTag = extra['heroTag']?.toString();
          return customTransitionPage(
            key: state.pageKey,
            child: ChatImageViewerScreen(imageUrl: imageUrl, heroTag: heroTag),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.chatPdfViewer,
        name: 'chatPdfViewer',
        pageBuilder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;
          final pdfUrl = extra['pdfUrl']?.toString() ?? '';
          final title = extra['title']?.toString() ?? 'PDF';
          return slideTransitionPage(
            key: state.pageKey,
            child: ChatPdfViewerScreen(pdfUrl: pdfUrl, title: title),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.locationMap,
        name: 'locationMap',
        pageBuilder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;
          final latitude = (extra['latitude'] as num?)?.toDouble() ??
              double.tryParse(extra['latitude']?.toString() ?? '0') ??
              0.0;
          final longitude = (extra['longitude'] as num?)?.toDouble() ??
              double.tryParse(extra['longitude']?.toString() ?? '0') ??
              0.0;
          final label = extra['label']?.toString() ?? 'Location';
          final pickMode = extra['pickMode'] == true || extra['pickMode'] == 'true';
          return slideTransitionPage(
            key: state.pageKey,
            child: LocationMapScreen(
              latitude: latitude,
              longitude: longitude,
              label: label,
              pickMode: pickMode,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.customCamera,
        name: 'customCamera',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const CustomCameraScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.yourJourney,
        name: 'yourJourney',
        pageBuilder: (context, state) {
          final function = state.extra is VoidCallback ? state.extra as VoidCallback : null;
          return slideTransitionPage(
            key: state.pageKey,
            child: YourJourneyScreen(function: function),
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

      GoRoute(
        path: AppRoutes.filterDetail,
        name: 'filterDetail',
        pageBuilder: (context, state) {
          Widget childWidget = const SizedBox.shrink();
          if (state.extra is Widget) {
            childWidget = state.extra as Widget;
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: childWidget,
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

      GoRoute(
        path: AppRoutes.inviteMatch,
        name: 'inviteMatch',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final eventId = extra['eventId']?.toString() ??
              state.uri.queryParameters['eventId'];
          final datePlanId = extra['datePlanId']?.toString() ??
              state.uri.queryParameters['datePlanId'];
          final isDatePlan = extra['isDatePlan'] as bool? ??
              (state.uri.queryParameters['isDatePlan'] == 'true');
          return slideTransitionPage(
            key: state.pageKey,
            child: InviteMatchScreen(
              eventId: eventId,
              datePlanId: datePlanId,
              isDatePlan: isDatePlan,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.filterEvents,
        name: 'filterEvents',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final category = extra['category'] as Map<String, String>? ?? {};
          final cityName = extra['cityName']?.toString() ??
              state.uri.queryParameters['cityName'] ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: FilterEventsScreen(
              category: category,
              cityName: cityName,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.cancelConfirm,
        name: 'cancelConfirm',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final isEligible = extra['isEligibleForRefund'] as bool? ??
              (state.uri.queryParameters['isEligibleForRefund'] == 'true');
          return slideTransitionPage(
            key: state.pageKey,
            child: CancelConfirmScreen(
              isEligibleForRefund: isEligible,
            ),
          );
        },
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
        path: AppRoutes.governmentVerification,
        name: 'governmentVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => GovernmentVerificationBloc(
              repository: GovernmentVerificationRepository(),
            )..add(LoadGovernmentVerificationEvent()),
            child: const GovernmentVerificationScreen(),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.governmentInstant,
        name: 'governmentInstant',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const InstantVerificationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.governmentUploadId,
        name: 'governmentUploadId',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const UploadIdScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.faceVerification,
        name: 'faceVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: FaceVerificationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.faceVerified,
        name: 'faceVerified',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const FaceVerifiedScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.videoVerification,
        name: 'videoVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: VideoVerificationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.educationVerification,
        name: 'educationVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => EducationBloc(
              repository: EducationRepository(),
            )..add(LoadEducationEvent()),
            child: const EducationScreen(),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.educationInstant,
        name: 'educationInstant',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const InstantEducationScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.educationManually,
        name: 'educationManually',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const EducationManuallyScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.professionalVerification,
        name: 'professionalVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => professional_verfication_bloc(
              repository: ProfessionalverificationRepository(),
            )..add(Loadprofessional_verficationEvent()),
            child: const ProfessionalVerficationScreen(),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.professionalEmail,
        name: 'professionalEmail',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => ProfessionalBloc(
              repository: ProfessionalRepositoryImpl(),
            ),
            child: const ProfessionalEmailScreen(),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.professionalCode,
        name: 'professionalCode',
        pageBuilder: (context, state) {
          final bloc = state.extra is ProfessionalBloc ? (state.extra as ProfessionalBloc) : null;
          return slideTransitionPage(
            key: state.pageKey,
            child: bloc != null
                ? BlocProvider.value(
                    value: bloc,
                    child: const ProfessionalCodeScreen(),
                  )
                : BlocProvider(
                    create: (_) => ProfessionalBloc(
                      repository: ProfessionalRepositoryImpl(),
                    ),
                    child: const ProfessionalCodeScreen(),
                  ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.professionalManually,
        name: 'professionalManually',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const ProfessionalManuallyScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.aadhaarVerified,
        name: 'aadhaarVerified',
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return slideTransitionPage(
              key: state.pageKey,
              child: AadhaarVerifiedScreen(
                icon: extra['icon'] as Icon?,
                iconcolor: extra['iconcolor'] as Color?,
                title: extra['title'] as String?,
                subtitle: extra['subtitle'] as String?,
                score: extra['score'] as int?,
                cardbottomtext: extra['cardbottomtext'] as String?,
              ),
            );
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: const AadhaarVerifiedScreen(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.incomeVerification,
        name: 'incomeVerification',
        pageBuilder: (context, state) {
          final screencall = state.uri.queryParameters['screencall'] == 'true';
          return slideTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => PlatinumVerificationBloc(
                repository: PlatinumVerificationRepository(),
              ),
              child: PlatinumContactScreen(screencall: screencall),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.platinumVerification,
        name: 'platinumVerification',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => PlatinumVerificationBloc(
              repository: PlatinumVerificationRepository(),
            )..add(LoadPlatinumVerification()),
            child: const PlatinumVerificationFlowScreen(),
          ),
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
        path: AppRoutes.giftSelection,
        name: 'giftSelection',
        pageBuilder: (context, state) {
          final extra = state.extra;
          String? recipientName;
          if (extra is String) {
            recipientName = extra;
          } else if (extra is Map<String, dynamic>) {
            recipientName = extra['recipientName'] as String?;
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: GiftSelectionScreen(recipientName: recipientName),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.complimentIdeas,
        name: 'complimentIdeas',
        pageBuilder: (context, state) {
          final initialText = state.extra is String ? state.extra as String : null;
          return slideTransitionPage(
            key: state.pageKey,
            child: ComplimentIdeasScreen(initialText: initialText),
          );
        },
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
        pageBuilder: (context, state) {
          PostPlanState? initialState;
          int initialStep = 1;
          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            initialState = extra['initialState'] as PostPlanState?;
            initialStep = extra['initialStep'] as int? ?? 1;
          } else if (state.extra is PostPlanState) {
            initialState = state.extra as PostPlanState;
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: Activity1Screen(
              initialState: initialState,
              initialStep: initialStep,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.requesterProfile,
        name: 'requesterProfile',
        pageBuilder: (context, state) {
          final request = state.extra as Map<String, dynamic>? ?? {};
          return slideTransitionPage(
            key: state.pageKey,
            child: MyPlanRequesterProfileScreen(request: request),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.requestsSent,
        name: 'requestsSent',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const RequestsSentScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.datePlanProfileDetail,
        name: 'datePlanProfileDetail',
        pageBuilder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : state.uri.queryParameters;
          return slideTransitionPage(
            key: state.pageKey,
            child: ProfileDetailScreen(
              userId: extra['userId']?.toString() ?? '',
              profileImageUrl: extra['profileImageUrl']?.toString() ?? extra['avatarUrl']?.toString(),
              profileName: extra['profileName']?.toString() ?? extra['name']?.toString(),
              plan: extra['plan'] as Map<String, dynamic>?,
              onPlanAction: extra['onPlanAction'] as VoidCallback?,
              customBottomWidget: extra['customBottomWidget'] as Widget?,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.admirerProfile,
        name: 'admirerProfile',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final userCard = extra['userCard'] as Map<String, dynamic>? ?? extra;
          final onAction = extra['onAction'] as Function(dynamic, String)? ?? (id, action) {};
          return slideTransitionPage(
            key: state.pageKey,
            child: AdmirerProfileView(
              userCard: userCard,
              onAction: onAction,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.choosePrompt,
        name: 'choosePrompt',
        pageBuilder: (context, state) {
          final extra = state.extra;
          List<String> addedPromptIds = [];
          if (extra is List<String>) {
            addedPromptIds = extra;
          } else if (extra is List) {
            addedPromptIds = extra.map((e) => e.toString()).toList();
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: ChoosePromptScreen(addedPromptIds: addedPromptIds),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.mapSelection,
        name: 'mapSelection',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const MapSelectionDialog(),
        ),
      ),

      GoRoute(
        path: AppRoutes.genericPicker,
        name: 'genericPicker',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return slideTransitionPage(
            key: state.pageKey,
            child: GenericListPickerScreen(
              title: extra['title'] as String? ?? 'Select',
              headerText: extra['headerText'] as String? ?? '',
              subHeaderText: extra['subHeaderText'] as String? ?? '',
              currentValue: extra['currentValue'] as String? ?? '',
              options: (extra['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
              optionSubtitles: extra['optionSubtitles'] as Map<String, String>?,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editBio,
        name: 'editBio',
        pageBuilder: (context, state) {
          final initialBio = state.extra is String ? state.extra as String : '';
          return slideTransitionPage(
            key: state.pageKey,
            child: EditBioScreen(initialBio: initialBio),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editTextInput,
        name: 'editTextInput',
        pageBuilder: (context, state) {
          if (state.extra is EditTextInputScreen) {
            return slideTransitionPage(
              key: state.pageKey,
              child: state.extra as EditTextInputScreen,
            );
          }
          final extra = state.extra as Map<String, dynamic>;
          return slideTransitionPage(
            key: state.pageKey,
            child: EditTextInputScreen(
              title: extra['title'] as String? ?? '',
              label: extra['label'] as String? ?? '',
              headerText: extra['headerText'] as String? ?? '',
              subHeaderText: extra['subHeaderText'] as String? ?? '',
              currentValue: extra['currentValue'] as String? ?? '',
              keyboardType: extra['keyboardType'] as TextInputType? ?? TextInputType.text,
              maxLines: extra['maxLines'] as int? ?? 1,
              maxLength: extra['maxLength'] as int?,
              validator: extra['validator'] as String? Function(String)?,
              inputFormatters: extra['inputFormatters'] as List<TextInputFormatter>?,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editDob,
        name: 'editDob',
        pageBuilder: (context, state) {
          final currentValue = state.extra is String
              ? state.extra as String
              : (state.extra as Map<String, dynamic>?)?['currentValue'] as String? ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: EditDobScreen(currentValue: currentValue),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editHeight,
        name: 'editHeight',
        pageBuilder: (context, state) {
          final currentValue = state.extra is String
              ? state.extra as String
              : (state.extra as Map<String, dynamic>?)?['currentValue'] as String? ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: EditHeightScreen(currentValue: currentValue),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editReligionCaste,
        name: 'editReligionCaste',
        pageBuilder: (context, state) {
          final currentValue = state.extra is String
              ? state.extra as String
              : (state.extra as Map<String, dynamic>?)?['currentValue'] as String? ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: EditReligionCasteScreen(currentValue: currentValue),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editLanguage,
        name: 'editLanguage',
        pageBuilder: (context, state) {
          final initialLanguageIds = state.extra is List<int>
              ? state.extra as List<int>
              : (state.extra as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? <int>[];
          return slideTransitionPage(
            key: state.pageKey,
            child: EditLanguageScreen(initialLanguageIds: initialLanguageIds),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editGraduationYear,
        name: 'editGraduationYear',
        pageBuilder: (context, state) {
          final currentValue = state.extra is String
              ? state.extra as String
              : (state.extra as Map<String, dynamic>?)?['currentValue'] as String? ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: EditGraduationYearScreen(currentValue: currentValue),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editIntentions,
        name: 'editIntentions',
        pageBuilder: (context, state) {
          final currentIntention = state.extra is String
              ? state.extra as String
              : (state.extra as Map<String, dynamic>?)?['currentIntention'] as String? ?? '';
          return slideTransitionPage(
            key: state.pageKey,
            child: EditIntentionsScreen(currentIntention: currentIntention),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editInterests,
        name: 'editInterests',
        pageBuilder: (context, state) {
          final initialSelected = state.extra is List<String>
              ? state.extra as List<String>
              : (state.extra as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
          return slideTransitionPage(
            key: state.pageKey,
            child: EditInterestsPickerScreen(initialSelected: initialSelected),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.editChoosePrompt,
        name: 'editChoosePrompt',
        pageBuilder: (context, state) {
          final alreadyAdded = state.extra is List<String>
              ? state.extra as List<String>
              : (state.extra as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
          return slideTransitionPage(
            key: state.pageKey,
            child: EditChoosePromptScreen(alreadyAddedQuestions: alreadyAdded),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.videoRecorder,
        name: 'videoRecorder',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const VideoRecorderScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.subScreen,
        name: 'subScreen',
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: state.extra as Widget,
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
        path: AppRoutes.membershipCheckout,
        name: 'membershipCheckout',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final plan = extra['plan'] as MembershipPlanModel;
          final duration = extra['duration'] as PlanDuration;
          return slideTransitionPage(
            key: state.pageKey,
            child: MembershipCheckoutScreen(plan: plan, duration: duration),
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
        path: AppRoutes.legalPolicyDetail,
        name: 'legalPolicyDetail',
        pageBuilder: (context, state) {
          Widget childWidget = const TermsServiceScreen();
          if (state.extra is Widget) {
            childWidget = state.extra as Widget;
          } else {
            final type = state.uri.queryParameters['type']?.toLowerCase() ?? '';
            switch (type) {
              case 'privacy':
                childWidget = const PrivacyPolicyScreen();
                break;
              case 'community':
                childWidget = const CommunityGuidelinesScreen();
                break;
              case 'safety':
                childWidget = const SafetyDatingTipsScreen();
                break;
              case 'child':
                childWidget = const ChildSafetyScreen();
                break;
              case 'moderation':
                childWidget = const ContentModerationScreen();
                break;
              case 'verification':
                childWidget = const VerificationPolicyScreen();
                break;
              case 'refund':
                childWidget = const RefundCancellationScreen();
                break;
              case 'wallet':
                childWidget = const WalletCoinTermsScreen();
                break;
              case '18plus':
                childWidget = const AgePolicyScreen();
                break;
              case 'forever':
                childWidget = const ForeverLoveScreen();
                break;
              case 'data':
                childWidget = const DataRightsScreen();
                break;
              case 'cookie':
                childWidget = const CookiePolicyScreen();
                break;
              case 'licenses':
                childWidget = const LicensesScreen();
                break;
              case 'delete':
                childWidget = const DeleteYourAccountScreen();
                break;
              case 'grievance':
                childWidget = const GrievanceOfficerScreen();
                break;
              default:
                childWidget = const TermsServiceScreen();
            }
          }
          return slideTransitionPage(
            key: state.pageKey,
            child: childWidget,
          );
        },
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
