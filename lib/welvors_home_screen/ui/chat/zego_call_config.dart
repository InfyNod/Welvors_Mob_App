// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// import 'chat_bloc/chat_state.dart';

// /// Real ZEGOCLOUD calling integration.
// ///
// /// IMPORTANT:
// /// - Use the SAME AppID/AppSign for both devices.
// /// - For production, prefer server-issued tokens instead of shipping AppSign.
// /// - Run with:
// ///   flutter run --dart-define=ZEGO_APP_ID=123456789 \
// ///     --dart-define=ZEGO_APP_SIGN=your_app_sign
// class ZegoCallConfig {
//   static const int appID = int.fromEnvironment(
//     'ZEGO_APP_ID',
//     defaultValue: 0,
//   );

//   static const String appSign = String.fromEnvironment(
//     'ZEGO_APP_SIGN',
//     defaultValue: '',
//   );

//   static bool get configured => appID > 0 && appSign.isNotEmpty;

//   static String safeUserId(String value) {
//     final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
//     return cleaned.isEmpty ? 'user' : cleaned;
//   }
// }

// class ZegoCallService {
//   static final ZegoUIKitPrebuiltCallInvitationService _service =
//       ZegoUIKitPrebuiltCallInvitationService();

//   static bool _initialized = false;

//   /// Use this exact key in MaterialApp.navigatorKey.
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();

//   static Future<bool> init({
//     required String userId,
//     required String userName,
//   }) async {
//     if (!ZegoCallConfig.configured) {
//       debugPrint(
//         'ZEGOCLOUD is not configured. Set ZEGO_APP_ID and ZEGO_APP_SIGN.',
//       );
//       return false;
//     }

//     _service.setNavigatorKey(navigatorKey);

//     if (_initialized && _service.isInit) {
//       return true;
//     }

//     await _service.init(
//       appID: ZegoCallConfig.appID,
//       appSign: ZegoCallConfig.appSign,
//       userID: ZegoCallConfig.safeUserId(userId),
//       userName: userName,
//       plugins: [ZegoUIKitSignalingPlugin()],
//     );

//     _initialized = true;
//     return true;
//   }

//   static Future<bool> sendCall({
//     required BuildContext context,
//     required String currentUserId,
//     required String currentUserName,
//     required ChatUser targetUser,
//     required bool isVideoCall,
//   }) async {
//     if (!ZegoCallConfig.configured) {
//       debugPrint(
//         'ZEGOCLOUD is not configured. Set ZEGO_APP_ID and ZEGO_APP_SIGN.',
//       );
//       return false;
//     }

//     _service.setNavigatorKey(navigatorKey);
//     if (!_initialized || !_service.isInit) {
//       await _service.init(
//         appID: ZegoCallConfig.appID,
//         appSign: ZegoCallConfig.appSign,
//         userID: ZegoCallConfig.safeUserId(currentUserId),
//         userName: currentUserName,
//         plugins: [ZegoUIKitSignalingPlugin()],
//       );
//       _initialized = true;
//     }

//     final targetId = ZegoCallConfig.safeUserId(targetUser.id);
//     final callId =
//         'chat_${ZegoCallConfig.safeUserId(currentUserId)}_$targetId_${DateTime.now().millisecondsSinceEpoch}';

//     return _service.send(
//       invitees: [
//         ZegoCallUser(
//           targetId,
//           targetUser.name,
//         ),
//       ],
//       isVideoCall: isVideoCall,
//       callID: callId,
//       notificationTitle: isVideoCall ? 'Incoming video call' : 'Incoming voice call',
//       notificationMessage: '$currentUserName is calling you',
//       timeoutSeconds: 60,
//     );
//   }

//   static Future<void> logout() async {
//     if (_service.isInit) {
//       await _service.uninit();
//     }
//     _initialized = false;
//   }
// }

// class ZegoRealCallPage extends StatelessWidget {
//   final String currentUserId;
//   final String currentUserName;
//   final String callId;
//   final bool isVideoCall;

//   const ZegoRealCallPage({
//     super.key,
//     required this.currentUserId,
//     required this.currentUserName,
//     required this.callId,
//     required this.isVideoCall,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (!ZegoCallConfig.configured) {
//       return const Scaffold(
//         body: Center(
//           child: Text(
//             'ZEGOCLOUD is not configured.\n\n'
//             'Set ZEGO_APP_ID and ZEGO_APP_SIGN.',
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     final config = isVideoCall
//         ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
//         : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

//     return ZegoUIKitPrebuiltCall(
//       appID: ZegoCallConfig.appID,
//       appSign: ZegoCallConfig.appSign,
//       userID: ZegoCallConfig.safeUserId(currentUserId),
//       userName: currentUserName,
//       callID: callId,
//       config: config
//         ..onOnlySelfInRoom = (context) {
//           Navigator.of(context).pop();
//         },
//     );
//   }
// }
