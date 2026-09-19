import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SocketService.dart';

import 'chat_bloc/chat_bloc.dart';
import 'chat_bloc/chat_event.dart';
import 'chat_bloc/chat_state.dart';
import 'chat_repository.dart';
import 'chat_detail_screen.dart';

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

class ChatScreen_ extends StatefulWidget {
  const ChatScreen_({super.key});

  @override
  State<ChatScreen_> createState() => _ChatScreen_State();
}

class _ChatScreen_State extends State<ChatScreen_> {
  late final Future<String> _initFuture = _init();

  Future<String> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedToken = prefs.getString('auth_token')?.trim() ?? '';
    final token = savedToken.startsWith('')
        ? savedToken.substring(7).trim()
        : savedToken;

    if (token.isEmpty) {
      debugPrint('❌ CHAT: no auth_token found - socket not connected');
    }

    // Socket connection is intentionally started by _ChatListView AFTER
    // online/offline listeners are registered. This prevents missing the
    // first user:online event during socket connect.
    return ChatRepository.userIdFromToken(token, fallback: '');
  }

  @override
  Widget build(BuildContext context) {
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
          child: _ChatListView(currentUserId: currentUserId),
        );
      },
    );
  }
}

// ==========================================================
// NEW MATCH MODEL
// ==========================================================

class _NewMatch {
  final String messageId;
  final String type;
  final String content;
  final String createdAt;
  final String userId;
  final String name;
  final int age;
  final String image;

  const _NewMatch({
    required this.messageId,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.name,
    required this.age,
    required this.image,
  });

