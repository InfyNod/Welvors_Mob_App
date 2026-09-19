import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:velvors/welvors_home_screen/ui/chat/ChatVideoPlayer.dart';
import 'package:velvors/welvors_home_screen/ui/chat/RoseTwinkleOverlay.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SuggestionLine.dart';
import 'package:velvors/welvors_home_screen/ui/chat/_FloatingRose.dart';
import 'package:velvors/welvors_home_screen/ui/chat/_SwipeToReply.dart';
import 'package:velvors/welvors_home_screen/ui/chat/sidedrawer.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_now_2/requests_sent/requests_sent_screen.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/send_request_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/chat/RelationshipTagSheet.dart';
import 'package:velvors/welvors_home_screen/ui/chat/YourJourneyScreen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_effects_overlay.dart';
import 'package:velvors/welvors_home_screen/ui/chat/composer_extras_panel.dart';
import 'package:velvors/welvors_home_screen/ui/chat/report_user_dialog.dart';
import 'package:velvors/welvors_home_screen/ui/chat/block_user_dialog.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/event_details.dart';
import 'SocketService.dart';
import 'chat_repository.dart';
import 'chat_bloc/chat_bloc.dart';
import 'chat_bloc/chat_event.dart';
import 'chat_bloc/chat_state.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'custom_camera_screen.dart' as custom_camera;
import 'location_map_screen.dart';
import 'chat_image_pdf_viewer_screen.dart';
import 'chat_media_links_docs_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser user;

  const ChatDetailScreen({super.key, required this.user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

bool _isBlocked = false;

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final TextEditingController _unmatchNoteController = TextEditingController();
  late TabController _tabController;
  final GlobalKey _textFieldKey = GlobalKey();

  bool _notificationsEnabled = true;
  bool _muteNotificationLoading = false;
  int _getLineCount() {
    final context = _textFieldKey.currentContext;

    if (context == null) {
      return 1;
    }

    final renderBox = context.findRenderObject();

    if (renderBox is! RenderBox) {
      return 1;
    }

    final height = renderBox.size.height;

    // TextField ka approx single-line height
    const double singleLineHeight = 48.0;

    if (height <= singleLineHeight + 5) {
      return 1;
    }

    final double extraHeight = height - singleLineHeight;

    final int lines = 1 + (extraHeight / 24).round();

    return lines.clamp(1, 6);
  }

  bool textIsEmpty(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  final scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  final FocusNode _messageFocusNode = FocusNode();

  ChatMessage? _replyingTo;

  // Live status for the other participant. This must be mutable UI state;
  // _isUserOnline is immutable and therefore cannot refresh on socket events.
  late bool _isUserOnline;
  bool _isUnmatched = false;

  // Live, dynamic profile/user details for this conversation. Loaded once
  // via REST (GET /api/user/chat/{conversationId}/details) on open, then
  // kept in sync in real time by the "profile:details" socket event.
  // Everything shown in the header (name/age/photo/online/package/blocked)
  // reads from here first and falls back to `widget.user` only until the
  // first fetch/event lands.
  ConversationProfileDetails? _profileDetails;

  String get _liveName => (_profileDetails?.name.trim().isNotEmpty ?? false)
      ? _profileDetails!.name
      : widget.user.name;

  int get _liveAge => _profileDetails?.age ?? widget.user.age;
  String? get _liveuserId => _profileDetails?.userId.toString();

  String get _liveImage =>
      (_profileDetails?.profileImage.trim().isNotEmpty ?? false)
      ? _profileDetails!.profileImage
      : widget.user.image;

  String get _livePackageType => _profileDetails?.packageType ?? 'FREE';

  num get _liveMatchScore => _profileDetails?.matchScore ?? 0;

  // Top banner alternates between "Gift Unlock Progress" and
  // "Relationship Progress" every few seconds.
  int _bannerIndex = 0;
  Timer? _bannerRotationTimer;

  // Voice recording / playback
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  DateTime? _recordingStartedAt;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  String? _playingAudioPath;
  bool _isAudioPlaying = false;

  // Keeps a key for every rendered message so reply quotes can jump to the original.
  final Map<String, GlobalKey> _messageKeys = {};

  int tab = 0;
  bool _loadingOlderMessages = false;
  String? _lastRequestedOlderCursor;
  Timer? _olderMessagesTimeout;
  final Set<String> _readMessageIds = <String>{};

  // IMPORTANT: messages are stored by conversationId, never by the other
  // user's id. This prevents one conversation from displaying another.
  String get _messageKey {
    final id = (widget.user.conversationId ?? '').trim();
    return id.isNotEmpty ? id : widget.user.id;
  }

  // True when this is the built-in "Card Showcase" thread
  // (ChatRepository.demoAllCardsUser) used to preview every card type.
  // bool get _isDemoThread => _messageKey == ChatRepository.demoAllCardsUserId;

  // Emoji / Stickers / Meme & Fun / Effects / GIF / Gifts panel
  bool _showExtrasPanel = false;
  int _extrasInitialTab = 0;

  void _toggleExtrasPanel() {
    _messageFocusNode.unfocus();
    setState(() {
      _showExtrasPanel = !_showExtrasPanel;
      if (_showExtrasPanel) _extrasInitialTab = 0;
    });
  }

  void _openGiftPanel() {
    _messageFocusNode.unfocus();
    setState(() {
      _showExtrasPanel = true;
      _extrasInitialTab = 5;
    });
  }

  void _closeExtrasPanel() {
    if (_showExtrasPanel) {
      setState(() => _showExtrasPanel = false);
    }
  }

  void joinConversation(String conversationId) {
    if (conversationId.isEmpty) {
      debugPrint('❌ CONVERSATION ID IS EMPTY');
      return;
    }

    debugPrint('🚪 Joining conversation: $conversationId');

    _socketService.emit('conversation:join', {
      'conversationId': conversationId,
    });

    _socketService.emit('profile:details', {'conversationId': conversationId});

    debugPrint('✅ conversation:join emitted');
  }

  Timer? _typingTimer;
  bool _isTyping = false;
  void _onTypingChanged(String value) {
    final conversationId = widget.user.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      debugPrint('❌ TYPING: conversationId is missing');
      return;
    }

    // Text empty => immediately stop typing
    if (value.trim().isEmpty) {
      _typingTimer?.cancel();

      if (_isTyping) {
        _isTyping = false;

        debugPrint('🛑 typing:stop');

        _socketService.emit('typing:stop', {'conversationId': conversationId});
      }

      return;
    }

    // First character => typing:start
    if (!_isTyping) {
      _isTyping = true;

      debugPrint('⌨️ typing:start');

      _socketService.emit('typing:start', {'conversationId': conversationId});
    }

    // User is still typing, reset timer
    _typingTimer?.cancel();

    _typingTimer = Timer(const Duration(seconds: 6), () {
      if (!_isTyping) return;

      _isTyping = false;

      debugPrint('🛑 typing:stop');

      _socketService.emit('typing:stop', {'conversationId': conversationId});
    });
  }

  void _insertEmoji(String emoji) {
    final text = controller.text;
    final selection = controller.selection;
    final cursor = selection.start >= 0 ? selection.start : text.length;

    final newText = text.replaceRange(cursor, cursor, emoji);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + emoji.length),
    );
    setState(() {});
  }

  void _sendQuickText(String text) {
    final reply = _replyingTo;
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        conversationId: widget.user.conversationId,
        type: ChatMessageType.text,
        message: text,
        typemsg: "Text",
        replyToId: reply?.id,
        replyText: reply?.text,
        replyImageUrl: reply?.imageUrl,
        replyFileUrl: reply?.fileUrl,
        replyType: reply?.type,
      ),
    );
    setState(() => _replyingTo = null);
    _scrollToBottom();
  }

  void _onStickerSelected(String emoji) {
    _sendQuickText(emoji);
    _toast('Sticker sent ✓');
  }

  void _onMemeSelected(String emoji, String label) {
    _sendQuickText('$emoji $label');
    _toast('Sent ✓');
  }

  void _onEffectSelected(String emoji, String label) {
    _playEffectAnimation(emoji, label);
    _sendEffectMessage(emoji, label);
    _toast('$label sent ✓');
  }

  void _playEffectAnimation(String emoji, String label) {
    EffectRainOverlay.play(
      context,
      emoji: emoji,
      count: 22,
      burstFromCenter: label == 'Love Burst' || label == 'Fireworks',
    );
  }

  void _sendEffectMessage(String emoji, String label) {
    final reply = _replyingTo;
    debugPrint(
      '💫 Sending effect message: $label ($emoji)>>>>>>${ChatMessageType.effect}',
    );
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        conversationId: widget.user.conversationId,
        type: ChatMessageType.effect,
        message: label,
        typemsg: emoji,

        giftEmoji: emoji,
        giftName: label,
        replyToId: reply?.id,
        replyText: reply?.text,
        replyImageUrl: reply?.imageUrl,
        replyFileUrl: reply?.fileUrl,
        replyType: reply?.type,
      ),
    );
    setState(() => _replyingTo = null);
    _scrollToBottom();
  }

  void _onGifSelected(String label, String category) {
    _sendAttachment(
      type: ChatMessageType.image,
      text: '',
      imageUrl:
          'https://placehold.co/320x220?text=${Uri.encodeComponent(label)}',
    );
    _toast('GIF sent ✓');
  }

  void _onGiftItemSelected(GiftItem gift) {
    debugPrint('🎁 GIFT SELECTED');
    debugPrint('🎁 giftId => ${gift.id}');
    debugPrint('🎁 giftName => ${gift.name}');
    debugPrint('🎁 giftEmoji => ${gift.emoji}');
    debugPrint('🎁 giftCoins => ${gift.coins}');
    debugPrint('🎁 giftImage => ${gift.image}');

    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        conversationId: widget.user.conversationId,

        // ==========================================================
        // GIFT
        // ==========================================================
        type: ChatMessageType.gift,

        message: gift.name + gift.emoji,

        giftId: gift.id > 0
            ? gift.id.toString()
            : 'gift_${DateTime.now().millisecondsSinceEpoch}',

        giftName: gift.name,

        giftEmoji: gift.emoji.isEmpty ? '🎁' : gift.emoji,

        // Keep coins on the optimistic message so a partial socket echo
        // can never reset the gift card to null/0.
        giftCoins: gift.coins > 0 ? gift.coins.toString() : null,
        giftClaimed: false,

        messageProgress: 1,
        messageTarget: 25,
        expiresIn: '7d',

        typemsg: "",

        imageUrl: gift.image,
      ),
    );

    _showExtrasPanel = false;

    _scrollToBottom();

    _toast('${gift.name} sent ✓');
  }

  void _markMessagesAsRead() {
    final bloc = context.read<ChatBloc>();
    final messages = bloc.state.messages[_messageKey] ?? const <ChatMessage>[];

    for (final message in messages) {
      // Only mark the other participant's messages as read.
      if (message.isMine || message.id.isEmpty) continue;
      if (_readMessageIds.contains(message.id)) continue;

      _readMessageIds.add(message.id);
      _socketService.markMessageAsRead(message.id);
      debugPrint('📖 message:read EMIT => messageId: ${message.id}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getMuteNotificationStatus();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    tab = 0;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      if (tab != _tabController.index) {
        setState(() {
          tab = _tabController.index;
        });

        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }

        _initialScrollDone = true;
      }
    });

    // _tabController.addListener(() {
    //   if (!_tabController.indexIsChanging) {
    //     context.read<AdmirersBloc>().add(
    //       ChangeAdmirersTab(_tabKeys[_tabController.index]),
    //     );
    //   }
    // });
    scrollController.addListener(() {
      if (scrollController.position.pixels > 20 && !_hideBanner) {
        setState(() {
          _hideBanner = true;
        });
      } else if (scrollController.position.pixels <= 20 && _hideBanner) {
        setState(() {
          _hideBanner = false;
        });
      }
    });

    _isUserOnline = widget.user.online;

    scrollController.addListener(_handleMessageScroll);

    final conversationId = widget.user.conversationId?.trim() ?? '';

    debugPrint('');
    debugPrint('==============================================');
    debugPrint('🟢 CHAT DETAIL INIT');
    debugPrint('==============================================');
    debugPrint('chatId         = ${widget.user.id}');
    debugPrint('userId         = ${widget.user.userId}');
    debugPrint('conversationId = $conversationId');
    debugPrint('==============================================');

    // ==========================================================
    // SOCKET JOIN
    // ==========================================================

    if (conversationId.isNotEmpty) {
      joinConversation(conversationId);
    } else {
      debugPrint('❌ CHAT DETAIL: conversationId is NULL/EMPTY');
    }

    // ==========================================================
    // SOCKET LISTENERS
    // ==========================================================

    _registerMessageReceiveListener();
    _registerOnlineStatusListeners();
    _registerProfileDetailsListener();

    // ==========================================================
    // PROFILE DETAILS
    // ==========================================================

    if (conversationId.isNotEmpty) {
      _loadConversationUserDetails(conversationId);
    }

    // ==========================================================
    // MESSAGE LOAD
    // ==========================================================

    if (conversationId.isNotEmpty) {
      _loadChatMessages(conversationId: conversationId);
    } else {
      debugPrint(
        '⚠️ CHAT DETAIL: missing conversationId; '
        'using legacy chat id',
      );

      final chatBloc = context.read<ChatBloc>();

      if (!chatBloc.isClosed) {
        chatBloc.add(LoadMessagesEvent(widget.user.id));
      }
    }

    // ==========================================================
    // BANNER TIMER
    // ==========================================================

    _bannerRotationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;

      setState(() {
        _bannerIndex = _bannerIndex == 0 ? 1 : 0;
      });
    });
  }
  // ============================================================
  // ONLINE / OFFLINE SOCKET
  // ============================================================

  void _registerOnlineStatusListeners() {
    _socketService.offListener('user:online', _onUserOnline);
    _socketService.offListener('user:offline', _onUserOffline);

    _socketService.on('user:online', _onUserOnline);
    _socketService.on('user:offline', _onUserOffline);

    debugPrint('🟢 CHAT DETAIL: user:online listener registered');
    debugPrint('🟢 CHAT DETAIL: user:offline listener registered');
  }

  Future<void> _loadChatMessages({required String conversationId}) async {
    final id = conversationId.trim();

    if (id.isEmpty) {
      debugPrint('❌ _loadChatMessages: conversationId empty');
      return;
    }

    if (!mounted) return;

    final bloc = context.read<ChatBloc>();

    if (bloc.isClosed) {
      debugPrint('❌ _loadChatMessages: ChatBloc already closed');
      return;
    }

    debugPrint('');
    debugPrint('==============================================');
    debugPrint('📥 LOAD CHAT MESSAGES');
    debugPrint('==============================================');
    debugPrint('conversationId = $id');
    debugPrint('chatId         = ${widget.user.id}');
    debugPrint('==============================================');

    // ----------------------------------------------------------
    // FIRST LOAD
    // ----------------------------------------------------------

    bloc.add(LoadMessagesEvent(widget.user.id, conversationId: id));

    // ----------------------------------------------------------
    // RETRY #1
    // ----------------------------------------------------------

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted || bloc.isClosed) return;

    var messages = bloc.state.messages[id];

    debugPrint(
      '📥 FIRST LOAD RESULT: '
      '${messages?.length ?? 0} messages',
    );

    if (messages != null && messages.isNotEmpty) {
      return;
    }

    debugPrint('🔁 Message list empty. Retry #1...');

    bloc.add(LoadMessagesEvent(widget.user.id, conversationId: id));

    // ----------------------------------------------------------
    // RETRY #2
    // ----------------------------------------------------------

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted || bloc.isClosed) return;

    messages = bloc.state.messages[id];

    if (messages != null && messages.isNotEmpty) {
      return;
    }
    bloc.add(LoadMessagesEvent(widget.user.id, conversationId: id));
  }

  String? _extractOnlineUserId(dynamic data) {
    if (data is Map) {
      final value = data['userId'] ?? data['id'];
      if (value != null && value.toString().isNotEmpty) return value.toString();

      final nested = data['data'];
      if (nested is Map) {
        final nestedValue = nested['userId'] ?? nested['id'];
        if (nestedValue != null && nestedValue.toString().isNotEmpty) {
          return nestedValue.toString();
        }
      }
    }
    return null;
  }

  void _onUserOnline(dynamic data) {
    final userId = _extractOnlineUserId(data);
    debugPrint('🟢 CHAT DETAIL user:online => $data | userId=$userId');
    if (!mounted || userId != widget.user.userId) return;

    setState(() {
      _isUserOnline = true;
    });
  }

  void _onUserOffline(dynamic data) {
    final userId = _extractOnlineUserId(data);
    debugPrint('🔴 CHAT DETAIL user:offline => $data | userId=$userId');
    if (!mounted || userId != widget.user.userId) return;

    setState(() {
      _isUserOnline = false;
    });
  }

  // ============================================================
  // CONVERSATION USER (PROFILE) DETAILS
  //
  // REST  : GET /api/user/chat/{conversationId}/details
  // SOCKET: "profile:details" (same shape, pushed in real time)
  // ============================================================

  Future<void> _loadConversationUserDetails(String conversationId) async {
    try {
      final details = await ChatRepository().fetchConversationUserDetails(
        conversationId,
      );

      debugPrint('👤 CHAT DETAIL: profile details loaded => $details');

      if (!mounted) return;
      if (widget.user.conversationId?.trim() != conversationId.trim()) return;

      setState(() {
        _profileDetails = details;
        _isUserOnline = details.isOnline;
        _isBlocked = details.isBlocked;
      });
    } catch (e) {
      debugPrint('❌ CHAT DETAIL: failed to load profile details: $e');
    }
  }

  void _registerProfileDetailsListener() {
    debugPrint('🔥 REGISTERING profile:details LISTENER');

    _socketService.offListener('profile:details', _onProfileDetails);
    _socketService.on('profile:details', (data) {
      debugPrint('🔥🔥🔥 profile:details RAW RECEIVED => $data');

      _onProfileDetails(data);
    });

    debugPrint('✅ profile:details LISTENER REGISTERED');
  }

  void _onProfileDetails(dynamic data) {
    debugPrint('🔥 profile:details RAW => $data');
    debugPrint('🔥 profile:details TYPE => ${data.runtimeType}');

    if (!mounted) {
      debugPrint('❌ profile:details ignored: screen not mounted');
      return;
    }

    final payload = _normalizeSocketMap(data);

    debugPrint('🔥 profile:details NORMALIZED => $payload');

    if (payload == null) {
      debugPrint('❌ profile:details payload is NULL');
      return;
    }

    try {
      final details = ConversationProfileDetails.fromJson(payload);

      debugPrint(
        '✅ profile:details PARSED'
        '\n'
        'conversationId = ${details.conversationId}'
        '\n'
        'name = ${details.name}'
        '\n'
        'age = ${details.age}'
        '\n'
        'image = ${details.profileImage}'
        '\n'
        'online = ${details.isOnline}'
        '\n'
        'blocked = ${details.isBlocked}',
      );

      final currentConversationId = widget.user.conversationId?.trim() ?? '';

      final eventConversationId = details.conversationId.trim();

      debugPrint('🔎 CURRENT conversationId = $currentConversationId');

      debugPrint('🔎 EVENT conversationId = $eventConversationId');

      if (eventConversationId.isNotEmpty &&
          currentConversationId.isNotEmpty &&
          eventConversationId != currentConversationId) {
        debugPrint('❌ profile:details ignored because conversationId differs');
        return;
      }

      setState(() {
        _profileDetails = details;
        _isUserOnline = details.isOnline;
        _isBlocked = details.isBlocked;
      });

      debugPrint('✅ profile:details UI UPDATED');
    } catch (e, stackTrace) {
      debugPrint('❌ profile:details PARSE ERROR => $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // MESSAGE RECEIVE SOCKET
  // ============================================================

  void _registerMessageReceiveListener() {
    // IMPORTANT: SocketService is a singleton shared with ChatBloc.
    // Never call off('message:receive') here because that removes the
    // ChatBloc's chat-list listener as well. Only this screen's callback
    // is removed in dispose().
    _socketService.on('message:receive', _onMessageReceive);

    debugPrint('🟢 CHAT DETAIL: message:receive listener registered');
    debugPrint('🟢 CHAT DETAIL: conversationId=${widget.user.conversationId}');
  }

  void _onMessageReceive(dynamic data) {
    debugPrint('📩 CHAT DETAIL: message:receive RECEIVED => $data');

    if (!mounted) return;

    final payload = _normalizeSocketMap(data);
    if (payload == null) {
      debugPrint('❌ CHAT DETAIL: message:receive invalid payload');
      return;
    }

    final receivedConversationId = _extractConversationId(payload);
    final currentConversationId = widget.user.conversationId?.trim();

    debugPrint('📩 RECEIVED conversationId => $receivedConversationId');
    debugPrint('📩 CURRENT conversationId => $currentConversationId');

    // If backend sends a conversation id, it MUST match this screen.
    if (receivedConversationId != null &&
        receivedConversationId.isNotEmpty &&
        currentConversationId != null &&
        currentConversationId.isNotEmpty &&
        receivedConversationId != currentConversationId) {
      debugPrint(
        'ℹ️ CHAT DETAIL: message:receive ignored - different conversation',
      );
      return;
    }

    // If there is no conversation id in the event, don't blindly inject it
    // into an open chat. This prevents cross-conversation messages.
    if ((receivedConversationId == null || receivedConversationId.isEmpty) &&
        (currentConversationId == null || currentConversationId.isEmpty)) {
      debugPrint(
        '⚠️ CHAT DETAIL: message:receive ignored - conversationId missing',
      );
      return;
    }

    // Some socket payloads omit conversationId after the envelope is unwrapped.
    // This screen is already scoped to one conversation, so attach that id before
    // handing the event to ChatBloc. ChatBloc then stores it in the correct bucket.
    if ((payload['conversationId'] ?? payload['conversation_id']) == null &&
        currentConversationId != null &&
        currentConversationId.isNotEmpty) {
      payload['conversationId'] = currentConversationId;
    }

    context.read<ChatBloc>().add(
      IncomingMessageEvent(chatId: widget.user.id, payload: payload),
    );

    debugPrint(
      '✅ CHAT DETAIL: IncomingMessageEvent added for ${widget.user.id}',
    );

    // Keep the latest received message visible when the user is already
    // near the bottom of the reversed ListView.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToBottom();
      }
    });
  }

  Map<String, dynamic>? _normalizeSocketMap(dynamic data) {
    dynamic value = data;

    // Socket.IO can deliver [payload, socketId].
    if (value is List) {
      if (value.isEmpty) return null;
      value = value.first;
    }

    // Unwrap common {data: ...} / {message: ...} envelopes.
    for (int i = 0; i < 4; i++) {
      if (value is! Map) return null;

      final map = Map<String, dynamic>.from(value);

      if (map['message'] is Map) {
        // Keep conversationId from the outer envelope when message itself
        // doesn't contain it.
        final inner = Map<String, dynamic>.from(map['message'] as Map);
        if (inner['conversationId'] == null &&
            inner['conversation_id'] == null) {
          if (map['conversationId'] != null) {
            inner['conversationId'] = map['conversationId'];
          } else if (map['conversation_id'] != null) {
            inner['conversationId'] = map['conversation_id'];
          }
        }
        value = inner;
        continue;
      }

      if (map['data'] is Map) {
        final inner = Map<String, dynamic>.from(map['data'] as Map);
        if (inner['conversationId'] == null &&
            inner['conversation_id'] == null) {
          if (map['conversationId'] != null) {
            inner['conversationId'] = map['conversationId'];
          } else if (map['conversation_id'] != null) {
            inner['conversation_id'] = map['conversation_id'];
          }
        }
        value = inner;
        continue;
      }

      return map;
    }

    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  String? _extractConversationId(Map<String, dynamic> payload) {
    dynamic value = payload;

    for (int i = 0; i < 3; i++) {
      if (value is! Map) return null;
      final map = Map<String, dynamic>.from(value);

      if (map['conversationId'] != null) {
        return map['conversationId'].toString();
      }
      if (map['conversation_id'] != null) {
        return map['conversation_id'].toString();
      }

      if (map['message'] is Map) {
        value = map['message'];
      } else if (map['data'] is Map) {
        value = map['data'];
      } else {
        break;
      }
    }

    return null;
  }

  void _handleMessageScroll() {
    if (!mounted || !scrollController.hasClients) return;

    final position = scrollController.position;

    // reverse:true:
    //   pixels == 0                 -> latest/bottom
    //   pixels ~= maxScrollExtent   -> oldest/top
    //
    // When the user reaches the visual TOP, request the next cursor page.
    final distanceFromTop = position.maxScrollExtent - position.pixels;

    if (distanceFromTop > 120) return;

    final bloc = context.read<ChatBloc>();
    final cursor = bloc.state.messageNextCursor[_messageKey];
    final hasMore = bloc.state.messageHasMore[_messageKey] ?? false;

    debugPrint(
      '🔼 CHAT TOP REACHED | pixels=${position.pixels} '
      'max=${position.maxScrollExtent} distance=$distanceFromTop '
      'hasMore=$hasMore cursor=$cursor '
      'loading=$_loadingOlderMessages',
    );

    if (!hasMore || cursor == null || cursor.trim().isEmpty) {
      debugPrint('⛔ NO OLDER PAGE | hasMore=$hasMore cursor=$cursor');
      return;
    }

    // Do not request the same cursor twice while its response is pending.
    if (_loadingOlderMessages && _lastRequestedOlderCursor == cursor) {
      return;
    }

    if (_lastRequestedOlderCursor == cursor && _loadingOlderMessages) {
      return;
    }

    _loadingOlderMessages = true;
    _lastRequestedOlderCursor = cursor;

    // Force a rebuild now (BLoC only emits once the page arrives) so the
    // bottom-of-list loader appears immediately while the older page loads.
    if (mounted) setState(() {});

    // Safety net: if the request errors out silently (no BLoC emit), don't
    // leave the loader spinning forever — unlock after a timeout so the
    // user can retry by scrolling again.
    _olderMessagesTimeout?.cancel();
    _olderMessagesTimeout = Timer(const Duration(seconds: 12), () {
      if (!mounted || !_loadingOlderMessages) return;
      debugPrint('⏱️ OLDER PAGE TIMEOUT | cursor=$_lastRequestedOlderCursor');
      setState(() {
        _loadingOlderMessages = false;
        _lastRequestedOlderCursor = null;
      });
    });

    debugPrint('🚀 LOAD OLDER CHAT | cursor=$cursor');

    bloc.add(
      LoadMessagesEvent(
        widget.user.id,
        conversationId: widget.user.conversationId,
        cursor: cursor,
      ),
    );
  }

  void _onOlderMessagesStateChanged(ChatState state) {
    final currentCursor = state.messageNextCursor[_messageKey];

    // Unlock when the BLoC has processed the requested cursor and produced
    // a new nextCursor. This also unlocks when the server reaches the end.
    if (_loadingOlderMessages && currentCursor != _lastRequestedOlderCursor) {
      debugPrint('✅ OLDER PAGE COMPLETE | nextCursor=$currentCursor');
      _olderMessagesTimeout?.cancel();
      _loadingOlderMessages = false;
      _lastRequestedOlderCursor = null;
      if (mounted) setState(() {});
    }
  }

  bool _onMessageScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    // ScrollUpdateNotification is the important one for finger scrolling.
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification ||
        notification is UserScrollNotification) {
      _handleMessageScroll();
    }

    return false;
  }

  @override
  void dispose() {
    // Remove only this screen's listener. Do NOT remove the global
    // ChatBloc message:receive listener.
    _socketService.offListener('message:receive', _onMessageReceive);
    _socketService.offListener('user:online', _onUserOnline);
    _socketService.offListener('user:offline', _onUserOffline);
    _socketService.offListener('profile:details', _onProfileDetails);

    _typingTimer?.cancel();

    if (_isTyping) {
      final conversationId = widget.user.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        _socketService.emit('typing:stop', {'conversationId': conversationId});
      }
      _isTyping = false;
    }

    _recordingTimer?.cancel();
    _bannerRotationTimer?.cancel();
    _olderMessagesTimeout?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    controller.dispose();
    scrollController.removeListener(_handleMessageScroll);
    scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    _closeExtrasPanel();
    try {
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        _toast('Microphone permission is required');
        return;
      }

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      if (!mounted) return;

      _recordingStartedAt = DateTime.now();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _recordingStartedAt == null) return;
        setState(() {
          _recordingDuration = DateTime.now().difference(_recordingStartedAt!);
        });
      });
    } catch (e, stackTrace) {
      debugPrint('START RECORDING ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      _toast('Unable to start recording');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final path = await _audioRecorder.stop();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });

      if (path == null || path.isEmpty) return;

      final file = File(path);
      if (!await file.exists()) {
        _toast('Audio file not found');
        return;
      }

      final size = await file.length();

      _sendAttachment(
        type: ChatMessageType.audio,
        text: '',
        filePath: path,
        audioUrl: path,
        fileName: 'Voice message',
        fileSize: _formatFileSize(size),
      );

      _toast('Voice message sent ✓');
    } catch (e, stackTrace) {
      debugPrint('STOP RECORDING ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingDuration = Duration.zero;
        });
      }
      _toast('Unable to send voice message');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final path = await _audioRecorder.stop();
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      debugPrint('CANCEL RECORDING ERROR: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
    }
  }

  Future<void> _toggleAudio(ChatMessage message) async {
    final path = message.audioUrl ?? message.fileUrl;
    if (path == null || path.isEmpty) {
      _toast('Audio unavailable');
      return;
    }

    try {
      if (_playingAudioPath == path && _isAudioPlaying) {
        await _audioPlayer.pause();
        if (!mounted) return;
        setState(() => _isAudioPlaying = false);
        return;
      }

      await _audioPlayer.stop();

      if (path.startsWith('http://') || path.startsWith('https://')) {
        await _audioPlayer.play(UrlSource(path));
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }

      if (!mounted) return;
      setState(() {
        _playingAudioPath = path;
        _isAudioPlaying = true;
      });
    } catch (e, stackTrace) {
      debugPrint('AUDIO PLAY ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      _toast('Unable to play audio');
    }
  }

  String _recordingTime() {
    final seconds = _recordingDuration.inSeconds;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  ChatMessageType getMessageTypeForTab(int tab) {
    switch (tab) {
      case 1:
        return ChatMessageType.gift;

      case 2:
        return ChatMessageType.compliment;

      case 3:
        return ChatMessageType.dateInvite;

      default:
        return ChatMessageType.text;
    }
  }

  void _sendText() {
    final text = controller.text.trim();
    final type = getMessageTypeForTab(tab);

    if (text.isEmpty) return;

    final reply = _replyingTo;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        conversationId: widget.user.conversationId,
        type: type,
        message: text,
        typemsg: "Text",
        replyToId: reply?.id,
        replyText: reply?.text,
        replyImageUrl: reply?.imageUrl,
        replyFileUrl: reply?.fileUrl,
        replyType: reply?.type,
        inviteStatus: "PENDING",
      ),
    );

    controller.clear();

    setState(() {
      _replyingTo = null;
    });

    _scrollToBottom();
  }

  void _startReply(ChatMessage message) {
    setState(() {
      _replyingTo = message;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _messageFocusNode.requestFocus();
      }
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppText.body.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkChip,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      ),
    );
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!scrollController.hasClients) return;

      // reverse:true => offset 0 is always the latest/bottom position.
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  GlobalKey _keyForMessage(String id) {
    return _messageKeys.putIfAbsent(id, GlobalKey.new);
  }

  num _estimatedMessageHeight(ChatMessage message) {
    switch (message.type) {
      case ChatMessageType.effect:
      case ChatMessageType.image:
        return 430;
      case ChatMessageType.audio:
      case ChatMessageType.document:
      case ChatMessageType.location:
      case ChatMessageType.contact:
      case ChatMessageType.gift:
      case ChatMessageType.RELATIONSHIP_TAG_PROPOSAL:
      case ChatMessageType.RELATIONSHIP_TAG_ACCEPTED:
      case ChatMessageType.rose:
      case ChatMessageType.ENGAGEMENT:
      case ChatMessageType.compliment:
      case ChatMessageType.dateInvite:
      case ChatMessageType.DATECONFIRMED:
      case ChatMessageType.video:
        return 140;
      case ChatMessageType.eventInvite:
        return 420;
      case ChatMessageType.text:
        if (message.typemsg == 'Effect') {
          return 100;
        }
        final lines = (message.text.length / 42).ceil().clamp(1, 6);
        final replyExtra = message.replyToId != null ? 70 : 0;
        return 65 + (lines * 22) + replyExtra;
    }
  }

  Future<void> _scrollToMessage(String? messageId) async {
    if (messageId == null || messageId.isEmpty) return;

    final targetContext = _messageKeys[messageId]?.currentContext;

    // Exact scroll when the original message is currently mounted.
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.35,
      );
      return;
    }

    final messages =
        context.read<ChatBloc>().state.messages[_messageKey] ??
        const <ChatMessage>[];

    final filtered = messages.where((m) {
      switch (tab) {
        case 1:
          return m.type == ChatMessageType.gift ||
              m.type == ChatMessageType.rose;
        case 2:
          return m.type == ChatMessageType.compliment;
        case 3:
          return m.type == ChatMessageType.dateInvite ||
              m.type == ChatMessageType.eventInvite;
        default:
          return true;
      }
    }).toList();

    final index = filtered.indexWhere((m) => m.id == messageId);
    if (index < 0 || !scrollController.hasClients) return;

    // ListView.builder only mounts visible children. Move approximately near
    // the target first; after the next frame the target key becomes mounted.
    double estimatedOffset = 14;
    for (int i = 0; i < index; i++) {
      estimatedOffset += _estimatedMessageHeight(filtered[i]);
    }

    final max = scrollController.position.maxScrollExtent;
    estimatedOffset = estimatedOffset.clamp(0.0, max).toDouble();

    await scrollController.animateTo(
      estimatedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final contextForTarget = _messageKeys[messageId]?.currentContext;
      if (contextForTarget == null) return;

      Scrollable.ensureVisible(
        contextForTarget,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.35,
      );
    });
  }

  bool _hideBanner = false;
  bool _initialScrollDone = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.messages[_messageKey] != current.messages[_messageKey] ||
          previous.chatAction != current.chatAction,
      listener: (context, state) {
        if (!mounted) return;

        if (state.chatAction == 'deleted') {
          Navigator.of(context).pop();
          return;
        }

        if (state.chatAction == 'cleared') {
          _toast('Chat cleared successfully');
          return;
        }

        if (state.chatAction == 'delete_error') {
          _toast(state.chatActionError ?? 'Unable to delete chat');
          return;
        }

        if (state.chatAction == 'clear_error') {
          _toast(state.chatActionError ?? 'Unable to clear chat');
          return;
        }

        _markMessagesAsRead();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          //   child: InkWell(
          //     onTap: () => Navigator.pop(context),
          //     borderRadius: BorderRadius.circular(24),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         shape: BoxShape.circle,
          //         border: Border.all(color: Colors.grey.shade200),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.04),
          //             blurRadius: 4,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.arrow_back_ios_new,
          //         color: Colors.black87,
          //         size: 16,
          //       ),
          //     ),
          //   ),
          // ),
          titleSpacing: 0,

          title: Row(
            children: [
              wSized15,
              _avatar(
                _liveImage,
                size: 48,
                name: _liveName,
                age: _liveAge.toString(),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _liveAge > 0 ? '$_liveName, $_liveAge' : _liveName,
                            style: AppText.h2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        _badge(
                          // _isDemoThread
                          //     ? 'DEMO'
                          //     :
                          _livePackageType.toUpperCase(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _isUserOnline
                                ? AppColors.green
                                : AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isUserOnline ? 'Online' : 'Offline',
                          style: AppText.body.copyWith(
                            color: _isUserOnline
                                ? AppColors.green
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            // _circleButton(Icons.phone_outlined, () {}),
            // _circleButton(Icons.videocam_outlined, () {}),
            IconButton(
              onPressed: () {
                Sidedrawer(
                  context: context,

                  liveImage: _liveImage,
                  liveName: _liveName,
                  liveAge: _liveAge,
                  isUserOnline: _isUserOnline,
                  bannerIndex: _bannerIndex,
                  messageKey: _messageKey,
                  isBlocked: _isBlocked,

                  userName: widget.user.name,

                  conversationId: "d8a02aa0-0f15-4c6a-bb82-5ace6aac183e",

                  avatar: (String image, double size, String name, String age) {
                    return _avatar(image, size: size, name: name, age: age);
                  },

                  giftUnlockProgress: () {
                    return _giftUnlockProgress();
                  },

                  relationshipProgress: () {
                    return _relationshipProgress();
                  },

                  openRelationshipTagSheet: () {
                    _openRelationshipTagSheet(false);
                  },

                  confirmClearChat: () {
                    _confirmClearChat();
                  },

                  confirmDeleteConversation: () {
                    _confirmDeleteConversation();
                  },

                  showReportUserSheet: () {
                    _showReportUserSheet();
                  },

                  showBlockUserSheet: () {
                    _showBlockUserSheet();
                  },

                  openUnmatchSheet: () {
                    _openUnmatchSheet();
                  },
                ).openProfileSheet();
                // _openProfileSheet(_isBlocked);
              },
              icon: const Icon(Icons.more_vert, color: AppColors.ink),
            ),
          ],
        ),

        body: SafeArea(
          child: Column(
            children: [
              _tabs(),
              Expanded(
                child: _isUnmatched
                    ? _unmatchedState()
                    : GestureDetector(
                        onTap: () {
                          if (_showExtrasPanel) {
                            setState(() => _showExtrasPanel = false);
                          }
                        },
                        child: _messageArea(),
                      ),
              ),
              if (_isBlocked)
                _blockedMessage()
              else if (!_isUnmatched)
                _composer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blockedMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(40, 10, 40, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You blocked ${widget.user.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF252525),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'She can’t message you or see your profile.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF99958F),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          GestureDetector(
            onTap: () async {
              await _confirmUnblockUser();
              // _unblockUser(widget.user.userId.toString(), false);
            },
            child: const Text(
              'Unblock',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE83D72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unblockUser(String userId, bool check) async {
    try {
      // The backend exposes the block action at this endpoint.
      // If the backend treats this endpoint as a toggle, calling it again
      // removes the block.
      await ChatRepository().UnblockUser(userId);

      if (!mounted) return;
      setState(() {
        _isBlocked = false;
      });
      _toast('${widget.user.name} unblocked');
      debugPrint("check>>>>>${check}");
      // if (check) {
      //   Navigator.pop(context);
      // }
    } catch (e) {
      debugPrint('❌ UNBLOCK USER ERROR: $e');
      if (mounted) {
        _toast(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // Future<bool> _unblockUser(String userId, bool check) async {
  //   try {
  //     await ChatRepository().UnblockUser(userId);

  //     if (!mounted) return false;

  //     setState(() {
  //       _isBlocked = false;
  //     });

  //     _toast('${widget.user.name} unblocked');

  //     debugPrint("check >>>>> $check");

  //     return false; // ✅ success par false
  //   } catch (e) {
  //     debugPrint('❌ UNBLOCK USER ERROR: $e');

  //     if (mounted) {
  //       _toast(e.toString().replaceFirst('Exception: ', ''));
  //     }

  //     return false; // ❌ error par bhi false
  //   }
  // }
  Widget _giftUnlockProgress() {
    const int repliesSoFar = 14;
    const int repliesNeeded = 25;
    const double progress = repliesSoFar / repliesNeeded;
    final int repliesRemaining = repliesNeeded - repliesSoFar;

    return SizedBox(
      height: 75,
      child: Padding(
        key: const ValueKey('gift_unlock_progress'),
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('GIFT UNLOCK PROGRESS', style: AppText.eyebrow),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Mycolor.pinkffeef2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$repliesSoFar / $repliesNeeded',
                    style: AppText.eyebrow.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: AppColors.soft,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),

            const SizedBox(height: 9),

            Row(
              children: [
                const Text('🎀', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$repliesRemaining more replies to unlock her gift',
                    style: AppText.body.copyWith(color: AppColors.ink60),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _relationshipProgress() {
    return SizedBox(
      height: 75,
      child: Padding(
        key: const ValueKey('relationship_progress'),
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💗', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('RELATIONSHIP PROGRESS', style: AppText.eyebrow),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => YourJourneyScreen(
                          function: () {
                            _openRelationshipTagSheet(true);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'LEVEL 4 ›',
                    style: AppText.eyebrow.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: .72,
                minHeight: 7,
                backgroundColor: AppColors.soft,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),

            const SizedBox(height: 9),

            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last milestone: ',
                  style: AppText.body.copyWith(color: AppColors.ink60),
                ),
                Expanded(
                  child: Text(
                    'Level 3 · First Meet',
                    style: AppText.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unmatchedState() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3EEF8), Color(0xFFFBE9EE)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Unmatched',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You and ${widget.user.name} are no longer matched. This chat has been removed for both of you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Back to messages →',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE85D7D),
                    decoration: TextDecoration.underline,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final ScrollController _tabScrollController = ScrollController();
  final Map<int, GlobalKey> _tabKeys = {};
  int selectedTab = 0;

  // ============================================================
  // TAB BADGE COUNTS
  // ------------------------------------------------------------
  // These used to be hardcoded ('4', '2', '3') so every conversation
  // — including the "Card Showcase" dummy thread — showed the exact
  // same numbers no matter what was actually in the message list.
  // They're now derived live from state.messages[_messageKey], the
  // same grouping used to filter the list below, so the badges stay
  // correct for any thread (real or dummy) and update as new
  // gifts/roses/compliments/invites come in.
  // ============================================================
  String _countLabel(int count) => count > 0 ? '$count' : '';

  final GlobalKey _allTabKey = GlobalKey();
  final GlobalKey _giftsTabKey = GlobalKey();
  final GlobalKey _complimentsTabKey = GlobalKey();
  final GlobalKey _dateInvitesTabKey = GlobalKey();
  void _centerSelectedTab(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_tabScrollController.hasClients) return;

      GlobalKey key;

      switch (index) {
        case 0:
          key = _allTabKey;
          break;
        case 1:
          key = _giftsTabKey;
          break;
        case 2:
          key = _complimentsTabKey;
          break;
        case 3:
          key = _dateInvitesTabKey;
          break;
        default:
          return;
      }

      final context = key.currentContext;

      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }

  Widget _tabs() {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.messages[_messageKey] != current.messages[_messageKey],
      builder: (context, state) {
        final messages = state.messages[_messageKey] ?? const <ChatMessage>[];

        final giftsCount = messages
            .where(
              (m) =>
                  m.type == ChatMessageType.gift ||
                  m.type == ChatMessageType.rose,
            )
            .length;

        final complimentsCount = messages
            .where((m) => m.type == ChatMessageType.compliment)
            .length;

        final dateInvitesCount = messages
            .where(
              (m) =>
                  m.type == ChatMessageType.dateInvite ||
                  m.type == ChatMessageType.eventInvite ||
                  m.type == ChatMessageType.DATECONFIRMED,
            )
            .length;

        return SingleChildScrollView(
          controller: _tabScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tab('💬 All', '', 0),

                const SizedBox(width: 18),

                _tab('🎁 Gifts', _countLabel(giftsCount), 1),

                const SizedBox(width: 18),

                _tab('💖 Compliments', _countLabel(complimentsCount), 2),

                const SizedBox(width: 18),

                _tab('📅 Date Invites', _countLabel(dateInvitesCount), 3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tab(String title, String count, int index) {
    final selected = tab == index;

    final tabKey = _tabKeys.putIfAbsent(index, GlobalKey.new);

    return GestureDetector(
      onTap: () {
        setState(() {
          tab = index;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (scrollController.hasClients) {
            scrollController.jumpTo(0);
          }

          _initialScrollDone = true;

          final tabContext = tabKey.currentContext;

          if (tabContext != null) {
            Scrollable.ensureVisible(
              tabContext,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: 0.5,
            );
          }
        });
      },
      child: KeyedSubtree(
        key: tabKey,
        child: Container(
          padding: const EdgeInsets.only(bottom: 6, top: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFE43A6A) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: AppText.h2.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFFE43A6A) : AppColors.ink60,
                ),
              ),

              if (count.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  count,
                  maxLines: 1,
                  style: AppText.pill.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? const Color(0xFFE43A6A) : AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageArea() {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        final oldCount = previous.messages[_messageKey]?.length ?? 0;
        final newCount = current.messages[_messageKey]?.length ?? 0;
        final cursorChanged =
            previous.messageNextCursor[_messageKey] !=
            current.messageNextCursor[_messageKey];
        return oldCount != newCount || cursorChanged;
      },
      listener: (context, state) {
        _onOlderMessagesStateChanged(state);
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final messages = state.messages[_messageKey] ?? const <ChatMessage>[];

          // Filter messages according to selected tab
          final filtered = messages.where((m) {
            switch (tab) {
              case 1:
                return m.type == ChatMessageType.gift ||
                    m.type == ChatMessageType.rose ||
                    m.type == ChatMessageType.ENGAGEMENT;

              case 2:
                return m.type == ChatMessageType.compliment;

              case 3:
                return m.type == ChatMessageType.dateInvite ||
                    m.type == ChatMessageType.eventInvite;

              default:
                return true;
            }
          }).toList();

          // No messages in selected filter
          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'Nothing here yet',
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            );
          }

          // ============================================================
          // INITIAL OPEN
          // Directly jump to latest message.
          // NO animateTo = NO blink / NO visible scrolling.
          // ============================================================
          if (!_initialScrollDone) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (!scrollController.hasClients) return;

              _initialScrollDone = true;

              scrollController.jumpTo(0);

              // If the first page does not fill the viewport, there may be no
              // physical scroll gesture. Trigger cursor pagination once the
              // frame has settled.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleMessageScroll();
              });
            });
          }

          return NotificationListener<ScrollNotification>(
            onNotification: _onMessageScrollNotification,
            child: ListView.builder(
              controller: scrollController,

              // Messages are sorted newest-first in ChatBloc.
              // reverse:true renders index 0 at the bottom (latest message).
              reverse: true,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              itemCount:
                  filtered.length +
                  (_isBlocked ? 1 : 0) +
                  (_loadingOlderMessages ? 1 : 0),
              itemBuilder: (context, index) {
                // Oldest end of the list (last index, reverse:true renders
                // it at the visual top) — pagination loader while the next
                // older page is being fetched.
                if (_loadingOlderMessages &&
                    index == filtered.length + (_isBlocked ? 1 : 0)) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }

                if (_isBlocked && index == filtered.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox.shrink(),
                  );
                }

                final message = filtered[index];

                return Container(
                  key: _keyForMessage(message.id),
                  child: SwipeToReply(
                    onDelete: () {},
                    onReply: () => _startReply(message),
                    child: _messageCardWithDelete(message),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    if (!message.isMine || message.id.isEmpty) return;

    const accentColor = Color(0xFFD6336C);
    final shouldDelete = await await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
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
                'Delete message',
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
                'This message will be removed from your chat.',
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
                    'Delete Message',
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
              // SizedBox(
              //   width: double.infinity,
              //   height: 52,
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.pop(dialogContext, false),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color.fromARGB(255, 228, 224, 224),
              //       foregroundColor: Colors.black,
              //       elevation: 0,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(14),
              //       ),
              //     ),
              //     child: const Text(
              //       'Cancel',
              //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete != true || !mounted) return;

    context.read<ChatBloc>().add(
      DeleteMessageEvent(
        chatId: widget.user.conversationId.toString(),
        messageId: message.id,
      ),
    );
  }

  Widget _messageCardWithDelete(ChatMessage message) {
    final card = _messageCard(message);

    // Delete is intentionally available only for messages sent by us.
    if (!message.isMine) return card;

    return GestureDetector(
      onLongPress: () => {
        debugPrint("message>>>>>>${message.id}"),
        _deleteMessage(message),
      },
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  Widget _messageCard(ChatMessage message) {
    // First handle gift-related messages based on actual gift data.
    if ((message.type == ChatMessageType.ENGAGEMENT) &&
        message.giftId != null) {
      return _engagementBundleCard(message);
    }

    // Handle rose messages.
    if (message.type == ChatMessageType.rose) {
      return _roseCard(message);
    }

    // ENGAGEMENT without gift should be handled as rose/engagement.
    if (message.type == ChatMessageType.ENGAGEMENT) {
      return _roseCard(message);
    }

    switch (message.type) {
      case ChatMessageType.text:
        return _textCard(message);
      case ChatMessageType.effect:
        return _effectCard(message);

      case ChatMessageType.image:
        return _imageCard(message);

      case ChatMessageType.video:
        return _videoCard(message);

      case ChatMessageType.audio:
        return _audioCard(message);

      case ChatMessageType.document:
        return _documentCard(message);

      case ChatMessageType.location:
        return _locationCard(message);

      case ChatMessageType.contact:
        return _contactCard(message);

      case ChatMessageType.gift:
        // giftId null hone par fallback
        return _giftCard(message);

      case ChatMessageType.ENGAGEMENT:
        // giftId null hone par engagement/rose fallback
        return _roseCard(message);

      case ChatMessageType.RELATIONSHIP_TAG_PROPOSAL ||
          ChatMessageType.RELATIONSHIP_TAG_ACCEPTED:
        return _relationshipTagProposalCard(message);

      case ChatMessageType.rose:
        return _roseCard(message);

      case ChatMessageType.compliment:
        return _complimentCard(message);

      case ChatMessageType.dateInvite:
        return _datenowplanCard(message);

      case ChatMessageType.eventInvite:
        return _eventInviteCard(message);

      case ChatMessageType.DATECONFIRMED:
        return _datenowplanCard(message);
    }
  }

  bool _hasReplyImage(ChatMessage message) {
    return message.replyType == ChatMessageType.image ||
        message.replyImageUrl != null ||
        message.replyFileUrl != null;
  }

  String formatMessageTime(String time) {
    if (time.isEmpty) return 'Now';

    try {
      final dateTime = DateTime.parse(time).toLocal();

      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  Widget _buildReplyImage(ChatMessage message) {
    if (message.replyFileUrl != null) {
      return Image.file(
        File(message.replyFileUrl!),
        fit: BoxFit.cover,
        alignment: Alignment
            .topCenter, // Image ko top se align karega taaki face na kate
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    if (message.replyImageUrl != null) {
      return Image.network(
        message.replyImageUrl!,
        fit: BoxFit.cover,
        alignment: Alignment
            .topCenter, // Image ko top se align karega taaki face na kate
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    return Container(
      color: AppColors.soft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.muted, size: 22),
    );
  }

  Widget _quotedMessage(ChatMessage message) {
    final isImage = _hasReplyImage(message);

    if (isImage) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _scrollToMessage(message.replyToId),
        child: Container(
          width: (isImage)
              ? MediaQuery.of(context).size.width * 0.7
              : double.infinity,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Hero Image Container with Badge Overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18.5),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 300,
                          height: 200,
                          child: _buildReplyImage(message),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💖', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            'COMPLIMENT SENT',
                            style: AppText.sub.copyWith(
                              color: const Color(0xFFE34F72),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Card Body Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Message Text with Pink Left Bar Indicator
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE34F72),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              message.text,
                              style: AppText.sub.copyWith(
                                color: const Color(0xff6d6b69),
                                fontSize: 14,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Sub-label context
                    Text.rich(
                      TextSpan(
                        text: 'On her ',
                        style: AppText.sub.copyWith(
                          color: const Color(0xFF8A8083),
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: 'hero photo',
                            style: AppText.sub.copyWith(
                              color: const Color(0xFFE34F72),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              height: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF3E2E6)),
                    const SizedBox(height: 10),

                    // Bottom Footer Bar (Coins spent badge, time & double ticks)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEFE2E5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👵', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '30 spent',
                                style: AppText.sub.copyWith(
                                  color: const Color(0xFFE34F72),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '8:47 PM',
                              style: AppText.sub.copyWith(
                                color: const Color(0xFF9E9497),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.done_all_rounded,
                              size: 14,
                              color: Color(0xFF9E9497),
                            ),
                          ],
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

    // Text message response - Normal UI (Aapka original logic bina kisi changes ke)
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _scrollToMessage(message.replyToId),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3C9D2), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE34F72).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.reply_rounded,
                        size: 14,
                        color: Color(0xFFE34F72),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          message.isMine ? 'You' : widget.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sub.copyWith(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.replyText?.trim().isNotEmpty == true
                        ? message.replyText!
                        : 'Message',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sub.copyWith(
                      color: const Color(0xFF5F5A5B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.primary.withOpacity(0.55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _replyComposerPreview() {
    final message = _replyingTo!;
    final isImage = message.type == ChatMessageType.image;
    debugPrint("message>>>>>${message.text}");
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      padding: const EdgeInsets.fromLTRB(10, 5, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.chatpinkcontanersender.withOpacity(0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.chatpinkborder),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          if (isImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: 42,
                height: 42,
                child: _buildImage(message),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isMine
                      ? 'Replying to yourself'
                      : 'Replying to ${widget.user.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sub.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isImage ? '📷 Photo' : message.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sub.copyWith(
                    color: AppColors.ink60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _cancelReply,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.close, size: 20, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT MESSAGE
  // ============================================================

  Widget _textCard(ChatMessage message) {
    // final bool isMine = message.id ==message.senderId;
    final bool isMine = message.isMine;
    final isImage = _hasReplyImage(message);
    debugPrint("isMine>>>>>>$isMine");
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: EdgeInsets.only(
          left: isMine ? 30 : 0,
          right: isMine ? 0 : 30,
          bottom: 18,
        ),
        padding: (isImage == false)
            ? const EdgeInsets.fromLTRB(10, 10, 10, 8)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isImage
              ? AppColors.white
              : isMine
              ? AppColors.chatpinkcontanersender
              : Colors.white,
          border: Border.all(color: AppColors.chatpinkborder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 20),
          ),
          boxShadow: AppColors.shadow,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.replyText != null) _quotedMessage(message),
            if (isImage == false)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 3, 3, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message.text,
                        softWrap: true,
                        style: AppText.body.copyWith(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w300,
                          color: isMine ? Colors.black : AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatMessageTime(message.time),
                          style: AppText.sub.copyWith(
                            fontSize: 12,
                            color: isMine
                                ? const Color(0xFFB07B8D)
                                : AppColors.muted,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formatMessageTime(message.time),
                                style: AppText.body.copyWith(
                                  color: const Color(0xff928d89),

                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ((message.isMine)
                                    ? (message.seen ? ' ✓✓' : '  ✓')
                                    : ""),
                                style: AppText.body.copyWith(
                                  // color: const Color(0xff928d89),
                                  color: message.seen
                                      ? AppColors.primary
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  // ============================================================
  // EFFECT MESSAGE (Confetti / Heart Rain / Butterflies / ...)
  // ============================================================
  Widget _effectCard(ChatMessage message) {
    final bool isMine = message.isMine;
    final emoji = message.giftEmoji ?? '✨';
    final label = message.giftName ?? message.text;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: isMine ? AppColors.chatpinkcontanersender : Colors.white,
          border: Border.all(color: AppColors.chatpinkborder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 20),
          ),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.chatpinkborder),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to play again',
                        style: AppText.sub.copyWith(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _playEffectAnimation(emoji, label),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EBEC),
                      shape: BoxShape.circle,
                      boxShadow: AppColors.shadow,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMessageTime(message.time),
                    style: AppText.sub.copyWith(
                      fontSize: 12,
                      color: isMine ? const Color(0xFFB07B8D) : AppColors.muted,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatMessageTime(message.time),
                          style: AppText.body.copyWith(
                            color: const Color(0xff928d89),

                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ((message.isMine)
                              ? (message.seen ? ' ✓✓' : '  ✓')
                              : ""),
                          style: AppText.body.copyWith(
                            // color: const Color(0xff928d89),
                            color: message.seen
                                ? AppColors.primary
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE MESSAGE
  // ============================================================
  Widget _buildImage(ChatMessage message) {
    if (message.fileUrl != null) {
      return Image.file(
        File(message.fileUrl!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _imagePlaceholder();
        },
      );
    }

    if (message.imageUrl != null) {
      return Image.network(
        message.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _imagePlaceholder();
        },
      );
    }

    return _imagePlaceholder();
  }

  Widget _imageCard(ChatMessage message) {
    final bool isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMine ? 20 : 0,
          right: isMine ? 0 : 20,
          bottom: 18,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // =====================================================
            // MAIN WHITE BUBBLE + IMAGE
            // =====================================================
            Container(
              width: 320,
              height: 380,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: isMine
                      ? const Radius.circular(22)
                      : const Radius.circular(0),
                  bottomRight: isMine
                      ? const Radius.circular(0)
                      : const Radius.circular(22),
                ),
                child: Stack(
                  children: [
                    // IMAGE
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _openChatImage(message),
                        child: Hero(
                          tag: 'chat-image-${message.id}',
                          child: _buildImage(message),
                        ),
                      ),
                    ),

                    // =================================================
                    // BOTTOM RIGHT DATETIME
                    // =================================================
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatMessageTime(message.time),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),

                          if (isMine) ...[
                            const SizedBox(width: 4),
                            Text(
                              message.seen ? '✓✓' : '✓',
                              style: TextStyle(
                                color: message.seen
                                    ? AppColors.primary
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =====================================================
            // REPLY OVERLAY
            // =====================================================
            if (message.replyToId != null)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: _imageReplyOverlay(message),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imageReplyOverlay(ChatMessage message) {
    final isImage = _hasReplyImage(message);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _scrollToMessage(message.replyToId),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 8),
            if (isImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: _buildReplyImage(message),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reply',
                    style: AppText.sub.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isImage ? '📷 Photo' : message.replyText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sub.copyWith(
                      color: AppColors.ink60,
                      fontSize: 13,
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

  Widget _imagePlaceholder() {
    return Container(
      height: 390,
      color: AppColors.soft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 60, color: AppColors.muted),
    );
  }

  Widget _attachmentBubble({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool? isMine,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(24),
          topRight: const Radius.circular(24),
          bottomLeft: Radius.circular(isMine! ? 24 : 0),
          bottomRight: Radius.circular(isMine ? 0 : 24),
        ),
        boxShadow: AppColors.shadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 12),

          // IMPORTANT: Give text area remaining width
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                ),

                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sub.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(ChatMessage message) {
    final url = message.videoUrl?.trim();
    if (url == null || url.isEmpty) return _textCard(message);
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.shadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ChatVideoPlayer(url: url),
        ),
      ),
    );
  }

  Widget _audioCard(ChatMessage message) {
    final isMine = message.isMine;
    final path = message.audioUrl ?? message.fileUrl;
    final isPlaying =
        path != null && path == _playingAudioPath && _isAudioPlaying;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 5),
            bottomRight: Radius.circular(isMine ? 5 : 20),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppColors.shadow,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleAudio(message),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(28, (index) {
                      final height = index.isEven ? 9.0 : 16.0;
                      return Container(
                        width: 3,
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isMine ? AppColors.primary : AppColors.ink60,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Voice message',
                    style: AppText.sub.copyWith(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (message.fileSize != null)
              Text(
                message.fileSize!,
                style: AppText.sub.copyWith(
                  color: AppColors.muted,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChatImage(ChatMessage message) async {
    final imageUrl = (message.imageUrl ?? '').trim();
    if (imageUrl.isEmpty) {
      debugPrint('❌ IMAGE VIEW: imageUrl is empty');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatImageViewerScreen(
          imageUrl: imageUrl,
          heroTag: 'chat-image-${message.id}',
        ),
      ),
    );
  }

  Future<void> _openChatDocument(ChatMessage message) async {
    final fileUrl = (message.fileUrl ?? '').trim();
    if (fileUrl.isEmpty) {
      debugPrint('❌ DOCUMENT VIEW: fileUrl is empty');
      return;
    }

    final cleanUrl = fileUrl.split('?').first.toLowerCase();
    final isPdf =
        cleanUrl.endsWith('.pdf') ||
        (message.fileName ?? '').toLowerCase().endsWith('.pdf');

    if (isPdf) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPdfViewerScreen(
            pdfUrl: fileUrl,
            title: message.fileName ?? 'PDF',
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(fileUrl);

    if (uri == null) {
      debugPrint('❌ Invalid document URL: $fileUrl');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      debugPrint('📄 Document opened: $opened');
    } catch (e) {
      debugPrint('❌ Document open error: $e');
    }
  }

  Widget _documentCard(ChatMessage message) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _openChatDocument(message),
        child: _attachmentBubble(
          icon: Icons.insert_drive_file_rounded,
          iconColor: const Color(0xFF3D8BE8),
          title: message.fileName ?? 'Document',
          subtitle: message.fileSize ?? 'Document',
          isMine: message.isMine,
        ),
      ),
    );
  }

  Widget _locationCard(ChatMessage message) {
    final latitude = message.latitude;
    final longitude = message.longitude;

    final hasCoordinates = latitude != null && longitude != null;

    final locationText = (message.locationLabel ?? message.text).trim();

    final address = locationText.isEmpty ? 'Location' : locationText;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: hasCoordinates
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LocationMapScreen(
                      latitude: latitude!,
                      longitude: longitude!,
                      label: address,
                    ),
                  ),
                );
              }
            : null,

        child: Container(
          width: 310,

          margin: const EdgeInsets.only(bottom: 16),

          clipBehavior: Clip.antiAlias,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),

              bottomLeft: Radius.circular(message.isMine ? 24 : 0),

              bottomRight: Radius.circular(message.isMine ? 0 : 24),
            ),

            boxShadow: AppColors.shadow,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // MAP
              // =================================================
              SizedBox(
                height: 155,
                width: double.infinity,

                child: hasCoordinates
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude!, longitude!),
                          zoom: 15.5,
                        ),

                        markers: {
                          Marker(
                            markerId: MarkerId('chat_${message.id}'),

                            position: LatLng(latitude, longitude),
                          ),
                        },

                        myLocationButtonEnabled: false,

                        zoomControlsEnabled: false,

                        compassEnabled: false,

                        mapToolbarEnabled: false,

                        liteModeEnabled: true,

                        scrollGesturesEnabled: false,

                        zoomGesturesEnabled: false,

                        rotateGesturesEnabled: false,

                        tiltGesturesEnabled: false,
                      )
                    : Container(
                        color: AppColors.primarySoft,

                        alignment: Alignment.center,

                        child: const Icon(
                          Icons.location_on_rounded,

                          color: AppColors.primary,

                          size: 50,
                        ),
                      ),
              ),

              // =================================================
              // LOCATION DETAILS
              // =================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // -------------------------------------------
                    // LOCATION ICON
                    // -------------------------------------------
                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.location_on_rounded,

                        color: AppColors.primary,

                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // -------------------------------------------
                    // ADDRESS
                    // -------------------------------------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Location',

                            style: AppText.h2.copyWith(fontSize: 16),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            address,

                            maxLines: 3,

                            overflow: TextOverflow.ellipsis,

                            style: AppText.sub.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------------------------
                    // OPEN ICON
                    // -------------------------------------------
                    if (hasCoordinates)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),

                        child: Icon(
                          Icons.open_in_new_rounded,

                          size: 18,

                          color: AppColors.muted,
                        ),
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

  Widget _contactCard(ChatMessage message) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () async {
          final phone = message.contactPhoneNumber?.trim();
          debugPrint(
            '❌ Phone number is empty>>>>>${message.contactPhoneNumber}',
          );
          if (phone == null || phone.isEmpty) {
            debugPrint('❌ Phone number is empty');
            return;
          }

          final Uri phoneUri = Uri(scheme: 'tel', path: phone);

          debugPrint('📞 Calling: $phoneUri');

          try {
            final bool launched = await launchUrl(
              phoneUri,
              mode: LaunchMode.externalApplication,
            );

            debugPrint('📞 Launch result: $launched');
          } catch (e) {
            debugPrint('❌ Call error: $e');
          }
        },
        child: _attachmentBubble(
          icon: Icons.person_rounded,
          iconColor: const Color(0xFF8A8680),
          title: message.contactName.toString(),
          subtitle: message.contactPhoneNumber.toString(),
          isMine: message.isMine,
        ),
      ),
    );
  }
  // ============================================================
  // GIFT CARD
  // ============================================================

  Widget _giftCard(ChatMessage message) {
    final current = message.messageProgress ?? 0;
    final target = message.messageTarget ?? 0;
    final hasProgress = target > 0;
    final progress = hasProgress ? (current / target).clamp(0.0, 1.0) : 0.0;
    final remaining = hasProgress ? (target - current).clamp(0, target) : 0;
    final isMine = message.isMine;
    final name = widget.user.name.trim().isEmpty
        ? 'AANYA'
        : widget.user.name.toUpperCase();
    final spent =
        message.giftCoins?.replaceFirst('+', '').replaceFirst(' Coins', '') ??
        '0';
    final unlocked = message.giftClaimed || (hasProgress && current >= target);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: (MediaQuery.sizeOf(context).width * .86)
            .clamp(300.0, 520.0)
            .toDouble(),
        margin: EdgeInsets.only(
          left: isMine ? 42 : 0,
          right: isMine ? 0 : 42,
          bottom: 20,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xfffffcfa),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isMine ? 24 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 24),
          ),
          border: Border.all(
            color: isMine ? const Color(0xffffd2dc) : const Color(0xffd8e5ff),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isMine ? const Color(0x18e34d70) : const Color(0x183b76df),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.imageUrl ?? '').trim().isNotEmpty)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xffeee8e5),
                          alignment: Alignment.center,
                          child: Text(
                            message.giftEmoji ?? '🎁',
                            style: const TextStyle(fontSize: 54),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          isMine ? '🎁 GIFT SENT' : '🎁 GIFT FROM $name',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3367c9),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.giftEmoji ?? '🎁',
                        style: const TextStyle(fontSize: 19),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          message.giftName ?? 'Gift',
                          style: AppText.h2.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((message.text ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff4b83f1),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              message.text ?? '',
                              style: AppText.body.copyWith(
                                fontSize: 14,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xff2d292b),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                  if (hasProgress) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isMine
                              ? const Color(0xffffd9e1)
                              : const Color(0xffdce7fb),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reply progress',
                                style: AppText.body.copyWith(
                                  color: const Color(0xff918c89),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                '$current/$target replies',
                                style: AppText.body.copyWith(
                                  color: isMine
                                      ? AppColors.primary
                                      : const Color(0xff3168ca),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: isMine
                                  ? const Color(0xffffe1e7)
                                  : const Color(0xffe2eafa),
                              valueColor: AlwaysStoppedAnimation(
                                isMine
                                    ? AppColors.primary
                                    : const Color(0xff4d87ee),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            unlocked
                                ? '✓ She replied enough — your gift is unlocked'
                                : '$remaining more replies and your gift unlocks${isMine ? '' : ' as'} ${isMine ? '' : '🪙$spent'}',
                            style: AppText.body.copyWith(
                              color: unlocked
                                  ? const Color(0xff2bb36b)
                                  : const Color(0xff686360),
                              fontSize: 12,
                              fontWeight: unlocked
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const Divider(color: Color(0xfff1dddd), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isMine
                                ? const Color(0xffffd4de)
                                : const Color(0xffd4e1fb),
                          ),
                        ),
                        child: Text(
                          '🪙$spent ${isMine ? 'spent' : 'pending'}',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3269ce),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatMessageTime(message.time),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),

                          if (isMine) ...[
                            const SizedBox(width: 4),
                            Text(
                              message.seen ? '✓✓' : '✓',
                              style: TextStyle(
                                color: message.seen
                                    ? AppColors.primary
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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

  // ============================================================
  // ROSE CARD (sent / received)
  // ============================================================

  Widget _engagementBundleCard(ChatMessage message) {
    final coin = message.coinAmount ?? '10';

    final progress = message.messageProgress;
    final target = message.messageTarget;

    final hasReplyProgress = progress != null && target != null && target > 0;

    final remaining = hasReplyProgress
        ? (target! - progress!).clamp(0, target!)
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),

      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF6D7C2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF9EEEF),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // =======================================================
              // ROSE - LEFT
              // =======================================================
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(child: RoseTwinkleOverlay()),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              message.isMine
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 13,
                              color: message.isMine
                                  ? const Color(0xFF8A6010)
                                  : AppColors.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // SAME EXISTING ANIMATED ROSE
                        const FloatingRose(), const SizedBox(width: 3),

                        Flexible(
                          child: Text(
                            message.isMine ? 'ROSE SENT' : 'ROSE RECEIVED',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.eyebrow.copyWith(
                              fontSize: 10,
                              color: message.isMine
                                  ? const Color(0xFF8A6010)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // const SizedBox(width: 10),

              // =======================================================
              // GIFT - RIGHT
              // =======================================================
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(child: RoseTwinkleOverlay()),
                    Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        // GIFT IMAGE
                        const SizedBox(height: 27),
                        FloatingGift(imageUrl: message.imageUrl),

                        const SizedBox(height: 13),
                        Text(
                          message.giftName ?? 'Special Gift',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF302A2C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // =========================================================
          // ROSE MESSAGE / QUOTE
          // =========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '"${message.complimentMessage ?? 'You are a beautiful soul, and I cherish every moment we share together.'}"',
              textAlign: TextAlign.center,
              style: AppText.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.35,
                color: const Color(0xFF272326),
              ),
            ),
          ),

          // =========================================================
          // INFO CARD
          // SCREENSHOT STYLE
          // =========================================================
          if (message.hintLine != null) ...[
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFF0ECEC), width: 1),
              ),
              child: Text(
                message.hintLine!,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: const Color(0xFF686163),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],

          // =========================================================
          // REPLY PROGRESS
          // SCREENSHOT STYLE
          // =========================================================
          if (hasReplyProgress) ...[
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 1, 18, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xfff3d4dc), width: 1.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------
                  // TITLE + 14/25
                  // -----------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          message.isMine
                              ? 'Her reply progress'
                              : 'Reply progress',
                          style: AppText.body.copyWith(
                            color: const Color(0xFF8B8680),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        '$progress/$target replies',
                        style: AppText.body.copyWith(
                          color: const Color(0xFFD83D62),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // -----------------------------------------------
                  // PROGRESS BAR
                  // -----------------------------------------------
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (progress / target).clamp(0.0, 1.0),
                      minHeight: 11,
                      backgroundColor: const Color(0xFFF4E1E6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD94768),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -----------------------------------------------
                  // HELPER TEXT
                  // -----------------------------------------------
                  Text(
                    message.isMine
                        ? '$remaining more replies to unlock your rose for her'
                        : '$remaining more replies to unlock her rose',
                    style: AppText.body.copyWith(
                      color: const Color(0xFF686163),
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // =========================================================
          // BOTTOM STATUS
          // =========================================================
          message.isMine ? SizedBox() : const SizedBox(height: 14),
          message.isMine
              ? SizedBox()
              : Container(
                  width: double.infinity,
                  // height: 1,
                  // color: const Color(0xFFF0ECEC),
                  child: Text(
                    "She sent this hoping you'd write back. Keep it going  — a few replies in, the rose unlocks as 🪙 10.",
                    style: AppText.sub1.copyWith(
                      color: const Color(0xFFC7395E),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
          const SizedBox(height: 14),
          Text(
            message.isMine
                ? "Sent · ${DateFormat('hh:mm a').format(DateTime.parse(message.time).toLocal())} · ${message.seen ? '✓✓ Seen' : '✓ Sent'}"
                : 'Received today ·${DateFormat('hh:mm a').format(DateTime.parse(message.time).toLocal())} · her rose unlocks as you talk',
            textAlign: TextAlign.center,
            style: AppText.sub1.copyWith(
              color: const Color(0xFF999294),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roseCard(ChatMessage message) {
    final coin = message.coinAmount ?? '10';

    final progress = message.messageProgress;
    final target = message.messageTarget;

    final hasReplyProgress = progress != null && target != null && target > 0;

    final remaining = hasReplyProgress
        ? (target! - progress!).clamp(0, target!)
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),

      // decoration: BoxDecoration(
      //   color: const Color(0xFFFFFBFB),
      //   borderRadius: BorderRadius.circular(22),
      //   border: Border.all(color: const Color(0xFFF6D7C2), width: 1.5),
      //   boxShadow: [
      //     BoxShadow(
      //       color: const Color(0xFFE35B78).withOpacity(0.08),
      //       blurRadius: 18,
      //       offset: const Offset(0, 8),
      //     ),
      //   ],
      // ),
      // decoration: BoxDecoration(
      //   color: const Color(0xFFFFFBFB),
      //   borderRadius: BorderRadius.circular(22),
      //   border: Border.all(color: const Color(0xFFF6D7C2), width: 1.5),
      //   boxShadow: [
      //     BoxShadow(
      //       color: const Color(0xFFE35B78).withOpacity(0.08),
      //       blurRadius: 18,
      //       offset: const Offset(0, 8),
      //     ),
      //   ],
      // ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF6D7C2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF9EEEF),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =========================================================
          // ROSE HEADER
          // KEEPING YOUR EXISTING ROSE MOTION
          // =========================================================
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        message.isMine
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: message.isMine
                            ? const Color(0xFF8A6010)
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.isMine
                            ? 'ROSE SENT · TO ${widget.user.name.toUpperCase()}'
                            : 'ROSE RECEIVED · FROM ${widget.user.name.toUpperCase()}',
                        style: AppText.eyebrow.copyWith(
                          color: message.isMine
                              ? const Color(0xFF8A6010)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // DO NOT REMOVE - animated rose
                  const FloatingRose(),
                ],
              ),

              // DO NOT REMOVE - animated twinkles
              const Positioned.fill(child: RoseTwinkleOverlay()),
            ],
          ),

          const SizedBox(height: 10),

          // =========================================================
          // ROSE MESSAGE / QUOTE
          // =========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '"${message.complimentMessage ?? 'You are a beautiful soul, and I cherish every moment we share together.'}"',
              textAlign: TextAlign.center,
              style: AppText.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.35,
                color: const Color(0xFF272326),
              ),
            ),
          ),

          // =========================================================
          // INFO CARD
          // SCREENSHOT STYLE
          // =========================================================
          if (message.hintLine != null) ...[
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFF0ECEC), width: 1),
              ),
              child: Text(
                message.hintLine!,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: const Color(0xFF686163),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],

          // =========================================================
          // REPLY PROGRESS
          // SCREENSHOT STYLE
          // =========================================================
          if (hasReplyProgress) ...[
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 1, 18, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xfff3d4dc), width: 1.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------
                  // TITLE + 14/25
                  // -----------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          message.isMine
                              ? 'Her reply progress'
                              : 'Reply progress',
                          style: AppText.body.copyWith(
                            color: const Color(0xFF8B8680),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        '$progress/$target replies',
                        style: AppText.body.copyWith(
                          color: const Color(0xFFD83D62),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // -----------------------------------------------
                  // PROGRESS BAR
                  // -----------------------------------------------
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (progress / target).clamp(0.0, 1.0),
                      minHeight: 11,
                      backgroundColor: const Color(0xFFF4E1E6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD94768),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -----------------------------------------------
                  // HELPER TEXT
                  // -----------------------------------------------
                  Text(
                    message.isMine
                        ? '$remaining more replies to unlock your rose for her'
                        : '$remaining more replies to unlock her rose',
                    style: AppText.body.copyWith(
                      color: const Color(0xFF686163),
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // =========================================================
          // BOTTOM STATUS
          // =========================================================
          message.isMine ? SizedBox() : const SizedBox(height: 14),
          message.isMine
              ? SizedBox()
              : Container(
                  width: double.infinity,
                  // height: 1,
                  // color: const Color(0xFFF0ECEC),
                  child: Text(
                    "She sent this hoping you'd write back. Keep it going  — a few replies in, the rose unlocks as 🪙 10.",
                    style: AppText.sub1.copyWith(
                      color: const Color(0xFFC7395E),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
          const SizedBox(height: 14),
          Text(
            message.isMine
                ? "Sent · ${DateFormat('hh:mm a').format(DateTime.parse(message.time).toLocal())} · ${message.seen ? '✓✓ Seen' : '✓ Sent'}"
                : 'Received today ·${DateFormat('hh:mm a').format(DateTime.parse(message.time).toLocal())} · her rose unlocks as you talk',
            textAlign: TextAlign.center,
            style: AppText.sub1.copyWith(
              color: const Color(0xFF999294),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // COMPLIMENT CARD (sent / received)
  // ============================================================

  Widget _complimentCard(ChatMessage message) {
    final coin = message.coinAmount ?? '30';
    final isMine = message.isMine;
    final hasImage = (message.complimentImageUrl ?? '').trim().isNotEmpty;
    final hasFact = (message.complimentFactTitle ?? '').trim().isNotEmpty;
    final read = (message.seen);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: (MediaQuery.sizeOf(context).width * .86)
            .clamp(300.0, 520.0)
            .toDouble(),
        margin: EdgeInsets.only(
          left: isMine ? 42 : 0,
          right: isMine ? 0 : 42,
          bottom: 18,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xfffffcfa),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isMine ? 24 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 24),
          ),
          border: Border.all(
            color: isMine ? const Color(0xffffd2dc) : const Color(0xffd9e6fb),
          ),
          boxShadow: [
            BoxShadow(
              color: isMine ? const Color(0x18e34d70) : const Color(0x183b76df),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              SizedBox(
                height: 175,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      message.complimentImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xffdbe7f2)),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 13,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          '💝 COMPLIMENT ${isMine ? 'SENT' : 'FROM ${widget.user.name.toUpperCase()}'}',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasImage)
                    Row(
                      children: [
                        Text(
                          "💝",
                          style: AppText.eyebrow.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          isMine
                              ? 'COMPLIMENT SENT'
                              : 'COMPLIMENT FROM ${widget.user.name.toUpperCase()}',
                          style: AppText.eyebrow.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  hSized10,
                  if (hasFact) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isMine
                              ? const Color(0xffffdce3)
                              : const Color(0xffdce7f7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xffffeff3)
                                  : const Color(0xffedf3ff),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              message.complimentIcon ?? '✨',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.complimentFactTitle!,
                                  style: AppText.h2.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  message.complimentFactSubtitle ?? '',
                                  style: AppText.body.copyWith(
                                    color: const Color(0xff918c89),
                                    fontSize: 10,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                  ],
                  if ((message.text ?? '').trim().isNotEmpty)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff4b83f1),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              message.text ?? '',
                              style: AppText.body.copyWith(
                                fontSize: 14,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xff2d292b),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasImage && (message.locationLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'On your ${message.locationLabel}',
                      style: AppText.body.copyWith(
                        color: const Color(0xff8e8986),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xfff0dddd), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isMine
                                ? const Color(0xffffd2dc)
                                : const Color(0xffd5e2fa),
                          ),
                        ),
                        child: Text(
                          isMine ? '🪙$coin spent' : '💝 Compliment received',
                          style: AppText.pill.copyWith(
                            color: isMine
                                ? AppColors.primary
                                : const Color(0xff3168ca),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            formatMessageTime(message.time),
                            style: AppText.body.copyWith(
                              color: const Color(0xff928d89),

                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ((message.isMine) ? (read ? ' ✓✓' : '  ✓') : ""),
                            style: AppText.body.copyWith(
                              // color: const Color(0xff928d89),
                              color: message.seen
                                  ? AppColors.primary
                                  : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
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

  // ============================================================
  // DATE INVITE CARD
  // ============================================================

  Widget _dateInviteCard(ChatMessage message) {
    // Rich "Date Now Plan" style — image banner, live badge, stats grid.
    if (message.inviteImageUrl != null) {
      return _richInviteCard(message);
    }

    final accepted = message.inviteStatus == 'ACCEPTED';

    return Padding(
      padding: EdgeInsets.only(
        left: message.isMine ? 45 : 0,
        right: message.isMine ? 0 : 45,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(message.isMine ? 24 : 0),
            bottomRight: Radius.circular(message.isMine ? 0 : 24),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  message.inviteTitle ?? 'Date Invite',
                  style: AppText.eyebrow.copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accepted
                        ? AppColors.greenSoft
                        : const Color(0xFFFFF3DC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (accepted ? '✓ ' : '') + (message.inviteStatus ?? ''),
                    style: AppText.pill.copyWith(
                      fontSize: 11,
                      color: accepted ? AppColors.green : AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            if (message.typemsg.toString() != "Text")
              const SizedBox(height: 10),

            if (message.typemsg.toString() != "Text")
              Text(
                message.inviteVenue ?? '',
                style: AppText.h2.copyWith(fontSize: 16),
              ),

            if (message.typemsg.toString() != "Text") const SizedBox(height: 6),

            Text(
              message.text.toString(),
              style: AppText.body.copyWith(color: AppColors.ink60, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EVENT INVITE (Sunset Soirée style — RSVP card with booking options)
  // ============================================================
  Widget _datenowplanCard(ChatMessage message) {
    debugPrint('Rendering event invite card for message: ${message.text}');
    debugPrint(
      'Rendering event invite card for message: ${message.inviteImageUrl}',
    );
    return _datenowplanCardhere(message);
  }

  Widget _datenowplanCardhere(ChatMessage message) {
    final hasStats =
        message.inviteStats != null && message.inviteStats!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: message.isMine ? 20 : 0,
        right: message.isMine ? 0 : 20,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(message.isMine ? 24 : 0),
            bottomRight: Radius.circular(message.isMine ? 0 : 24),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------
            // IMAGE BANNER + BADGE
            // -----------------------------------------------------
            if (message.eventHeroImage != null)
              Stack(
                children: [
                  SizedBox(
                    height: 165,
                    width: double.infinity,

                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(0),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 185,
                          child: Image.network(
                            message.eventHeroImage!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;

                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('❌ Event hero image error: $error');
                              debugPrint('❌ URL: ${message.eventHeroImage}');

                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (message.inviteBadge != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: message.inviteBadge != 'LIVE NOW'
                              ? Color(0xfffff4e0)
                              : Color(0xff3d945f),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // message.inviteEyebrow!
                              message.inviteBadge == 'LIVE NOW'
                                  ? "● LIVE NOW"
                                  : "● AWAITING RSVP",
                              style: AppText.pill.copyWith(
                                color: message.inviteBadge != 'LIVE NOW'
                                    ? Color(0xff8a6010)
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Container(
                    height: 160,
                    // color: Colors.black.withOpacity(0.55),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.eventTitle != null)
                            Text(
                              message.eventTitle!,
                              style: AppText.h2.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          if (message.inviteVenue != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    message.inviteVenue!,
                                    style: AppText.body.copyWith(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  if (message.inviteStatus == 'LIVE') hSized20,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.eventDate != null)
                        Builder(
                          builder: (context) {
                            final date = DateTime.tryParse(message.eventDate!);

                            if (date == null) {
                              return const SizedBox.shrink();
                            }

                            const days = [
                              'MON',
                              'TUE',
                              'WED',
                              'THU',
                              'FRI',
                              'SAT',
                              'SUN',
                            ];

                            const months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.colorf3d4dc,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    days[date.weekday - 1],
                                    style: AppText.pill.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),

                                  Text(
                                    '${date.day}',
                                    style: AppText.h2.copyWith(
                                      color: Colors.black,
                                      fontSize: 20,
                                      height: 1.1,
                                    ),
                                  ),

                                  Text(
                                    months[date.month - 1],
                                    style: AppText.pill.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.eventStartTime != null)
                              Row(
                                children: [
                                  Text(
                                    formatMessageTime(message.eventStartTime!),
                                    style: AppText.h2.copyWith(fontSize: 16),
                                  ),
                                  Text(
                                    " - ${formatMessageTime(message.eventEndTime!)}",
                                    style: AppText.h2.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            if (message.eventVenueName != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                message.eventVenueName!,
                                style: AppText.body.copyWith(
                                  color: AppColors.colorc7395e,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  hSized5,
                  Divider(height: 20, thickness: 1, color: AppColors.line),
                  hSized5,

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xfff3d4dc),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      wSized10,
                      Expanded(
                        child: Text(
                          '"Come with me? — pick how you\'d like to book. 💜"',
                          style: AppText.body.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.ink60,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  // STATS GRID
                  if (hasStats) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final entry in message.inviteStats!.entries) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppText.body.copyWith(
                                      color: AppColors.ink60,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style: AppText.body.copyWith(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Last item ke baad divider nahi
                            if (entry.key !=
                                message.inviteStats!.entries.last.key)
                              const Divider(
                                height: 2,
                                color: Color(0xFFF3E2E6),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  hSized10,

                  // BUTTONS
                  // if (message.inviteButtonPrimary != null) ...[
                  const SizedBox(height: 10),

                  message.isMine
                      ? const Text(
                          "You sent a date plan",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : message.isAlreadyRequested == true
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final requestSent = await showRequestDateBottomSheet(
                                      context,
                                      {
                                        "id": message.dateplanid,
                                        "imageUrl": message.imageUrl,
                                        "location": message.inviteSafetyNote!,
                                        // "distance": "Near you",
                                        // "match": "26% match",
                                        "date":
                                            "📅 ${message.eventDate!.toString().substring(0, 10)}",
                                        "time":
                                            "🕔 ${message.eventType!.toString()}",
                                        "type": message.eventType,
                                        "title": message.eventTitle,
                                        // "subtitle": "3rd one",
                                        "people":
                                            "⏱️ ${message.inviteStats} mins",
                                        "pay": message.inviteStats,
                                        "name": "${_liveName}, ${_liveAge}",
                                        "userId": message.senderId,
                                        "verified": "false",
                                        "nameSubtitle": "Host",
                                        "avatarUrl":
                                            "https://ik.imagekit.io/hzyuadmua/user-photos/upload_1788931884236_znX2xo652.jpg",
                                      },
                                    );

                                    if (requestSent == true) {
                                      message.isAlreadyRequested = true;
                                      // request sent successfully
                                    }
                                  },
                                  child: _richInviteButton1(
                                    label: "Request to join",
                                    primary: true,
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: InkWell(
                              //     //navneet
                              //     // onTap: () => _showViewPlanBottomSheet(context, {
                              //     //   "id": "78d5b281-0be1-40d7-be05-e054839f64b7",
                              //     //   "planId":
                              //     //       "3dfb1dd1-e253-4d57-80fc-0a8b20755abf",
                              //     //   "imageUrl":
                              //     //       "https://ik.imagekit.io/hzyuadmua/date-plan-options/1787118624770-download_fuuujdZNe.jpg",
                              //     //   "activityName": "Dinner",
                              //     //   "title": "rahul date",
                              //     //   "subtitle": "Today · 7:35 PM · amnora",
                              //     //   "hostName": "Rahul",
                              //     //   "hostAvatar": null,
                              //     //   "status": "Pending",
                              //     //   "message": "heeello",
                              //     //   "billSuggestionLabel": "🤷 Decide there",
                              //     //   "statusMessage":
                              //     //       "Waiting for host to approve. You can withdraw anytime.",
                              //     //   "pay": "🙋 I’ll pay",
                              //     //   "match": "88%",
                              //     //   "isLive": false,
                              //     // }),
                              //     onTap: () {
                              //       Navigator.pushAndRemoveUntil(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) =>
                              //               const RequestsSentScreen(
                              //                 initialTabIndex: 0,
                              //               ),
                              //         ),
                              //         (route) => route.isFirst,
                              //       );
                              //     },
                              //     child: _richInviteButton1(
                              //       label: "View Plan",
                              //       primary: false,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                  // const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "🛡️ Venue: ${message.inviteSafetyNote ?? ""}",
                            style: AppText.body.copyWith(
                              color: AppColors.green,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  hSized10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatMessageTime(message.time),
                        style: AppText.body.copyWith(
                          color: const Color(0xff928d89),

                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ((message.isMine)
                            ? (message.seen ? ' ✓✓' : '  ✓')
                            : ""),
                        style: AppText.body.copyWith(
                          // color: const Color(0xff928d89),
                          color: message.seen
                              ? AppColors.primary
                              : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
                // ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showViewPlanBottomSheet(
    BuildContext context,
    Map<String, dynamic> plan,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top image with title overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          plan['imageUrl'] != null &&
                              plan['imageUrl'].toString().isNotEmpty
                          ? NetworkImage(plan['imageUrl']) as ImageProvider
                          : const AssetImage('assets/dummyphoto.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      plan['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: '💜 ${plan['match']} match',
                              style: const TextStyle(
                                color: Color(0xFF9C27B0),
                              ), // Purple color for match
                            ),
                            const TextSpan(text: ' · 🛡️ 98% trust'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date/Time
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plan['subtitle'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tags row (Payment, people)
                      Row(
                        children: [
                          Text(
                            plan['pay'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '·',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '👥 2 people',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Host details card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  plan['hostAvatar'] != null &&
                                      plan['hostAvatar'].toString().isNotEmpty
                                  ? NetworkImage(plan['hostAvatar'])
                                        as ImageProvider
                                  : const AssetImage('assets/dummyphoto.jpeg'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan['hostName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Host of this plan',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Message card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          plan['message'].replaceAll('You: ', 'You said: '),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context); // Close view plan
                                // _showWithdrawBottomSheet(
                                //   context,
                                //   plan,
                                // ); // Show withdraw
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Withdraw',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFA6A85),
                                      Color(0xFFDE2957),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getEventPrice(BuildContext context, ChatMessage message) {
    final gender =
        context
            .read<ProfileEditCubit>()
            .state
            .gender
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';

    String? originalPrice;
    String? discountedPrice;

    if (gender == 'woman') {
      originalPrice = message.eventWomenEntryPrice;
      discountedPrice = message.eventWomenDiscountedPrice;
    } else if (gender == 'man') {
      originalPrice = message.eventMenEntryPrice;
      discountedPrice = message.eventMenDiscountedPrice;
    } else {
      discountedPrice = message.eventOtherDiscountedPrice;
    }

    // Discounted price available hai to wahi show karo
    final discounted = double.tryParse(discountedPrice ?? '');

    if (discounted != null && discounted > 0) {
      return discounted == discounted.truncateToDouble()
          ? '₹${discounted.toInt()}'
          : '₹${discounted.toStringAsFixed(1)}';
    }

    // Fallback original price
    final original = double.tryParse(originalPrice ?? '');

    if (original != null && original > 0) {
      return original == original.truncateToDouble()
          ? '₹${original.toInt()}'
          : '₹${original.toStringAsFixed(1)}';
    }

    return 'Free';
  }

  Widget _eventInviteCard(ChatMessage message) {
    return _richInviteCard(message);
  }

  /// Shared renderer for the richer "Date Now Plan" / "Event Invite" cards:
  /// photo banner + status badge, day chip, quote box, optional stat grid,
  /// safety note, and one or two action buttons.
  Widget _richInviteCard(ChatMessage message) {
    final hasStats =
        message.inviteStats != null && message.inviteStats!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: message.isMine ? 20 : 0,
        right: message.isMine ? 0 : 20,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(message.isMine ? 24 : 0),
            bottomRight: Radius.circular(message.isMine ? 0 : 24),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------
            // IMAGE BANNER + BADGE
            // -----------------------------------------------------
            if (message.eventHeroImage != null)
              Stack(
                children: [
                  SizedBox(
                    height: 165,
                    width: double.infinity,

                    child: Padding(
                      padding: (message.inviteBadge == 'LIVE NOW')
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(top: 35),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(0),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 185,
                          child: Image.network(
                            message.eventHeroImage!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;

                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('❌ Event hero image error: $error');
                              debugPrint('❌ URL: ${message.eventHeroImage}');

                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (message.inviteBadge != 'LIVE NOW')
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Mycolor.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  if (message.eventType != 'LIVE NOW')
                    Positioned(
                      top: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: message.eventType == 'LIVE NOW'
                              ? AppColors.green
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              // message.inviteEyebrow!
                              "🎟️ ",
                              style: AppText.pill.copyWith(
                                color: Mycolor.redlight,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              message.eventType.toString(),
                              // " EVENT INVITE",
                              style: AppText.pill.copyWith(
                                color: Mycolor.redlight,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (message.inviteBadge != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: message.inviteBadge != 'LIVE NOW'
                              ? Color(0xfffff4e0)
                              : Color(0xff3d945f),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // message.inviteEyebrow!
                              message.inviteBadge == 'LIVE NOW'
                                  ? "● LIVE NOW"
                                  : "● AWAITING RSVP",
                              style: AppText.pill.copyWith(
                                color: message.inviteBadge != 'LIVE NOW'
                                    ? Color(0xff8a6010)
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (message.inviteBadge == 'LIVE NOW')
                    if (message.inviteEyebrow != null)
                      Container(
                        height: 150,
                        // color: Colors.black.withOpacity(0.55),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.eventTitle != null)
                                Text(
                                  message.eventTitle!,
                                  style: AppText.h2.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              if (message.inviteVenue != null) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        message.inviteVenue!,
                                        style: AppText.body.copyWith(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE

                  // if (message.inviteBadge == 'LIVE NOW')
                  // if (message.eventEyebrow != null)
                  //   if (message.eventBadge != 'LIVE NOW')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      hSized10,
                      if (message.eventTitle != null)
                        Text(
                          message.eventTitle!,
                          style: AppText.h2.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      hSized10,
                    ],
                  ),
                  if (message.inviteStatus == 'LIVE') hSized20,
                  // if (message.inviteStatus != 'LIVE')
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.eventDate != null)
                        Builder(
                          builder: (context) {
                            final date = DateTime.tryParse(message.eventDate!);

                            if (date == null) {
                              return const SizedBox.shrink();
                            }

                            const days = [
                              'MON',
                              'TUE',
                              'WED',
                              'THU',
                              'FRI',
                              'SAT',
                              'SUN',
                            ];

                            const months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.colorf3d4dc,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    days[date.weekday - 1],
                                    style: AppText.pill.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),

                                  Text(
                                    '${date.day}',
                                    style: AppText.h2.copyWith(
                                      color: Colors.black,
                                      fontSize: 20,
                                      height: 1.1,
                                    ),
                                  ),

                                  Text(
                                    months[date.month - 1],
                                    style: AppText.pill.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.eventStartTime != null)
                              Text(
                                formatMessageTime(message.eventStartTime!),
                                style: AppText.h2.copyWith(fontSize: 16),
                              ),
                            if (message.eventVenueName != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                message.eventVenueName!,
                                style: AppText.body.copyWith(
                                  color: AppColors.colorc7395e,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  hSized5,
                  Divider(height: 20, thickness: 1, color: AppColors.line),
                  if (message.inviteStatus == 'LIVE') hSized5,
                  // DATE CHIP + TIME
                  if (message.inviteStatus == 'LIVE')
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xfff3d4dc),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        wSized10,
                        Expanded(
                          child: Text(
                            '"Come with me? — pick how you\'d like to book. 💜"',
                            style: AppText.body.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.ink60,
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (message.eventFullAddress != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "📍 ${message.eventFullAddress}",
                            style: AppText.body.copyWith(
                              color: AppColors.ink60,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (message.eventMenEntryPrice != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "🎫  ₹ ${message.eventMenEntryPrice!} per person",
                          style: AppText.body.copyWith(
                            color: AppColors.ink60,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "🛡  Verified-only entry · safety team on site",
                          style: AppText.body.copyWith(
                            color: AppColors.ink60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  hSized5,
                  // QUOTE
                  // if (message.inviteStatus != "LIVE")
                  // if (message.inviteQuote != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '"Come with me? — pick how you\'d like to book. 💜"',
                      style: AppText.body.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink60,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // ],
                  const SizedBox(height: 10),
                  // STATS GRID
                  if (hasStats) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final entry in message.inviteStats!.entries) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppText.body.copyWith(
                                      color: AppColors.ink60,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style: AppText.body.copyWith(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Last item ke baad divider nahi
                            if (entry.key !=
                                message.inviteStats!.entries.last.key)
                              const Divider(
                                height: 2,
                                color: Color(0xFFF3E2E6),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (message.isMine == true) hSized10,
                  if (message.isMine == true)
                    Text(
                      "BOOKING",
                      style: AppText.body.copyWith(
                        color: AppColors.ink60,
                        fontSize: 10.5,
                      ),
                    ),
                  // BUTTONS
                  // if (message.inviteButtonPrimary != null) ...[
                  const SizedBox(height: 10),

                  if (message.isEventBook == false)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // if (message.isEventBook) {
                              // } else {}
                              final featureTags =
                                  (message.eventSafetyFeatures as List? ?? [])
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final index = entry.key;
                                        final feature = entry.value;

                                        return {
                                          'id': feature is Map
                                              ? feature['id']?.toString() ?? ''
                                              : '',
                                          'label': feature is Map
                                              ? feature['label']?.toString() ??
                                                    ''
                                              : feature.toString(),
                                          'displayOrder': index,
                                        };
                                      })
                                      .toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                    eventId: message.eventId.toString(),
                                    title: message.eventTitle.toString(),
                                    date: message.eventDate.toString(),
                                    location: message.eventFullAddress
                                        .toString(),
                                    imageUrl: message.eventHeroImage.toString(),
                                    status: message.eventType.toString(),
                                    // price:
                                    //     (int.parse(
                                    //               message.eventMenEntryPrice
                                    //                   .toString(),
                                    //             ) *
                                    //             2)
                                    //         .toString(),
                                    price: getEventPrice(context, message),
                                    featureTags: featureTags,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.80,
                              decoration: BoxDecoration(
                                color: Mycolor.pink,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(
                                    color: Mycolor.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // if (hasSecondaryButton) ...[

                        // ],
                      ],
                    ),
                  // const Spacer(),

                  // ],

                  // // SAFETY NOTE (footer style, for date-now-plan card)
                  // if (message.inviteSafetyNote != null &&
                  //     message.inviteTitle != 'Sunset Soirée for Singles') ...[
                  //   const SizedBox(height: 12),
                  //   Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 10,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.greenSoft,
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             "🛡️${message.inviteSafetyNote!}",
                  //             style: AppText.body.copyWith(
                  //               color: AppColors.green,
                  //               fontSize: 12,
                  //               height: 1.35,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                  hSized10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatMessageTime(message.time) +
                            ((message.isMine)
                                ? (message.seen ? ' ✓✓' : ' ✓')
                                : ""),
                        style: AppText.body.copyWith(
                          color: const Color(0xff928d89),
                          fontSize: 14,
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

  Widget _richInviteButton({
    required String label,
    String? sub,
    required bool primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: primary ? Mycolor.pinkffeef2 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: primary
            ? Border.all(color: AppColors.primary)
            : Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              color: primary ? AppColors.primary : AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                color: primary ? AppColors.muted : AppColors.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _richInviteButton1({
    required String label,
    String? sub,
    required bool primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: primary ? AppColors.colore85a7a : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: primary
            ? Border.all(color: AppColors.colore85a7a)
            : Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              color: primary ? AppColors.white : AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                color: primary ? AppColors.ink : AppColors.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
  // ============================================================
  // RELATIONSHIP PROPOSAL
  // ============================================================

  Widget _relationshipTagProposalCard(ChatMessage message) {
    final isMine = message.isMine;

    String title = 'Relationship Proposal';
    String description = message.text.isNotEmpty
        ? message.text
        : 'Wants to update your relationship status.';

    final rawTag = (message.text).trim().toUpperCase();

    if (rawTag.contains('IN_RELATIONSHIP')) {
      title = 'In a Relationship';
      description = 'Committed and official.';
    } else if (rawTag.contains('OPEN_RELATIONSHIP')) {
      title = 'Open Relationship';
      description = 'Explore with transparency.';
    } else if (rawTag.contains('ENGAGED')) {
      title = 'Engaged';
      description = 'Planning for a future together.';
    } else if (rawTag.contains('DATE_TO_MARRY')) {
      title = 'Date to Marry';
      description = 'Committed to a future marriage.';
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8FA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withOpacity(.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RELATIONSHIP TAG',
                        style: AppText.eyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(title, style: AppText.h2.copyWith(fontSize: 17)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            RichText(
              text: TextSpan(
                style: AppText.body.copyWith(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.ink60,
                ),
                children: [
                  if (isMine)
                    const TextSpan(text: 'Relationship tag proposal sent.')
                  else ...[
                    TextSpan(
                      text:
                          '${widget.user.name} has proposed this relationship status to ',
                    ),
                    TextSpan(
                      text: title,
                      style: AppText.body.copyWith(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.ink, // dark
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' on both profiles.'),
                  ],
                ],
              ),
            ),

            if (!isMine) ...[
              const SizedBox(height: 10),
              // Text(message.relationshipStatus.toString()),
              if (message.relationshipStatus == "PENDING")
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            debugPrint(
                              "message>>>relationproposalId>>>${message.relationproposalId}",
                            );
                            final chatBloc = context.read<ChatBloc>();
                            chatBloc.add(
                              AcceptRelationshipTagProposalEvent(
                                proposalId: message.relationproposalId
                                    .toString(),
                              ),
                            );
                            // Accept API yahan add karenge
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            final chatBloc = context.read<ChatBloc>();
                            chatBloc.add(
                              RejectRelationshipTagProposalEvent(
                                proposalId: message.relationproposalId
                                    .toString(),
                              ),
                            );
                            // Maybe later
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Maybe later',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Mycolor.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMPOSER
  // ============================================================

  Widget _composer() {
    if (_isRecording) {
      return _recordingComposer();
    }

    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // =========================================================
            // REPLY PREVIEW
            // =========================================================
            if (_replyingTo != null) _replyComposerPreview(),

            // =========================================================
            // SINGLE MESSAGE COMPOSER
            // =========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // =======================================================
                // SINGLE TEXTFIELD
                // =======================================================
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // =================================================
                      // TEXT FIELD
                      // =================================================
                      TextField(
                        key: _textFieldKey,
                        controller: controller,
                        focusNode: _messageFocusNode,

                        // Single line when empty, multiline while typing
                        minLines: 1,
                        maxLines: 4,

                        textInputAction: controller.text.trim().isEmpty
                            ? TextInputAction.send
                            : TextInputAction.newline,

                        keyboardType: controller.text.trim().isEmpty
                            ? TextInputType.text
                            : TextInputType.multiline,

                        onTap: _closeExtrasPanel,

                        onSubmitted: (_) {
                          if (controller.text.trim().isNotEmpty) {
                            _sendText();
                          }
                        },

                        onChanged: (value) {
                          _onTypingChanged(value);
                          setState(() {});
                        },

                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: AppText.body.copyWith(
                            color: AppColors.muted,
                          ),

                          // =================================================
                          // EMPTY STATE
                          // =================================================
                          filled: controller.text.trim().isEmpty,
                          fillColor: AppColors.white,

                          // =================================================
                          // BORDER
                          // Empty = old border
                          // Typing = transparent
                          // =================================================
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(color: Colors.white),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(color: Colors.white),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(color: Colors.white),
                          ),

                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,

                          counterText: '',

                          // =================================================
                          // DYNAMIC PADDING
                          //
                          // Empty -> old TextField padding
                          // Typing -> left side Stack ke liye space
                          // =================================================
                          contentPadding: controller.text.trim().isEmpty
                              ? EdgeInsets.only(
                                  left: 0,
                                  right: 0,
                                  top: 20,
                                  bottom: 10,
                                )
                              : const EdgeInsets.only(
                                  left: 0,
                                  right: 4,
                                  top: 20,
                                  bottom: 10,
                                ),

                          // =================================================
                          // PREFIX ICON
                          //
                          // FIX: slot hamesha mounted rehta hai (empty ho ya
                          // typing), taaki uska width/padding hamesha input
                          // area ko same amount se push kare. Sirf visibility
                          // toggle hoti hai (opacity 0 + ignore pointer jab
                          // typing ho), taaki hint text aur real typed text
                          // hamesha same x-position se start ho.
                          // =================================================
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                              right: 2,
                              // left: 4,
                            ),
                            child: Opacity(
                              opacity: controller.text.trim().isEmpty ? 1 : 0,
                              child: IgnorePointer(
                                ignoring: controller.text.trim().isNotEmpty,
                                child: _smallAction(
                                  _showExtrasPanel
                                      ? Icons.keyboard_alt_outlined
                                      : Icons.emoji_emotions_outlined,
                                  () {
                                    _removeMessageFocus();
                                    _toggleExtrasPanel();
                                  },
                                ),
                              ),
                            ),
                          ),

                          // =================================================
                          // EMPTY STATE RIGHT ACTIONS
                          // =================================================
                          suffixIcon: controller.text.trim().isEmpty
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ---------------------------------------
                                    // TRY
                                    // ---------------------------------------
                                    GestureDetector(
                                      onTap: _openSaySomethingBetterSheet,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '💡',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Try',
                                              style: AppText.pill.copyWith(
                                                color: AppColors.primary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // ---------------------------------------
                                    // ATTACH
                                    // ---------------------------------------
                                    _smallAction(
                                      Icons.attach_file_rounded,
                                      _openShareSheet,
                                    ),

                                    const SizedBox(width: 6),

                                    // ---------------------------------------
                                    // CAMERA
                                    // ---------------------------------------
                                    GestureDetector(
                                      onTap: _openGiftPanel,
                                      child: Material(
                                        elevation: 4,
                                        shadowColor: Colors.black.withOpacity(
                                          0.25,
                                        ),
                                        shape: const CircleBorder(),
                                        color: Mycolor.white,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Mycolor.white,
                                          child: Image.asset(
                                            "assets/gift.png",
                                            height: 25,
                                            width: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      // =================================================
                      // TYPING STATE LEFT ACTION STACK
                      //
                      // Empty hone par ye hidden hai.
                      // =================================================
                      if (controller.text.trim().isNotEmpty)
                        Positioned(
                          left: 4.7,
                          bottom: 4,
                          child: Builder(
                            builder: (context) {
                              final int lineCount = _getLineCount();
                              debugPrint("lineCount>>>> $lineCount");

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CAMERA (3+ lines)
                                  if (lineCount >= 3)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 0,
                                        left: 0,
                                      ),
                                      child: _smallAction(
                                        Icons.camera_alt_outlined,
                                        _openCamera,
                                      ),
                                    ),

                                  // ATTACH (2+ lines)
                                  if (lineCount >= 2)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 0,
                                        left: 0,
                                      ),
                                      child: _smallAction(
                                        Icons.attach_file_rounded,
                                        _openShareSheet,
                                      ),
                                    ),

                                  // EMOJI / KEYBOARD
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 6,
                                      left: 1,
                                    ),
                                    child: _smallAction(
                                      _showExtrasPanel
                                          ? Icons.keyboard_alt_outlined
                                          : Icons.emoji_emotions_outlined,
                                      _toggleExtrasPanel,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // =======================================================
                // MIC / SEND
                // =======================================================
                GestureDetector(
                  onTap: controller.text.trim().isEmpty
                      ? _startRecording
                      : _sendText,
                  child: Container(
                    width: 35,
                    height: 35,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: controller.text.trim().isEmpty
                        ? const Icon(
                            Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Transform.rotate(
                              angle: -0.7,
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),

            // =========================================================
            // EXTRAS PANEL
            // =========================================================
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _showExtrasPanel
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ComposerExtrasPanel(
                        initialTab: _extrasInitialTab,
                        onEmojiSelected: _insertEmoji,
                        onStickerSelected: _onStickerSelected,
                        onMemeSelected: _onMemeSelected,
                        onEffectSelected: _onEffectSelected,
                        onGifSelected: _onGifSelected,
                        onGiftSelected: _onGiftItemSelected,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordingComposer() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording...',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _recordingTime(),
                    style: AppText.sub.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _stopRecordingAndSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 35,
        height: 30,

        child: Icon(icon, color: AppColors.ink60, size: 20),
      ),
    );
  }

  // ============================================================
  // SHARE SHEET + ATTACHMENTS
  // ============================================================

  void _openShareSheet() {
    _removeMessageFocus();
    _closeExtrasPanel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text('Share with ${widget.user.name}', style: AppText.h2),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 10,
                    childAspectRatio: .8,
                    children: [
                      _shareOption(
                        Icons.photo_outlined,
                        "assets/gallery.jpeg",
                        'Gallery',
                        const Color(0xFF7C6CF0),
                        _pickGallery,
                      ),
                      _shareOption(
                        Icons.camera_alt_outlined,
                        "assets/camera.jpg",
                        'Camera',
                        Colors.transparent,
                        () async {
                          debugPrint('📷 SHARE CAMERA: clicked');

                          // Sirf BottomSheet close karo
                          Navigator.pop(sheetContext);

                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );

                          if (!mounted) return;

                          await _captureImage();
                        },
                      ),
                      _shareOption(
                        Icons.music_note_outlined,
                        "assets/audio.jpg",
                        'Audio',
                        const Color(0xFFE8A53D),
                        _pickAudio,
                      ),
                      _shareOption(
                        Icons.insert_drive_file_outlined,
                        "assets/document.jpg",
                        'Document',
                        const Color(0xFF3D8BE8),
                        _pickDocument,
                      ),
                      _shareOption(
                        Icons.location_on_outlined,
                        "assets/location.jpg",
                        'Location',
                        const Color(0xFF2EAF6B),
                        _sendLocation,
                      ),
                      _shareOption(
                        Icons.person_outline,
                        "assets/contact.jpg",
                        'Contact',
                        const Color(0xFF8A8680),
                        _pickContact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shareOption(
    IconData icon,
    String iconPath,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            // child: Icon(icon, color: Colors.white, size: 24),
            child: iconPath == ""
                ? Icon(icon, color: Colors.white, size: 24)
                : Center(
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: Image.asset(iconPath, fit: BoxFit.cover),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sub.copyWith(color: AppColors.ink60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _pickGallery() async {
    Navigator.pop(context);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      _showImageSendLoader();
      try {
        for (final picked in result.files) {
          final path = picked.path;
          if (path == null || path.isEmpty) continue;

          final extension = path.split('.').last.toLowerCase();
          final xFile = XFile(path);

          if ({
            'jpg',
            'jpeg',
            'png',
            'webp',
            'heic',
            'heif',
          }.contains(extension)) {
            await _uploadAndSendImage(xFile);
          } else if ({
            'mp4',
            'mov',
            'm4v',
            'avi',
            'mkv',
            'webm',
            '3gp',
          }.contains(extension)) {
            await _uploadAndSendVideo(
              xFile,
              fileName: picked.name,
              fileSize: picked.size,
            );
          } else {
            debugPrint('⚠️ Unsupported gallery media: ${picked.name}');
          }
        }
      } finally {
        _hideImageSendLoader();
      }
    } catch (e, st) {
      debugPrint('❌ GALLERY IMAGE ERROR: $e');
      debugPrint('$st');
      if (mounted) _toast('Unable to send image');
    }
  }

  // ============================================================
  // IMAGE: UPLOAD FIRST, THEN SEND mediaUrl THROUGH SOCKET
  // ============================================================
  Future<File?> _compressChatImage(XFile image) async {
    try {
      final originalBytes = await image.readAsBytes();
      debugPrint(
        '🖼️ ORIGINAL IMAGE SIZE => '
        '${(originalBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      // ==========================================================
      // Heavy decode/resize/encode work is offloaded to a background
      // isolate via compute(). Doing this on the main isolate blocks
      // the UI thread for large camera photos (often several MB /
      // 3000x4000px+), which can freeze the app long enough for the
      // OS / debugger to consider the process unresponsive
      // ("Lost connection to device", callGcSupression NPE noise).
      // ==========================================================
      final jpgBytes = await compute(encodeChatImageIsolate, originalBytes);

      if (jpgBytes == null) {
        debugPrint('❌ IMAGE DECODE/ENCODE FAILED');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/chat_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(jpgBytes, flush: true);

      debugPrint(
        '✅ COMPRESSED IMAGE SIZE => '
        '${(jpgBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      return file;
    } catch (e, st) {
      debugPrint('❌ IMAGE COMPRESSION ERROR => $e');
      debugPrint('$st');
      return null;
    }
  }

  Future<void> _uploadAndSendImage(XFile image) async {
    final conversationId = widget.user.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      debugPrint('❌ IMAGE: conversationId missing');
      return;
    }

    try {
      // ==========================================================
      // TOKEN
      // ==========================================================

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("auth_token");
      // ==========================================================
      // COMPRESS
      // ==========================================================

      debugPrint('==========================================');
      debugPrint('📤 IMAGE UPLOAD START');
      debugPrint('📤 ORIGINAL FILE => ${image.path}');

      final compressedFile = await _compressChatImage(image);

      if (compressedFile == null) {
        throw Exception('Unable to compress image');
      }

      final compressedSize = await compressedFile.length();

      debugPrint(
        '📦 UPLOAD FILE SIZE => '
        '${(compressedSize / 1024).toStringAsFixed(2)} KB',
      );

      // ==========================================================
      // UPLOAD
      // ==========================================================

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.welvors.com/api/chat/media/upload'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization':
            token != null && token.toLowerCase().startsWith('bearer ')
            ? token
            : 'Bearer $token',
      });

      // IMPORTANT
      request.fields['mediaType'] = 'IMAGE';

      debugPrint('📤 MEDIA TYPE => IMAGE');

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          compressedFile.path,
          filename: 'chat_image.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      debugPrint(
        '📤 UPLOAD URL => '
        'https://api.welvors.com/api/chat/media/upload',
      );

      debugPrint('📤 CONVERSATION ID => $conversationId');
      debugPrint('📤 FILE => ${compressedFile.path}');

      // ==========================================================
      // SEND UPLOAD REQUEST
      // ==========================================================

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint(
        '📥 IMAGE UPLOAD STATUS => '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 IMAGE UPLOAD BODY => '
        '${response.body}',
      );

      // ==========================================================
      // 413
      // ==========================================================

      if (response.statusCode == 413) {
        debugPrint('❌ HTTP 413: REQUEST TOO LARGE');

        throw Exception('Image is too large for server upload limit');
      }

      // ==========================================================
      // HTTP ERROR
      // ==========================================================

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Image upload failed: HTTP ${response.statusCode}');
      }

      // ==========================================================
      // PARSE RESPONSE
      // ==========================================================

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid upload response');
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Image upload failed',
        );
      }

      // ==========================================================
      // GET DATA
      // ==========================================================

      final rawData = decoded['data'];

      if (rawData is! Map) {
        throw Exception('Upload response data missing');
      }

      final data = Map<String, dynamic>.from(rawData);

      // ==========================================================
      // GET IMAGE URL
      // ==========================================================

      final mediaUrl = (data['url'] ?? '').toString().trim();

      if (mediaUrl.isEmpty) {
        throw Exception('Upload response data.url is empty');
      }

      // ==========================================================
      // SEND IMAGE MESSAGE
      // ==========================================================

      final reply = _replyingTo;

      if (!mounted) return;

      context.read<ChatBloc>().add(
        SendMessageEvent(
          chatId: widget.user.id,
          conversationId: conversationId,

          // IMPORTANT
          type: ChatMessageType.image,

          // IMPORTANT
          typemsg: 'IMAGE',

          // IMPORTANT
          message: null,

          // Uploaded ImageKit URL
          imageUrl: mediaUrl,

          replyToId: reply?.id,
          replyText: reply?.text,
          replyImageUrl: reply?.imageUrl,
          replyFileUrl: reply?.fileUrl,
          replyType: reply?.type,
        ),
      );

      // ==========================================================
      // CLEAR REPLY
      // ==========================================================

      setState(() {
        _replyingTo = null;
      });

      // ==========================================================
      // SCROLL
      // ==========================================================

      _scrollToBottom();

      debugPrint('✅ IMAGE MESSAGE EVENT DISPATCHED');
    } catch (e, st) {
      debugPrint('❌ IMAGE UPLOAD/SEND ERROR => $e');

      debugPrint('$st');

      if (mounted) {
        _toast(
          e.toString().contains('too large')
              ? 'Image is too large'
              : 'Unable to send image',
        );
      }
    }
  }

  bool _openingCamera = false;
  void _removeMessageFocus() {
    if (_messageFocusNode.hasFocus) {
      _messageFocusNode.unfocus();
    }
  }

  Future<void> _openCamera() async {
    _removeMessageFocus();
    debugPrint('📷 CAMERA: _openCamera START');

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      debugPrint('❌ CAMERA: widget not mounted');
      return;
    }

    debugPrint('📷 CAMERA: calling _captureImage');

    await _captureImage();
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const custom_camera.CustomCameraScreen(),
        ),
      );

      debugPrint('📷 CAMERA: picker returned');

      if (image == null) {
        debugPrint('⚠️ CAMERA: returned NULL');
        debugPrint('⚠️ CAMERA: user cancelled OR Activity was recreated');
        return;
      }

      debugPrint('✅ CAMERA: image received');
      debugPrint('📷 CAMERA PATH: ${image.path}');

      if (!mounted) {
        debugPrint('⚠️ CAMERA: widget not mounted after image received');
        return;
      }

      _showImageSendLoader();

      try {
        debugPrint('📤 CAMERA: uploading image...');

        await _uploadAndSendImage(image);

        debugPrint('✅ CAMERA: upload/send successful');

        if (mounted) {
          _toast('Photo sent ✓');
        }
      } finally {
        _hideImageSendLoader();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ CAMERA ERROR: $e');
      debugPrint('❌ CAMERA STACKTRACE: $stackTrace');

      if (mounted) {
        if (e.toString().contains('upload') ||
            e.toString().contains('Upload')) {
          _toast('Unable to send photo');
        } else {
          _toast('Unable to open camera');
        }
      }
    }
  }

  // ============================================================
  // IMAGE SEND LOADER (SAFE & MODERN)
  // ============================================================
  bool _isImageSendLoaderOpen = false;

  void _showImageSendLoader() {
    if (_isImageSendLoaderOpen || !mounted) return;
    _isImageSendLoaderOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false, // WillPopScope ki jagah Flutter standard PopScope
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  void _hideImageSendLoader() {
    if (!_isImageSendLoaderOpen || !mounted) return;
    _isImageSendLoaderOpen = false;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _pickAudio() async {
    if (Navigator.canPop(context)) Navigator.pop(context);

    try {
      final result = await FilePicker.pickFiles(type: FileType.audio);
      if (result == null || result.files.isEmpty || !mounted) return;

      final file = result.files.first;
      if (file.path == null) return;

      _sendAttachment(
        type: ChatMessageType.audio,
        text: file.name,
        filePath: file.path,
        fileName: file.name,
        fileSize: _formatFileSize(file.size),
      );
      _toast('Audio sent ✓');
    } catch (e) {
      _toast('Unable to select audio');
    }
  }

  Future<void> _pickDocument() async {
    if (Navigator.canPop(context)) Navigator.pop(context);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'csv',
          'zip',
        ],
      );

      if (result == null || result.files.isEmpty || !mounted) return;
      final file = result.files.first;
      if (file.path == null || file.path!.isEmpty) return;

      _showImageSendLoader();
      await _uploadAndSendFile(
        file.path!,
        mediaType: 'FILE',
        messageType: ChatMessageType.document,
        fileName: file.name,
        fileSize: file.size,
      );
      _toast('Document sent ✓');
    } catch (e) {
      _toast('Unable to select document');
    } finally {
      _hideImageSendLoader();
    }
  }

  Future<void> _uploadAndSendFile(
    String filePath, {
    required String mediaType,
    required ChatMessageType messageType,
    required String fileName,
    required int fileSize,
  }) async {
    final conversationId = widget.user.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      _toast('Conversation unavailable');
      return;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception('File not found');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.welvors.com/api/chat/media/upload'),
      );
      request.headers['Accept'] = 'application/json';
      if (token.isNotEmpty) {
        request.headers['Authorization'] =
            token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
      }
      request.fields['mediaType'] = mediaType;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
          contentType: http.MediaType.parse(
            _attachmentContentType(filePath, mediaType),
          ),
        ),
      );

      debugPrint('📤 $mediaType UPLOAD => $fileName');
      final response = await http.Response.fromStream(await request.send());
      debugPrint(
        '📥 $mediaType UPLOAD ${response.statusCode} => ${response.body}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Upload failed: HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final data = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'])
          : <String, dynamic>{};
      final mediaUrl = (data['url'] ?? '').toString().trim();
      final serverFileName = (data['fileName'] ?? data['filename'] ?? fileName)
          .toString();
      final serverSize = data['size'];

      if (mediaUrl.isEmpty)
        throw Exception('Upload succeeded but data.url is empty');

      final reply = _replyingTo;
      context.read<ChatBloc>().add(
        SendMessageEvent(
          chatId: widget.user.id,
          conversationId: conversationId,
          type: messageType,
          typemsg: mediaType,
          message: null,
          audioUrl: mediaType == 'AUDIO' ? mediaUrl : null,
          fileUrl: mediaType == 'FILE' ? mediaUrl : null,
          fileName: serverFileName.isEmpty ? fileName : serverFileName,
          fileSize: serverSize is num
              ? _formatFileSize(serverSize.toInt())
              : _formatFileSize(fileSize),
          replyToId: reply?.id,
          replyText: reply?.text,
          replyImageUrl: reply?.imageUrl,
          replyFileUrl: reply?.fileUrl,
          replyType: reply?.type,
        ),
      );

      setState(() => _replyingTo = null);
      _scrollToBottom();
      _toast(mediaType == 'FILE' ? 'File sent ✓' : 'Audio sent ✓');
    } catch (e, st) {
      debugPrint('❌ $mediaType UPLOAD/SEND ERROR => $e');
      debugPrint('$st');
      if (mounted) _toast('Unable to send file');
    }
  }

  String _attachmentContentType(String path, String mediaType) {
    if (mediaType == 'AUDIO') {
      final ext = path.split('.').last.toLowerCase();
      const audio = {
        'mp3': 'audio/mpeg',
        'wav': 'audio/wav',
        'ogg': 'audio/ogg',
        'aac': 'audio/aac',
        'm4a': 'audio/mp4',
        'mp4': 'audio/mp4',
        'webm': 'audio/webm',
      };
      return audio[ext] ?? 'application/octet-stream';
    }
    final ext = path.split('.').last.toLowerCase();
    const files = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'zip': 'application/zip',
    };
    return files[ext] ?? 'application/octet-stream';
  }

  Future<void> _uploadAndSendVideo(
    XFile video, {
    required String fileName,
    required int fileSize,
  }) async {
    final conversationId = widget.user.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      _toast('Conversation unavailable');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.welvors.com/api/chat/media/upload'),
      );
      request.headers['Accept'] = 'application/json';
      if (token.isNotEmpty) {
        request.headers['Authorization'] =
            token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
      }
      request.fields['mediaType'] = 'VIDEO';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          video.path,
          filename: fileName,
          contentType: http.MediaType.parse(_videoContentType(video.path)),
        ),
      );

      debugPrint('📤 VIDEO UPLOAD => $fileName');
      final response = await http.Response.fromStream(await request.send());
      debugPrint('📥 VIDEO UPLOAD ${response.statusCode} => ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Video upload failed: HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      final data = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'])
          : <String, dynamic>{};
      final mediaUrl = (data['url'] ?? '').toString().trim();
      if (mediaUrl.isEmpty) throw Exception('Video upload data.url is empty');

      final reply = _replyingTo;
      context.read<ChatBloc>().add(
        SendMessageEvent(
          chatId: widget.user.id,
          conversationId: conversationId,
          type: ChatMessageType.video,
          typemsg: 'VIDEO',
          message: null,
          videoUrl: mediaUrl,
          fileName: fileName,
          fileSize: _formatFileSize(fileSize),
          replyToId: reply?.id,
          replyText: reply?.text,
          replyImageUrl: reply?.imageUrl,
          replyFileUrl: reply?.fileUrl,
          replyType: reply?.type,
        ),
      );
      setState(() => _replyingTo = null);
      _scrollToBottom();
      _toast('Video sent ✓');
    } catch (e, st) {
      debugPrint('❌ VIDEO UPLOAD/SEND ERROR => $e');
      debugPrint('$st');
      if (mounted) _toast('Unable to send video');
    }
  }

  String _videoContentType(String path) {
    switch (path.split('.').last.toLowerCase()) {
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'mkv':
        return 'video/x-matroska';
      case '3gp':
        return 'video/3gpp';
      default:
        return 'video/mp4';
    }
  }

  Future<void> _sendLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast('Please enable location service');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _toast('Location permission denied');
        return;
      }

      // Get current location ONLY to open the picker initially.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final selected = await LocationMapScreen.pick(
        context: context,
        latitude: position.latitude,
        longitude: position.longitude,
        label: 'Current Location',
      );

      if (!mounted || selected == null) return;

      debugPrint('📍 SELECTED LOCATION');
      debugPrint('Latitude  : ${selected.latitude}');
      debugPrint('Longitude : ${selected.longitude}');
      debugPrint('Label     : ${selected.label}');
      debugPrint('Address   : ${selected.address}');

      _sendAttachment(
        type: ChatMessageType.location,

        // Address ko message text me bhejo
        text: selected.address.isNotEmpty ? selected.address : selected.label,

        latitude: selected.latitude,
        longitude: selected.longitude,

        // Actual selected address
        locationLabel: selected.address.isNotEmpty
            ? selected.address
            : selected.label,
      );
      Navigator.pop(context);
      _toast('Location sent ✓');
    } catch (e, st) {
      debugPrint('❌ LOCATION PICKER ERROR => $e');
      debugPrint('$st');

      if (mounted) {
        _toast('Unable to get location');
      }
    }
  }

  Future<void> _pickContact() async {
    Navigator.pop(context);

    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      debugPrint('CONTACT PERMISSION: $permission');

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        _toast('Contact permission denied');
        return;
      }

      debugPrint('CONTACT PERMISSION: $permission');

      if (permission != PermissionStatus.granted) {
        _toast('Contact permission denied');
        return;
      }

      final contacts = await FlutterContacts.getAll(
        properties: const {ContactProperty.phone},
      );

      if (!mounted) return;

      if (contacts.isEmpty) {
        _toast('No contacts found');
        return;
      }

      final selected = await showModalBottomSheet<Contact>(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.75,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text('Select Contact', style: AppText.h1),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (_, index) {
                        final contact = contacts[index];

                        final phone = contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : '';

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              contact.displayName!.isNotEmpty
                                  ? contact.displayName![0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(contact.displayName!),
                          subtitle: Text(
                            phone.isNotEmpty ? phone : 'No phone number',
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext, contact);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted || selected == null) return;

      final phone = selected.phones.isNotEmpty
          ? selected.phones.first.number
          : '';

      _sendAttachment(
        type: ChatMessageType.contact,
        text: selected.displayName!,
        fileName: phone,
      );

      _toast('Contact sent ✓');
    } catch (e, stackTrace) {
      debugPrint('CONTACT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _toast('Unable to select contact');
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _sendAttachment({
    required ChatMessageType type,
    String text = '',
    String? filePath,
    String? fileName,
    String? fileSize,
    String? imageUrl,
    String? audioUrl,
    String? locationLabel,

    // LOCATION
    double? latitude,
    double? longitude,
  }) {
    final reply = _replyingTo;

    final bool isContact = type == ChatMessageType.contact;

    final bool isLocation = type == ChatMessageType.location;

    // ============================================================
    // CONTACT
    // text     = contact name
    // fileName = contact phone
    // ============================================================
    final String? contactName = isContact ? text.trim() : null;

    final String? contactPhoneNumber = isContact
        ? (fileName ?? '').trim()
        : null;

    // ============================================================
    // DEBUG
    // ============================================================
    debugPrint('================ SEND ATTACHMENT ================');

    debugPrint('chatId              : ${widget.user.id}');

    debugPrint('conversationId      : ${widget.user.conversationId}');

    debugPrint('type                : $type');

    debugPrint(
      'typemsg             : '
      '${isContact
          ? "CONTACT"
          : isLocation
          ? "LOCATION"
          : "Attachment"}',
    );

    debugPrint('message/text        : $text');

    debugPrint('filePath            : $filePath');

    debugPrint('fileName            : $fileName');

    debugPrint('fileSize            : $fileSize');

    // ============================================================
    // CONTACT DEBUG
    // ============================================================
    if (isContact) {
      debugPrint('---------------- CONTACT DATA ----------------');

      debugPrint('contactName         : $contactName');

      debugPrint('contactPhoneNumber  : $contactPhoneNumber');

      debugPrint('------------------------------------------------');
    }

    // ============================================================
    // LOCATION DEBUG
    // ============================================================
    if (isLocation) {
      debugPrint('---------------- LOCATION DATA ----------------');

      debugPrint('latitude            : $latitude');

      debugPrint('longitude           : $longitude');

      debugPrint('locationLabel       : $locationLabel');

      debugPrint('------------------------------------------------');
    }

    // ============================================================
    // SEND EVENT
    // ============================================================
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        conversationId: widget.user.conversationId,

        type: type,

        // ========================================================
        // CONTACT
        // ========================================================
        contactName: contactName,
        contactPhoneNumber: contactPhoneNumber,

        // ========================================================
        // OTHER ATTACHMENTS
        // ========================================================
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        fileUrl: filePath,
        fileSize: fileSize,

        // ========================================================
        // LOCATION
        // ========================================================
        locationLabel: locationLabel,

        // Agar SendMessageEvent mein fields hain
        latitude: latitude,
        longitude: longitude,

        // ========================================================
        // MESSAGE TYPE
        // ========================================================
        typemsg: isContact
            ? 'CONTACT'
            : isLocation
            ? 'LOCATION'
            : 'Attachment',

        // LOCATION should also have a readable text fallback so the
        // location card never renders an empty subtitle.
        message: isLocation ? (locationLabel ?? text) : text,

        // ========================================================
        // REPLY
        // ========================================================
        replyToId: reply?.id,
        replyText: reply?.text,
        replyImageUrl: reply?.imageUrl,
        replyFileUrl: reply?.fileUrl,
        replyType: reply?.type,
      ),
    );

    // ============================================================
    // CLEAR REPLY
    // ============================================================
    setState(() {
      _replyingTo = null;
    });

    // ============================================================
    // SCROLL
    // ============================================================
    _scrollToBottom();
  }

  // ============================================================
  // "SAY SOMETHING BETTER" SHEET (opened from the Try pill)
  // ============================================================

  void _openSaySomethingBetterSheet() {
    _closeExtrasPanel();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SaySomethingBetterSheet(
          onPick: (line) {
            controller.text = line;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
            setState(() {});
            Navigator.pop(context);
            _toast('Added — edit it before sending ✎');
          },
        );
      },
    );
  }

  void _openUnmatchSheet() {
    final reasons = [
      'No connection',
      'Chat went cold',
      'Met someone else',
      'They were rude',
      'Different intentions',
      'Too far away',
      'Felt unsafe',
      'Something else',
    ];
    final selectedReason = ValueNotifier<String?>(null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          bottom: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.90,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.line,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Unmatch with ${widget.user.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(sheetContext),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This removes the match and deletes the chat for both of you.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Mycolor.pinkffeef2,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Unmatching: ${widget.user.name}, ${widget.user.age} • this can\'t be undone',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE85D7D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why are you unmatching? *',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Only used to improve your matches — never shown to her.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: selectedReason,
                            builder: (context, current, _) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: reasons.map((reason) {
                                  final isSelected = current == reason;
                                  return ChoiceChip(
                                    label: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isSelected
                                            ? const Color(0xFFE85D7D)
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      selectedReason.value = reason;
                                    },
                                    backgroundColor: Colors.white,
                                    showCheckmark: false,
                                    selectedColor: const Color(0xFFFCEAF0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFFE85D7D)
                                            : Colors.grey.shade300,
                                        width: 1.2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Anything else?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Optional — tell us more so we show you better people.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _unmatchNoteController,
                              minLines: 3,
                              maxLines: 5,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Add a note...',
                                hintStyle: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EFEA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Note:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Gifts and roses already sent aren’t refunded. You won’t see each other in discovery again.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<String?>(
                          valueListenable: selectedReason,
                          builder: (context, reason, _) {
                            final enabled = reason != null;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: enabled
                                    ? () async {
                                        final reason = selectedReason.value;

                                        if (reason == null ||
                                            reason.trim().isEmpty) {
                                          return;
                                        }

                                        final note = _unmatchNoteController.text
                                            .trim();

                                        try {
                                          debugPrint('💔 UNMATCH API CALL');
                                          debugPrint(
                                            'Other User ID: ${widget.user.userId}',
                                          );
                                          debugPrint('Reason: $reason');
                                          debugPrint('Note: $note');

                                          await ChatRepository().unmatchUser(
                                            otherUserId: widget.user.userId,
                                            reason: reason,
                                            note: note.isEmpty ? null : note,
                                          );

                                          if (!mounted) return;

                                          // Bottom sheet close
                                          Navigator.pop(sheetContext);

                                          // Unmatched state
                                          setState(() {
                                            _isUnmatched = true;
                                          });

                                          _toast('User unmatched successfully');
                                        } catch (e) {
                                          debugPrint('❌ UNMATCH API ERROR: $e');

                                          if (!mounted) return;

                                          _toast(
                                            e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                          );
                                        } // repository
                                        // Navigator.pop(sheetContext);
                                        // if (mounted) {
                                        //   setState(() => _isUnmatched = true);
                                        // }
                                      }
                                    : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE85D7D),
                                  disabledBackgroundColor: Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                  shadowColor: const Color(
                                    0xFFE85D7D,
                                  ).withOpacity(0.25),
                                ),
                                child: Text(
                                  'Unmatch',
                                  style: TextStyle(
                                    color: enabled
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.pop(sheetContext),
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Keep the match',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE SHEET (opened from the ⋮ menu)
  // ============================================================

  void _openProfileSheet(bool _isBlocked) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(sheetContext).size.height,
          width: double.infinity,
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hSized30,
                // ============================================================
                // TOP APP BAR / PROFILE HEADER
                // ============================================================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 20,
                  ),
                  child: SizedBox(
                    height: 82,
                    child: Row(
                      children: [
                        // BACK BUTTON
                        IconButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 21,
                            color: Colors.black,
                          ),
                        ),

                        // CENTER PROFILE IMAGE
                        Expanded(
                          child: Center(
                            child: _avatar(
                              _liveImage,
                              size: 72,
                              name: _liveName,
                              age: _liveAge.toString(),
                            ),
                          ),
                        ),

                        // Keeps avatar exactly centered
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                // ============================================================
                // PROFILE NAME
                // ============================================================
                const SizedBox(height: 5),

                Center(
                  child: Text(
                    _liveAge > 0 ? '$_liveName, $_liveAge' : _liveName,
                    style: AppText.h1.copyWith(fontSize: 20),
                  ),
                ),

                // ============================================================
                // ONLINE / OFFLINE
                // ============================================================
                const SizedBox(height: 4),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _isUserOnline
                              ? AppColors.green
                              : AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isUserOnline ? 'Online' : 'Offline',
                        style: AppText.body.copyWith(
                          color: _isUserOnline
                              ? AppColors.green
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================================
                // LOCATION
                // ============================================================
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

                // ============================================================
                // BANNER
                // ============================================================
                AnimatedSize(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    opacity: 1.0,
                    child: _bannerIndex == 0
                        ? _giftUnlockProgress()
                        : _relationshipProgress(),
                  ),
                ),

                hSized20,

                Divider(color: Mycolor.grey1, height: 2),

                hSized10,

                // ============================================================
                // SCROLLABLE CONTENT
                // ============================================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ======================================================
                        // PREFERENCES
                        // ======================================================
                        Text('PREFERENCES', style: AppText.eyebrow),

                        const SizedBox(height: 6),

                        // ======================================================
                        // RELATIONSHIP TAGS
                        // ======================================================
                        _sheetTile(
                          color: Mycolor.pinkffeef2,
                          Icons.favorite,
                          'Relationship Tags',
                          'Define how you connect',
                          titleColor: const Color(0xffe15555),
                          textColor: Colors.black,
                          iconcolor: const Color(0xffe15555),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                          ),

                          // ----------------------------------------------------
                          // RELATIONSHIP TAG TAP
                          // ----------------------------------------------------
                          onTap: () {
                            if (_isBlocked == false) {
                              _openRelationshipTagSheet(false);
                            } else {
                              final overlay = Overlay.of(context);

                              late OverlayEntry entry;

                              entry = OverlayEntry(
                                builder: (context) {
                                  return Positioned(
                                    top:
                                        MediaQuery.of(context).padding.top + 10,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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

                              Future.delayed(const Duration(seconds: 2), () {
                                if (entry.mounted) {
                                  entry.remove();
                                }
                              });
                            }
                          },
                        ),

                        // ======================================================
                        // MUTE NOTIFICATIONS
                        // ======================================================
                        _sheetToggleTile(
                          Icons.notifications_off_outlined,
                          'Mute Notifications',
                          Mycolor.colorf5f2ec,
                        ),

                        // ======================================================
                        // MEDIA LINKS DOCS
                        // ======================================================
                        _sheetTile(
                          color: Mycolor.colorf5f2ec,
                          Icons.perm_media_outlined,
                          'Media, Links & Docs',
                          '${(() {
                            final sharedMessages = context.read<ChatBloc>().state.messages[_messageKey] ?? const <ChatMessage>[];

                            return sharedMessages.where((m) => m.type == ChatMessageType.image || m.type == ChatMessageType.video || m.type == ChatMessageType.audio || m.type == ChatMessageType.document || m.text.contains('http://') || m.text.contains('https://')).length;
                          })()} shared items',
                          titleColor: Colors.black,
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                          ),

                          // ----------------------------------------------------
                          // MEDIA TAP
                          // ----------------------------------------------------
                          onTap: () {
                            Navigator.pop(sheetContext);

                            final sharedMessages = List<ChatMessage>.from(
                              context
                                      .read<ChatBloc>()
                                      .state
                                      .messages[_messageKey] ??
                                  const <ChatMessage>[],
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatMediaLinksDocsScreen(
                                  userName: _liveName,
                                  conversationId:
                                      "d8a02aa0-0f15-4c6a-bb82-5ace6aac183e",
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // ======================================================
                        // PRIVACY & SAFETY
                        // ======================================================
                        Text('PRIVACY & SAFETY', style: AppText.eyebrow),

                        const SizedBox(height: 6),

                        // ======================================================
                        // REPORT USER
                        // ======================================================
                        _sheetTile(
                          Icons.flag_outlined,
                          titleColor: const Color(0xffe15555),
                          iconcolor: const Color(0xffe15555),
                          textColor: const Color(0xffe15555),
                          'Report User',
                          null,
                          color: Mycolor.pinkffeef2,
                          onTap: () {
                            Navigator.pop(sheetContext, 'report');
                          },
                        ),

                        // ======================================================
                        // BLOCK USER
                        // ======================================================
                        (_isBlocked == false)
                            ? _sheetTile(
                                Icons.block,
                                'Block ${widget.user.name}',
                                iconcolor: const Color(0xffe15555),
                                textColor: const Color(0xffe15555),
                                null,
                                titleColor: const Color(0xffe15555),
                                color: Mycolor.pinkffeef2,
                                onTap: () {
                                  Navigator.pop(sheetContext, 'block');
                                },
                              )
                            : Container(),

                        // ======================================================
                        // UNMATCH
                        // ======================================================
                        if (_isBlocked == false)
                          _sheetTile(
                            Icons.heart_broken,
                            'Unmatch',
                            titleColor: const Color(0xffe15555),
                            iconcolor: const Color(0xffe15555),
                            textColor: const Color(0xffe15555),
                            'Removes the match and this chat',
                            color: Mycolor.pinkffeef2,
                            onTap: () {
                              Navigator.pop(sheetContext, 'unmatch');
                            },
                          ),

                        const SizedBox(height: 6),

                        // ======================================================
                        // CLEAR CHAT
                        // ======================================================
                        _sheetTile(
                          Icons.cleaning_services_outlined,
                          iconcolor: const Color(0xffe15555),
                          'Clear Chat',
                          titleColor: const Color(0xffe15555),
                          textColor: const Color(0xffe15555),
                          'Remove all messages from this chat',
                          color: Mycolor.pinkffeef2,

                          onTap: () {
                            Navigator.pop(sheetContext);

                            // Small delay ensures bottom sheet
                            // is completely closed first.
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () {
                                if (mounted) {
                                  _confirmClearChat();
                                }
                              },
                            );
                          },
                        ),

                        // ======================================================
                        // DELETE CONVERSATION
                        // ======================================================
                        _sheetTile(
                          Icons.delete_outline_rounded,
                          iconcolor: const Color(0xffe15555),
                          textColor: const Color(0xffe15555),
                          'Delete Conversation',
                          'Remove this conversation from your chat list',
                          color: Mycolor.pinkffeef2,
                          titleColor: const Color(0xffe15555),

                          onTap: () {
                            Navigator.pop(sheetContext);

                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () {
                                if (mounted) {
                                  _confirmDeleteConversation();
                                }
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
          ),
        );
      },
    ).then((action) {
      if (!mounted || action == null) return;

      debugPrint("action>>>>>>${action}");

      switch (action) {
        case 'report':
          _showReportUserSheet();
          break;

        case 'block':
          _showBlockUserSheet();
          break;

        case 'unmatch':
          _openUnmatchSheet();
          break;
      }
    });
  }

  // Opened only after the profile sheet has fully finished closing
  // (see .then() above) — avoids the Navigator race where a second
  // modal opened in the same frame as the first one's pop gets dropped.
  void _showReportUserSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: ReportUserDialog(
            userName: widget.user.name,
            userAge: widget.user.age,
            matchedDate: 'matched ${widget.user.match}',

            onSubmit: (reason, description, alsoBlock) async {
              final reportedId = widget.user.userId.trim();

              debugPrint('🚫 REPORT USER CLICKED');
              debugPrint('🚫 reportedId => $reportedId');
              debugPrint('🚫 reason => $reason');
              debugPrint('🚫 description => $description');
              debugPrint('🚫 alsoBlock => $alsoBlock');

              if (reportedId.isEmpty) {
                throw Exception('User ID is missing');
              }

              final repository = ChatRepository();

              await repository.reportUser(
                reportedId: reportedId,
                reason: reason,
                description: description,
              );

              if (alsoBlock) {
                await repository.blockUser(reportedId);
              }

              if (!mounted) return;

              setState(() {
                if (alsoBlock) {
                  _isBlocked = true;
                }
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmUnblockUser() async {
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
                child: const Icon(Icons.block, color: accentColor, size: 32),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Unblock user?',
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
                'Are you sure you want to unblock '
                '${widget.user.name}? You will be able to interact with this user again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              // Primary action
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Unblock',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Cancel
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
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

    if (confirmed == true && mounted) {
      await _unblockUser(_liveuserId.toString(), true);
    }
  }

  void _showBlockUserSheet() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("reciverId", widget.user.userId);
    print("reciverId>>>>>>>${prefs.getString("reciverId")}");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: BlockUserDialog(
            userName: widget.user.name,
            userAge: widget.user.age,
            userId: widget.user.id.toString(),

            onBlock: (selectedOption) async {
              final blockedId = widget.user.userId.trim();
              debugPrint('🚫 BLOCK BUTTON CLICKED');
              debugPrint('🚫 blockedId => $blockedId');
              debugPrint('🚫 selectedOption => $selectedOption');

              if (blockedId.isEmpty) {
                _toast('User ID is missing');
                throw Exception('User ID is missing');
              }
              // setState(() {
              //   _isBlocked = true;
              // });

              // IMPORTANT: API is called here, before changing the UI state.
              if (selectedOption == "block_only") {
                await ChatRepository().blockUser(blockedId);
              }

              if (!mounted) return;
              setState(() {
                _isBlocked = true;
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmClearChat() async {
    final conversationId = widget.user.conversationId?.trim() ?? '';
    if (conversationId.isEmpty) {
      _toast('Conversation ID is missing');
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
                'Clear chat?',
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
                'All messages in this conversation will be cleared. '
                'The conversation itself will remain in your chat list.',
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
                    'Clear Chat',
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

    if (confirmed == true && mounted) {
      context.read<ChatBloc>().add(
        ClearConversationEvent(conversationId: conversationId),
      );
    }
  }

  Future<void> _confirmDeleteConversation() async {
    final conversationId = widget.user.conversationId?.trim() ?? '';
    if (conversationId.isEmpty) {
      _toast('Conversation ID is missing');
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
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
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
                'This will permanently remove this conversation from your chat list.',
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
                    'Delete',
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

    if (confirmed == true && mounted) {
      context.read<ChatBloc>().add(
        DeleteConversationEvent(conversationId: conversationId),
      );
    }
  }

  Widget _sheetTile(
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
              child: Icon(icon, color: iconcolor ?? Colors.black, size: 20),
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

  Future<void> _getMuteNotificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.trim().isEmpty) {
        debugPrint('🔔 MUTE GET: auth token missing');
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/user/notification/mute'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token.toLowerCase().startsWith('bearer ')
              ? token
              : 'Bearer $token',
        },
      );

      debugPrint('🔔 MUTE GET => ${response.statusCode}');
      debugPrint('🔔 MUTE GET BODY => ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map && decoded['data'] is Map
            ? Map<String, dynamic>.from(decoded['data'])
            : null;
        final enabled = data?['isEnabled'];

        if (enabled is bool && mounted) {
          setState(() {
            _notificationsEnabled = enabled;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🔔 MUTE GET ERROR => $e');
      debugPrint('$stackTrace');
    }
  }

  Future<bool> _updateMuteNotification(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.trim().isEmpty) {
        debugPrint('🔔 MUTE PATCH: auth token missing');
        return false;
      }

      final response = await http.patch(
        Uri.parse('https://api.welvors.com/api/user/notification/mute'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token.toLowerCase().startsWith('bearer ')
              ? token
              : 'Bearer $token',
        },
        body: jsonEncode({'isEnabled': enabled}),
      );

      debugPrint('🔔 MUTE PATCH isEnabled=$enabled');
      debugPrint('🔔 MUTE PATCH => ${response.statusCode}');
      debugPrint('🔔 MUTE PATCH BODY => ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stackTrace) {
      debugPrint('🔔 MUTE PATCH ERROR => $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  Widget _sheetToggleTile(IconData icon, String title, Color color) {
    // IMPORTANT:
    // This local value must live OUTSIDE StatefulBuilder's builder callback.
    // Otherwise every setLocal() rebuild resets it back to false.
    bool isEnabled = _notificationsEnabled;

    return StatefulBuilder(
      builder: (tileContext, setTileState) {
        final isMuted = !isEnabled;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                width: 30,
                height: 30,
                child: Icon(icon, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: AppText.body.copyWith(fontSize: 15)),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _muteNotificationLoading
                    ? null
                    : () async {
                        final oldEnabled = isEnabled;
                        final newEnabled = !oldEnabled;

                        debugPrint(
                          '🔔 MUTE TOGGLE CLICKED: '
                          'old=$oldEnabled new=$newEnabled',
                        );

                        // Update the bottom-sheet switch immediately.
                        setTileState(() {
                          isEnabled = newEnabled;
                        });

                        if (mounted) {
                          setState(() {
                            _notificationsEnabled = newEnabled;
                            _muteNotificationLoading = true;
                          });
                        }

                        final success = await _updateMuteNotification(
                          newEnabled,
                        );

                        if (!mounted) return;

                        setState(() {
                          _muteNotificationLoading = false;
                          if (!success) {
                            _notificationsEnabled = oldEnabled;
                          }
                        });

                        if (!success) {
                          setTileState(() {
                            isEnabled = oldEnabled;
                          });
                          _toast('Failed to update notification settings');
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 30,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isMuted ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMuted ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isMuted
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _muteNotificationLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Container(
                            width: 25,
                            height: 25,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // RELATIONSHIP TAG PROPOSAL SHEET
  // ============================================================
  void _openRelationshipTagSheet(bool check) {
    final chatBloc = context.read<ChatBloc>();

    final receiverId = widget.user.userId.trim().isNotEmpty
        ? widget.user.userId.trim()
        : widget.user.id.trim();

    debugPrint('💗 RELATIONSHIP RECEIVER: $receiverId');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: chatBloc,
          child: BlocConsumer<ChatBloc, ChatState>(
            listenWhen: (previous, current) =>
                previous.relationshipTagAction !=
                    current.relationshipTagAction ||
                previous.relationshipTagError != current.relationshipTagError,
            listener: (context, state) async {
              debugPrint(
                '💗 RELATIONSHIP ACTION: ${state.relationshipTagAction}',
              );

              // ==========================================================
              // SUCCESS
              // ==========================================================
              if (state.relationshipTagAction == 'CREATE_SUCCESS') {
                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }

                // Relationship sheet is opened from inside the profile
                // Sidedrawer sheet. Close BOTH sheets so the user lands back
                // directly on ChatDetailScreen.
                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }

                // Wait for the relationship sheet to finish closing, then
                // close the Sidedrawer/profile sheet as well.
                await Future<void>.delayed(const Duration(milliseconds: 180));

                if (!mounted) return;

                final rootContext = context;
                // if (Navigator.of(rootContext).canPop()) {
                //   Navigator.of(rootContext).pop();
                // }

                // Reload the current conversation so the newly-created
                // proposal is immediately visible in ChatDetailScreen.
                final conversationId = widget.user.conversationId?.trim() ?? '';

                if (conversationId.isNotEmpty && !chatBloc.isClosed) {
                  chatBloc.add(
                    LoadMessagesEvent(
                      widget.user.id,
                      conversationId: conversationId,
                    ),
                  );
                }

                Future.delayed(const Duration(milliseconds: 450), () {
                  if (mounted) {
                    _scrollToBottom();
                    _toast('Proposal sent ✓');
                  }
                });
                return;
              }

              // ==========================================================
              // ERROR
              // ==========================================================
              if (state.relationshipTagAction == 'CREATE_ERROR') {
                final error = (state.relationshipTagError ?? '').trim();
                final message = error.isNotEmpty
                    ? error
                    : 'Unable to send relationship tag proposal.';

                // Always close the bottom sheet first. The error must be
                // shown as a popup/dialog so the user clearly sees why the
                // request was not sent.
                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }

                await Future<void>.delayed(const Duration(milliseconds: 150));

                if (mounted) {
                  _showRelationshipPopup(message, isError: true);
                }
              }
            },
            builder: (context, state) {
              return RelationshipTagSheet(
                onSend: (tag, message) {
                  debugPrint('💗 RELATIONSHIP TAG: $tag');
                  debugPrint('💗 RELATIONSHIP MESSAGE: $message');
                  debugPrint('💗 RELATIONSHIP RECEIVER: $receiverId');

                  if (receiverId.isEmpty) {
                    if (Navigator.of(sheetContext).canPop()) {
                      Navigator.of(sheetContext).pop();
                    }
                    _showRelationshipPopup(
                      'Receiver ID is missing',
                      isError: true,
                    );
                    return;
                  }

                  context.read<ChatBloc>().add(
                    SendRelationshipTagProposalEvent(
                      receiverId: receiverId,
                      tag: tag,
                      message: message,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showRelationshipPopup(String message, {bool isError = false}) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                isError ? Icons.info_outline : Icons.check_circle_outline,
                color: isError ? AppColors.primary : Colors.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isError ? 'Proposal not sent' : 'Proposal sent',
                  style: AppText.h1.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppText.body.copyWith(color: AppColors.ink),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: AppText.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkChip,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: AppText.pill.copyWith(
          color: const Color(0xFFFFD34D),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _avatar(
    String url, {
    double size = 58,
    required String name,
    required String age,
  }) {
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            url,
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
    );
  }
}

// ============================================================
// SAY SOMETHING BETTER SHEET WIDGET
// ============================================================

// ============================================================
// RELATIONSHIP TAG PROPOSAL SHEET WIDGET
// ============================================================

// ============================================================
// ANIMATED ROSE — soft pulsing glow + floating twinkle decorations
// ============================================================

/// WhatsApp-style swipe-to-reply interaction.
/// The message visibly follows the user's finger while swiping right.
/// Reply is triggered only after crossing the threshold; taps and long-presses
/// do not trigger it.
