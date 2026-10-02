import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/config/custom_snackbar.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';
import 'chat_bloc/chat_bloc.dart';
import 'chat_bloc/chat_state.dart';
import 'chat_detail_screen.dart';
import 'services/new_matches_service.dart';

class AllNewMatchesScreen extends StatefulWidget {
  const AllNewMatchesScreen({super.key});

  @override
  State<AllNewMatchesScreen> createState() => _AllNewMatchesScreenState();
}

class _AllNewMatchesScreenState extends State<AllNewMatchesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<NewMatchItem> _matches = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMatches(page: 1, isInitial: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // When within 250px of the bottom, load the next page
    if (currentScroll >= (maxScroll - 250) && !_isLoadingMore && _hasMore) {
      _loadNextPage();
    }
  }

  Future<void> _fetchMatches({
    required int page,
    bool isInitial = false,
  }) async {
    if (!mounted) return;

    if (isInitial) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await NewMatchesService.instance.getNewMatches(
        page: page,
        limit: 20,
      );

      if (!mounted) return;

      setState(() {
        if (page == 1) {
          _matches.clear();
        }

        // Avoid duplicates by userId
        final existingIds = _matches.map((m) => m.userId).toSet();
        for (final item in result.matches) {
          if (!existingIds.contains(item.userId)) {
            _matches.add(item);
            existingIds.add(item.userId);
          }
        }

        _currentPage = page;
        _hasMore = result.hasMore;
        _isLoadingInitial = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (e) {
      AppLogger.e('AllNewMatchesScreen', 'Error fetching new matches page $page: $e');
      if (!mounted) return;

      final cleanError = CustomSnackBar.cleanMessage(e.toString());
      setState(() {
        _isLoadingInitial = false;
        _isLoadingMore = false;
        if (page == 1) {
          _errorMessage = cleanError;
        }
      });

      if (!isInitial) {
        CustomSnackBar.showError(context, cleanError);
      }
    }
  }

  Future<void> _refresh() async {
    await _fetchMatches(page: 1, isInitial: false);
  }

  void _loadNextPage() {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _fetchMatches(page: _currentPage + 1);
  }

  List<NewMatchItem> get _filteredMatches {
    if (_searchQuery.trim().isEmpty) return _matches;
    final q = _searchQuery.toLowerCase().trim();
    return _matches.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  void _navigateToChat(NewMatchItem match) {
    ChatBloc? chatBloc;
    try {
      chatBloc = context.read<ChatBloc>();
    } catch (_) {
      chatBloc = null;
    }

    // Check if an existing conversation exists in bloc state
    ChatUser? existingChat;
    if (chatBloc != null) {
      for (final chat in chatBloc.state.allChats) {
        if (chat.userId == match.userId || chat.id == match.userId) {
          existingChat = chat;
          break;
        }
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

    if (existingChat != null && chatBloc != null && (existingChat.conversationId?.isNotEmpty ?? false)) {
      chatBloc.joinConversation(existingChat.conversationId!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (chatBloc != null) {
            return BlocProvider.value(
              value: chatBloc,
              child: ChatDetailScreen(user: userToOpen),
            );
          }
          return ChatDetailScreen(user: userToOpen);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMatches;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEFECE6)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'New Matches',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1F1F),
              ),
            ),
            if (_matches.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_matches.length}',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE85A7A),
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEFECE6)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8A8680),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: Color(0xFF1F1F1F),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search new matches',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: Color(0xFF8A8680),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF8A8680),
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content body
          Expanded(
            child: _buildBody(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<NewMatchItem> filtered) {
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE85A7A),
        ),
      );
    }

    if (_errorMessage != null && _matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEF2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFFE85A7A),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load matches',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Color(0xFF8A8680),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchMatches(page: 1, isInitial: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85A7A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEF2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💌', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matches match "$_searchQuery"'
                  : 'No new matches yet',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Swipe more profiles to discover new connections!',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF8A8680),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFE85A7A),
      backgroundColor: Colors.white,
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
        ),
        itemCount: filtered.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return _buildShimmerCard();
          }
          final match = filtered[index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(NewMatchItem match) {
    return InkWell(
      onTap: () => _navigateToChat(match),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFECE6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with badges
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(17),
                    ),
                    child: match.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: match.image,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: const Color(0xFFF5F2EC),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE85A7A),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: const Color(0xFFF5F2EC),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF8A8680),
                                size: 44,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF5F2EC),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF8A8680),
                              size: 44,
                            ),
                          ),
                  ),

                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating top badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: match.isGiftBadge
                            ? const Color(0xFFE8A53D)
                            : const Color(0xFFE85A7A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        match.badgeText,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  // Match score pill at bottom of photo
                  if (match.matchScore.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${match.matchScore}% Match',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC73A5E),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // User info & action
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.age > 0 ? '${match.name}, ${match.age}' : match.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _navigateToChat(match),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85A7A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 14),
                          SizedBox(width: 5),
                          Text(
                            'Chat',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFECE6)),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFE85A7A),
          ),
        ),
      ),
    );
  }
}
