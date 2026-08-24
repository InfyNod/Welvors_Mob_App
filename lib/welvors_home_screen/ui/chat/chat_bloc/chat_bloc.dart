import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SocketService.dart';

import '../chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Map<String, String?> _messageNextCursor = {};
  final Map<String, bool> _messageHasMore = {};
  final ChatRepository repository;
  final SocketService socketService;
  ChatBloc({required this.repository, required this.socketService})
    : super(const ChatState()) {
    on<LoadChatsEvent>(_loadChats);
    on<SearchChatsEvent>(_searchChats);
    on<SelectFilterEvent>(_selectFilter);
    on<LoadMessagesEvent>(_loadMessages);
    on<SendMessageEvent>(_sendMessage);
    on<IncomingMessageEvent>(_incomingMessage);
    on<ConversationUpdateEvent>(_conversationUpdate);
    on<MessageReadSocketEvent>(_messageReadSocketEvent);
    on<MessageDeliveredSocketEvent>(_messageDeliveredSocketEvent);
    on<DeleteMessageEvent>(_deleteMessageEvent);

    // Register this listener in the BLoC itself. The BLoC owns the chat-list
    // state, so the update cannot be lost because ChatScreen rebuilds or
    // because its socket listener is registered a little later.
    socketService.off('conversation:update');
    socketService.on('conversation:update', _onConversationUpdateSocket);

    // Server confirms delivery of our sent messages.
    socketService.off('message:delivered');
    socketService.on('message:delivered', _onMessageDeliveredSocket);

    // Server sends message:read when the other participant has opened/read
    // one of our messages. This listener updates the local ticks immediately.
    socketService.off('message:read');
    socketService.on('message:read', _onMessageReadSocket);

    debugPrint('🟢 CHAT BLOC: conversation:update listener registered');
    debugPrint('🟢 CHAT BLOC: message:read listener registered');
  }

  void _onMessageReadSocket(dynamic payload) {
    debugPrint('📩 CHAT BLOC: message:read RECEIVED => $payload');

    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return;
      data = data.first;
    }

    if (data is! Map) {
      debugPrint('❌ message:read invalid payload => $data');
      return;
    }

    final map = Map<String, dynamic>.from(data);
    final messageId = (map['messageId'] ?? map['message_id'] ?? '')
        .toString()
        .trim();
    final conversationId =
        (map['conversationId'] ?? map['conversation_id'] ?? '')
            .toString()
            .trim();

    if (messageId.isEmpty && conversationId.isEmpty) {
      debugPrint('⚠️ message:read missing messageId/conversationId');
      return;
    }

    add(
      MessageReadSocketEvent(
        messageId: messageId.isEmpty ? null : messageId,
        conversationId: conversationId.isEmpty ? null : conversationId,
      ),
    );
  }

  void _onMessageDeliveredSocket(dynamic payload) {
    debugPrint('📩 CHAT BLOC: message:delivered RECEIVED => $payload');

    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return;
      data = data.first;
    }
    if (data is! Map) return;

    Map<String, dynamic> map = Map<String, dynamic>.from(data);
    if (map['message'] is Map) {
      map = Map<String, dynamic>.from(map['message'] as Map);
    } else if (map['data'] is Map) {
      map = Map<String, dynamic>.from(map['data'] as Map);
    }

    final messageId = (map['messageId'] ?? map['message_id'] ?? map['id'] ?? '')
        .toString()
        .trim();
    final conversationId =
        (map['conversationId'] ?? map['conversation_id'] ?? '')
            .toString()
            .trim();

    if (messageId.isEmpty && conversationId.isEmpty) return;

    add(
      MessageDeliveredSocketEvent(
        messageId: messageId.isEmpty ? null : messageId,
        conversationId: conversationId.isEmpty ? null : conversationId,
      ),
    );
  }

  void _messageDeliveredSocketEvent(
    MessageDeliveredSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    if (event.messageId == null || event.messageId!.isEmpty) return;

    for (final entry in state.messages.entries) {
      final messages = entry.value;
      final index = messages.indexWhere((m) => m.id == event.messageId);
      if (index == -1) continue;

      final message = messages[index];
      // if (!message.isMine || message.delivered) return;

      // final updated = List<ChatMessage>.from(messages);
      // updated[index] = message.copyWith(delivered: true);

      final updatedMessages = Map<String, List<ChatMessage>>.from(
        state.messages,
      );
      // updatedMessages[entry.key] = updated;

      emit(state.copyWith(messages: updatedMessages));
      debugPrint('✅ message:delivered applied to ${event.messageId}');
      return;
    }
  }

  Future<void> _deleteMessageEvent(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = state.messages[event.chatId] ?? const <ChatMessage>[];
      final target = messages.where((m) => m.id == event.messageId).isNotEmpty
          ? messages.firstWhere((m) => m.id == event.messageId)
          : null;

      // Sender-side only.
      if (target == null || !target.isMine) {
        debugPrint('⚠️ DELETE MESSAGE: sender-side message only');
        return;
      }

      await repository.deleteMessage(event.messageId);

      final updated = messages
          .where((m) => m.id != event.messageId)
          .toList(growable: false);

      final updatedMessages = Map<String, List<ChatMessage>>.from(
        state.messages,
      );
      updatedMessages[event.chatId] = updated;

      emit(state.copyWith(messages: updatedMessages));
      debugPrint('🗑️ DELETE MESSAGE SUCCESS => ${event.messageId}');
    } catch (e) {
      debugPrint('❌ DELETE MESSAGE ERROR => $e');
    }
  }

  void _onConversationUpdateSocket(dynamic payload) {
    debugPrint('📩 CHAT BLOC: conversation:update RECEIVED => $payload');

    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return;
      data = data.first;
    }

    if (data is! Map) {
      debugPrint('❌ conversation:update invalid payload => $data');
      return;
    }

    add(ConversationUpdateEvent(Map<String, dynamic>.from(data)));
  }

  // ============================================================
  // LOAD CHAT LIST
  // ============================================================

  Future<void> _loadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(loading: true));

    try {
      final chats = await repository.fetchChats();

      emit(
        state.copyWith(loading: false, allChats: chats, filteredChats: chats),
      );
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  // ============================================================
  // CONVERSATION UPDATE -> CHAT LIST
  // ============================================================

  void _conversationUpdate(
    ConversationUpdateEvent event,
    Emitter<ChatState> emit,
  ) {
    final data = event.payload;
    final conversationId =
        (data['conversationId'] ?? data['conversation_id'] ?? '')
            .toString()
            .trim();

    if (conversationId.isEmpty) {
      debugPrint('❌ conversation:update missing conversationId');
      return;
    }

    final lastMessage = data['lastMessage'] is Map
        ? Map<String, dynamic>.from(data['lastMessage'] as Map)
        : const <String, dynamic>{};

    final content = (lastMessage['content'] ?? data['content'] ?? '')
        .toString();
    final createdAt = (lastMessage['createdAt'] ?? data['createdAt'] ?? '')
        .toString();

    final unreadRaw = data['unreadCount'];
    final hasUnreadCount = unreadRaw != null;
    final unread = ChatUser.toInt(unreadRaw);

    debugPrint(
      '🔄 conversation:update -> id=$conversationId | '
      'content=$content | unread=$unread | hasUnread=$hasUnreadCount',
    );

    final current = state.allChats;
    final index = current.indexWhere(
      (chat) => chat.conversationId == conversationId,
    );

    if (index == -1) {
      debugPrint('⚠️ conversation:update chat not found -> reloading list');
      add(const LoadChatsEvent());
      return;
    }

    final oldChat = current[index];
    final updatedChat = oldChat.copyWith(
      preview: content.isNotEmpty ? content : oldChat.preview,
      time: createdAt.isNotEmpty
          ? ChatUser.formatConversationTime(createdAt)
          : oldChat.time,
      unread: hasUnreadCount ? unread : oldChat.unread,
    );

    final updatedAll = <ChatUser>[
      updatedChat,
      ...current.where((chat) => chat.conversationId != conversationId),
    ];

    var updatedFiltered = _applyFilter(
      List<ChatUser>.from(updatedAll),
      state.filter,
    );

    final query = state.search.trim().toLowerCase();
    if (query.isNotEmpty) {
      updatedFiltered = updatedFiltered.where((chat) {
        return chat.name.toLowerCase().contains(query) ||
            chat.preview.toLowerCase().contains(query);
      }).toList();
    }

    emit(state.copyWith(allChats: updatedAll, filteredChats: updatedFiltered));

    debugPrint(
      '✅ CHAT LIST UPDATED -> $conversationId | preview="$content" | unread=$unread',
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _searchChats(SearchChatsEvent event, Emitter<ChatState> emit) {
    final query = event.query.trim().toLowerCase();

    List<ChatUser> filtered = List<ChatUser>.from(state.allChats);

    // Apply selected filter
    filtered = _applyFilter(filtered, state.filter);

    // Apply search
    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.preview.toLowerCase().contains(query);
      }).toList();
    }

    emit(state.copyWith(search: event.query, filteredChats: filtered));
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _selectFilter(SelectFilterEvent event, Emitter<ChatState> emit) {
    List<ChatUser> filtered = List<ChatUser>.from(state.allChats);

    filtered = _applyFilter(filtered, event.filter);

    final query = state.search.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.preview.toLowerCase().contains(query);
      }).toList();
    }

    emit(state.copyWith(filter: event.filter, filteredChats: filtered));
  }

  // ============================================================
  // APPLY FILTER
  // ============================================================

  List<ChatUser> _applyFilter(List<ChatUser> users, String filter) {
    switch (filter) {
      case 'Unread':
        return users.where((e) => e.unread > 0).toList();

      case 'Online':
        return users.where((e) => e.online).toList();

      case 'Nearby':
        // Add nearby API/filter logic here.
        return users;

      case 'Date Invites':
        // Add date invite filter here.
        return users;

      case 'All':
      default:
        return users;
    }
  }

  // ============================================================
  // LOAD CHAT MESSAGES
  // ============================================================

  Future<void> _loadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final page = await repository.fetchMessages(
        event.chatId,
        conversationId: event.conversationId,
        limit: 10,
        cursor: event.cursor,
      );

      final updatedMessages = Map<String, List<ChatMessage>>.from(
        state.messages,
      );

      updatedMessages[event.chatId] = _mergeMessages(
        state.messages[event.chatId] ?? const <ChatMessage>[],
        page.messages,
      );

      _messageNextCursor[event.chatId] = page.nextCursor;
      _messageHasMore[event.chatId] =
          page.nextCursor != null && page.nextCursor!.isNotEmpty;

      final nextCursors = Map<String, String?>.from(state.messageNextCursor);
      final hasMoreMap = Map<String, bool>.from(state.messageHasMore);
      nextCursors[event.chatId] = page.nextCursor;
      hasMoreMap[event.chatId] = _messageHasMore[event.chatId] ?? false;

      emit(
        state.copyWith(
          messages: updatedMessages,
          messageNextCursor: nextCursors,
          messageHasMore: hasMoreMap,
        ),
      );
    } catch (e) {
      // Keep existing state if API fails.
    }
  }

  void _messageReadSocketEvent(
    MessageReadSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    if (event.messageId != null && event.messageId!.isNotEmpty) {
      for (final entry in state.messages.entries) {
        final messages = entry.value;
        final index = messages.indexWhere((m) => m.id == event.messageId);
        if (index == -1) continue;

        final message = messages[index];
        if (!message.isMine || message.seen) return;

        final updated = List<ChatMessage>.from(messages);
        updated[index] = message.copyWith(seen: true);
        final updatedMessages = Map<String, List<ChatMessage>>.from(
          state.messages,
        );
        updatedMessages[entry.key] = updated;
        emit(state.copyWith(messages: updatedMessages));
        debugPrint('✅ message:read applied to ${event.messageId}');
        return;
      }
      debugPrint(
        '⚠️ message:read message not found locally: ${event.messageId}',
      );
      return;
    }

    if (event.conversationId != null && event.conversationId!.isNotEmpty) {
      final existing = state.messages[event.conversationId!];
      if (existing == null) return;

      bool changed = false;
      final updated = existing.map((message) {
        if (message.isMine && !message.seen) {
          changed = true;
          return message.copyWith(seen: true);
        }
        return message;
      }).toList();

      if (changed) {
        final updatedMessages = Map<String, List<ChatMessage>>.from(
          state.messages,
        );
        updatedMessages[event.conversationId!] = updated;
        emit(state.copyWith(messages: updatedMessages));
        debugPrint(
          '✅ message:read applied to conversation ${event.conversationId}',
        );
      }
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  void joinConversation(String conversationId) {
    socketService.emit('conversation:join', {'conversationId': conversationId});
  }

  // Clear only the local list badge after the detail screen is closed.
  // ChatDetailScreen separately emits message:read for each received messageId.
  // void clearConversationUnread(String conversationId) {
  //   if (conversationId.isEmpty) return;

  //   final updatedAll = state.allChats.map((chat) {
  //     return chat.conversationId == conversationId
  //         ? chat.copyWith(unread: 0)
  //         : chat;
  //   }).toList();

  //   final updatedFiltered = state.filteredChats.map((chat) {
  //     return chat.conversationId == conversationId
  //         ? chat.copyWith(unread: 0)
  //         : chat;
  //   }).toList();

  //   emit(state.copyWith(allChats: updatedAll, filteredChats: updatedFiltered));
  // }
  void clearConversationUnread(String conversationId) {
    if (conversationId.isEmpty) return;

    final updatedAllChats = state.allChats.map((chat) {
      if (chat.conversationId == conversationId && chat.unread > 0) {
        return chat.copyWith(unread: 0);
      }
      return chat;
    }).toList();

    final updatedFilteredChats = state.filteredChats.map((chat) {
      if (chat.conversationId == conversationId && chat.unread > 0) {
        return chat.copyWith(unread: 0);
      }
      return chat;
    }).toList();

    emit(
      state.copyWith(
        allChats: updatedAllChats,
        filteredChats: updatedFilteredChats,
      ),
    );

    // debugPrint('✅ CHAT LIST LOCAL UNREAD CLEARED: $conversationId');
  }

  /// Marks the opened conversation as read on the socket and immediately
  /// clears its unread badge locally in the chat list.
  void markConversationRead(String conversationId) {
    if (conversationId.isEmpty) return;

    print('📖 Mark conversation read locally: $conversationId');
    // Do NOT emit message:read with conversationId here.
    // The backend message:read contract is messageId-based; ChatDetailScreen
    // emits one message:read event for every unread incoming message.

    final updatedAllChats = state.allChats.map((chat) {
      if (chat.conversationId == conversationId && chat.unread > 0) {
        return chat.copyWith(unread: 0);
      }
      return chat;
    }).toList();

    final updatedFilteredChats = state.filteredChats.map((chat) {
      if (chat.conversationId == conversationId && chat.unread > 0) {
        return chat.copyWith(unread: 0);
      }
      return chat;
    }).toList();

    emit(
      state.copyWith(
        allChats: updatedAllChats,
        filteredChats: updatedFilteredChats,
      ),
    );

    print('✅ MESSAGE READ EVENT SENT: $conversationId');
  }

  String _getSocketMessageType(SendMessageEvent event) {
    // IMAGE MUST ALWAYS BE IMAGE
    if (event.type == ChatMessageType.image) {
      return 'IMAGE';
    }

    // typemsg IMAGE bhi IMAGE hi rahega
    if ((event.typemsg ?? '').trim().toUpperCase() == 'IMAGE') {
      return 'IMAGE';
    }

    if (event.type == ChatMessageType.audio) {
      return 'AUDIO';
    }

    return 'TEXT';
  }

  void _sendMessage(SendMessageEvent event, Emitter<ChatState> emit) {
    // ==========================================================
    // 1. CHECK MESSAGE TYPE
    // ==========================================================

    final bool isImage =
        event.type == ChatMessageType.image ||
        (event.typemsg ?? '').trim().toUpperCase() == 'IMAGE';

    final String socketMessageType = isImage
        ? 'IMAGE'
        : _getSocketMessageType(event);

    // ==========================================================
    // 2. SEND MESSAGE THROUGH SOCKET
    // ==========================================================

    final socketPayload = <String, dynamic>{
      'conversationId': event.conversationId,

      // IMAGE => null
      'content': isImage ? null : (event.message ?? ''),

      // IMAGE => IMAGE
      'messageType': socketMessageType,
    };

    // ==========================================================
    // 3. IMAGE URL
    // ==========================================================

    if (isImage && (event.imageUrl ?? '').trim().isNotEmpty) {
      socketPayload['mediaUrl'] = event.imageUrl!.trim();
    }

    debugPrint('========================================');
    debugPrint('📤 MESSAGE SEND');
    debugPrint('📦 SOCKET PAYLOAD => $socketPayload');
    debugPrint('📌 messageType => $socketMessageType');
    debugPrint('🖼️ mediaUrl => ${event.imageUrl}');
    debugPrint('========================================');

    socketService.emitWhenConnected('message:send', socketPayload);

    // ==========================================================
    // 4. GET OLD MESSAGES
    // ==========================================================

    final oldMessages = state.messages[event.chatId] ?? const <ChatMessage>[];

    // ==========================================================
    // 3. CREATE LOCAL MESSAGE
    // ==========================================================

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),

      // IMAGE => empty text
      text: isImage ? '' : (event.message ?? ''),

      // IMPORTANT
      typemsg: isImage ? 'IMAGE' : event.typemsg,

      time: DateTime.now().toIso8601String(),

      isMine: true,

      // Dynamic type
      type: event.type,

      // IMAGE URL
      imageUrl: event.imageUrl,

      // ========================================================
      // REPLY
      // ========================================================
      replyToId: event.replyToId,
      replyText: event.replyText,
      replyImageUrl: event.replyImageUrl,
      replyFileUrl: event.replyFileUrl,
      replyType: event.replyType,

      // ========================================================
      // AUDIO
      // ========================================================
      audioUrl: event.audioUrl,

      // ========================================================
      // FILE / DOCUMENT
      // ========================================================
      fileUrl: event.fileUrl,
      fileName: event.fileName,
      fileSize: event.fileSize,

      // ========================================================
      // GIFT
      // ========================================================
      giftId: event.giftId,
      giftName: event.giftName,
      giftEmoji: event.giftEmoji,
      giftCoins: event.giftCoins,
      giftClaimed: event.giftClaimed,

      // ========================================================
      // GIFT PROGRESS
      // ========================================================
      messageProgress: event.messageProgress,
      messageTarget: event.messageTarget,
      expiresIn: event.expiresIn,

      // ========================================================
      // ROSE / COMPLIMENT
      // ========================================================
      coinAmount: event.coinAmount,
      seen: event.seen,
      hintLine: event.hintLine,
      locationLabel: event.locationLabel,
      isNew: event.isNew,

      // ========================================================
      // PROPOSAL
      // ========================================================
      proposalId: event.proposalId,

      // ========================================================
      // DATE INVITE
      // ========================================================
      inviteTitle: event.inviteTitle,
      inviteVenue: event.inviteVenue,
      inviteStatus: event.inviteStatus,
    );

    // ==========================================================
    // 4. UPDATE LOCAL MESSAGE LIST
    // ==========================================================

    final updatedMessages = Map<String, List<ChatMessage>>.from(state.messages);

    updatedMessages[event.chatId] = _mergeMessages(oldMessages, [message]);

    // ==========================================================
    // 7. UPDATE CHAT LIST ONLY ONCE
    // ==========================================================

    final chatList = List<ChatUser>.from(state.allChats);

    final conversationId = (event.conversationId ?? '').trim();

    final chatIndex = chatList.indexWhere((chat) {
      return chat.id == event.chatId ||
          (conversationId.isNotEmpty &&
              (chat.conversationId ?? '').trim() == conversationId);
    });

    if (chatIndex >= 0) {
      final oldChat = chatList[chatIndex];

      // IMAGE preview
      final String sentPreview = isImage
          ? '📷 Image'
          : (event.message ?? '').trim();

      final updatedChat = oldChat.copyWith(
        preview: sentPreview.isEmpty ? oldChat.preview : sentPreview,
        time: ChatUser.formatConversationTime(message.time),
        unread: 0,
      );

      // Remove current chat
      chatList.removeAt(chatIndex);

      // Put at top
      chatList.insert(0, updatedChat);

      debugPrint('📋 CHAT LIST LIVE UPDATE SUCCESS');

      debugPrint('📋 updated chat = ${updatedChat.name}');

      debugPrint('📋 preview = ${updatedChat.preview}');
    } else {
      debugPrint(
        '⚠️ CHAT LIST LIVE UPDATE: chat not found | chatId=${event.chatId} | conversationId=$conversationId',
      );
    }

    final filtered = _applyFilter(List<ChatUser>.from(chatList), state.filter);

    final query = state.search.trim().toLowerCase();

    final searched = query.isEmpty
        ? filtered
        : filtered.where((chat) {
            return chat.name.toLowerCase().contains(query) ||
                chat.preview.toLowerCase().contains(query);
          }).toList();

    // ==========================================================
    // 6. EMIT UPDATED STATE
    // ==========================================================

    emit(
      state.copyWith(
        messages: updatedMessages,
        allChats: chatList,
        filteredChats: searched,
      ),
    ); // ==========================================================
    // 5. UPDATE CHAT LIST IMMEDIATELY
    // ==========================================================

    final newPreview = (event.message ?? '').trim();

    if (conversationId.isNotEmpty && newPreview.isNotEmpty) {
      final index = state.allChats.indexWhere(
        (chat) => (chat.conversationId ?? '').trim() == conversationId,
      );

      if (index != -1) {
        final oldChat = state.allChats[index];

        final updatedChat = oldChat.copyWith(
          preview: newPreview,
          time: ChatUser.formatConversationTime(
            DateTime.now().toIso8601String(),
          ),
        );

        // IMPORTANT:
        // index se remove karo, id se nahi.
        // Isse baaki users accidentally remove nahi honge.
        final updatedAllChats = <ChatUser>[];

        for (int i = 0; i < state.allChats.length; i++) {
          if (i != index) {
            updatedAllChats.add(state.allChats[i]);
          }
        }

        // Sent chat ko TOP par lao.
        updatedAllChats.insert(0, updatedChat);

        // Search/filter ko dobara apply karo.
        var updatedFilteredChats = _applyFilter(
          List<ChatUser>.from(updatedAllChats),
          state.filter,
        );

        final search = state.search.trim().toLowerCase();

        if (search.isNotEmpty) {
          updatedFilteredChats = updatedFilteredChats.where((chat) {
            return chat.name.toLowerCase().contains(search) ||
                chat.preview.toLowerCase().contains(search);
          }).toList();
        }

        debugPrint('========================================');
        debugPrint('✅ CHAT LIST LIVE UPDATE');
        debugPrint('conversationId: $conversationId');
        debugPrint('user: ${updatedChat.name}');
        debugPrint('preview: $newPreview');
        debugPrint('old list count: ${state.allChats.length}');
        debugPrint('new list count: ${updatedAllChats.length}');
        debugPrint('order: ${updatedAllChats.map((e) => e.name).toList()}');
        debugPrint('========================================');

        emit(
          state.copyWith(
            messages: updatedMessages,
            allChats: updatedAllChats,
            filteredChats: updatedFilteredChats,
          ),
        );

        return;
      }

      debugPrint(
        '⚠️ CHAT LIST UPDATE FAILED: conversation not found: $conversationId',
      );
    }

    // Normal message state update if chat wasn't found.
    emit(state.copyWith(messages: updatedMessages));
  }

  // ============================================================
  // MESSAGE READ / SEEN
  //
  // Called when the OTHER participant reads this conversation
  // (server broadcasts `message:read` back into the room). Marks all
  // of *our* sent messages in that chat as seen so the "✓✓ Seen" tick
  // updates live instead of only after leaving and reopening the chat.
  // ============================================================

  void markMessagesSeen(String chatId) {
    final existing = state.messages[chatId];
    if (existing == null || existing.isEmpty) return;

    bool changed = false;

    final updated = existing.map((message) {
      if (message.isMine && !message.seen) {
        changed = true;
        return message.copyWith(seen: true);
      }
      return message;
    }).toList();

    if (!changed) return;

    final updatedMessages = Map<String, List<ChatMessage>>.from(state.messages);
    updatedMessages[chatId] = updated;

    emit(state.copyWith(messages: updatedMessages));
  }

  // ============================================================
  // INCOMING SOCKET MESSAGE
  // ============================================================
  void _incomingMessage(IncomingMessageEvent event, Emitter<ChatState> emit) {
    final payload = _unwrapMessagePayload(event.payload);

    final incoming = ChatMessage.fromJson(
      payload,
      currentUserId: repository.currentUserId,
    );

    final oldMessages = state.messages[event.chatId] ?? const <ChatMessage>[];

    final updatedMessages = Map<String, List<ChatMessage>>.from(state.messages);

    updatedMessages[event.chatId] = _mergeIncomingMessage(
      oldMessages,
      incoming,
    );

    emit(state.copyWith(messages: updatedMessages));
  }

  // ============================================================
  // DEDUPE OWN MESSAGE ECHO
  //
  // The server broadcasts `message:receive` back to the sender as well
  // (delivery echo). Since that echo carries the real server id while
  // our optimistic local copy (added in _sendMessage) carries a local
  // timestamp id, a plain id-based merge treats them as two different
  // messages -> the same text/image shows twice. Here we detect that
  // echo and replace the matching local optimistic bubble instead of
  // adding a new one.
  // ============================================================

  static final RegExp _tempIdPattern = RegExp(r'^\d+$');

  List<ChatMessage> _mergeIncomingMessage(
    List<ChatMessage> existing,
    ChatMessage incoming,
  ) {
    if (incoming.isMine) {
      final bool incomingIsImage =
          (incoming.typemsg ?? '').trim().toUpperCase() == 'IMAGE';

      int matchIndex = -1;

      if (incomingIsImage) {
        // IMAGES: the server can re-host/normalize the URL, so the echoed
        // imageUrl doesn't always string-match what we uploaded. Instead,
        // match the OLDEST still-unconfirmed optimistic image bubble
        // (local timestamp id) - echoes arrive in the same order the
        // images were sent, so FIFO is a safe way to pair them up.
        DateTime? oldestTime;

        for (int i = 0; i < existing.length; i++) {
          final message = existing[i];

          if (!message.isMine || !_tempIdPattern.hasMatch(message.id)) {
            continue;
          }

          if ((message.typemsg ?? '').trim().toUpperCase() != 'IMAGE') {
            continue;
          }

          final parsedTime = DateTime.tryParse(message.time);

          if (matchIndex == -1 ||
              (parsedTime != null &&
                  (oldestTime == null || parsedTime.isBefore(oldestTime)))) {
            matchIndex = i;
            oldestTime = parsedTime ?? oldestTime;
          }
        }
      } else {
        // TEXT: exact content match against an unconfirmed local bubble.
        matchIndex = existing.indexWhere((message) {
          if (!message.isMine || !_tempIdPattern.hasMatch(message.id)) {
            return false;
          }

          if ((message.typemsg ?? '').trim().toUpperCase() == 'IMAGE') {
            return false;
          }

          return message.text.isNotEmpty && message.text == incoming.text;
        });
      }

      if (matchIndex != -1) {
        final replaced = List<ChatMessage>.from(existing);
        replaced[matchIndex] = incoming;
        replaced.sort((a, b) => ChatMessage.compareByTime(b, a));
        return replaced;
      }
    }

    return _mergeMessages(existing, [incoming]);
  }

  Map<String, dynamic> _unwrapMessagePayload(Map<String, dynamic> raw) {
    dynamic value = raw;

    // Supports common socket formats:
    // {message: {...}}
    // {data: {...}}
    // {data: {message: {...}}}
    for (int i = 0; i < 3; i++) {
      if (value is! Map) break;
      final map = Map<String, dynamic>.from(value);
      if (map['message'] is Map) {
        value = map['message'];
      } else if (map['data'] is Map) {
        value = map['data'];
      } else {
        return map;
      }
    }

    return value is Map ? Map<String, dynamic>.from(value) : raw;
  }

  List<ChatMessage> _mergeMessages(
    List<ChatMessage> existing,
    List<ChatMessage> incoming,
  ) {
    final byId = <String, ChatMessage>{
      for (final message in existing) message.id: message,
    };

    for (final message in incoming) {
      byId[message.id] = message;
    }

    final result = byId.values.toList();

    // IMPORTANT: ListView uses reverse:true. Keep newest message first.
    // Index 0 is rendered at the bottom, so a newly typed/sent message
    // is always shown at the bottom instead of at the top.
    result.sort((a, b) => ChatMessage.compareByTime(b, a));
    return result;
  }

  // ============================================================
  // CURRENT TIME
  // ============================================================

  String _currentTime() {
    final now = DateTime.now();

    final hour = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;

    final minute = now.minute.toString().padLeft(2, '0');

    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
