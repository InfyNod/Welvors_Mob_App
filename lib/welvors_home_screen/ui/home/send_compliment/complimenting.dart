import 'package:velvors/onbording_allpage/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/welvors_home_screen/home_bloc/home_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_event.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_state.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_detail_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_repository.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SocketService.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';
import 'try_screen.dart';
import 'gift_selection_screen.dart';

Future<String> _currentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('auth_token')?.trim() ?? '';
  if (token.startsWith('Bearer ')) token = token.substring(7).trim();
  return ChatRepository.userIdFromToken(token, fallback: '');
}

class ComplimentingBottomSheet extends StatefulWidget {
  final String complimentingType;
  final String? complimentingID;
  final String? profileName;
  final String? profileImageUrl;
  final ProfileModel? profile;

  const ComplimentingBottomSheet({
    super.key,
    this.complimentingType = 'PROMPT',
    this.complimentingID,
    this.profileName,
    this.profileImageUrl,
    this.profile,
  });

  static void show(
    BuildContext context, {
    String type = 'PROMPT',
    String? complimentingID,
    String? profileName,
    String? profileImageUrl,
    String? user_ID,
    final ProfileModel? profilemodel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FutureBuilder<String>(
          future: _currentUserId(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final chatBloc = ChatBloc(
              repository: ChatRepository(currentUserId: snapshot.data!),
              socketService: SocketService(),
            );

            // IMPORTANT: use BlocProvider.value here, NOT
            // BlocProvider(create: ...). A `create:` BlocProvider auto
            // *closes* the bloc it created as soon as it's removed from
            // the tree — which happens the moment this bottom sheet is
            // popped after a successful send. We then reuse this exact
            // same `chatBloc` instance on the ChatDetailScreen route, so
            // it must stay open. Using `.value()` here means flutter_bloc
            // will not manage/close this bloc's lifecycle, which is
            // exactly what we want since ChatDetailScreen keeps using it.
            return BlocProvider<ChatBloc>.value(
              value: chatBloc,
              child: ComplimentingBottomSheet(
                complimentingType: type,
                profileName: profileName,
                profileImageUrl: profileImageUrl,
                profile: profilemodel,
                complimentingID: complimentingID,
              ),
            );
          },
        );
      },
    );
  }

  @override
  State<ComplimentingBottomSheet> createState() =>
      _ComplimentingBottomSheetState();
}

