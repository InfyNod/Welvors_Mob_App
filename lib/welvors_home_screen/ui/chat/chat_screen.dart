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

    // final token = prefs.getString('auth_token');

    final token =
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

    if (token.isNotEmpty) {
      SocketService().connect(token: token);
    } else {
      debugPrint('❌ CHAT: no auth_token found - socket not connected');
    }

    return ChatRepository.userIdFromToken(
      token,
      fallback: '46d3f097-2825-4a41-adc5-8747e3b07f2b',
    );
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

  static const double headerHeight = 80;
  static const double searchHeight = 65;
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
      final prefs = await SharedPreferences.getInstance();
      final token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs";

      final uri = Uri.parse(
        'https://api.welvors.com/api/user/matches/new',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _socketService = SocketService();
    _loadNewMatches();

    _scrollController.addListener(_onScroll);

    _registerTypingListeners();

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

    debugPrint('🔴 CHAT LIST: typing listeners removed');

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
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Messages',
              style: AppText.h1.copyWith(fontSize: 20, letterSpacing: -.7),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
      height: 154,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 20, 10),
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
            height: 116,
            child: _newMatchesLoading
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 17),
                    itemBuilder: (_, index) => _newMatchShimmer(index),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _newMatchesData.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 17),
                    itemBuilder: (_, index) {
                      return _newMatchItem(_newMatchesData[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _newMatchShimmer(int index) {
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 58,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
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
                              errorBuilder: (_, __, ___) => Container(
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

  Widget _filters() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          return BlocBuilder<ChatBloc, ChatState>(
            builder: (_, state) {
              final bool selected = state.filter == filters[index];

              return GestureDetector(
                onTap: () {
                  context.read<ChatBloc>().add(
                    SelectFilterEvent(filters[index]),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.line,
                    ),
                    boxShadow: selected
                        ? const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filters[index],
                    style: AppText.body.copyWith(
                      fontSize: 15,
                      color: selected ? Colors.white : AppColors.ink60,
                      fontWeight: FontWeight.w700,
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
        if (state.loading) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        if (state.filteredChats.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
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
          padding: const EdgeInsets.fromLTRB(20, 3, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _chatTile(state.filteredChats[index]);
            }, childCount: state.filteredChats.length),
          ),
        );
      },
    );
  }

  // ==========================================================
  // CHAT TILE
  // ==========================================================

  Widget _chatTile(ChatUser user) {
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

    return GestureDetector(
      onTap: () => _openChat(user),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
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
                _avatar(user.image, 70),
                if (user.online)
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
                    children: [
                      Flexible(
                        child: Text(
                          '${user.name}, ${user.age}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.h2.copyWith(fontSize: 15),
                        ),
                      ),

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

                  const SizedBox(height: 5),

                  // ===========================================
                  // PREVIEW / TYPING
                  // ===========================================
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
                  if (user.progress != '0%' || user.reward.isNotEmpty)
                    Row(
                      children: [
                        if (user.progress != '0%')
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(10),
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.28,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressColor,
                                ),
                              ),
                            ),
                          ),

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
    );
  }

  // ==========================================================
  // AVATAR
  // ==========================================================

  Widget _avatar(String url, double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
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
            errorBuilder: (_, __, ___) {
              return const ColoredBox(
                color: AppColors.soft,
                child: Icon(Icons.person, color: AppColors.muted),
              );
            },
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

    // ❌ Yahan message:read mat bhejo.
    // Message read individual message ke messageId se hoga.

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
