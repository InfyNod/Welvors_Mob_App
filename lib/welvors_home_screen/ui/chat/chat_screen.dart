import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SocketService.dart';

import 'chat_bloc/chat_bloc.dart';
import 'chat_bloc/chat_event.dart';
import 'chat_bloc/chat_state.dart';
import 'chat_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:velvors/utils/navigation/app_routes.dart';
import 'chat_detail_screen.dart';
import 'all_new_matches_screen.dart';
import 'services/new_matches_service.dart';

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class ChatScreen_ extends StatefulWidget {
  /// Fires whenever the chat tab becomes the active tab.
  /// _ChatListView listens to this and refreshes the chat list.
  final ValueNotifier<int>? refreshNotifier;

  const ChatScreen_({super.key, this.refreshNotifier});

  @override
  State<ChatScreen_> createState() => _ChatScreen_State();
}

class _ChatScreen_State extends State<ChatScreen_>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final Future<String> _initFuture = _init();

  Future<String> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedToken = prefs.getString('auth_token')?.trim() ?? '';
    final token = savedToken.toLowerCase().startsWith('bearer ')
        ? savedToken.substring(7).trim()
        : savedToken;

    if (token.isEmpty) {
      AppLogger.e('ChatScreen', '❌ CHAT: no auth_token found - socket not connected');
    }

    // Socket connection is intentionally started by _ChatListView AFTER
    // online/offline listeners are registered. This prevents missing the
    // first user:online event during socket connect.
    return ChatRepository.userIdFromToken(token, fallback: '');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return FutureBuilder<String>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.canvas,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = snapshot.data!;

        return BlocProvider(
          create: (_) {
            return ChatBloc(
              repository: ChatRepository(currentUserId: currentUserId),
              socketService: SocketService(),
            )..add(const LoadChatsEvent());
          },
          child: _ChatListView(
            currentUserId: currentUserId,
            refreshNotifier: widget.refreshNotifier,
          ),
        );
      },
    );
  }
}


// ==========================================================
// NEW MATCH MODEL (ALIASED TO NewMatchItem)
// ==========================================================

typedef _NewMatch = NewMatchItem;

int? _openSwipeIndex;
VoidCallback? _closeOpenSwipe;

void _onSwipeOpened(int index, VoidCallback close) {
  // Agar koi doosri conversation open hai,
  // pehle usko close karo.
  if (_openSwipeIndex != null && _openSwipeIndex != index) {
    _closeOpenSwipe?.call();
  }

  _openSwipeIndex = index;
  _closeOpenSwipe = close;
}

void _onSwipeClosed(int index) {
  if (_openSwipeIndex == index) {
    _openSwipeIndex = null;
    _closeOpenSwipe = null;
  }
}

void _closeSwipe() {
  _closeOpenSwipe?.call();
  _openSwipeIndex = null;
  _closeOpenSwipe = null;
}
// ==========================================================
// SWIPE TO DELETE
// ==========================================================

class _SwipeDeleteChatTile extends StatefulWidget {
  final int index;
  final Widget child;
  final VoidCallback onDelete;

  final void Function(int index, VoidCallback close) onOpen;
  final void Function(int index) onClose;

  const _SwipeDeleteChatTile({
    required this.index,
    required this.child,
    required this.onDelete,
    required this.onOpen,
    required this.onClose,
  });

  @override
  State<_SwipeDeleteChatTile> createState() => _SwipeDeleteChatTileState();
}

class _SwipeDeleteChatTileState extends State<_SwipeDeleteChatTile> {
  double _dragOffset = 0.0;

  // ===========================================================
  // CLOSE THIS TILE
  // ===========================================================

  void _close() {
    if (!mounted) return;

    if (_dragOffset == 0) {
      return;
    }

    setState(() {
      _dragOffset = 0.0;
    });

    widget.onClose(widget.index);
  }

  // ===========================================================
  // OPEN THIS TILE
  // ===========================================================

