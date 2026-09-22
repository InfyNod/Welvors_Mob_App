import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:velvors/welvors_home_screen/ui/chat/ChatVideoPlayer.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SuggestionLine.dart';
import 'package:velvors/welvors_home_screen/ui/chat/_SwipeToReply.dart';
import 'package:velvors/welvors_home_screen/ui/chat/sidedrawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/chat/RelationshipTagSheet.dart';
import 'package:velvors/welvors_home_screen/ui/chat/YourJourneyScreen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_effects_overlay.dart';
import 'package:velvors/welvors_home_screen/ui/chat/composer_extras_panel.dart';
import 'package:velvors/welvors_home_screen/ui/chat/report_user_dialog.dart';
import 'package:velvors/welvors_home_screen/ui/chat/block_user_dialog.dart';
import 'SocketService.dart';
import 'chat_repository.dart';
import 'chat_bloc/chat_bloc.dart';
import 'chat_bloc/chat_event.dart';
import 'chat_bloc/chat_state.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'custom_camera_screen.dart' as custom_camera;
import 'location_map_screen.dart';
import 'chat_image_pdf_viewer_screen.dart';

import 'package:velvors/config/env_config.dart';
import 'widgets/chat_detail_app_bar.dart';
import 'widgets/chat_filter_tabs.dart';
import 'widgets/chat_status_banners.dart';
import 'widgets/chat_recording_composer.dart';
import 'widgets/chat_message_card_factory.dart';
import 'services/chat_attachment_service.dart';
import 'widgets/chat_input_composer.dart';
import 'widgets/dialogs/chat_dialogs.dart';
import 'widgets/sheets/chat_unmatch_sheet.dart';
import 'widgets/sheets/chat_attachment_bottom_sheet.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser user;

  const ChatDetailScreen({super.key, required this.user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

bool _isBlocked = false;

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ChatAttachmentService _attachmentService = ChatAttachmentService(
    getContext: () => context,
    user: widget.user,
    getReplyingTo: () => _replyingTo,
    onClearReply: () {
      if (mounted) setState(() => _replyingTo = null);
    },
    onScrollToBottom: _scrollToBottom,
    showToast: _toast,
    onShowLoader: _showImageSendLoader,
    onHideLoader: _hideImageSendLoader,
  );
  final TextEditingController controller = TextEditingController();
  late TabController _tabController;
  final GlobalKey _textFieldKey = GlobalKey();

  bool textIsEmpty(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  final scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  final FocusNode _messageFocusNode = FocusNode();

  void _removeMessageFocus() {
    if (_messageFocusNode.hasFocus) {
      _messageFocusNode.unfocus();
    }
  }

  bool _isImageSendLoaderOpen = false;

  void _showImageSendLoader() {
    if (_isImageSendLoaderOpen || !mounted) return;
    _isImageSendLoaderOpen = true;
    ChatDialogs.showImageSendLoader(context);
  }

  void _hideImageSendLoader() {
    if (!_isImageSendLoaderOpen) return;
    _isImageSendLoaderOpen = false;
    if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

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
    _attachmentService.sendAttachment(
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

      _attachmentService.sendAttachment(
        type: ChatMessageType.audio,
        text: '',
        filePath: path,
        audioUrl: path,
        fileName: 'Voice message',
        fileSize: _attachmentService.formatFileSize(size),
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
        appBar: ChatDetailAppBar(
          liveImage: _liveImage,
          liveName: _liveName,
          liveAge: _liveAge,
          livePackageType: _livePackageType,
          isUserOnline: _isUserOnline,
          onMoreTap: () {
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
              giftUnlockProgress: () => _giftUnlockProgress(),
              relationshipProgress: () => _relationshipProgress(),
              openRelationshipTagSheet: () => _openRelationshipTagSheet(false),
              confirmClearChat: _confirmClearChat,
              confirmDeleteConversation: _confirmDeleteConversation,
              showReportUserSheet: _showReportUserSheet,
              showBlockUserSheet: _showBlockUserSheet,
              openUnmatchSheet: _openUnmatchSheet,
            ).openProfileSheet();
          },
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
    return ChatBlockedBanner(
      userName: widget.user.name,
      onUnblock: _confirmUnblockUser,
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
    return const ChatGiftUnlockProgressBanner();
  }

  Widget _relationshipProgress() {
    return ChatRelationshipProgressBanner(
      onJourneyTap: () {
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
    );
  }

  Widget _unmatchedState() {
    return ChatUnmatchedBanner(
      userName: widget.user.name,
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  final ScrollController _tabScrollController = ScrollController();
  final Map<int, GlobalKey> _tabKeys = {};
  int selectedTab = 0;

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

        return ChatFilterTabs(
          selectedTab: tab,
          onTabSelected: (index) {
            setState(() {
              tab = index;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (scrollController.hasClients) {
                scrollController.jumpTo(0);
              }
              _initialScrollDone = true;

              final tabContext = _tabKeys[index]?.currentContext;
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
          tabScrollController: _tabScrollController,
          tabKeys: _tabKeys,
          giftsCount: giftsCount,
          complimentsCount: complimentsCount,
          dateInvitesCount: dateInvitesCount,
        );
      },
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

    final shouldDelete = await ChatDialogs.showDeleteMessageDialog(context);
    if (shouldDelete == true && mounted) {
      context.read<ChatBloc>().add(
            DeleteMessageEvent(
              messageId: message.id,
              chatId: widget.user.id,
            ),
          );
    }
  }

  Widget _messageCardWithDelete(ChatMessage message) {
    return ChatMessageCardFactory(
      message: message,
      peerName: widget.user.name,
      liveName: _liveName,
      liveAge: _liveAge,
      isAudioPlaying: _isAudioPlaying,
      playingAudioPath: _playingAudioPath,
      onTapReply: () => _scrollToMessage(message.replyToId),
      onTapImage: () => _openChatImage(message),
      onTapReplyOverlay: () => _scrollToMessage(message.replyToId),
      onToggleAudio: () => _toggleAudio(message),
      onOpenDocument: () => _openChatDocument(message),
      onPlayEffect: (emoji, label) => _playEffectAnimation(emoji, label),
      onAcceptRelationshipTag: () {
        context.read<ChatBloc>().add(
              AcceptRelationshipTagProposalEvent(
                proposalId: message.relationproposalId.toString(),
              ),
            );
      },
      onRejectRelationshipTag: () {
        context.read<ChatBloc>().add(
              RejectRelationshipTagProposalEvent(
                proposalId: message.relationproposalId.toString(),
              ),
            );
      },
      onDeleteMessage: _deleteMessage,
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
  // ============================================================
  // COMPOSER
  // ============================================================

  Widget _composer() {
    if (_isRecording) {
      return _recordingComposer();
    }

    return ChatInputComposer(
      controller: controller,
      messageFocusNode: _messageFocusNode,
      textFieldKey: _textFieldKey,
      userName: widget.user.name,
      replyingTo: _replyingTo,
      onCancelReply: _cancelReply,
      showExtrasPanel: _showExtrasPanel,
      extrasInitialTab: _extrasInitialTab,
      onToggleExtrasPanel: _toggleExtrasPanel,
      onCloseExtrasPanel: _closeExtrasPanel,
      onRemoveFocus: _removeMessageFocus,
      onOpenShareSheet: _openShareSheet,
      onOpenGiftPanel: _openGiftPanel,
      onOpenSaySomethingBetter: _openSaySomethingBetterSheet,
      onOpenCamera: _attachmentService.openCamera,
      onStartRecording: _startRecording,
      onSendText: _sendText,
      onTypingChanged: (value) {
        _onTypingChanged(value);
        setState(() {});
      },
      onEmojiSelected: _insertEmoji,
      onStickerSelected: _onStickerSelected,
      onMemeSelected: _onMemeSelected,
      onEffectSelected: _onEffectSelected,
      onGifSelected: _onGifSelected,
      onGiftSelected: _onGiftItemSelected,
    );
  }

  Widget _recordingComposer() {
    return ChatRecordingComposer(
      recordingTime: _recordingTime(),
      onCancel: _cancelRecording,
      onSend: _stopRecordingAndSend,
    );
  }


  // ============================================================
  // SHARE SHEET + ATTACHMENTS
  // ============================================================

  void _openShareSheet() {
    _removeMessageFocus();
    _closeExtrasPanel();
    ChatAttachmentBottomSheet.show(
      context,
      userName: widget.user.name,
      onPickGallery: _attachmentService.pickGallery,
      onPickCamera: () async {
        debugPrint('📷 SHARE CAMERA: clicked');
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        await _attachmentService.captureImage();
      },
      onPickAudio: _attachmentService.pickAudio,
      onPickDocument: _attachmentService.pickDocument,
      onPickLocation: _attachmentService.sendLocation,
      onPickContact: _attachmentService.pickContact,
    );
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
    ChatUnmatchSheet.show(
      context,
      userName: widget.user.name,
      userAge: widget.user.age.toString(),
      otherUserId: widget.user.userId,
      onUnmatched: () {
        if (mounted) {
          setState(() {
            _isUnmatched = true;
          });
        }
      },
      showToast: _toast,
    );
  }

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
    final confirmed = await ChatDialogs.showUnblockUserDialog(
      context,
      widget.user.name,
    );
    if (confirmed == true && mounted) {
      await _unblockUser(_liveuserId.toString(), true);
    }
  }

  void _showBlockUserSheet() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("reciverId", widget.user.userId);
    if (!mounted) return;
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
              if (blockedId.isEmpty) {
                _toast('User ID is missing');
                throw Exception('User ID is missing');
              }
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

    final confirmed = await ChatDialogs.showClearChatDialog(context);
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

    final confirmed = await ChatDialogs.showDeleteConversationDialog(context);
    if (confirmed == true && mounted) {
      context.read<ChatBloc>().add(
            DeleteConversationEvent(conversationId: conversationId),
          );
    }
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

  Widget _avatar(
    String url, {
    double size = 58,
    required String name,
    required String age,
  }) {
    final parsedAge = int.tryParse(age) ?? 0;
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
                              placeholder: (_, __) => const SizedBox(
                                width: 400,
                                height: 400,
                                child: ColoredBox(color: AppColors.soft),
                              ),
                              errorWidget: (_, _, _) => const SizedBox(
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
                              ),
                            ),
                          ),

                          // Bottom 20px white strip
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                '$name${parsedAge > 0 ? ", $age yrs" : ""}',
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
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(color: AppColors.soft),
            errorWidget: (_, _, _) => const ColoredBox(
              color: AppColors.soft,
              child: Icon(Icons.person, color: AppColors.muted),
            ),
          ),
        ),
      ),
    );
  }
}