class _ComplimentingBottomSheetState extends State<ComplimentingBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _roseSelected = false;
  bool _giftSelected = false;
  int? _selectedGiftId;
  String? _selectedGiftName;
  String? _selectedGiftEmoji;

  int _commentsBalance = 0;
  int _rosesBalance = 0;
  String _walletBalance = '₹0';
  bool _balancesLoading = true;

  // ==========================================================
  // INLINE ERROR MESSAGE STATE
  // ==========================================================
  // Why: this widget lives INSIDE a modal bottom sheet. Calling
  // ScaffoldMessenger.of(context).showSnackBar(...) from here attaches
  // the SnackBar to the underlying page's Scaffold, but visually the
  // bottom sheet sits ABOVE it in the overlay stack — so the SnackBar
  // gets rendered behind the sheet and the user never sees it until
  // the sheet is dismissed. Showing the error as part of the sheet's
  // own layout instead guarantees it's always visible.
  String? _errorMessage;
  bool _isSending = false;

  final Color _primaryColor = const Color(0xFFE43A6A);
  final Color _softGrey = const Color(0xFFF5F5F5);
  final Color _borderGrey = const Color(0xFFEBEBEB);

  @override
  void initState() {
    super.initState();
    _loadMyBalances();
    _textController.addListener(() {
      setState(() {});
    });
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadMyBalances() async {
    if (mounted) {
      setState(() => _balancesLoading = true);
    }

    final response = await ApiService.getMyBalances();
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'];
      if (data is Map) {
        final compliments = data['compliments'];
        final roses = data['roses'];
        final wallet = data['wallet'];

        setState(() {
          _commentsBalance =
              (compliments is Map ? compliments['balance'] : 0) is num
              ? ((compliments['balance'] as num?)?.toInt() ?? 0)
              : 0;
          _rosesBalance = (roses is Map ? roses['balance'] : 0) is num
              ? ((roses['balance'] as num?)?.toInt() ?? 0)
              : 0;
          _walletBalance = wallet is Map
              ? (wallet['formattedBalance']?.toString() ??
                    '₹${wallet['balance'] ?? 0}')
              : '₹0';
          _balancesLoading = false;
        });
      } else {
        setState(() => _balancesLoading = false);
      }
    } else {
      debugPrint('❌ MY BALANCES FAILED: ${response['message']}');
      setState(() => _balancesLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _buttonText {
    bool hasText = _textController.text.trim().isNotEmpty;
    bool hasRose = _roseSelected;
    bool hasGift = _giftSelected;

    if (hasText && hasRose && hasGift) {
      return 'Send 💬 + 🌹 + 🎁';
    } else if (hasRose && hasGift) {
      return 'Send 🌹 + 🎁';
    } else if (hasText && hasRose) {
      return 'Send 💬 + 🌹';
    } else if (hasText && hasGift) {
      return 'Send 💬 + 🎁';
    } else if (hasText) {
      return 'Send 💬';
    } else if (hasRose) {
      return 'Send 🌹';
    } else if (hasGift) {
      return 'Send 🎁';
    } else {
      return 'Send Compliment';
    }
  }

  bool get _canSend {
    return _textController.text.trim().isNotEmpty ||
        _roseSelected ||
        _giftSelected;
  }

  Future<void> _sendProfileAction() async {
    // Clear any previous error every time a new attempt starts, and
    // guard against double-taps while a request is already in flight.
    if (_isSending) return;
    setState(() {
      _errorMessage = null;
      _isSending = true;
    });

    final receiverId = widget.profile?.id.trim() ?? '';
    final message = _textController.text.trim();

    final rawType = widget.complimentingType.trim().toUpperCase();
    String? targetType;
    if (rawType == 'PROFILE' ||
        rawType == 'ENTIRE PROFILE' ||
        rawType == 'MATCH' ||
        rawType.isEmpty) {
      targetType = null;
    } else if (rawType == 'VIDEO INTRO' || rawType == 'VIDEO') {
      targetType = 'VIDEO';
    } else if (rawType == 'PHOTO') {
      targetType = 'PHOTO';
    } else if (rawType == 'PROMPT') {
      targetType = 'PROMPT';
    } else {
      targetType = rawType;
    }
    final complimentingID = widget.complimentingID;

    // Safety check: Backend requires targetId for PHOTO/PROMPT.
    // If we don't have it, fallback to Entire Profile.
    if (complimentingID == null || complimentingID.trim().isEmpty) {
      targetType = null;
    }

    debugPrint(
      '🚀 PROFILE ACTION receiverId=$receiverId type=$targetType rose=$_roseSelected gift=$_giftSelected message=$message',
    );
    if (receiverId.isEmpty) {
      debugPrint('❌ receiverId missing');
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
          _isSending = false;
        });
      }
      return;
    }

    // ==========================================================
    // SELECTED ITEMS
    // ==========================================================

    final hasMessage = message.isNotEmpty;
    final hasRose = _roseSelected;
    final hasGift = _giftSelected;

    final selectedCount =
        (hasMessage ? 1 : 0) + (hasRose ? 1 : 0) + (hasGift ? 1 : 0);

    debugPrint('');
    debugPrint('==============================================');
    debugPrint('🚀 PROFILE ACTION');
    debugPrint('==============================================');
    debugPrint('receiverId       = $receiverId');
    debugPrint('targetType       = $targetType');
    debugPrint('targetId         = $complimentingID');
    debugPrint('message          = $message');
    debugPrint('hasMessage       = $hasMessage');
    debugPrint('hasRose          = $hasRose');
    debugPrint('hasGift          = $hasGift');
    debugPrint('selectedCount    = $selectedCount');
    debugPrint('==============================================');

    if (selectedCount == 0) {
      debugPrint('❌ Nothing selected');
      if (mounted) {
        setState(() {
          _errorMessage = 'Please select compliment, rose or gift';
          _isSending = false;
        });
      }
      return;
    }

    final chatBloc = context.read<ChatBloc>();

    // ==========================================================
    // FIND EXISTING CONVERSATION BEFORE SEND
    // ==========================================================

    ChatUser? preExistingTarget;

    try {
      debugPrint('🔎 Looking for existing conversation before send...');

      chatBloc.add(const LoadChatsEvent());

      final loadedState = await chatBloc.stream
          .firstWhere(
            (state) => state.allChats.any(
              (u) => u.userId == receiverId || u.conversationId == receiverId,
            ),
          )
          .timeout(const Duration(seconds: 5));

      for (final u in loadedState.allChats) {
        if ((u.userId == receiverId || u.conversationId == receiverId) &&
            (u.conversationId ?? '').trim().isNotEmpty) {
          preExistingTarget = u;
          break;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Pre-send conversation lookup failed: $e');

      for (final u in chatBloc.state.allChats) {
        if ((u.userId == receiverId || u.conversationId == receiverId) &&
            (u.conversationId ?? '').trim().isNotEmpty) {
          preExistingTarget = u;
          break;
        }
      }
    }

    debugPrint(
      '🔎 PRE-SEND CONVERSATION = '
      '${preExistingTarget?.conversationId ?? "NONE"}',
    );

    try {
      // ==========================================================
      // API SEND LOGIC
      // ==========================================================
      //
      // 1 item:
      //
      // compliment -> sendCompliment()
      // rose       -> sendRose()
      // gift       -> sendGift()
      //
      // IMPORTANT:
      // SINGLE CASE MEIN KOI SendMessageEvent NAHI HOGA.
      //
      // 2+ items:
      //
      // compliment + gift
      // rose + compliment
      // rose + gift
      // rose + compliment + gift
      //
      //                 ↓
      //        ONLY sendEngagement()
      //
      // Combination ke case mein bhi koi local
      // SendMessageEvent nahi hoga.
      // ==========================================================

      debugPrint('');
      debugPrint('==============================================');
      debugPrint('🚀 SENDING ENGAGEMENT');
      debugPrint('==============================================');

      final r = await ApiService.sendEngagement(
        receiverId: receiverId,
        targetType: targetType,
        targetId: complimentingID,
        includeRose: hasRose,
        complimentMessage: hasMessage ? message : null,
        giftId: hasGift ? (_selectedGiftId ?? 2) : null,
        giftMessage: hasGift ? message : null,
      );

      debugPrint('✨ ENGAGEMENT RESPONSE = $r');

      if (r['success'] != true) {
        throw Exception(r['message'] ?? 'Engagement send failed');
      }

      debugPrint('✅ ENGAGEMENT API SUCCESS');
      await _loadMyBalances();

      // ==========================================================
      // FIND CONVERSATION
      // ==========================================================

      ChatUser? target = preExistingTarget;

      // ==========================================================
      // NEW CONVERSATION
      // ==========================================================

      if (target == null) {
        debugPrint('🆕 Existing conversation not found.');
        debugPrint('🔄 Loading chats after send...');

        chatBloc.add(const LoadChatsEvent());

        try {
          final state = await chatBloc.stream
              .firstWhere(
                (state) => state.allChats.any(
                  (u) =>
                      u.userId == receiverId || u.conversationId == receiverId,
                ),
              )
              .timeout(const Duration(seconds: 8));

          // IMPORTANT: only accept an entry that actually has a
          // conversationId. The chats list can contain a "match/discover"
          // style row for the same userId that has no real conversation
          // yet — grabbing that one instead of the freshly-created
          // conversation is exactly why ChatDetailScreen used to open
          // with the right screen but an empty/wrong message list.
          for (final u in state.allChats) {
            if ((u.userId == receiverId || u.conversationId == receiverId) &&
                (u.conversationId ?? '').trim().isNotEmpty) {
              target = u;
              break;
            }
          }
        } catch (e) {
          debugPrint('⚠️ Post-send lookup failed: $e');

          for (final u in chatBloc.state.allChats) {
            if ((u.userId == receiverId || u.conversationId == receiverId) &&
                (u.conversationId ?? '').trim().isNotEmpty) {
              target = u;
              break;
            }
          }
        }

        // Backend can take a beat to persist the brand-new conversation
        // after the send API call returns. If the first list refresh still
        // doesn't contain it, give it one more short retry before giving up.
        if (target == null) {
          debugPrint('🔁 Conversation still not found, retrying once...');
          await Future<void>.delayed(const Duration(milliseconds: 900));
          chatBloc.add(const LoadChatsEvent());

          try {
            final retryState = await chatBloc.stream
                .firstWhere(
                  (state) => state.allChats.any(
                    (u) =>
                        (u.userId == receiverId ||
                            u.conversationId == receiverId) &&
                        (u.conversationId ?? '').trim().isNotEmpty,
                  ),
                )
                .timeout(const Duration(seconds: 6));

            for (final u in retryState.allChats) {
              if ((u.userId == receiverId || u.conversationId == receiverId) &&
                  (u.conversationId ?? '').trim().isNotEmpty) {
                target = u;
                break;
              }
            }
          } catch (e) {
            debugPrint('⚠️ Retry lookup failed: $e');

            for (final u in chatBloc.state.allChats) {
              if ((u.userId == receiverId || u.conversationId == receiverId) &&
                  (u.conversationId ?? '').trim().isNotEmpty) {
                target = u;
                break;
              }
            }
          }
        }
      }

      // ==========================================================
      // CHECK TARGET
      // ==========================================================

      if (!mounted) {
        return;
      }

      if (target == null) {
        final newConvId =
            r['data']?['conversationId']?.toString() ??
            r['conversationId']?.toString() ??
            receiverId;
        target = ChatUser(
          id: receiverId,
          userId: receiverId,
          conversationId: newConvId,
          name: widget.profile?.name ?? 'Match',
          age: widget.profile?.age ?? 25,
          image: widget.profile?.images.isNotEmpty == true
              ? widget.profile!.images.first
              : '',
          preview: message.isNotEmpty ? message : 'Interaction sent',
          time: 'Just now',
          match: widget.profile?.matchPercentage ?? '0%',
          trust: widget.profile?.trustPercentage ?? '0%',
          online: true,
          unread: 0,
          progress: '0/1',
          reward: 'Gift',
          progressCurrent: 0,
          progressTarget: 0,
          progressPercentage: 0,
          progressLabel: '',
          progressType: '',
          giftName: '',
          progressExpiresAt: DateTime.parse('2026-09-14T09:30:53.592Z'),
        );
      }

      if (target.conversationId == null ||
          target.conversationId!.trim().isEmpty) {
        throw Exception('Conversation ID missing for receiverId=$receiverId');
      }

      final user = target;
      final conversationId = user.conversationId!.trim();

      // ==========================================================
      // JOIN CONVERSATION
      // ==========================================================

      chatBloc.joinConversation(conversationId);

      debugPrint('');
      debugPrint('==============================================');
      debugPrint('🟢 DIRECT CHAT DETAIL');
      debugPrint('==============================================');
      debugPrint('Receiver ID : $receiverId');
      debugPrint('User ID     : ${user.userId}');
      debugPrint('Chat ID     : ${user.id}');
      debugPrint('Conversation : $conversationId');
      debugPrint('==============================================');

      // ==========================================================
      // IMPORTANT
      // ==========================================================
      //
      // YAHAN BHI KOI SendMessageEvent NAHI HOGA.
      //
      // SINGLE:
      // API → Chat Detail
      //
      // COMBINATION:
      // Engagement API → Chat Detail
      //
      // Backend/socket/API se actual message aayega.
      //
      // ❌ No local compliment
      // ❌ No local rose
      // ❌ No local gift
      // ❌ No duplicate messages
      // ==========================================================

      // ==========================================================
      // CLOSE CURRENT PROFILE ACTION
      // ==========================================================

      Navigator.of(context).pop();

      if (!mounted) {
        return;
      }

      final nav = Navigator.of(context);

      // ==========================================================
      // DIRECT CHAT DETAIL
      // ==========================================================

      nav.push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: chatBloc,
            child: ChatDetailScreen(user: user),
          ),
        ),
      );

      debugPrint('✅ ChatDetailScreen opened directly');
    } catch (e, st) {
      debugPrint('');
      debugPrint('==============================================');
      debugPrint('❌ PROFILE ACTION FAILED');
      debugPrint('==============================================');
      debugPrint('receiverId = $receiverId');
      debugPrint('targetType = $targetType');
      debugPrint('message    = $message');
      debugPrint('compliment = $hasMessage');
      debugPrint('rose       = $hasRose');
      debugPrint('gift       = $hasGift');
      debugPrint('count      = $selectedCount');
      debugPrint('ERROR      = $e');
      debugPrint('STACK      = $st');
      debugPrint('==============================================');

      if (mounted) {
        setState(() {
          _errorMessage = 'Send failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding > 0
              ? bottomPadding
              : MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 14.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'COMPLIMENTING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (widget.profileName != null)
                  Row(
                    children: [
                      if (widget.profileImageUrl != null) ...[
                        Container(
                          padding: const EdgeInsets.all(2), // Border width
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              widget.profileImageUrl!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.profileName!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    widget.complimentingType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                const SizedBox(height: 20),

                // Stats Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildStatPill(
                        emoji: '💬',
                        text: _balancesLoading
                            ? '... comments'
                            : '$_commentsBalance comments',
                      ),
                      const SizedBox(width: 8),
                      _buildStatPill(
                        emoji: '🌹',
                        text: _balancesLoading
                            ? '... roses'
                            : '$_rosesBalance roses',
                      ),
                      const SizedBox(width: 8),
                      _buildStatPill(
                        emoji: '🪙',
                        text: _balancesLoading
                            ? '... balance'
                            : '$_walletBalance balance',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Text Input Area
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _focusNode.hasFocus
                        ? Colors.white
                        : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _focusNode.hasFocus ? _primaryColor : _borderGrey,
                      width: _focusNode.hasFocus ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: 4,
                        minLines: 2,
                        maxLength: 140,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write a sweet compliment...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 'Try' Button
                      GestureDetector(
                        onTap: () async {
                          final selectedCompliment =
                              await ComplimentIdeasScreen.show(
                                context,
                                initialText: _textController.text,
                              );
                          if (selectedCompliment != null) {
                            setState(() {
                              _textController.text = selectedCompliment;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFB6C1).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 14,
                                color: _primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Try',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Gift Selection Row — Rose and Gift now toggle
                // independently, so both can be selected together.
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _roseSelected = !_roseSelected;
                          });
                        },
                        child: _buildGiftButton(
                          text: 'Rose',
                          emoji: '🌹',
                          isSelected: _roseSelected,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final selectedGift =
                              await Navigator.push<SelectedGift>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GiftSelectionScreen(
                                    recipientName: widget.profileName,
                                  ),
                                ),
                              );
                          if (!mounted || selectedGift == null) return;
                          setState(() {
                            _giftSelected = true;
                            _selectedGiftId = selectedGift.id;
                            _selectedGiftName = selectedGift.name;
                            _selectedGiftEmoji = selectedGift.emoji;
                            if (selectedGift.message.isNotEmpty) {
                              _textController.text = selectedGift.message;
                              _textController.selection =
                                  TextSelection.collapsed(
                                    offset: _textController.text.length,
                                  );
                            }
                          });
                        },
                        child: _buildGiftButton(
                          text: _selectedGiftName ?? 'Select Gift',
                          emoji: _selectedGiftEmoji ?? '🎁',
                          isSelected: _giftSelected,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_textController.text.length}/140',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ==========================================================
                // INLINE ERROR MESSAGE
                // ==========================================================
                // Rendered as part of the sheet's own layout so it's always
                // visible — never hidden behind the modal overlay the way a
                // ScaffoldMessenger SnackBar would be from inside a bottom
                // sheet context.
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _errorMessage = null),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Bottom Actions
                Row(
                  children: [
                    // Send Button
                    Expanded(
                      child: GestureDetector(
                        onTap: (_canSend && !_isSending)
                            ? _sendProfileAction
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 50,
                          decoration: BoxDecoration(
                            color: (_canSend && !_isSending)
                                ? _primaryColor
                                : _primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: _isSending
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      _buttonText,
                                      key: ValueKey(_buttonText),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill({required String emoji, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _softGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftButton({
    required String text,
    required String emoji,
    required bool isSelected,
  }) {
    // We can't access _primaryColor directly if this was static, but it's an instance method, so we can!
    final primaryPink = const Color(0xFFE43A6A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? primaryPink.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? primaryPink : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? primaryPink : Colors.black87,
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: primaryPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