  void _open(double maxReveal) {
    if (!mounted) return;

    setState(() {
      _dragOffset = maxReveal;
    });

    // Parent ko batao ki ye tile open hai
    widget.onOpen(widget.index, _close);
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 20% ko 50% kar diya
        final double maxReveal = constraints.maxWidth * 0.20;

        final bool showDeleteButton = _dragOffset >= maxReveal;

        return ClipRect(
          child: Stack(
            children: [
              // =================================================
              // DELETE AREA - FIXED RIGHT SIDE
              // =================================================
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: maxReveal,
                child: IgnorePointer(
                  ignoring: !showDeleteButton,

                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),

                    opacity: showDeleteButton ? 1.0 : 0.0,

                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.center,

                      child: Material(
                        color: AppColors.primary,

                        borderRadius: BorderRadius.circular(12),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),

                          onTap: () {
                            widget.onDelete();
                          },

                          child: const SizedBox(
                            width: 64,
                            height: 64,

                            child: Center(
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // =================================================
              // CHAT TILE
              // =================================================
              Transform.translate(
                offset: Offset(-_dragOffset, 0),

                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,

                  // =============================================
                  // SWIPE
                  // =============================================
                  onHorizontalDragUpdate: (details) {
                    final double next = (_dragOffset - details.delta.dx).clamp(
                      0.0,
                      maxReveal,
                    );

                    setState(() {
                      _dragOffset = next;
                    });
                  },

                  // =============================================
                  // RELEASE
                  // =============================================
                  onHorizontalDragEnd: (_) {
                    if (_dragOffset >= maxReveal * 0.2) {
                      // Open
                      _open(maxReveal);
                    } else {
                      // Close
                      _close();
                    }
                  },

                  child: widget.child,
                ),
              ),

              // =================================================
              // INDENTED DIVIDER (matches design line)
              // =================================================
              Positioned(
                left: 75,
                right: 0,
                bottom: 0,

                child: IgnorePointer(
                  child: Container(height: 1, color: const Color(0xFFEFECE6)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================================
// CHAT LIST
// ==========================================================

class _ChatListView extends StatefulWidget {
  final String currentUserId;
  final ValueNotifier<int>? refreshNotifier;

  const _ChatListView({
    required this.currentUserId,
    this.refreshNotifier,
  });

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ==========================================================
  // LAYOUT CONSTANTS
  // ==========================================================

  static const double firstCardHeight = 132.0;

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  String get _currentUserId => widget.currentUserId;

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  // ==========================================================
  // SOCKET
  // ==========================================================

  late final SocketService _socketService;

  // ==========================================================
  // FILTERS
  // ==========================================================

  final List<String> filters = const [
    'All',
    'Unread',
    'Online',
    'Nearby',
    'Date Invites',
    'Gifts',
  ];

  // ==========================================================
  // NEW MATCHES API
  // ==========================================================

  List<_NewMatch> _newMatchesData = [];
  // Guard: ensures the new-matches API is called only once per
  // widget lifetime, even if the tab is switched back and forth.
  bool _newMatchesLoaded = false;

  Future<void> _loadNewMatches({bool forceRefresh = false}) async {
    if (!mounted) return;

    // Skip if already successfully loaded (unless explicitly refreshing)
    if (_newMatchesLoaded && !forceRefresh) return;

    try {
      AppLogger.i('ChatScreen', '🌐 Calling new matches API: ${NewMatchesService.endpointPath}');
      final result = await NewMatchesService.instance.getNewMatches(
        page: 1,
        limit: 15,
      );

      if (!mounted) return;

      setState(() {
        _newMatchesData = result.matches;
        _newMatchesLoaded = true;
      });
      AppLogger.i('ChatScreen', '✅ New matches loaded: count=${_newMatchesData.length}');
    } catch (e) {
      AppLogger.e('ChatScreen', '❌ NEW MATCHES ERROR: $e');

      if (!mounted) return;

      setState(() {
        _newMatchesData = [];
      });
    }
  }

  // ==========================================================
  // SCROLL
  // ==========================================================

  double _scrollProgress = 0.0;

  bool _isSnapping = false;

  // ==========================================================
  // TYPING
  //
  // IMPORTANT:
  //
  // conversationId IS NOT USED HERE.
  //
  // We track typing by USER ID.
  //
  // {
  //   "46d3f097-...": true,
  //   "another-user-id": true,
  // }
  // ==========================================================

  final Map<String, bool> _typingUsers = {};

  // Live online/offline status received from socket.
  // This is local UI state so the chat list rebuilds immediately without
  // waiting for a tab change or another Bloc event.
  final Map<String, bool> _onlineUsers = {};

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _filterKeys.addAll(List.generate(filters.length, (_) => GlobalKey()));
    _socketService = SocketService();
    _loadNewMatches();

    _scrollController.addListener(_onScroll);

    _registerTypingListeners();
    _registerOnlineStatusListeners();

    // Connect only after listeners are attached. SocketService queues any
    // listeners while creating the socket, so user:online cannot be missed.
    _socketService.ensureConnected();

    // Listen to tab-switch signal from the bottom nav.
    // When the chat tab becomes active, refresh the chat listing so any
    // messages received while on another tab are immediately visible.
    widget.refreshNotifier?.addListener(_onTabRefresh);

    AppLogger.d('ChatScreen', '🟢 CHAT LIST: initState completed');
  }

  /// Called by [refreshNotifier] whenever the chat tab becomes active.
  void _onTabRefresh() {
    if (!mounted) return;
    AppLogger.d('ChatScreen', '🔄 Tab refresh signal received - reloading chat list');
    context.read<ChatBloc>().add(const LoadChatsEvent());
    _loadNewMatches(forceRefresh: true);
  }

  // ==========================================================
  // REGISTER TYPING LISTENERS
  // ==========================================================

  void _registerTypingListeners() {
    if (!mounted) {
      return;
    }

    if (_socketService.socket == null) {
      AppLogger.d('ChatScreen', 
        '⏳ CHAT LIST: SOCKET NULL - retrying listener registration...',
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _registerTypingListeners();
        }
      });

      return;
    }

    // Remove old listeners
    _socketService.off('typing:start');
    _socketService.off('typing:stop');

    // Register listeners
    _socketService.on('typing:start', _onTypingStart);

    _socketService.on('typing:stop', _onTypingStop);

    AppLogger.d('ChatScreen', '🟢 CHAT LIST: typing:start listener registered');

    AppLogger.d('ChatScreen', '🟢 CHAT LIST: typing:stop listener registered');

    AppLogger.i('ChatScreen', 
      '🟢 CHAT LIST: socket connected = '
      '${_socketService.socket?.connected}',
    );
  }

  // ==========================================================
  // ONLINE / OFFLINE LISTENERS
  // ==========================================================

  void _registerOnlineStatusListeners() {
    if (!mounted) return;

    if (_socketService.socket == null) {
      AppLogger.d('ChatScreen', 
        '⏳ CHAT LIST: SOCKET NULL - retrying online listener registration...',
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _registerOnlineStatusListeners();
      });
      return;
    }

    _socketService.offListener('user:online', _onUserOnline);
    _socketService.offListener('user:offline', _onUserOffline);

    _socketService.on('user:online', _onUserOnline);
    _socketService.on('user:offline', _onUserOffline);

    AppLogger.d('ChatScreen', '🟢 CHAT LIST: user:online listener registered');
    AppLogger.d('ChatScreen', '🟢 CHAT LIST: user:offline listener registered');
  }

  String? _extractUserId(dynamic data) {
    if (data is Map) {
      final direct = data['userId'] ?? data['id'];
      if (direct != null && direct.toString().isNotEmpty) {
        return direct.toString();
      }

      final nested = data['data'];
      if (nested is Map) {
        final value = nested['userId'] ?? nested['id'];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return null;
  }

  void _onUserOnline(dynamic data) {
    final userId = _extractUserId(data);
    AppLogger.d('ChatScreen', '🟢 user:online RECEIVED => $data | userId=$userId');
    if (!mounted ||
        userId == null ||
        userId.isEmpty ||
        userId == _currentUserId) {
      return;
    }

    setState(() {
      _onlineUsers[userId] = true;
    });
  }

  void _onUserOffline(dynamic data) {
    final userId = _extractUserId(data);
    AppLogger.d('ChatScreen', '🔴 user:offline RECEIVED => $data | userId=$userId');
    if (!mounted ||
        userId == null ||
        userId.isEmpty ||
        userId == _currentUserId) {
      return;
    }

    setState(() {
      _onlineUsers[userId] = false;
    });
  }

  // ==========================================================
  // TYPING START
  //
  // Response:
  //
  // {
  //   "conversationId": "...",
  //   "userId": "46d3..."
  // }
  //
  // conversationId intentionally ignored.
  // ==========================================================

  void _onTypingStart(dynamic data) {
    AppLogger.d('ChatScreen', '🟢 SOCKET typing:start RECEIVED => $data');

    // ONLY userId is extracted.
    final String? userId = _extractTypingValue(data, 'userId');

    AppLogger.d('ChatScreen', '🟢 typing:start userId => $userId');

    if (!mounted) {
      AppLogger.w('ChatScreen', '⚠️ CHAT LIST NOT MOUNTED');
      return;
    }

    if (userId == null || userId.isEmpty) {
      AppLogger.e('ChatScreen', '❌ typing:start userId missing');
      return;
    }

    // Ignore own typing
    if (userId == _currentUserId) {
      AppLogger.d('ChatScreen', 'ℹ️ Own typing:start event ignored');
      return;
    }

    // Show typing for this USER
    setState(() {
      _typingUsers[userId] = true;
    });

    AppLogger.i('ChatScreen', '✅ TYPING SHOWING FOR USER: $userId');
  }

  // ==========================================================
  // TYPING STOP
  //
  // conversationId intentionally ignored.
  // ==========================================================

  void _onTypingStop(dynamic data) {
    AppLogger.d('ChatScreen', '🔴 SOCKET typing:stop RECEIVED => $data');

    // ONLY userId is extracted.
    final String? userId = _extractTypingValue(data, 'userId');

    AppLogger.d('ChatScreen', '🔴 typing:stop userId => $userId');

    if (!mounted) {
      return;
    }

    if (userId == null || userId.isEmpty) {
      AppLogger.e('ChatScreen', '❌ typing:stop userId missing');
      return;
    }

    // Ignore own typing
    if (userId == _currentUserId) {
      AppLogger.d('ChatScreen', 'ℹ️ Own typing:stop event ignored');
      return;
    }

    // Hide typing for this USER
    setState(() {
      _typingUsers.remove(userId);
    });

    AppLogger.i('ChatScreen', '✅ TYPING HIDDEN FOR USER: $userId');
  }

  // ==========================================================
  // EXTRACT SOCKET VALUE
  //
  // Supports:
  //
  // {
  //   "userId": "..."
  // }
  //
  // {
  //   "data": {
  //      "userId": "..."
  //   }
  // }
  //
  // snake_case also supported.
  // ==========================================================

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
  String? _extractTypingValue(dynamic data, String key) {
    dynamic value = data;

    // ==========================================================
    // SOCKET.IO ARRAY PAYLOAD
    //
    // Actual response:
    //
    // [
    //   {
    //     conversationId: "...",
    //     userId: "..."
    //   },
    //   "Q0e3bHu"
    // ]
    //
    // First item is the actual payload.
    // ==========================================================

    if (value is List) {
      if (value.isEmpty) {
        AppLogger.e('ChatScreen', '❌ Typing event list is empty');
        return null;
      }

      value = value.first;

      AppLogger.d('ChatScreen', '🟢 Typing event first item => $value');
    }

    // ==========================================================
    // MAP PAYLOAD
    // ==========================================================

    for (int i = 0; i < 5; i++) {
      if (value is List) {
        if (value.isEmpty) {
          return null;
        }

        value = value.first;
        continue;
      }

      if (value is! Map) {
        AppLogger.e('ChatScreen', '❌ Typing event data is not Map/List: $value');
        return null;
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(value);

      // ========================================================
      // DIRECT VALUE
      // ========================================================

      dynamic result = map[key];

      // ========================================================
      // SNAKE CASE
      // ========================================================

      if (result == null) {
        if (key == 'userId') {
          result = map['user_id'];
        }

        if (key == 'conversationId') {
          result = map['conversation_id'];
        }
      }

      // ========================================================
      // VALUE FOUND
      // ========================================================

      if (result != null && result.toString().isNotEmpty) {
        return result.toString();
      }

      // ========================================================
      // NESTED DATA
      // ========================================================

      if (map['data'] is Map || map['data'] is List) {
        value = map['data'];
        continue;
      }

      // ========================================================
      // NESTED USER
      // ========================================================

      if (map['user'] is Map || map['user'] is List) {
        value = map['user'];
        continue;
      }

      // ========================================================
      // NESTED CONVERSATION
      // ========================================================

      if (map['conversation'] is Map || map['conversation'] is List) {
        value = map['conversation'];
        continue;
      }

      break;
    }

    return null;
  }
  // ==========================================================
  // SCROLL
  // ==========================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    const double start = 0.0;
    const double end = firstCardHeight;

    final double offset = _scrollController.offset;

    final double progress = ((offset - start) / (end - start)).clamp(0.0, 1.0);

    if ((_scrollProgress - progress).abs() > 0.01) {
      setState(() {
        _scrollProgress = progress;
      });
    }
  }

  // ==========================================================
  // SCROLL END / SNAP
  // ==========================================================

  bool _handleScrollEnd(ScrollNotification notification) {
    if (notification is! ScrollEndNotification) {
      return false;
    }

    if (_isSnapping) {
      return false;
    }

    if (!_scrollController.hasClients) {
      return false;
    }

    const double start = 0.0;
    const double end = firstCardHeight;

    final double offset = _scrollController.offset;

    if (offset <= start || offset >= end) {
      return false;
    }

    final double progress = ((offset - start) / (end - start)).clamp(0.0, 1.0);

    final double target = progress < 0.5 ? start : end;

    _isSnapping = true;

    _scrollController
        .animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          _isSnapping = false;
        });

    return false;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    // Remove tab-refresh listener to avoid calling a disposed widget
    widget.refreshNotifier?.removeListener(_onTabRefresh);

    _socketService.off('typing:start');
    _socketService.off('typing:stop');
    _socketService.offListener('user:online', _onUserOnline);
    _socketService.offListener('user:offline', _onUserOffline);

    AppLogger.d('ChatScreen', '🔴 CHAT LIST: socket listeners removed');

    searchController.dispose();

    _searchFocusNode.dispose();

    _scrollController.removeListener(_onScroll);

    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      body: SafeArea(
        child: Column(
          children: [
            _header(),

            _search(),

            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 1.0 - _scrollProgress,
                child: Opacity(
                  opacity: (1.0 - Curves.easeIn.transform(_scrollProgress))
                      .clamp(0.0, 1.0),
                  child: _newMatches(),
                ),
              ),
            ),

            _filters(),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollEnd,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [_chatSliver()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return Container(
      // color: const Color(0xFFFAF8F4),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(
                  text: 'Mess',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'ages',
                  style: TextStyle(color: Color(0xFFE43A6A)), // Pink
                ),
              ],
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => const ChatAutomationScreen(),
          //       ),
          //     );
          //   },
          //   child: Container(
          //     width: 38,
          //     height: 38,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       shape: BoxShape.circle,
          //       border: Border.all(color: const Color(0xFFEFECE6)),
          //       boxShadow: const [
          //         BoxShadow(
          //           color: Color(0x0A000000),
          //           blurRadius: 4,
          //           offset: Offset(0, 1),
          //         ),
          //       ],
          //     ),
          //     child: Stack(
          //       alignment: Alignment.center,
          //       children: [
          //         const Icon(
          //           Icons.send_rounded,
          //           color: Color(0xFFC73A5E),
          //           size: 18,
          //         ),
          //         Positioned(
          //           top: 6,
          //           right: 6,
          //           child: Container(
          //             width: 7,
          //             height: 7,
          //             decoration: BoxDecoration(
          //               color: const Color(0xFFE85A7A),
          //               shape: BoxShape.circle,
          //               border: Border.all(color: Colors.white, width: 1.5),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _search() {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFECE6)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF8A8680),
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                context.read<ChatBloc>().add(SearchChatsEvent(value));
              },
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: Color(0xFF1F1F1F),
              ),
              decoration: const InputDecoration(
                hintText: 'Search matches or messages',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  color: Color(0xFF8A8680),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                searchController.clear();
                context.read<ChatBloc>().add(const SearchChatsEvent(''));
                setState(() {});
              },
              child: const Icon(
                Icons.close,
                color: Color(0xFF8A8680),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // NEW MATCHES
  // ==========================================================

  Widget _newMatches() {
    if (_newMatchesData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NEW MATCHES',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Color(0xFFE85A7A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ChatBloc>(),
                        child: const AllNewMatchesScreen(),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'See all →',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8680),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _newMatchesData.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, index) {
              return _newMatchItem(_newMatchesData[index]);
            },
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  // ==========================================================
  // NEW MATCH ITEM
  // ==========================================================

  Widget _newMatchItem(_NewMatch match) {
    return GestureDetector(
      onTap: () => _openChatWithNewMatch(match),
      child: SizedBox(
        width: 66,
        child: Column(
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE85A7A), Color(0xFFF8A0B8)],
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFAF8F4),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: ClipOval(
                        child: match.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: match.image,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: const Color(0xFFEFECE6),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: const Color(0xFFEFECE6),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF8A8680),
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFEFECE6),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF8A8680),
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Floating badge
                  if (match.badgeText.isNotEmpty)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        padding: match.badgeText.length > 2
                            ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
                            : const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: match.isGiftBadge
                              ? const Color(0xFFE8A53D)
                              : const Color(0xFFE85A7A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFAF8F4),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          match.badgeText,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              match.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatWithNewMatch(_NewMatch match) {
    final ChatBloc chatBloc = context.read<ChatBloc>();

    ChatUser? existingChat;
    for (final chat in chatBloc.state.allChats) {
      if (chat.userId == match.userId || chat.id == match.userId) {
        existingChat = chat;
        break;
      }
    }

    final ChatUser userToOpen = existingChat ??
        ChatUser(
          id: match.userId,
          conversationId: null,
          userId: match.userId,
          name: match.name,
          age: match.age,
          image: match.image,
          preview: match.content.isNotEmpty ? match.content : 'You matched — say hi 👋',
          time: 'Now',
          match: match.matchScore.isNotEmpty ? '${match.matchScore}% Match' : '',
          trust: match.trustScore.isNotEmpty ? '${match.trustScore}% Trust' : '',
          online: false,
          unread: 0,
          progress: '',
          reward: '',
          progressCurrent: 0,
          progressTarget: 0,
          progressPercentage: 0,
          progressLabel: '',
          progressType: '',
          giftName: '',
          progressExpiresAt: null,
        );

    if (existingChat != null && (existingChat.conversationId?.isNotEmpty ?? false)) {
      chatBloc.joinConversation(existingChat.conversationId!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: chatBloc,
          child: ChatDetailScreen(user: userToOpen),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      chatBloc.add(const LoadChatsEvent());
    });
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  final ScrollController _filterScrollController = ScrollController();

  final List<GlobalKey> _filterKeys = [];
  void _centerSelectedFilter(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final itemContext = _filterKeys[index].currentContext;

      if (itemContext == null) return;

      Scrollable.ensureVisible(
        itemContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }

  Widget _filters() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        controller: _filterScrollController,
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          return BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) => previous.filter != current.filter,
            builder: (_, state) {
              final selected = state.filter == filters[index];

              return GestureDetector(
                key: _filterKeys[index],
                onTap: () {
                  final selectedFilter = filters[index];

                  String type;
                  switch (selectedFilter) {
                    case 'All':
                      type = 'all';
                      break;
                    case 'Online':
                      type = 'online';
                      break;
                    case 'Unread':
                      type = 'unread';
                      break;
                    case 'Nearby':
                      type = 'nearby';
                      break;
                    case 'Date Invites':
                      type = 'date_invite';
                      break;
                    case 'Gifts':
                    case 'Gift':
                      type = 'gift';
                      break;
                    default:
                      type = 'all';
                  }

                  AppLogger.d('ChatScreen', '🔎 Filter clicked: $selectedFilter -> $type');

                  context.read<ChatBloc>().add(
                        SelectFilterEvent(selectedFilter),
                      );

                  context.read<ChatBloc>().add(LoadChatsEvent(type: type));

                  _centerSelectedFilter(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE85A7A) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFE85A7A)
                          : const Color(0xFFEFECE6),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filters[index],
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF5F5C56),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================================
  // CHAT SLIVER
  // ==========================================================

  Widget _chatSliver() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.filteredChats.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.70,
              child: Center(
                child: Text(
                  'No messages found',
                  style: AppText.body.copyWith(color: AppColors.muted),
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final user = state.filteredChats[index];

              return _chatTile(
                user,
                isLast: index == state.filteredChats.length - 1,
                index: index,
              );
            }, childCount: state.filteredChats.length),
          ),
        );
      },
    );
  }

  // ==========================================================
  // CHAT TILE
  // ==========================================================

  Widget _chatTile(ChatUser user, {bool isLast = false, required int index}) {
    final double rawProgress =
        (double.tryParse(user.progress.replaceAll('%', '')) ?? 0) / 100;
    final double progress = rawProgress.clamp(0.0, 1.0);

    final bool isDone = progress >= 0.99 || user.reward.toLowerCase().contains('unlocked');
    final bool isWarn = user.reward.toLowerCase().contains('deadline');
    final Color progressFillColor = isDone
        ? const Color(0xFF2EAF6B)
        : (isWarn ? const Color(0xFFE05050) : const Color(0xFFE85A7A));

    final bool isTyping = _typingUsers[user.userId] == true;
    final bool isOnline = _onlineUsers.containsKey(user.userId)
        ? _onlineUsers[user.userId] == true
        : user.online;

    final bool hasProgress = user.reward.isNotEmpty ||
        (user.progress.isNotEmpty && user.progress != '0%' && user.progress != '0');

    return _SwipeDeleteChatTile(
      index: index,
      onOpen: _onSwipeOpened,
      onClose: _onSwipeClosed,
      onDelete: () => _showDeleteConversationDialog(user),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _closeSwipe();
          _openChat(user);
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // AVATAR 54x54
              // =================================================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _avatar(user.image, 54, user.name, user.age.toString()),
                  if (isOnline)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2EAF6B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 13),

              // =================================================
              // BODY
              // =================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: name, age, match pill, trust pill, time
                    Row(
                      children: [
                        Expanded(
                        child: Tooltip(
                          message: user.age > 0
                              ? '${capitalizeFirstLetter(user.name)}, ${user.age}'
                              : capitalizeFirstLetter(user.name),
                          child: Text(
                            user.age > 0
                                ? '${capitalizeFirstLetter(user.name)}, ${user.age}'
                                : capitalizeFirstLetter(user.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                        ),
                      ),
                        if (user.match.isNotEmpty) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEF2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.match.contains('%')
                                  ? user.match
                                  : '${user.match}% Match',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC73A5E),
                              ),
                            ),
                          ),
                        ],
                        if (user.trust.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8EF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.trust.contains('%')
                                  ? user.trust
                                  : '${user.trust}% Trust',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2EAF6B),
                              ),
                            ),
                          ),
                        ],
                        // const Spacer(),
                        const SizedBox(width: 6,),
                        Text(
                          user.time,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: Color(0xFF8A8680),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Preview row with unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isTyping ? 'Typing…' : user.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: isTyping
                                  ? const Color(0xFFE85A7A)
                                  : const Color(0xFF5F5C56),
                              fontWeight: isTyping
                                  ? FontWeight.w700
                                  : (user.unread > 0
                                      ? FontWeight.w700
                                      : FontWeight.w400),
                            ),
                          ),
                        ),
                        if (user.unread > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            constraints: const BoxConstraints(minWidth: 19),
                            height: 19,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2EAF6B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${user.unread}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // Progress bar or Meta line
                    if (hasProgress)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F2EC),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress > 0 ? progress : 0.05,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: progressFillColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.reward.isNotEmpty
                                ? user.reward
                                : '${user.progress} for Rose 🌹',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? const Color(0xFF2EAF6B)
                                  : (isWarn
                                      ? const Color(0xFFE05050)
                                      : const Color(0xFF8A8680)),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Text('🌹 ', style: TextStyle(fontSize: 11)),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11.5,
                                color: Color(0xFF8A8680),
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Send a rose',
                                  style: TextStyle(
                                    color: Color(0xFFC73A5E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: ' to make your first impression',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConversationDialog(ChatUser user) async {
    final conversationId = (user.conversationId ?? '').trim();
    if (conversationId.isEmpty) {
      AppLogger.e('ChatScreen', '❌ DELETE CHAT: conversationId is missing for ${user.name}');
      return;
    }

    const accentColor = Color(0xFFD6336C);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Delete conversation?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                "This will delete your conversation with ${user.name}.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),

              // Primary action (filled)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Clear Conversation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary action (text)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || confirmed != true) return;

    context.read<ChatBloc>().add(
      DeleteConversationEvent(conversationId: conversationId),
    );
  }

  // ==========================================================
  // AVATAR
  // ==========================================================

  Widget _avatar(String url, double size, String name, String age) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 400,
                height: 440,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main white container
                    Container(
                      width: 400,
                      height: 440,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 400,
                              height: 400,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => const SizedBox(
                                width: 400,
                                height: 400,
                                child: ColoredBox(color: AppColors.soft),
                              ),
                              errorWidget: (_, _, _) {
                                return const SizedBox(
                                  width: 400,
                                  height: 400,
                                  child: ColoredBox(
                                    color: AppColors.soft,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Bottom 20px white strip
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                '$name${(int.tryParse(age.toString()) ?? 0) > 0 ? ", $age yrs" : ""}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cross icon - Top Right
                    Positioned(
                      top: -12,
                      right: -12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: size,
        height: size,
        // padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Container(
          // padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.canvas,
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => ColoredBox(
                color: AppColors.soft,
                child: SizedBox(width: size, height: size),
              ),
              errorWidget: (_, _, _) {
                return const ColoredBox(
                  color: AppColors.soft,
                  child: Icon(Icons.person, color: AppColors.muted),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // OPEN CHAT
  //
  // conversationId is still used here because
  // conversation join needs it.
  //
  // Typing listener does NOT use it.
  // ==========================================================
  void _openChat(ChatUser user) {
    final ChatBloc chatBloc = context.read<ChatBloc>();

    final String? conversationId = user.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      AppLogger.e('ChatScreen', '❌ Conversation ID is missing');
      return;
    }

    AppLogger.d('ChatScreen', '🟢 OPEN CHAT CONVERSATION ID: $conversationId');

    // ==========================================================
    // JOIN CONVERSATION
    // ==========================================================

    chatBloc.joinConversation(conversationId);

    final bool isOnline = _onlineUsers.containsKey(user.userId)
        ? _onlineUsers[user.userId] == true
        : (_onlineUsers.containsKey(user.id)
            ? _onlineUsers[user.id] == true
            : user.online);

    final ChatUser userToOpen = user.copyWith(online: isOnline);

    context.push(
      AppRoutes.chatDetail,
      extra: {
        'user': userToOpen,
        'bloc': chatBloc,
      },
    ).then((_) {
      if (!mounted) return;
      chatBloc.clearConversationUnread(conversationId);
      // Refresh chat list so new messages show after returning from ChatDetail
      chatBloc.add(const LoadChatsEvent());
      AppLogger.d('ChatScreen', '🔙 RETURNED CHAT -> unread cleared: $conversationId');
    });
  }
}
