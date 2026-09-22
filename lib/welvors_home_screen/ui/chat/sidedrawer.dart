import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// YOUR PROJECT IMPORTS
// ============================================================

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_state.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_media_links_docs_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';

import 'package:velvors/config/env_config.dart';

import '../../services/logger_service.dart';
// ============================================================
// SIDEDRAWER
// ============================================================

class Sidedrawer {
  Sidedrawer({
    required this.context,
    required this.liveImage,
    required this.liveName,
    required this.liveAge,
    required this.isUserOnline,
    required this.bannerIndex,
    required this.messageKey,
    required this.isBlocked,
    required this.userName,
    required this.conversationId,
    required this.avatar,
    required this.giftUnlockProgress,
    required this.relationshipProgress,
    required this.openRelationshipTagSheet,
    required this.confirmClearChat,
    required this.confirmDeleteConversation,
    required this.showReportUserSheet,
    required this.showBlockUserSheet,
    required this.openUnmatchSheet,
  });

  // ============================================================
  // CONTEXT
  // ============================================================

  final BuildContext context;

  // ============================================================
  // PROFILE DATA
  // ============================================================

  final String liveImage;
  final String liveName;
  final int liveAge;
  final bool isUserOnline;
  final int bannerIndex;
  final String messageKey;
  final bool isBlocked;
  final String userName;
  final String conversationId;

  // ============================================================
  // CALLBACKS FROM CHAT SCREEN
  // ============================================================

  final Widget Function(String image, double size, String name, String age)
  avatar;

  final Widget Function() giftUnlockProgress;

  final Widget Function() relationshipProgress;

  final VoidCallback openRelationshipTagSheet;

  final VoidCallback confirmClearChat;

  final VoidCallback confirmDeleteConversation;

  final VoidCallback showReportUserSheet;

  final VoidCallback showBlockUserSheet;

  final VoidCallback openUnmatchSheet;

  // ============================================================
  // OPEN PROFILE SHEET
  // ============================================================