  factory _NewMatch.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] is Map
        ? Map<String, dynamic>.from(json['sender'] as Map)
        : const <String, dynamic>{};

    final ageValue = sender['age'];

    return _NewMatch(
      messageId: (json['messageId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      userId: (sender['id'] ?? '').toString(),
      name: (sender['name'] ?? 'Unknown').toString(),
      age: ageValue is num
          ? ageValue.toInt()
          : int.tryParse(ageValue?.toString() ?? '') ?? 0,
      image: (sender['photo'] ?? '').toString(),
    );
  }
}

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

  bool _isOpen = false;

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
      _isOpen = false;
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
      _isOpen = true;
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

                      if (_dragOffset < maxReveal) {
                        _isOpen = false;
                      }
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
              // FULL WIDTH DIVIDER
              // =================================================
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,

                child: IgnorePointer(
                  child: Container(height: 1, color: AppColors.line),
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

  const _ChatListView({required this.currentUserId});

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView> {
  // ==========================================================
  // LAYOUT CONSTANTS
  // ==========================================================

  static const double headerHeight = 70;
  static const double searchHeight = 60;
  static const double filterHeight = 50;
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
  // SEARCH
  // ==========================================================

  bool _isSearchOpen = false;

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
    });

    if (_isSearchOpen) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      searchController.clear();

      context.read<ChatBloc>().add(const SearchChatsEvent(''));

      _searchFocusNode.unfocus();
    }
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  final List<String> filters = const [
    'All',
    'Unread',
    'Online',
    'Nearby',
    'Date Invites',
    'Event',
  ];

  // ==========================================================
  // NEW MATCHES API
  // ==========================================================

  List<_NewMatch> _newMatchesData = const [];
  bool _newMatchesLoading = true;
  String? _newMatchesError;

  Future<void> _loadNewMatches() async {
    if (!mounted) return;

    setState(() {
      _newMatchesLoading = true;
      _newMatchesError = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      final uri = Uri.parse(
        'https://dating-app-backend-plum.vercel.app/api/user/matches/new',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token?.isNotEmpty == true)
            'Authorization': token!.toLowerCase().startsWith('bearer ')
                ? token
                : 'Bearer $token',
        },
      );

      debugPrint('NEW MATCHES status: ${response.statusCode}');
      debugPrint('NEW MATCHES body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to load new matches (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
        throw Exception('New matches API returned success=false');
      }

      final rawData = decoded['data'];
      final items = rawData is List
          ? rawData
                .whereType<Map>()
                .map(
                  (item) => _NewMatch.fromJson(Map<String, dynamic>.from(item)),
                )
                .where((item) => item.userId.isNotEmpty)
                .toList()
          : <_NewMatch>[];

      // Keep one card per sender. The newest API item wins.
      final unique = <String, _NewMatch>{};
      for (final item in items) {
        unique[item.userId] = item;
      }

      if (!mounted) return;

      setState(() {
        _newMatchesData = unique.values.toList();
        _newMatchesLoading = false;
      });
    } catch (e) {
      debugPrint('❌ NEW MATCHES: $e');

      if (!mounted) return;

      setState(() {
        _newMatchesData = const [];
        _newMatchesLoading = false;
        _newMatchesError = e.toString();
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

    debugPrint('🟢 CHAT LIST: initState completed');
  }

  // ==========================================================
  // REGISTER TYPING LISTENERS
  // ==========================================================

  void _registerTypingListeners() {
    if (!mounted) {
      return;
    }

    if (_socketService.socket == null) {
      debugPrint(
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

    debugPrint('🟢 CHAT LIST: typing:start listener registered');

    debugPrint('🟢 CHAT LIST: typing:stop listener registered');

    debugPrint(
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
      debugPrint(
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

    debugPrint('🟢 CHAT LIST: user:online listener registered');
    debugPrint('🟢 CHAT LIST: user:offline listener registered');
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
    debugPrint('🟢 user:online RECEIVED => $data | userId=$userId');
    if (!mounted ||
        userId == null ||
        userId.isEmpty ||
        userId == _currentUserId)
      return;

    setState(() {
      _onlineUsers[userId] = true;
    });
  }

  void _onUserOffline(dynamic data) {
    final userId = _extractUserId(data);
    debugPrint('🔴 user:offline RECEIVED => $data | userId=$userId');
    if (!mounted ||
        userId == null ||
        userId.isEmpty ||
        userId == _currentUserId)
      return;

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
    debugPrint('🟢 SOCKET typing:start RECEIVED => $data');

    // ONLY userId is extracted.
    final String? userId = _extractTypingValue(data, 'userId');

    debugPrint('🟢 typing:start userId => $userId');

    if (!mounted) {
      debugPrint('⚠️ CHAT LIST NOT MOUNTED');
      return;
    }

    if (userId == null || userId.isEmpty) {
      debugPrint('❌ typing:start userId missing');
      return;
    }

    // Ignore own typing
    if (userId == _currentUserId) {
      debugPrint('ℹ️ Own typing:start event ignored');
      return;
    }

    // Show typing for this USER
    setState(() {
      _typingUsers[userId] = true;
    });

    debugPrint('✅ TYPING SHOWING FOR USER: $userId');
  }

  // ==========================================================
  // TYPING STOP
  //
  // conversationId intentionally ignored.
  // ==========================================================

  void _onTypingStop(dynamic data) {
    debugPrint('🔴 SOCKET typing:stop RECEIVED => $data');

    // ONLY userId is extracted.
    final String? userId = _extractTypingValue(data, 'userId');

    debugPrint('🔴 typing:stop userId => $userId');

    if (!mounted) {
      return;
    }

    if (userId == null || userId.isEmpty) {
      debugPrint('❌ typing:stop userId missing');
      return;
    }

    // Ignore own typing
    if (userId == _currentUserId) {
      debugPrint('ℹ️ Own typing:stop event ignored');
      return;
    }

    // Hide typing for this USER
    setState(() {
      _typingUsers.remove(userId);
    });

    debugPrint('✅ TYPING HIDDEN FOR USER: $userId');
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
        debugPrint('❌ Typing event list is empty');
        return null;
      }

      value = value.first;

      debugPrint('🟢 Typing event first item => $value');
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
        debugPrint('❌ Typing event data is not Map/List: $value');
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
    _socketService.off('typing:start');
    _socketService.off('typing:stop');
    _socketService.offListener('user:online', _onUserOnline);
    _socketService.offListener('user:offline', _onUserOffline);

    debugPrint('🔴 CHAT LIST: socket listeners removed');

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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: headerHeight, child: _header()),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _isSearchOpen
                  ? SizedBox(height: searchHeight, child: _search())
                  : const SizedBox(width: double.infinity, height: 0),
            ),

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

            SizedBox(height: filterHeight, child: _filters()),

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
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          Expanded(
            child: RichText(
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
          ),
          _iconButton(
            _isSearchOpen ? Icons.close : Icons.search,
            _toggleSearch,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _search() {
    return Container(
      color: AppColors.canvas,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          context.read<ChatBloc>().add(SearchChatsEvent(value));
        },
        style: AppText.body.copyWith(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.muted,
            size: 24,
          ),
          hintText: 'Search matches or messages',
          hintStyle: AppText.body.copyWith(
            color: AppColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  // ==========================================================
  // NEW MATCHES
  // ==========================================================

  Widget _newMatches() {
    // Keep the original section height so the rest of the chat list UI does
    // not jump while the API request is loading.
    if (!_newMatchesLoading && _newMatchesData.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _newMatchesLoading ? 0 : 154,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 1, 10, 10),
            child: Row(
              children: [
                Text(
                  'NEW MATCHES',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See all →',
                    style: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _newMatchesLoading ? 0 : 116,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _newMatchesData.length,
              separatorBuilder: (_, _) => const SizedBox(width: 17),
              itemBuilder: (_, index) {
                return _newMatchItem(_newMatchesData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NEW MATCH ITEM
  // ==========================================================

  Widget _newMatchItem(_NewMatch match) {
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: match.image.isNotEmpty
                          ? Image.network(
                              match.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.line,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.muted,
                                  size: 32,
                                ),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.line,
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.line,
                              child: const Icon(
                                Icons.person,
                                color: AppColors.muted,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                ),

                // API response is a new ROSE match in the supplied endpoint.
                Positioned(
                  top: 1,
                  right: -4,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      match.type.toUpperCase() == 'ROSE' ? '🌹' : '💖',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            match.age > 0 ? '${match.name}, ${match.age}' : match.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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
      height: 50,
      child: ListView.separated(
        controller: _filterScrollController,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 7),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
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

                    case 'Gift':
                      type = 'gift';
                      break;

                    case 'Event':
                      type = 'event';
                      break;

                    default:
                      type = 'all';
                  }

                  debugPrint('🔎 Filter clicked: $selectedFilter -> $type');

                  context.read<ChatBloc>().add(
                    SelectFilterEvent(selectedFilter),
                  );

                  context.read<ChatBloc>().add(LoadChatsEvent(type: type));

                  // Selected filter ko center mein lao
                  _centerSelectedFilter(index);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected
                            ? const Color(0xFFE43A6A)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    filters[index],
                    maxLines: 1,
                    softWrap: false,
                    style: AppText.body.copyWith(
                      fontSize: 14,
                      color: selected
                          ? const Color(0xFFE43A6A)
                          : AppColors.ink60,
                      fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 24),
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
    final double progress =
        (double.tryParse(user.progress.replaceAll('%', '')) ?? 0) / 100;

    final Color progressColor = user.progress == '92%'
        ? AppColors.green
        : AppColors.primary;

    // ========================================================
    // IMPORTANT:
    //
    // Typing is now checked using USER ID.
    //
    // NO conversationId is used here.
    // ========================================================

    final bool isTyping = _typingUsers[user.userId] == true;
    final bool isOnline = _onlineUsers.containsKey(user.userId)
        ? _onlineUsers[user.userId] == true
        : user.online;

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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // AVATAR
              // =================================================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _avatar(user.image, 60, user.name, user.age.toString()),
                  if (isOnline)
                    Positioned(
                      right: -1,
                      bottom: 1,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.canvas, width: 3),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // =================================================
              // CONTENT
              // =================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===========================================
                    // NAME / MATCH / TIME
                    // ===========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${user.name}, ${user.age}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.h2.copyWith(fontSize: 15),
                          ),
                        ),

                        Wrap(
                          children: [
                            const SizedBox(width: 8),

                            if (user.match.isNotEmpty)
                              _miniPill(
                                '${user.match}% Match',
                                AppColors.primarySoft,
                                AppColors.primaryDark,
                              ),

                            if (user.match.isNotEmpty) const SizedBox(width: 6),

                            if (user.trust.isNotEmpty)
                              _miniPill(
                                '${user.trust}% Trust',
                                AppColors.greenSoft,
                                AppColors.green,
                              ),

                            const SizedBox(width: 6),

                            Text(
                              user.time,
                              style: AppText.sub.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ===========================================
                    // PREVIEW / TYPING
                    // ===========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            // alignment: Alignment.centerLeft,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Align(
                              key: ValueKey(
                                isTyping
                                    ? 'typing-${user.userId}'
                                    : 'preview-${user.userId}',
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isTyping ? 'Typing...' : user.preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppText.body.copyWith(
                                  fontSize: 15,
                                  color: isTyping
                                      ? AppColors.green
                                      : user.unread > 0
                                      ? Colors.black
                                      : AppColors.ink60,
                                  fontWeight: isTyping
                                      ? FontWeight.w800
                                      : user.unread > 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ========================================
                        // UNREAD
                        // ========================================
                        if (user.unread > 0) ...[
                          const SizedBox(width: 8),

                          Container(
                            width: 25,
                            height: 25,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${user.unread}',
                              style: AppText.pill.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // ===========================================
                    // PROGRESS / REWARD
                    // ===========================================
                    if (user.reward.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width * 0.50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(10),
                                backgroundColor: Colors.grey.withValues(
                                  alpha: 0.28,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressColor,
                                ),
                              ),
                            ),
                          ),
                          // wSized10,
                          if (user.reward.isNotEmpty)
                            Expanded(
                              child: Text(
                                user.reward,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.sub.copyWith(
                                  fontSize: 11.5,
                                  color: user.reward.contains('Deadline')
                                      ? AppColors.primary
                                      : AppColors.green,
                                  fontWeight: FontWeight.w800,
                                ),
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
      debugPrint('❌ DELETE CHAT: conversationId is missing for ${user.name}');
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
                  color: accentColor.withOpacity(0.1),
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
          barrierColor: Colors.black.withOpacity(0.8),
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
                            child: Image.network(
                              url,
                              width: 400,
                              height: 400,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const SizedBox(
                                  width: 400,
                                  height: 400,
                                  child: ColoredBox(
                                    color: AppColors.soft,
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.muted,
                                        size: 80,
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
                                '$name${int.tryParse(age?.toString() ?? '0') != null && int.tryParse(age?.toString() ?? '')! > 0 ? ", ${age} yrs" : ""}',
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
            child: Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
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
  // MINI PILL
  // ==========================================================

  Widget _miniPill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.pill.copyWith(
          fontSize: 10.5,
          color: foreground,
          fontWeight: FontWeight.w800,
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
      debugPrint('❌ Conversation ID is missing');
      return;
    }

    debugPrint('🟢 OPEN CHAT CONVERSATION ID: $conversationId');

    // ==========================================================
    // JOIN CONVERSATION
    // ==========================================================

    chatBloc.joinConversation(conversationId);

    // Message read individual message ke messageId se hoga.
    // debugPrint("user>>>idd>>${user.userId}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: chatBloc,
          child: ChatDetailScreen(user: user),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      chatBloc.clearConversationUnread(conversationId);
      debugPrint('🔙 RETURNED CHAT -> unread cleared: $conversationId');
    });
  }
  // ==========================================================
  // ICON BUTTON
  // ==========================================================

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppColors.shadow,
        ),
        child: Icon(icon, color: AppColors.ink, size: 25),
      ),
    );
  }
}
