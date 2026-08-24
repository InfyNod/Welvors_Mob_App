import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/chat/RelationshipTagSheet.dart';
import 'package:velvors/welvors_home_screen/ui/chat/YourJourneyScreen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_effects_overlay.dart';
import 'package:velvors/welvors_home_screen/ui/chat/composer_extras_panel.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';

import 'SocketService.dart';
import 'chat_bloc/chat_bloc.dart';
import 'chat_bloc/chat_event.dart';
import 'chat_bloc/chat_state.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser user;

  const ChatDetailScreen({super.key, required this.user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _messageFocusNode = FocusNode();

  ChatMessage? _replyingTo;

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
  final Set<String> _readMessageIds = <String>{};

  // Emoji / Stickers / Meme & Fun / Effects / GIF / Gifts panel
  bool _showExtrasPanel = false;

  void _toggleExtrasPanel() {
    _messageFocusNode.unfocus();
    setState(() {
      _showExtrasPanel = !_showExtrasPanel;
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
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.text,
        message: label,
        typemsg: "Effect",
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
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.gift,
        message: 'A little something for you 💝',
        giftId: 'gift_${DateTime.now().millisecondsSinceEpoch}',
        giftName: gift.name,
        giftEmoji: gift.emoji,
        giftCoins: '${gift.coins} coins',
        giftClaimed: false,
        messageProgress: 1,
        messageTarget: 25,
        expiresIn: '7d',
        typemsg: "",
      ),
    );
    _scrollToBottom();
    _toast('${gift.name} sent ✓');
  }

  void _markMessagesAsRead() {
    final bloc = context.read<ChatBloc>();
    final messages =
        bloc.state.messages[widget.user.id] ?? const <ChatMessage>[];

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

    scrollController.addListener(_handleMessageScroll);

    // Conversation join
    final conversationId = widget.user.conversationId;

    if (conversationId != null && conversationId.isNotEmpty) {
      joinConversation(conversationId);
    }

    // ============================================================
    // message:receive
    // ============================================================
    // Listen while this ChatDetailScreen is open. The payload is filtered
    // by conversationId before it is sent to ChatBloc, so messages from
    // another conversation never appear in this screen.
    _registerMessageReceiveListener();

    // Load messages
    context.read<ChatBloc>().add(
      LoadMessagesEvent(
        widget.user.id,
        conversationId: widget.user.conversationId,
      ),
    );
  }

  // ============================================================
  // MESSAGE RECEIVE SOCKET
  // ============================================================

  void _registerMessageReceiveListener() {
    _socketService.off('message:receive');
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
    if (!mounted || !scrollController.hasClients || _loadingOlderMessages)
      return;

    // reverse:true: offset 0 = latest/bottom, maxScrollExtent = oldest/top.
    final position = scrollController.position;
    if (position.maxScrollExtent - position.pixels > 80) return;

    final bloc = context.read<ChatBloc>();
    final cursor = bloc.state.messageNextCursor[widget.user.id];
    final hasMore = bloc.state.messageHasMore[widget.user.id] ?? false;
    if (!hasMore || cursor == null || cursor.isEmpty) return;

    _loadingOlderMessages = true;
    bloc.add(
      LoadMessagesEvent(
        widget.user.id,
        conversationId: widget.user.conversationId,
        cursor: cursor,
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();

    if (_isTyping) {
      final conversationId = widget.user.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        _socketService.emit('typing:stop', {'conversationId': conversationId});
      }
      _isTyping = false;
    }

    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    controller.dispose();
    scrollController.removeListener(_handleMessageScroll);
    scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
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
      case ChatMessageType.image:
        return 430;
      case ChatMessageType.audio:
      case ChatMessageType.document:
      case ChatMessageType.location:
      case ChatMessageType.contact:
      case ChatMessageType.gift:
      case ChatMessageType.proposal:
      case ChatMessageType.rose:
      case ChatMessageType.compliment:
      case ChatMessageType.dateInvite:
        return 140;
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
        context.read<ChatBloc>().state.messages[widget.user.id] ??
        const <ChatMessage>[];

    final filtered = messages.where((m) {
      switch (tab) {
        case 1:
          return m.type == ChatMessageType.gift ||
              m.type == ChatMessageType.rose;
        case 2:
          return m.type == ChatMessageType.compliment;
        case 3:
          return m.type == ChatMessageType.dateInvite;
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

  bool _initialScrollDone = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.messages[widget.user.id] != current.messages[widget.user.id],
      listener: (context, state) {
        if (!mounted) return;
        _markMessagesAsRead();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,

          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
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

          titleSpacing: 0,

          title: Row(
            children: [
              wSized8,
              _avatar(widget.user.image, size: 48),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${widget.user.name}',
                            style: AppText.h2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        _badge('PLATINUM'),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: widget.user.online
                                ? AppColors.green
                                : AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.user.online ? 'Online' : 'Offline',
                          style: AppText.body.copyWith(
                            color: widget.user.online
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
              onPressed: _openProfileSheet,
              icon: const Icon(Icons.more_vert, color: AppColors.ink),
            ),
          ],
        ),

        body: SafeArea(
          child: Column(
            children: [
              // _relationshipProgress(),
              _tabs(),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_showExtrasPanel) {
                      setState(() => _showExtrasPanel = false);
                    }
                  },
                  child: _messageArea(),
                ),
              ),
              _composer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _relationshipProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RELATIONSHIP PROGRESS', style: AppText.eyebrow),
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
    );
  }

  final ScrollController _tabScrollController = ScrollController();
  int selectedTab = 0;
  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      decoration: const BoxDecoration(
        // border: Border(
        //   top: BorderSide(color: AppColors.line),
        //   bottom: BorderSide(color: AppColors.line),
        // ),
      ),
      child: SingleChildScrollView(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _tab('💬 All', '', 0),
            const SizedBox(width: 10),
            _tab('🎁 Gifts', '4', 1),
            const SizedBox(width: 10),
            _tab('💖 Compliments', '2', 2),
            const SizedBox(width: 10),
            _tab('📅 Date Invites', '2', 3),
          ],
        ),
      ),
    );
  }

  Widget _tab(String title, String count, int index) {
    final selected = tab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          tab = index;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (!scrollController.hasClients) return;

          // reverse:true => offset 0 is the latest/bottom message, NOT
          // maxScrollExtent (that's the oldest/top). Jumping to
          // maxScrollExtent here was landing on the oldest message
          // whenever the tab changed, making it look like new/sent
          // messages had disappeared.
          scrollController.jumpTo(0);

          _initialScrollDone = true;
        });
      },
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppText.h2.copyWith(
                fontSize: 15,
                color: selected ? Colors.white : AppColors.ink60,
              ),
            ),

            if (count.isNotEmpty) ...[
              const SizedBox(width: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white24 : AppColors.soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: AppText.pill.copyWith(
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _messageArea() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final messages =
            state.messages[widget.user.id] ?? const <ChatMessage>[];

        // Messages abhi load nahi hue
        if (messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Filter messages according to selected tab
        final filtered = messages.where((m) {
          switch (tab) {
            case 1:
              return m.type == ChatMessageType.gift ||
                  m.type == ChatMessageType.rose;

            case 2:
              return m.type == ChatMessageType.compliment;

            case 3:
              return m.type == ChatMessageType.dateInvite;

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
          });
        }

        return ListView.builder(
          controller: scrollController,

          // Important:
          // Do NOT use
          reverse: true,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final message = filtered[index];

            return Container(
              key: _keyForMessage(message.id),
              child: _SwipeToReply(
                onReply: () => _startReply(message),
                child: _messageCardWithDelete(message),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    if (!message.isMine || message.id.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete message?'),
          content: const Text('This message will be removed from your chat.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    context.read<ChatBloc>().add(
      DeleteMessageEvent(chatId: widget.user.id, messageId: message.id),
    );
  }

  Widget _messageCardWithDelete(ChatMessage message) {
    final card = _messageCard(message);

    // Delete is intentionally available only for messages sent by us.
    if (!message.isMine) return card;

    return GestureDetector(
      onTap: () => _deleteMessage(message),
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  Widget _messageCard(ChatMessage message) {
    switch (message.type) {
      case ChatMessageType.text:
        if (message.typemsg == 'Effect') {
          return _effectCard(message);
        }
        return _textCard(message);
      case ChatMessageType.image:
        return _imageCard(message);
      case ChatMessageType.audio:
        return _audioCard(message);
      case ChatMessageType.document:
        return _documentCard(message);
      case ChatMessageType.location:
        return _locationCard(message);
      case ChatMessageType.contact:
        return _contactCard(message);
      case ChatMessageType.gift:
        return _giftCard(message);
      case ChatMessageType.proposal:
        return _proposalCard(message);
      case ChatMessageType.rose:
        return _roseCard(message);
      case ChatMessageType.compliment:
        return _complimentCard(message);
      case ChatMessageType.dateInvite:
        return _dateInviteCard(message);
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
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    if (message.replyImageUrl != null) {
      return Image.network(
        message.replyImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _scrollToMessage(message.replyToId),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
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
                    message.isMine ? 'You' : widget.user.name,
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
                    isImage ? '📷 Photo' : message.replyText ?? '',
                    maxLines: 2,
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

  Widget _replyComposerPreview() {
    final message = _replyingTo!;
    final isImage = message.type == ChatMessageType.image;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.chatpinkcontanersender.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
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
    debugPrint("isMine>>>>>>${isMine}");
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.replyToId != null) _quotedMessage(message),
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
                        Text(
                          message.delivered ? '✓✓' : '✓',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -2,
                            color: message.delivered
                                ? AppColors.primary
                                : const Color(0xFFB07B8D),
                          ),
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
                    message.time.isEmpty ? 'Now' : message.time,
                    style: AppText.sub.copyWith(
                      fontSize: 12,
                      color: isMine ? const Color(0xFFB07B8D) : AppColors.muted,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '✓✓',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -2,
                        color: Color(0xFFB07B8D),
                      ),
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
        errorBuilder: (_, __, ___) {
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
        errorBuilder: (_, __, ___) {
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
          left: isMine ? 45 : 0,
          right: isMine ? 0 : 45,
          bottom: 18,
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // =====================================================
            // IMAGE + WHATSAPP TAIL
            // =====================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (message.replyToId != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: _imageReplyOverlay(message),
                  ),

                // =================================================
                // MAIN WHITE BUBBLE
                // =================================================
                Container(
                  width: 320,
                  height: 380,
                  padding: const EdgeInsets.all(5),
                  margin: EdgeInsets.only(right: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                      bottomLeft: isMine
                          ? Radius.circular(22)
                          : Radius.circular(0),
                      bottomRight: isMine
                          ? Radius.circular(0)
                          : Radius.circular(22),
                    ),

                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildImage(message),
                    ),
                  ),
                ),

                // =================================================
                // WHATSAPP TOP CORNER NODE
                // =================================================
                // Positioned(
                //   top: 375,
                //   left: isMine ? null : -5,
                //   right: isMine ? -3 : null,
                //   child: CustomPaint(
                //     size: const Size(24, 22),
                //     painter: WhatsAppTailPainter(
                //       isMine: isMine,
                //       color: const Color.fromARGB(255, 207, 203, 203),
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 15),

            // =====================================================
            // TIME
            // =====================================================
            Padding(
              padding: EdgeInsets.only(
                left: isMine ? 0 : 8,
                right: isMine ? 8 : 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: AppText.sub.copyWith(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),

                  if (isMine) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 15, color: Colors.blue),
                  ],
                ],
              ),
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
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadow,
      ),
      child: Row(
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
          Column(
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
        ],
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

  Widget _documentCard(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: _attachmentBubble(
        icon: Icons.insert_drive_file_rounded,
        iconColor: const Color(0xFF3D8BE8),
        title: message.fileName ?? 'Document',
        subtitle: message.fileSize ?? 'Document',
      ),
    );
  }

  Widget _locationCard(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Current Location', style: AppText.h2.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              message.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.sub.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: _attachmentBubble(
        icon: Icons.person_rounded,
        iconColor: const Color(0xFF8A8680),
        title: message.text.isEmpty ? 'Contact' : message.text,
        subtitle: message.fileName,
      ),
    );
  }

  // ============================================================
  // GIFT CARD
  // ============================================================

  Widget _giftCard(ChatMessage message) {
    final progress = message.messageProgress;
    final target = message.messageTarget;
    final isCoffee = message.giftName == 'Virtual Coffee';
    final isMine = message.isMine;

    final progressValue = progress != null && target != null && target > 0
        ? (progress / target).clamp(0.0, 1.0)
        : 0.0;

    // Keep gift cards visually narrower than the chat area, like the design.
    final cardWidth = (MediaQuery.sizeOf(context).width * .86)
        .clamp(280.0, 540.0)
        .toDouble();

    final receiverName = widget.user.name.toUpperCase();

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(
          left: isMine ? 40 : 0,
          right: isMine ? 0 : 40,
          bottom: 18,
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0ECE8), width: 1),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SENT / RECEIVED HEADER
            Row(
              children: [
                Icon(
                  isMine
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 18,
                  color: isMine ? AppColors.primary : AppColors.green,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    isMine
                        ? 'YOU SENT THIS GIFT · TO $receiverName'
                        : '$receiverName SENT YOU A GIFT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.eyebrow.copyWith(
                      color: isMine ? AppColors.primary : AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 14),

            // GIFT DETAILS
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isCoffee
                        ? const Color(0xFFFFF4DC)
                        : const Color(0xFFFFEDF2),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    message.giftEmoji ?? '🎁',
                    style: const TextStyle(fontSize: 25),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.giftName ?? 'Gift',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.h2.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message.giftCoins ?? '',
                        style: AppText.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                if (message.typemsg != 'Text')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: message.giftClaimed
                          ? const Color(0xFFE8F8EF)
                          : const Color(0xFFFFEAF0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.giftClaimed ? 'CLAIMED' : 'UNCLAIMED',
                      style: AppText.pill.copyWith(
                        color: message.giftClaimed
                            ? AppColors.green
                            : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // GIFT NOTE
            Text(
              '"${message.text}"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.body.copyWith(
                fontSize: 12,
                height: 1.45,
                fontStyle: FontStyle.italic,
                color: AppColors.muted,
              ),
            ),

            if (isMine) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _toast('Gift receipt opened');
                },
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            '${(message.giftCoins?.replaceFirst('+', '').replaceFirst('Coins', 'coins') ?? '0')} credited to wallet · tap for receipt',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // RECEIVED GIFT PROGRESS
            if (!isMine && progress != null && target != null) ...[
              const SizedBox(height: 10),
              const Divider(color: AppColors.line, height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    'REPLY PROGRESS',
                    style: AppText.eyebrow.copyWith(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$progress/$target REPLIES',
                    style: AppText.pill.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  backgroundColor: AppColors.soft,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),

              if (message.expiresIn != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 17,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Expires in: ',
                      style: AppText.body.copyWith(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatGiftExpiry(message.expiresIn!),
                      style: AppText.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatGiftExpiry(String value) {
    if (value == '7d') return '7d';
    return value;
  }

  // ============================================================
  // ROSE CARD (sent / received)
  // ============================================================

  Widget _roseCard(ChatMessage message) {
    final coin = message.coinAmount ?? '10';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.isMine
                            ? 'ROSE SENT · TO ${widget.user.name.toUpperCase()}'
                            : 'ROSE RECEIVED · FROM ${widget.user.name.toUpperCase()}',
                        style: AppText.eyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const _FloatingRose(),
                ],
              ),

              // floating twinkle decorations spread across the whole header
              const Positioned.fill(child: _RoseTwinkleOverlay()),
            ],
          ),

          Text(
            '"${message.text}"',
            textAlign: TextAlign.center,
            style: AppText.h2.copyWith(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),

          if (message.hintLine != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.hintLine!,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: AppColors.ink60,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          Text(
            message.isMine
                ? '${message.time} · ${message.seen ? "✓✓ Seen" : ""} ·  🪙$coin spent'
                : '${message.time} ·  🪙$coin credited to your wallet',
            textAlign: TextAlign.center,
            style: AppText.sub1,
          ),

          const SizedBox(height: 16),

          if (message.isMine)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Follow up with a gift'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('Rose her back ·  🪙$coin'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.line),
                        foregroundColor: AppColors.ink60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Reply'),
                    ),
                  ),
                ),
              ],
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

    return Container(
      margin: EdgeInsets.only(
        left: message.isMine ? 30 : 0,
        right: message.isMine ? 0 : 30,
        bottom: 18,
      ),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: message.isMine
              ? [Color(0xfffff8f9), Color(0xfffffcfd)]
              : [Color(0xfffffcf5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

        // color: const Color(0xfffffcf5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: message.isMine
              ? AppColors.colorf7dae2
              : AppColors.yellowborder,
        ),
        boxShadow: AppColors.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                message.isMine
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                message.isMine
                    ? 'COMPLIMENT SENT'
                    : 'COMPLIMENT FROM ${widget.user.name.toUpperCase()}',
                style: AppText.eyebrow.copyWith(color: AppColors.primary),
              ),
              if (message.typemsg != "Text") const Spacer(),
              if (message.typemsg != "Text")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🪙$coin',
                    style: AppText.pill.copyWith(color: AppColors.ink60),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '"${message.text}"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),
          if (!message.isMine && message.isNew) ...[
            Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 5),
          Row(
            children: [
              if (message.locationLabel != null)
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "on her ",
                        style: AppText.body.copyWith(color: AppColors.muted),
                      ),
                      Text(
                        message.locationLabel!,
                        style: AppText.body.copyWith(
                          color: Mycolor.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              if (message.isMine)
                Text(
                  message.seen ? '✓✓ Seen ${message.time}' : message.time,
                  style: AppText.body.copyWith(
                    color: Mycolor.color8b8680,
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                  ),
                )
              else if (message.isNew)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!message.isMine && message.isNew) ...[
                const SizedBox(width: 5),
                Text(
                  'New',
                  style: AppText.pill.copyWith(color: AppColors.primary),
                ),
              ],
            ],
          ),

          if (!message.isMine) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.pink),
                  foregroundColor: AppColors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Reply with a compliment · 🪙$coin',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.pink1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // DATE INVITE CARD
  // ============================================================

  Widget _dateInviteCard(ChatMessage message) {
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
          borderRadius: BorderRadius.circular(18),
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
  // RELATIONSHIP PROPOSAL
  // ============================================================

  Widget _proposalCard(ChatMessage message) {
    final accepted = message.inviteStatus == 'ACCEPTED';
    final pendding = message.inviteStatus == 'PENDING';
    return (accepted == true || pendding == true)
        ? Container()
        : Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8FA),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RELATIONSHIP PROPOSAL',
                            style: AppText.eyebrow.copyWith(
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '"${message.text}"',
                            style: AppText.h2.copyWith(
                              fontSize: 17,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  '${widget.user.name} has proposed updating your relationship status to Exclusively Dating on both profiles.',
                  style: AppText.body.copyWith(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.ink60,
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    // ACCEPT
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {},
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: AppColors.primary.withOpacity(
                                  0.10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ).copyWith(
                                // Custom shadow
                                elevation: WidgetStateProperty.all(0),
                              ),
                          child: const Text(
                            'Accept Proposal',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w900,
                              color: Mycolor.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // MAYBE LATER - SMALLER
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.30,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.line),
                          foregroundColor: AppColors.ink60,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Maybe later',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: Mycolor.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingTo != null) _replyComposerPreview(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: _messageFocusNode,
                    textInputAction: TextInputAction.send,
                    onTap: _closeExtrasPanel,
                    onSubmitted: (_) => _sendText(),
                    onChanged: (value) {
                      _onTypingChanged(value);

                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: AppText.body.copyWith(color: AppColors.muted),
                      filled: true,
                      fillColor: AppColors.canvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _smallAction(
                          _showExtrasPanel
                              ? Icons.keyboard_alt_outlined
                              : Icons.emoji_emotions_outlined,
                          _toggleExtrasPanel,
                        ),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Center(
                                widthFactor: 1,
                                child: GestureDetector(
                                  onTap: _openSaySomethingBetterSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(20),
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
                              ),
                            ),
                          _smallAction(
                            Icons.attach_file_rounded,
                            _openShareSheet,
                          ),
                          if (controller.text.isEmpty) const SizedBox(width: 6),
                          if (controller.text.isEmpty)
                            _smallAction(
                              Icons.camera_alt_outlined,
                              _openCameraDirectly,
                            ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: controller.text.trim().isEmpty
                      ? _startRecording
                      : _sendText,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: controller.text.trim().isEmpty
                        ? const Icon(
                            Icons.mic_none_rounded,
                            color: Colors.white,
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Transform.rotate(
                              angle: -0.7,
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _showExtrasPanel
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ComposerExtrasPanel(
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
      child: Container(
        width: 35,
        height: 35,

        child: Icon(icon, color: AppColors.ink60, size: 20),
      ),
    );
  }

  // ============================================================
  // SHARE SHEET + ATTACHMENTS
  // ============================================================

  void _openShareSheet() {
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                  Text('Share with ${widget.user.name}', style: AppText.h1),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 12,
                    childAspectRatio: .8,
                    children: [
                      _shareOption(
                        Icons.photo_outlined,
                        'Gallery',
                        const Color(0xFF7C6CF0),
                        _pickGallery,
                      ),
                      _shareOption(
                        Icons.camera_alt_outlined,
                        'Camera',
                        const Color(0xFFE8734A),
                        _openCamera,
                      ),
                      _shareOption(
                        Icons.music_note_outlined,
                        'Audio',
                        const Color(0xFFE8A53D),
                        _pickAudio,
                      ),
                      _shareOption(
                        Icons.insert_drive_file_outlined,
                        'Document',
                        const Color(0xFF3D8BE8),
                        _pickDocument,
                      ),
                      _shareOption(
                        Icons.location_on_outlined,
                        'Location',
                        const Color(0xFF2EAF6B),
                        _sendLocation,
                      ),
                      _shareOption(
                        Icons.person_outline,
                        'Contact',
                        const Color(0xFF8A8680),
                        _pickContact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('WELVORS', style: AppText.eyebrow),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 12,
                    childAspectRatio: .8,
                    children: [
                      _shareOption(
                        Icons.calendar_today_outlined,
                        'Date plan',
                        AppColors.primary,
                        () {
                          Navigator.pop(sheetContext);
                          _openDatePlan();
                        },
                      ),
                      _shareOption(
                        Icons.lightbulb_outline,
                        'Openers',
                        const Color(0xFFE8A53D),
                        () {
                          Navigator.pop(sheetContext);
                          _openSaySomethingBetterSheet();
                        },
                      ),
                      _shareOption(
                        Icons.celebration_outlined,
                        'Event',
                        const Color(0xFF9B6DFF),
                        () {
                          Navigator.pop(sheetContext);
                          _sendEvent();
                        },
                      ),
                      _shareOption(
                        Icons.card_giftcard_outlined,
                        'Gift',
                        const Color(0xFFE85D8B),
                        () {
                          Navigator.pop(sheetContext);
                          _sendGift();
                        },
                      ),
                      _shareOption(
                        Icons.local_florist_outlined,
                        'Rose',
                        const Color(0xFFD83A68),
                        () {
                          Navigator.pop(sheetContext);
                          _sendRose();
                        },
                      ),
                      _shareOption(
                        Icons.favorite_border_rounded,
                        'Compliment',
                        const Color(0xFF9B6DFF),
                        () {
                          Navigator.pop(sheetContext);
                          _sendCompliment();
                        },
                      ),
                      _shareOption(
                        Icons.favorite_outline_rounded,
                        'Proposal',
                        AppColors.primary,
                        () {
                          Navigator.pop(sheetContext);
                          _openRelationshipTagSheet(false);
                        },
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
            child: Icon(icon, color: Colors.white, size: 24),
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
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      for (final image in images) {
        await _uploadAndSendImage(image);
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

      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) {
        debugPrint('❌ IMAGE DECODE FAILED');
        return null;
      }

      img.Image resized = decoded;
      if (decoded.width > 1600 || decoded.height > 1600) {
        if (decoded.width >= decoded.height) {
          resized = img.copyResize(decoded, width: 1600);
        } else {
          resized = img.copyResize(decoded, height: 1600);
        }
      }

      int quality = 75;
      Uint8List jpgBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );

      // Keep the upload comfortably below common server limits.
      while (jpgBytes.length > 900 * 1024 && quality > 25) {
        quality -= 10;
        jpgBytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
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
      debugPrint('✅ JPEG QUALITY => $quality');

      return file;
    } catch (e, st) {
      debugPrint('❌ IMAGE COMPRESSION ERROR => $e');
      debugPrint('$st');
      return null;
    }
  }

  // ============================================================
  // IMAGE: UPLOAD FIRST, THEN SEND mediaUrl THROUGH SOCKET
  // ============================================================
  // Future<void> _uploadAndSendImage(XFile image) async {
  //   final conversationId = widget.user.conversationId;
  //   if (conversationId == null || conversationId.isEmpty) {
  //     debugPrint('❌ IMAGE: conversationId missing');
  //     return;
  //   }

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final rawToken = prefs.getString('auth_token') ?? '';
  //     final auth =
  //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

  //     // Compress before multipart upload to avoid HTTP 413.
  //     final compressedFile = await _compressChatImage(image);
  //     if (compressedFile == null) {
  //       throw Exception('Image compression failed');
  //     }

  //     final compressedSize = await compressedFile.length();
  //     debugPrint(
  //       '📦 UPLOAD FILE SIZE => '
  //       '${(compressedSize / 1024).toStringAsFixed(2)} KB',
  //     );

  //     final request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('https://api.welvors.com/api/chat/media/upload'),
  //     );
  //     request.headers['Accept'] = 'application/json';
  //     if (auth.isNotEmpty) request.headers['Authorization'] = auth;

  //     // REQUIRED BY BACKEND
  //     request.fields['mediaType'] = 'IMAGE';

  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         'file',
  //         compressedFile.path,
  //         filename: 'chat_image.jpg',
  //       ),
  //     );

  //     debugPrint('📤 IMAGE UPLOAD START => ${compressedFile.path}');
  //     debugPrint('📤 mediaType => IMAGE');

  //     final response = await http.Response.fromStream(await request.send());
  //     debugPrint('📥 IMAGE UPLOAD STATUS => ${response.statusCode}');
  //     debugPrint('📥 IMAGE UPLOAD BODY => ${response.body}');

  //     if (response.statusCode < 200 || response.statusCode >= 300) {
  //       throw Exception('Upload failed: HTTP ${response.statusCode}');
  //     }

  //     final decoded = jsonDecode(response.body);
  //     final data = decoded is Map && decoded['data'] is Map
  //         ? Map<String, dynamic>.from(decoded['data'])
  //         : <String, dynamic>{};
  //     final mediaUrl = (data['url'] ?? '').toString().trim();

  //     if (mediaUrl.isEmpty) {
  //       throw Exception('Upload succeeded but data.url is empty');
  //     }

  //     debugPrint('✅ IMAGE UPLOADED URL => $mediaUrl');

  //     if (!mounted) return;

  //     // ChatBloc must send this as:
  //     // conversationId + content:null + messageType:IMAGE + mediaUrl:url
  //     context.read<ChatBloc>().add(
  //       SendMessageEvent(
  //         chatId: widget.user.id,
  //         conversationId: conversationId,
  //         type: ChatMessageType.image,
  //         typemsg: 'IMAGE',
  //         message: null,
  //         imageUrl: mediaUrl,
  //       ),
  //     );

  //     _scrollToBottom();
  //   } catch (e, st) {
  //     debugPrint('❌ IMAGE UPLOAD/SEND ERROR => $e');
  //     debugPrint('$st');
  //     if (mounted) _toast('Unable to send image');
  //   }
  // }
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

      var token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

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
        'Authorization': 'Bearer $token',
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

      debugPrint('==========================================');
      debugPrint('✅ IMAGE UPLOADED SUCCESSFULLY');
      debugPrint('✅ MEDIA URL => $mediaUrl');
      debugPrint('==========================================');

      // ==========================================================
      // SEND IMAGE MESSAGE
      // ==========================================================

      final reply = _replyingTo;

      if (!mounted) return;

      debugPrint('==========================================');
      debugPrint('📤 SENDING IMAGE MESSAGE');
      debugPrint('📤 conversationId => $conversationId');
      debugPrint('📤 content => null');
      debugPrint('📤 messageType => IMAGE');
      debugPrint('📤 mediaUrl => $mediaUrl');
      debugPrint('==========================================');

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

  Future<void> _openCamera() async {
    Navigator.pop(context);
    await _captureImage();
  }

  Future<void> _openCameraDirectly() async {
    await _captureImage();
  }

  Future<void> _captureImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) return;
      await _uploadAndSendImage(image);
      _toast('Photo sent ✓');
    } catch (e) {
      _toast('Unable to open camera');
    }
  }

  Future<void> _pickAudio() async {
    Navigator.pop(context);
    try {
      final result = await FilePicker.pickFiles(type: FileType.audio);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
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
    Navigator.pop(context);
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
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      _sendAttachment(
        type: ChatMessageType.document,
        text: file.name,
        filePath: file.path,
        fileName: file.name,
        fileSize: _formatFileSize(file.size),
      );
      _toast('Document sent ✓');
    } catch (e) {
      _toast('Unable to select document');
    }
  }

  Future<void> _sendLocation() async {
    Navigator.pop(context);
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
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      var address = 'Current Location';
      try {
        final places = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (places.isNotEmpty) {
          final p = places.first;
          address = [
            p.name,
            p.locality,
            p.administrativeArea,
          ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
        }
      } catch (_) {}
      _sendAttachment(
        type: ChatMessageType.location,
        text: address,
        filePath: '${position.latitude},${position.longitude}',
      );
      _toast('Location sent ✓');
    } catch (e) {
      _toast('Unable to get location');
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
  }) {
    final reply = _replyingTo;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        conversationId: widget.user.conversationId,
        type: type,
        message: text,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        fileUrl: filePath,
        fileName: fileName,
        fileSize: fileSize,
        locationLabel: locationLabel,
        typemsg: "Attachment",
        replyToId: reply?.id,
        replyText: reply?.text,
        replyImageUrl: reply?.imageUrl,
        replyFileUrl: reply?.fileUrl,
        replyType: reply?.type,
      ),
    );

    setState(() {
      _replyingTo = null;
    });

    _scrollToBottom();
  }

  // void _scrollToBottom() {
  //   Future.delayed(const Duration(milliseconds: 100), () {
  //     if (!mounted || !scrollController.hasClients) return;
  //     scrollController.animateTo(
  //       scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   });
  // }

  void _openDatePlan() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('☕', style: TextStyle(fontSize: 24)),
              title: const Text('Coffee Date'),
              onTap: () => _sendSpecialMessage('☕ Coffee Date'),
            ),
            ListTile(
              leading: const Text('🍽️', style: TextStyle(fontSize: 24)),
              title: const Text('Dinner'),
              onTap: () => _sendSpecialMessage('🍽️ Dinner'),
            ),
            ListTile(
              leading: const Text('🎬', style: TextStyle(fontSize: 24)),
              title: const Text('Movie'),
              onTap: () => _sendSpecialMessage('🎬 Movie'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendSpecialMessage(String text) {
    Navigator.pop(context);
    final parts = text.split(' ');
    final title = parts.length > 1
        ? text.substring(parts.first.length).trim()
        : text;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.dateInvite,
        message: text,
        inviteTitle: '$title Invitation',
        inviteVenue: 'To be decided',
        inviteStatus: 'PENDING',
        typemsg: "",
      ),
    );
    _scrollToBottom();
    _toast('Date plan sent ✓');
  }

  void _sendEvent() {
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.dateInvite,
        message: '🎉 Event invitation',
        inviteTitle: 'Event Invitation',
        inviteVenue: 'To be decided',
        inviteStatus: 'PENDING',
        typemsg: "",
      ),
    );
    _scrollToBottom();
    _toast('Event sent ✓');
  }

  void _sendGift() {
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.gift,
        message: 'A little something for you 💝',
        giftId: 'gift_${DateTime.now().millisecondsSinceEpoch}',
        giftName: 'Virtual Coffee',
        giftEmoji: '☕',
        giftCoins: '+100 Coins',
        giftClaimed: false,
        messageProgress: 1,
        messageTarget: 25,
        expiresIn: '7d',
        typemsg: "",
      ),
    );
    _scrollToBottom();
    _toast('Gift sent ✓');
  }

  void _sendRose() {
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.rose,
        message:
            "Not a pickup line — I'd genuinely like to take you for coffee. 🌹",
        coinAmount: '10',
        hintLine: 'Rose sent successfully.',
        typemsg: "",
      ),
    );
    _scrollToBottom();
    _toast('Rose sent ✓');
  }

  void _sendCompliment() {
    context.read<ChatBloc>().add(
      SendMessageEvent(
        chatId: widget.user.id,
        type: ChatMessageType.compliment,
        message:
            'Your energy is amazing — you make ordinary days look special. ✨',
        coinAmount: '30',
        seen: false,
        locationLabel: 'On your profile',
        typemsg: "",
      ),
    );
    _scrollToBottom();
    _toast('Compliment sent ✓');
  }

  // ============================================================
  // "SAY SOMETHING BETTER" SHEET (opened from the Try pill)
  // ============================================================

  void _openSaySomethingBetterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _SaySomethingBetterSheet(
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

  // ============================================================
  // PROFILE SHEET (opened from the ⋮ menu)
  // ============================================================

  void _openProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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

              Center(child: _avatar(widget.user.image, size: 72)),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  widget.user.name,
                  style: AppText.h1.copyWith(fontSize: 20),
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.user.online ? 'Online' : 'Offline',
                      style: AppText.body.copyWith(color: AppColors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: Text(
                  'Mumbai, India',
                  style: AppText.sub.copyWith(color: AppColors.muted),
                ),
              ),

              hSized20,
              Divider(color: Mycolor.grey1, height: 2),
              hSized10,
              Text('PREFERENCES', style: AppText.eyebrow),

              const SizedBox(height: 6),

              _sheetTile(
                color: Mycolor.pinkffeef2,
                Icons.favorite_outline,
                'Relationship Tags',
                'Define how you connect',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openRelationshipTagSheet(false);
                },
              ),

              _sheetToggleTile(
                Icons.notifications_off_outlined,
                'Mute Notifications',
                Mycolor.colorf5f2ec,
              ),

              _sheetTile(
                color: Mycolor.colorf5f2ec,
                Icons.perm_media_outlined,
                'Media, Links & Docs',
                '48 shared items',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                ),
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 18),

              Text('PRIVACY & SAFETY', style: AppText.eyebrow),

              const SizedBox(height: 6),

              _sheetTile(
                Icons.flag_outlined,
                'Report User',
                null,
                color: Mycolor.pinkffeef2,
                onTap: () => Navigator.pop(context),
              ),

              _sheetTile(
                Icons.block,
                'Block ${widget.user.name}',
                null,
                color: Mycolor.pinkffeef2,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetTile(
    IconData icon,

    String title,
    String? subtitle, {
    Widget? trailing,
    Color? color,
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
              width: 30,
              height: 30,
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppText.sub.copyWith(color: AppColors.muted),
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

  bool value = false;
  Widget _sheetToggleTile(IconData icon, String title, Color color) {
    return StatefulBuilder(
      builder: (context, setLocal) {
        var value = false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color ?? Mycolor.pinkffeef2,
                  borderRadius: BorderRadius.circular(6),
                ),
                width: 30,
                height: 30,
                child: Icon(icon, color: Colors.black, size: 20),
              ),
              // Icon(icon, color: AppColors.ink, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: AppText.body.copyWith(fontSize: 15)),
              ),
              GestureDetector(
                onTap: () {
                  setLocal(() {
                    value = !value;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 30,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: value ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: value ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 25,
                      height: 35,
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return RelationshipTagSheet(
          onSend: (tag) {
            // Close sheet
            if (check) Navigator.of(sheetContext).pop();
            Navigator.of(sheetContext).pop();

            // Use ORIGINAL ChatBloc
            chatBloc.add(
              SendMessageEvent(
                chatId: widget.user.id,
                type: ChatMessageType.proposal,
                message: tag,
                proposalId: 'proposal_${DateTime.now().millisecondsSinceEpoch}',
                typemsg: "",
              ),
            );

            _scrollToBottom();

            _toast('Proposal sent ✓');
          },
        );
      },
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 35,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppColors.shadow,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
      ),
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

  Widget _avatar(String url, {double size = 58}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const ColoredBox(
              color: AppColors.soft,
              child: Icon(Icons.person, color: AppColors.muted),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// SAY SOMETHING BETTER SHEET WIDGET
// ============================================================

class _SuggestionLine {
  final String text;
  final String tag;
  const _SuggestionLine(this.text, this.tag);
}

class _SaySomethingBetterSheet extends StatefulWidget {
  final ValueChanged<String> onPick;

  const _SaySomethingBetterSheet({required this.onPick});

  @override
  State<_SaySomethingBetterSheet> createState() =>
      _SaySomethingBetterSheetState();
}

class _SaySomethingBetterSheetState extends State<_SaySomethingBetterSheet> {
  int _mode =
      1; // 0 Openers, 1 Impression, 2 Go deeper, 3 Ask her out, 4 Revive it

  static const _tabs = [
    '🌱 Openers',
    '✨ Impression',
    '💬 Go deeper',
    '💌 Ask her out',
    '🔄 Revive it',
  ];

  static const _hints = [
    'First message. Reference her profile — generic "hey" gets ignored.',
    'Warm but not over the top. Say one real thing, not five compliments.',
    'Once the small talk is done. These move a chat forward.',
    'Be specific — day, place, and an easy way to say yes to.',
    'Chat gone quiet? Own the gap and give her something easy to reply to.',
  ];

  static const Map<int, List<_SuggestionLine>> _lines = {
    0: [
      _SuggestionLine(
        'Okay, the Lonavala trek photo — was that sunrise or sunset? I keep meaning to do that one.',
        'USES HER PHOTO',
      ),
      _SuggestionLine(
        'Your bio says "night owl" and your gym check-in says 6 AM. I need an explanation.',
        'PLAYFUL, SPECIFIC',
      ),
      _SuggestionLine(
        'Two questions: best filter coffee in Pune, and are you free this week to prove it?',
        'OPENER + PLAN',
      ),
      _SuggestionLine(
        'You listed pottery and product management in the same breath. That combination is very interesting.',
        'CURIOUS',
      ),
      _SuggestionLine(
        'I read the whole profile before typing this, so I refuse to open with "hey".',
        'HONEST, LIGHT',
      ),
    ],
    1: [
      _SuggestionLine(
        'You have that rare thing where the photos and the words sound like the same person.',
        'SINCERE',
      ),
      _SuggestionLine(
        'I like that you know exactly what you want and you said it plainly. That is attractive.',
        'VALUES HER CLARITY',
      ),
      _SuggestionLine(
        'Talking to you feels easy in a way that most conversations here really are not.',
        'WARM',
      ),
      _SuggestionLine(
        'You are the first person in weeks whose reply I actually looked forward to.',
        'HONEST',
      ),
      _SuggestionLine(
        'You make ordinary plans sound like they would be a good evening.',
        'PLAYFUL',
      ),
    ],
    2: [
      _SuggestionLine(
        'What does a really good weekend look like for you — the honest version, not the Instagram one?',
        'REAL ANSWER',
      ),
      _SuggestionLine(
        'What are you building towards this year? Work, personal, anything.',
        'AMBITION',
      ),
      _SuggestionLine(
        'What is something you changed your mind about in the last year?',
        'THOUGHTFUL',
      ),
      _SuggestionLine(
        'What made you join Welvors — what are you hoping to find?',
        'INTENT',
      ),
      _SuggestionLine(
        'Who knows you best, and what would they say about you?',
        'PERSONAL',
      ),
    ],
    3: [
      _SuggestionLine(
        'Coffee this Saturday, 5 PM, Blue Tokai in Bandra? Say the word and I will book it.',
        'SPECIFIC',
      ),
      _SuggestionLine(
        'I would rather talk to you in person than type. Are you free one evening this week?',
        'DIRECT',
      ),
      _SuggestionLine(
        'There is a pottery place in Koregaon Park I have been meaning to try. Come make something ugly with me?',
        'ACTIVITY',
      ),
      _SuggestionLine(
        'No pressure at all — but if you are free Friday, dinner is on me.',
        'LOW PRESSURE',
      ),
      _SuggestionLine(
        'I am posting a Date Now plan for Sunday brunch. If it looks good, request to join.',
        'SOFT ASK',
      ),
    ],
    4: [
      _SuggestionLine(
        'I disappeared into a work week. Sorry! How did yours go?',
        'OWNS THE GAP',
      ),
      _SuggestionLine(
        'Still owe you an answer on the coffee question. And a coffee.',
        'CALLBACK',
      ),
      _SuggestionLine(
        'This chat deserves better than my last reply. Starting again: how was your weekend?',
        'LIGHT',
      ),
      _SuggestionLine(
        'Random, but I saw a cat today that looked exactly like your profile cat. Had to tell someone.',
        'EASY REPLY',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final lines = _lines[_mode] ?? const [];

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
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

              Text('Say something better', style: AppText.h1),

              const SizedBox(height: 4),

              Text(
                'Tap a line to drop it in your message box.',
                style: AppText.body.copyWith(color: AppColors.muted),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = _mode == index;
                    return GestureDetector(
                      onTap: () => setState(() => _mode = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.darkChip : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.darkChip
                                : AppColors.line,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: AppText.pill.copyWith(
                            color: selected ? Colors.white : AppColors.ink60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

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
                  _hints[_mode],
                  style: AppText.body.copyWith(color: AppColors.ink60),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return GestureDetector(
                      onTap: () => widget.onPick(line.text),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.text,
                              style: AppText.body.copyWith(
                                fontSize: 15,
                                height: 1.4,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              line.tag,
                              style: AppText.eyebrow.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// RELATIONSHIP TAG PROPOSAL SHEET WIDGET
// ============================================================

// ============================================================
// ANIMATED ROSE — soft pulsing glow + floating twinkle decorations
// ============================================================

class _FloatingRose extends StatefulWidget {
  const _FloatingRose();

  @override
  State<_FloatingRose> createState() => _FloatingRoseState();
}

class _FloatingRoseState extends State<_FloatingRose>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = -6 * Curves.easeInOut.transform(_controller.value);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: const Text('🌹', style: TextStyle(fontSize: 70)),
    );
  }
}

class _RoseTwinkleOverlay extends StatefulWidget {
  const _RoseTwinkleOverlay();

  @override
  State<_RoseTwinkleOverlay> createState() => _RoseTwinkleOverlayState();
}

class _RoseTwinkleOverlayState extends State<_RoseTwinkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 0 → 1 → 0
  double _pulse(double value) {
    return math.sin(value * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          // ----------------------------------------------------------
          // HEART
          // ----------------------------------------------------------

          final heartProgress = (t + 0.00) % 1.0;

          final heart = _pulse(heartProgress);

          final heartScale = 0.80 + (heart * 0.75);

          final heartY = -28 * Curves.easeOut.transform(heart);

          final heartOpacity = heartProgress < 0.15
              ? heartProgress / 0.15
              : heartProgress > 0.70
              ? (1 - heartProgress) / 0.30
              : 1.0;

          // ----------------------------------------------------------
          // FLOWER
          // ----------------------------------------------------------

          final flowerProgress = (t + 0.28) % 1.0;

          final flower = _pulse(flowerProgress);

          final flowerScale = 0.55 + (flower * 0.85);

          final flowerY = -32 * Curves.easeOut.transform(flower);

          final flowerOpacity = flowerProgress < 0.15
              ? flowerProgress / 0.15
              : flowerProgress > 0.70
              ? (1 - flowerProgress) / 0.30
              : 1.0;

          // ----------------------------------------------------------
          // SPARKLE
          // ----------------------------------------------------------

          final sparkleProgress = (t + 0.55) % 1.0;

          final sparkle = _pulse(sparkleProgress);

          final sparkleScale = 0.45 + (sparkle * 0.95);

          final sparkleY = -30 * Curves.easeOut.transform(sparkle);

          final sparkleOpacity = sparkleProgress < 0.15
              ? sparkleProgress / 0.15
              : sparkleProgress > 0.70
              ? (1 - sparkleProgress) / 0.30
              : 1.0;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ------------------------------------------------------
              // HEART
              // ------------------------------------------------------
              Positioned(
                top: 18 + heartY,
                child: Opacity(
                  opacity: heartOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: heartScale,
                    child: const Text('💗', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),

              // ------------------------------------------------------
              // FLOWER
              // ------------------------------------------------------
              Positioned(
                left: 108,
                top: 48 + flowerY,
                child: Opacity(
                  opacity: flowerOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: flowerScale,
                    child: const Text('🌸', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),

              // ------------------------------------------------------
              // SPARKLE
              // ------------------------------------------------------
              Positioned(
                right: 108,
                top: 52 + sparkleY,
                child: Opacity(
                  opacity: sparkleOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: sparkleScale,
                    child: const Text('✨', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// WhatsApp-style swipe-to-reply interaction.
/// The message visibly follows the user's finger while swiping right.
/// Reply is triggered only after crossing the threshold; taps and long-presses
/// do not trigger it.
class _SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const _SwipeToReply({required this.child, required this.onReply});

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;

  double _dragX = 0;
  double _startX = 0;
  bool _replyTriggered = false;

  static const double _maxDrag = 82;
  static const double _replyThreshold = 58;

  @override
  void initState() {
    super.initState();
    _resetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 180),
        )..addListener(() {
          if (!mounted) return;
          setState(() {
            _dragX = _startX * (1 - _resetController.value);
          });
        });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _resetController.stop();
    _startX = _dragX;
    _replyTriggered = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Only allow left -> right movement. Ignore left swipes.
    final next = (_dragX + details.delta.dx).clamp(0.0, _maxDrag);

    if (next == _dragX) return;

    setState(() {
      _dragX = next;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final shouldReply = _dragX >= _replyThreshold;

    if (shouldReply && !_replyTriggered) {
      _replyTriggered = true;
      widget.onReply();
    }

    _animateBack();
  }

  void _onDragCancel() {
    _animateBack();
  }

  void _animateBack() {
    _startX = _dragX;
    _resetController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_dragX / _replyThreshold).clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // Hidden by default. It becomes visible ONLY while the
          // message is being swiped to the right.
          IgnorePointer(
            child: Opacity(
              opacity: progress,
              child: Transform.scale(
                scale: 0.75 + (0.25 * progress),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.reply_rounded,
                    size: 21,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: _onDragCancel,
            child: Transform.translate(
              offset: Offset(_dragX, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