  Future<void> openProfileSheet() async {
    // ============================================================
    // IMPORTANT:
    // BANNER STATE MUST BE OUTSIDE StatefulBuilder
    // Otherwise every setModalState() will reset the index.
    // ============================================================

    int currentBannerIndex = bannerIndex;

    // ============================================================
    // TIMER MUST ALSO BE OUTSIDE StatefulBuilder
    // ============================================================

    Timer? bannerTimer;

    // ============================================================
    // FLAG TO PREVENT MULTIPLE TIMERS
    // ============================================================

    bool bannerTimerStarted = false;

    // ============================================================
    // START AUTO BANNER
    // ============================================================

    void startBannerTimer(
      BuildContext sheetContext,
      StateSetter setModalState,
    ) {
      // Already started
      if (bannerTimerStarted) {
        return;
      }

      bannerTimerStarted = true;

      AppLogger.d(
        'SideDrawer',
        'Banner timer started - initial index: $currentBannerIndex',
      );

      bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        // ========================================================
        // SHEET CLOSED
        // ========================================================

        if (!sheetContext.mounted) {
          AppLogger.d('SideDrawer', 'Banner timer cancelled - sheet closed');

          timer.cancel();
          bannerTimer = null;
          bannerTimerStarted = false;

          return;
        }

        // ========================================================
        // CHANGE BANNER INDEX
        // ========================================================

        setModalState(() {
          currentBannerIndex = currentBannerIndex == 0 ? 1 : 0;
        });

        AppLogger.d('SideDrawer', 'Auto banner changed: $currentBannerIndex');
      });
    }

    // ============================================================
    // SHOW PROFILE SHEET
    // ============================================================

    final String? action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,

      // Let the sheet naturally fill the safe area without forced screen height constraints.

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (sheetContext) {
        // ========================================================
        // MUTE NOTIFICATION STATE
        // ========================================================

        bool muteEnabled = true;

        bool muteLoading = true;

        bool muteUpdating = false;

        // ========================================================
        // GET MUTE STATUS
        // ========================================================

        Future<void> loadMuteNotificationStatus(
          StateSetter setModalState,
        ) async {
          try {
            final prefs = await SharedPreferences.getInstance();

            final token = prefs.getString('auth_token');

            AppLogger.d(
              'SideDrawer',
              'Mute notification get, token exists: ${token != null && token.isNotEmpty}',
            );

            if (token == null || token.isEmpty) {
              if (sheetContext.mounted) {
                setModalState(() {
                  muteLoading = false;
                });
              }

              return;
            }

            final response = await http.get(
              Uri.parse('${EnvConfig.apiBaseUrl}/user/notification/mute'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            AppLogger.apiResponse(
              'SideDrawer',
              statusCode: response.statusCode,
              body: response.body,
            );

            if (response.statusCode >= 200 && response.statusCode < 300) {
              final Map<String, dynamic> responseData = jsonDecode(
                response.body,
              );

              final dynamic data = responseData['data'];

              bool enabled = true;

              if (data is Map<String, dynamic>) {
                final dynamic apiValue = data['isEnabled'];

                if (apiValue is bool) {
                  enabled = apiValue;
                }
              }

              if (sheetContext.mounted) {
                setModalState(() {
                  muteEnabled = enabled;
                  muteLoading = false;
                });
              }
            } else {
              if (sheetContext.mounted) {
                setModalState(() {
                  muteLoading = false;
                });
              }
            }
          } catch (e, stackTrace) {
            AppLogger.e(
              'SideDrawer',
              'Mute get error',
              error: e,
              stackTrace: stackTrace,
            );

            if (sheetContext.mounted) {
              setModalState(() {
                muteLoading = false;
              });
            }
          }
        }

        // ========================================================
        // PATCH MUTE STATUS
        // ========================================================

        Future<bool> updateMuteNotificationStatus(bool newValue) async {
          try {
            final prefs = await SharedPreferences.getInstance();

            final token = prefs.getString('auth_token');

            AppLogger.d(
              'SideDrawer',
              'Mute notification patch: newValue=$newValue',
            );

            if (token == null || token.isEmpty) {
              AppLogger.w('SideDrawer', 'Mute patch: auth token not found');

              return false;
            }

            final response = await http.patch(
              Uri.parse('${EnvConfig.apiBaseUrl}/user/notification/mute'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'isEnabled': newValue}),
            );

            AppLogger.apiResponse(
              'SideDrawer',
              statusCode: response.statusCode,
              body: response.body,
            );

            if (response.statusCode >= 200 && response.statusCode < 300) {
              return true;
            }

            return false;
          } catch (e, stackTrace) {
            AppLogger.e(
              'SideDrawer',
              'Mute patch error',
              error: e,
              stackTrace: stackTrace,
            );

            return false;
          }
        }

        // ========================================================
        // SHEET TILE
        // ========================================================

        Widget sheetTile(
          IconData icon,
          String title,
          String? subtitle, {
          Widget? trailing,
          Color? color,
          Color? iconcolor,
          Color? titleColor,
          Color? textColor,
          required VoidCallback onTap,
        }) {
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: color ?? Mycolor.pinkffeef2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: 35,
                    height: 35,
                    child: Icon(
                      icon,
                      color: iconcolor ?? Colors.black,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.body.copyWith(
                            color: textColor ?? Colors.black,
                            fontSize: 15,
                          ),
                        ),

                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: AppText.sub.copyWith(
                              color: const Color(0xffb0aea9),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (trailing != null) trailing,
                ],
              ),
            ),
          );
        }

        // ========================================================
        // MUTE TOGGLE TILE
        // ========================================================

        Widget muteToggleTile(StateSetter setModalState) {
          return Container(
            margin: const EdgeInsets.only(bottom: 0),
            decoration: BoxDecoration(
              color: Mycolor.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Mycolor.colorf5f2ec,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  width: 35,
                  height: 35,
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    size: 20,
                    color: AppColors.ink,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Mute Notifications',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),

                if (muteLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: muteEnabled,

                    activeThumbColor: Mycolor.pink3,

                    inactiveThumbColor: Mycolor.lightGreyText1,

                    inactiveTrackColor: Mycolor.white,

                    onChanged: muteUpdating
                        ? null
                        : (bool newValue) async {
                            if (muteUpdating) {
                              return;
                            }

                            final bool oldValue = muteEnabled;

                            setModalState(() {
                              muteUpdating = true;
                            });

                            final bool success =
                                await updateMuteNotificationStatus(newValue);

                            if (!sheetContext.mounted) {
                              return;
                            }

                            if (success) {
                              setModalState(() {
                                muteEnabled = newValue;
                                muteUpdating = false;
                              });

                              AppLogger.i(
                                'SideDrawer',
                                'Mute status updated: $newValue',
                              );
                            } else {
                              setModalState(() {
                                muteEnabled = oldValue;
                                muteUpdating = false;
                              });

                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Unable to update notification setting',
                                  ),
                                ),
                              );
                            }
                          },

                    activeColor: AppColors.green,
                  ),
              ],
            ),
          );
        }

        // ========================================================
        // STATEFUL BUILDER
        // ========================================================

        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            // ====================================================
            // LOAD MUTE GET API ONLY ON FIRST BUILD
            // ====================================================

            if (muteLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (sheetContext.mounted && muteLoading) {
                  loadMuteNotificationStatus(setModalState);
                }
              });
            }

            // ====================================================
            // START BANNER TIMER ONLY ONCE
            // ====================================================

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (sheetContext.mounted) {
                startBannerTimer(sheetContext, setModalState);
              }
            });

            // ====================================================
            // FULL SCREEN UI
            // ====================================================

            return FractionallySizedBox(
              heightFactor: 0.96,
              widthFactor: 1.0,
              child: Column(
                  mainAxisSize: MainAxisSize.max,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    hSized30,

                    // ==================================================
                    // TOP APP BAR / PROFILE HEADER
                    // ==================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),

                      child: SizedBox(
                        height: 95,

                        child: Row(
                          children: [
                            // BACK BUTTON
                            // IconButton(
                            //   onPressed: () {
                            //     Navigator.pop(sheetContext);
                            //   },

                            //   icon: const Icon(
                            //     Icons.arrow_back_ios_new_rounded,
                            //     size: 21,
                            //     color: Colors.black,
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 8,
                                bottom: 8,
                              ),
                              child: InkWell(
                                onTap: () => Navigator.pop(sheetContext),
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black87,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),

                            // CENTER PROFILE IMAGE
                            Expanded(
                              child: Column(
                                children: [
                                  hSized20,

                                  Center(
                                    child: avatar(
                                      liveImage,
                                      72,
                                      liveName,
                                      liveAge.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // KEEP AVATAR CENTERED
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // PROFILE NAME
                    // ==================================================
                    Center(
                      child: Text(
                        liveAge > 0 ? '$liveName, $liveAge' : liveName,

                        style: AppText.h1.copyWith(fontSize: 20),
                      ),
                    ),

                    // ==================================================
                    // ONLINE / OFFLINE
                    // ==================================================
                    const SizedBox(height: 4),

                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Container(
                            width: 7,
                            height: 7,

                            decoration: BoxDecoration(
                              color: isUserOnline
                                  ? AppColors.green
                                  : AppColors.muted,

                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            isUserOnline ? 'Online' : 'Offline',

                            style: AppText.body.copyWith(
                              color: isUserOnline
                                  ? AppColors.green
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // LOCATION
                    // ==================================================
                    const SizedBox(height: 4),

                    Center(
                      child: Wrap(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.muted,
                          ),

                          Text(
                            'Mumbai, India',

                            style: AppText.sub.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),

                    hSized10,

                    // ==================================================
                    // BANNER.     futue this code need so do not remove
                    // ==================================================
                    // AnimatedSwitcher(
                    //   duration: const Duration(milliseconds: 220),

                    //   // reverseDuration: const Duration(milliseconds: 500),
                    //   switchInCurve: Curves.easeInOutSine,
                    //   switchOutCurve: Curves.easeInOutSine,

                    //   transitionBuilder:
                    //       (Widget child, Animation<double> animation) {
                    //         return FadeTransition(
                    //           opacity: animation,
                    //           child: child,
                    //         );
                    //       },

                    //   child: KeyedSubtree(
                    //     key: ValueKey<int>(currentBannerIndex),

                    //     child: currentBannerIndex == 0
                    //         ? giftUnlockProgress()
                    //         : relationshipProgress(),
                    //   ),
                    // ),

                    // hSized20,
                    Divider(color: Mycolor.grey1, height: 1),

                    hSized10,

                    // ==================================================
                    // SCROLLABLE CONTENT
                    // ==================================================
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // ==========================================
                            // PREFERENCES
                            // ==========================================
                            Text('PREFERENCES', style: AppText.eyebrow),

                            const SizedBox(height: 6),

                            // ==========================================
                            // RELATIONSHIP TAGS
                            // ==========================================
                            sheetTile(
                              Icons.favorite,

                              'Relationship Tags',

                              'Define how you connect',

                              color: Mycolor.pinkffeef2,

                              titleColor: const Color(0xffe15555),

                              textColor: Colors.black,

                              iconcolor: const Color(0xffe15555),

                              trailing: const Icon(
                                Icons.chevron_right,
                                color: AppColors.muted,
                              ),

                              onTap: () {
                                if (!isBlocked) {
                                  openRelationshipTagSheet();
                                } else {
                                  final overlay = Overlay.of(context);

                                  late OverlayEntry entry;

                                  entry = OverlayEntry(
                                    builder: (context) {
                                      return Positioned(
                                        top:
                                            MediaQuery.of(context).padding.top +
                                            10,

                                        left: 16,

                                        right: 16,

                                        child: Material(
                                          color: Colors.transparent,

                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),

                                            decoration: BoxDecoration(
                                              color: Mycolor.colore11d74,

                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),

                                            child: const Text(
                                              'User blocked',

                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  overlay.insert(entry);

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (entry.mounted) {
                                        entry.remove();
                                      }
                                    },
                                  );
                                }
                              },
                            ),

                            // ==========================================
                            // MUTE NOTIFICATIONS
                            // ==========================================
                            muteToggleTile(setModalState),

                            // ==========================================
                            // MEDIA LINKS DOCS
                            // ==========================================
                            sheetTile(
                              Icons.perm_media_outlined,

                              'Media, Links & Docs',

                              '${(() {
                                final sharedMessages = context.read<ChatBloc>().state.messages[messageKey] ?? const <ChatMessage>[];

                                return sharedMessages.where((m) => m.type == ChatMessageType.image || m.type == ChatMessageType.video || m.type == ChatMessageType.audio || m.type == ChatMessageType.document || m.text.contains('http://') || m.text.contains('https://')).length;
                              })()} shared items',

                              color: Mycolor.colorf5f2ec,

                              titleColor: Colors.black,

                              trailing: const Icon(
                                Icons.chevron_right,
                                color: AppColors.muted,
                              ),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatMediaLinksDocsScreen(
                                      userName: liveName,
                                      conversationId: conversationId,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 18),

                            // ==========================================
                            // PRIVACY & SAFETY
                            // ==========================================
                            Text('PRIVACY & SAFETY', style: AppText.eyebrow),

                            const SizedBox(height: 6),

                            // ==========================================
                            // REPORT USER
                            // ==========================================
                            sheetTile(
                              Icons.flag_outlined,

                              'Report User',

                              null,

                              color: Mycolor.pinkffeef2,

                              titleColor: const Color(0xffe15555),

                              iconcolor: const Color(0xffe15555),

                              textColor: const Color(0xffe15555),

                              onTap: () {
                                Navigator.pop(sheetContext, 'report');
                              },
                            ),

                            // ==========================================
                            // BLOCK USER
                            // ==========================================
                            if (!isBlocked)
                              sheetTile(
                                Icons.block,

                                'Block $userName',

                                null,

                                color: Mycolor.pinkffeef2,

                                titleColor: const Color(0xffe15555),

                                iconcolor: const Color(0xffe15555),

                                textColor: const Color(0xffe15555),

                                onTap: () {
                                  Navigator.pop(sheetContext, 'block');
                                },
                              ),

                            // ==========================================
                            // UNMATCH
                            // ==========================================
                            if (!isBlocked)
                              sheetTile(
                                Icons.heart_broken,

                                'Unmatch',

                                'Removes the match and this chat',

                                color: Mycolor.pinkffeef2,

                                titleColor: const Color(0xffe15555),

                                iconcolor: const Color(0xffe15555),

                                textColor: const Color(0xffe15555),

                                onTap: () {
                                  Navigator.pop(sheetContext, 'unmatch');
                                },
                              ),

                            const SizedBox(height: 6),

                            // ==========================================
                            // CLEAR CHAT
                            // ==========================================
                            sheetTile(
                              Icons.cleaning_services_outlined,

                              'Clear Chat',

                              'Remove all messages from this chat',

                              color: Mycolor.pinkffeef2,

                              titleColor: const Color(0xffe15555),

                              iconcolor: const Color(0xffe15555),

                              textColor: const Color(0xffe15555),

                              onTap: () {
                                Navigator.pop(sheetContext);

                                Future.delayed(
                                  const Duration(milliseconds: 200),
                                  () {
                                    confirmClearChat();
                                  },
                                );
                              },
                            ),

                            // ==========================================
                            // DELETE CONVERSATION
                            // ==========================================
                            sheetTile(
                              Icons.delete_outline_rounded,

                              'Delete Conversation',

                              'Remove this conversation from your chat list',

                              color: Mycolor.pinkffeef2,

                              titleColor: const Color(0xffe15555),

                              iconcolor: const Color(0xffe15555),

                              textColor: const Color(0xffe15555),

                              onTap: () {
                                Navigator.pop(sheetContext);

                                Future.delayed(
                                  const Duration(milliseconds: 200),
                                  () {
                                    confirmDeleteConversation();
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            );
          },
        );
      },
    );
    // ============================================================
    // VERY IMPORTANT:
    // CANCEL TIMER WHEN MODAL SHEET IS CLOSED
    // ============================================================

    if (bannerTimer != null) {
      AppLogger.d(
        'SideDrawer',
        'Banner timer cancelled - profile sheet closed',
      );

      bannerTimer!.cancel();
      bannerTimer = null;
    }

    bannerTimerStarted = false;

    // ============================================================
    // HANDLE SHEET ACTION
    // ============================================================

    if (action == 'report') {
      showReportUserSheet();
    } else if (action == 'block') {
      showBlockUserSheet();
    } else if (action == 'unmatch') {
      openUnmatchSheet();
    }
  }
}
