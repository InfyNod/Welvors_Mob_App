import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/chat/SocketService.dart';

import '../chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Map<String, String?> _messageNextCursor = {};
  final Map<String, bool> _messageHasMore = {};
  final ChatRepository repository;
  final SocketService socketService;
  final Set<String> _handledSocketMessageIds = <String>{};
  ChatBloc({required this.repository, required this.socketService})
    : super(const ChatState()) {
    on<LoadChatsEvent>(_loadChats);
    on<SearchChatsEvent>(_searchChats);
    on<SelectFilterEvent>(_selectFilter);
    on<LoadMessagesEvent>(_loadMessages);
    on<SendMessageEvent>(_sendMessage);
    on<SendRelationshipTagProposalEvent>(_sendRelationshipTagProposal);
    on<AcceptRelationshipTagProposalEvent>(_acceptRelationshipTagProposal);
    on<RejectRelationshipTagProposalEvent>(_rejectRelationshipTagProposal);
    on<IncomingMessageEvent>(_incomingMessage);
    on<ConversationUpdateEvent>(_conversationUpdate);
    on<MessageReadSocketEvent>(_messageReadSocketEvent);
    on<MessageDeliveredSocketEvent>(_messageDeliveredSocketEvent);
    on<DeleteMessageEvent>(_deleteMessageEvent);
    on<DeleteConversationEvent>(_deleteConversationEvent);
    on<ClearConversationEvent>(_clearConversationEvent);
    on<UserOnlineSocketEvent>(_userOnlineSocketEvent);
    on<UserOfflineSocketEvent>(_userOfflineSocketEvent);
    on<IncomingSocketMessageListEvent>(_incomingSocketMessageListEvent);

    // The BLoC owns chat-list socket listeners. Never use socketService.off(event)
    // here because ChatScreen/ChatDetailScreen share the same singleton socket.
    // Removing the whole event would silently break another screen's listener.
    socketService.on('conversation:update', _onConversationUpdateSocket);
    socketService.on('message:delivered', _onMessageDeliveredSocket);
    socketService.on('message:read', _onMessageReadSocket);
    socketService.on('message:receive', _onMessageReceiveSocket);
    socketService.on('user:online', _onUserOnlineSocket);
    socketService.on('user:offline', _onUserOfflineSocket);

    AppLogger.d('ChatBloc', '🟢 CHAT BLOC: real-time socket listeners registered');
  }

  String? _socketUserId(dynamic payload) {
    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return null;
      data = data.first;
    }

    for (var i = 0; i < 4; i++) {
      if (data is! Map) return null;
      final map = Map<String, dynamic>.from(data);
      final direct = map['userId'] ?? map['user_id'] ?? map['id'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }
      if (map['data'] is Map) {
        data = map['data'];
        continue;
      }
      if (map['user'] is Map) {
        data = map['user'];
        continue;
      }
      return null;
    }
    return null;
  }

  void _onUserOnlineSocket(dynamic payload) {
    final userId = _socketUserId(payload);
    AppLogger.d('ChatBloc', '🟢 CHAT BLOC user:online => $payload | userId=$userId');
    if (userId == null || userId.isEmpty) return;
    add(UserOnlineSocketEvent(userId));
  }

  void _onUserOfflineSocket(dynamic payload) {
    final userId = _socketUserId(payload);
    AppLogger.d('ChatBloc', '🔴 CHAT BLOC user:offline => $payload | userId=$userId');
    if (userId == null || userId.isEmpty) return;
    add(UserOfflineSocketEvent(userId));
  }

  void _onMessageReceiveSocket(dynamic payload) {
    AppLogger.d('ChatBloc', '📩 CHAT BLOC message:receive => $payload');
    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return;
      data = data.first;
    }
    if (data is! Map) return;

    final normalized = _unwrapMessagePayload(Map<String, dynamic>.from(data));
    add(IncomingSocketMessageListEvent(normalized));
  }

  void _userOnlineSocketEvent(
    UserOnlineSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    _updateUserOnlineState(event.userId, true, emit);
  }

  void _userOfflineSocketEvent(
    UserOfflineSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    _updateUserOnlineState(event.userId, false, emit);
  }

  void _updateUserOnlineState(
    String userId,
    bool online,
    Emitter<ChatState> emit,
  ) {
    bool changed = false;
    final updatedAll = state.allChats
        .map((chat) {
          if (chat.userId != userId || chat.online == online) return chat;
          changed = true;
          return chat.copyWith(online: online);
        })
        .toList(growable: false);

    if (!changed) return;

    final filtered = _applyFilter(
      List<ChatUser>.from(updatedAll),
      state.filter,
    );
    final query = state.search.trim().toLowerCase();
    final searched = query.isEmpty
        ? filtered
        : filtered
              .where(
                (chat) =>
                    chat.name.toLowerCase().contains(query) ||
                    chat.preview.toLowerCase().contains(query),
              )
              .toList(growable: false);

    emit(state.copyWith(allChats: updatedAll, filteredChats: searched));
  }

  void _incomingSocketMessageListEvent(
    IncomingSocketMessageListEvent event,
    Emitter<ChatState> emit,
  ) {
    final payload = _unwrapMessagePayload(event.payload);
    final conversationId =
        (payload['conversationId'] ?? payload['conversation_id'] ?? '')
            .toString()
            .trim();
    if (conversationId.isEmpty) {
      AppLogger.w('ChatBloc', 
        '⚠️ message:receive ignored for chat list: conversationId missing',
      );
      return;
    }

    final messageId =
        (payload['id'] ?? payload['messageId'] ?? payload['_id'] ?? '')
            .toString()
            .trim();
    if (messageId.isNotEmpty) {
      if (_handledSocketMessageIds.contains(messageId)) {
        AppLogger.d('ChatBloc', 'ℹ️ Duplicate message:receive ignored => $messageId');
        return;
      }
      _handledSocketMessageIds.add(messageId);
      if (_handledSocketMessageIds.length > 500) {
        _handledSocketMessageIds.remove(_handledSocketMessageIds.first);
      }
    }

    final content =
        (payload['content'] ?? payload['text'] ?? payload['message'] ?? '')
            .toString();
    final createdAt =
        (payload['createdAt'] ??
                payload['created_at'] ??
                DateTime.now().toIso8601String())
            .toString();

    final index = state.allChats.indexWhere((chat) {
      final cId = (chat.conversationId ?? '').trim();
      return (cId.isNotEmpty && cId == conversationId) ||
          chat.id == conversationId;
    });
    if (index == -1) {
      add(const LoadChatsEvent());
      return;
    }

    final oldChat = state.allChats[index];
    final updatedChat = oldChat.copyWith(
      preview: content.isNotEmpty ? content : oldChat.preview,
      time: ChatUser.formatConversationTime(createdAt),
      // Do not double increment when conversation:update and message:receive
      // arrive for the same message. conversation:update can later provide the
      // authoritative unreadCount.
      unread: oldChat.unread,
    );

    final updatedAll = List<ChatUser>.from(state.allChats);
    updatedAll.removeAt(index);
    updatedAll.insert(0, updatedChat);
    var filtered = _applyFilter(List<ChatUser>.from(updatedAll), state.filter);
    final query = state.search.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (chat) =>
                chat.name.toLowerCase().contains(query) ||
                chat.preview.toLowerCase().contains(query),
          )
          .toList(growable: false);
    }

    emit(state.copyWith(allChats: updatedAll, filteredChats: filtered));
  }

  void _onMessageReadSocket(dynamic payload) {
    AppLogger.d('ChatBloc', '📩 CHAT BLOC: message:read RECEIVED => $payload');

    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return;
      data = data.first;
    }

    if (data is! Map) {
      AppLogger.e('ChatBloc', '❌ message:read invalid payload => $data');
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
      AppLogger.w('ChatBloc', '⚠️ message:read missing messageId/conversationId');
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
    AppLogger.d('ChatBloc', '📩 CHAT BLOC: message:delivered RECEIVED => $payload');

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
      if (!message.isMine || message.delivered) return;

      final updated = List<ChatMessage>.from(messages);
      updated[index] = message.copyWith(delivered: true);

      final updatedMessages = Map<String, List<ChatMessage>>.from(
        state.messages,
      );
      updatedMessages[entry.key] = updated;

      emit(state.copyWith(messages: updatedMessages));
      AppLogger.i('ChatBloc', '✅ message:delivered applied to ${event.messageId}');
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
        AppLogger.w('ChatBloc', '⚠️ DELETE MESSAGE: sender-side message only>>>>$target');
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
      AppLogger.i('ChatBloc', '🗑️ DELETE MESSAGE SUCCESS => ${event.messageId}');
    } catch (e) {
      AppLogger.e('ChatBloc', '❌ DELETE MESSAGE ERROR => $e');
    }
  }

  void _onConversationUpdateSocket(dynamic payload) {
    AppLogger.d('ChatBloc', '📩 CHAT BLOC: conversation:update RECEIVED => $payload');

    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return;
      data = data.first;
    }

    if (data is! Map) {
      AppLogger.e('ChatBloc', '❌ conversation:update invalid payload => $data');
      return;
    }

    dynamic normalized = data;
    for (var i = 0; i < 4; i++) {
      if (normalized is! Map) break;
      final map = Map<String, dynamic>.from(normalized);
      if (map['conversationId'] != null || map['conversation_id'] != null) {
        normalized = map;
        break;
      }
      if (map['data'] is Map) {
        normalized = map['data'];
        continue;
      }
      if (map['conversation'] is Map) {
        normalized = map['conversation'];
        continue;
      }
      break;
    }

    if (normalized is Map) {
      add(ConversationUpdateEvent(Map<String, dynamic>.from(normalized)));
    }
  }

  Future<void> _deleteConversationEvent(
    DeleteConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.conversationId.trim();
    if (id.isEmpty) return;

    // The "Card Showcase" dummy thread isn't a real conversation on the
    // backend, so there's nothing to delete there — just drop it locally.
    // if (id == ChatRepository.demoAllCardsUserId) {
    //   final all = state.allChats
    //       .where((chat) => (chat.conversationId ?? '').trim() != id)
    //       .toList(growable: false);
    //   final filtered = _applyFilter(List<ChatUser>.from(all), state.filter);

    //   emit(
    //     state.copyWith(
    //       allChats: all,
    //       filteredChats: filtered,
    //       chatAction: 'deleted',
    //       chatActionError: null,
    //     ),
    //   );
    //   return;
    // }

    emit(state.copyWith(chatAction: 'deleting', chatActionError: null));
    try {
      await repository.deleteConversation(id);

      final all = state.allChats
          .where((chat) => (chat.conversationId ?? '').trim() != id)
          .toList(growable: false);
      final filtered = _applyFilter(List<ChatUser>.from(all), state.filter);
      final search = state.search.trim().toLowerCase();
      final finalFiltered = search.isEmpty
          ? filtered
          : filtered
                .where((chat) {
                  return chat.name.toLowerCase().contains(search);
                })
                .toList(growable: false);

      final messages = Map<String, List<ChatMessage>>.from(state.messages)
        ..remove(id);
      final cursors = Map<String, String?>.from(state.messageNextCursor)
        ..remove(id);
      final hasMore = Map<String, bool>.from(state.messageHasMore)..remove(id);

      emit(
        state.copyWith(
          allChats: all,
          filteredChats: finalFiltered,
          messages: messages,
          messageNextCursor: cursors,
          messageHasMore: hasMore,
          chatAction: 'deleted',
          chatActionError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          chatAction: 'delete_error',
          chatActionError: e.toString(),
        ),
      );
    }
  }

  Future<void> _clearConversationEvent(
    ClearConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.conversationId.trim();
    if (id.isEmpty) return;

    // Same idea as delete above — clear the dummy showcase thread locally
    // instead of calling a backend that has never heard of it.
    // if (id == ChatRepository.demoAllCardsUserId) {
    //   final messages = Map<String, List<ChatMessage>>.from(state.messages);
    //   messages[id] = const <ChatMessage>[];

    //   emit(
    //     state.copyWith(
    //       messages: messages,
    //       chatAction: 'cleared',
    //       chatActionError: null,
    //     ),
    //   );
    //   return;
    // }

    emit(state.copyWith(chatAction: 'clearing', chatActionError: null));
    try {
      await repository.clearConversation(id);

      final messages = Map<String, List<ChatMessage>>.from(state.messages);
      messages[id] = const <ChatMessage>[];

      final updatedAll = state.allChats
          .map((chat) {
            if ((chat.conversationId ?? '').trim() != id) return chat;
            return chat.copyWith(preview: '', unread: 0);
          })
          .toList(growable: false);

      final updatedFiltered = _applyFilter(
        List<ChatUser>.from(updatedAll),
        state.filter,
      );

      emit(
        state.copyWith(
          allChats: updatedAll,
          filteredChats: updatedFiltered,
          messages: messages,
          messageNextCursor: Map<String, String?>.from(state.messageNextCursor)
            ..remove(id),
          messageHasMore: Map<String, bool>.from(state.messageHasMore)
            ..remove(id),
          chatAction: 'cleared',
          chatActionError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          chatAction: 'clear_error',
          chatActionError: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // LOAD CHAT LIST
  // ============================================================

  Future<void> _loadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(loading: true));

    try {
      AppLogger.d('ChatBloc', '🔄 Loading chats => type=${event.type}');

      final chats = await repository.fetchChats(type: event.type);

      AppLogger.i('ChatBloc', 
        '✅ Chats loaded => '
        'type=${event.type}, count=${chats.length}',
      );

      // `allChats` is the authoritative local source. For a filtered API
      // request, merge the returned rows into it instead of throwing away
      // conversations from the other filters. For `all`, replace it.
      List<ChatUser> allChats;
      if (event.type == 'all') {
        allChats = List<ChatUser>.from(chats);
      } else {
        final byConversation = <String, ChatUser>{
          for (final chat in state.allChats)
            (chat.conversationId ?? chat.id).trim(): chat,
        };
        for (final chat in chats) {
          byConversation[(chat.conversationId ?? chat.id).trim()] = chat;
        }
        allChats = byConversation.values.toList();
      }

      var filtered = _applyFilter(List<ChatUser>.from(allChats), state.filter);

      final query = state.search.trim().toLowerCase();
      if (query.isNotEmpty) {
        filtered = filtered
            .where(
              (chat) =>
                  chat.name.toLowerCase().contains(query) ||
                  chat.preview.toLowerCase().contains(query),
            )
            .toList(growable: false);
      }

      emit(
        state.copyWith(
          loading: false,
          allChats: allChats,
          filteredChats: filtered,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('ChatBloc', 
        '❌ Load chats error '
        'type=${event.type}: $e',
      );

      debugPrintStack(stackTrace: stackTrace);

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
      AppLogger.e('ChatBloc', '❌ conversation:update missing conversationId');
      return;
    }

    final lastMessage = data['lastMessage'] is Map
        ? Map<String, dynamic>.from(data['lastMessage'] as Map)
        : const <String, dynamic>{};

    final content = (lastMessage['content'] ?? data['content'] ?? '')
        .toString();
    final createdAt = (lastMessage['createdAt'] ?? data['createdAt'] ?? '')
        .toString();

    // Media messages carry no text content — fall back to a label so the
    // chat-list card doesn't show stale/blank text for the last message.
    final rawType =
        (lastMessage['type'] ??
                lastMessage['messageType'] ??
                lastMessage['typemsg'] ??
                data['type'] ??
                data['messageType'] ??
                '')
            .toString()
            .trim()
            .toUpperCase();
    final mediaLabel = _mediaPreviewLabel(rawType);

    final unreadRaw = data['unreadCount'];
    final hasUnreadCount = unreadRaw != null;
    final unread = ChatUser.toInt(unreadRaw);

    AppLogger.d('ChatBloc', 
      '🔄 conversation:update -> id=$conversationId | '
      'content=$content | unread=$unread | hasUnread=$hasUnreadCount',
    );

    final current = state.allChats;
    final index = current.indexWhere((chat) {
      final cId = (chat.conversationId ?? '').trim();
      return (cId.isNotEmpty && cId == conversationId) ||
          chat.id == conversationId;
    });

    if (index == -1) {
      AppLogger.w('ChatBloc', '⚠️ conversation:update chat not found -> reloading list');
      add(const LoadChatsEvent());
      return;
    }

    final oldChat = current[index];
    final updatedChat = oldChat.copyWith(
      preview: content.isNotEmpty ? content : (mediaLabel ?? oldChat.preview),
      time: createdAt.isNotEmpty
          ? ChatUser.formatConversationTime(createdAt)
          : oldChat.time,
      unread: hasUnreadCount ? unread : oldChat.unread,
    );

    final updatedAll = List<ChatUser>.from(current);
    updatedAll.removeAt(index);
    updatedAll.insert(0, updatedChat);

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

    AppLogger.i('ChatBloc', 
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
  // CHAT LIST PREVIEW LABEL FOR MEDIA MESSAGES
  // Media messages have no text content, so the last-message spot on
  // the chat-list card falls back to one of these labels instead of
  // showing blank/stale text.
  // ============================================================
  String? _mediaPreviewLabel(String type) {
    switch (type) {
      case 'IMAGE':
        return '📷 Photo';
      case 'VIDEO':
        return '🎥 Video';
      case 'AUDIO':
        return '🎤 Voice message';
      case 'FILE':
      case 'DOCUMENT':
        return '📄 Document';
      default:
        return null;
    }
  }

  // ============================================================
  // MESSAGE STATE KEY
  // ============================================================
  // Keep every conversation in its own bucket. The UI may use the other
  // user's id as chatId, but messages are uniquely scoped by conversationId.
  String _messageKey(String chatId, String? conversationId) {
    final conversation = (conversationId ?? '').trim();
    return conversation.isNotEmpty ? conversation : chatId.trim();
  }

  // ============================================================
  // LOAD CHAT MESSAGES
  // ============================================================

  Future<void> _loadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      AppLogger.d('ChatBloc', 
        '➡️ FETCH MESSAGES: chatId=${event.chatId} '
        'conversationId=${event.conversationId} cursor=${event.cursor}',
      );

      final conversationId = (event.conversationId ?? '').trim();
      final page = await repository.fetchMessages(
        event.chatId,
        conversationId: conversationId.isEmpty ? null : conversationId,
        limit: 10,
        cursor: event.cursor,
      );

      AppLogger.d('ChatBloc', 
        '⬅️ FETCH RESULT: count=${page.messages.length} '
        'nextCursor=${page.nextCursor} hasMore=${page.hasMore}',
      );

      final key = _messageKey(event.chatId, event.conversationId);

      AppLogger.d('ChatBloc', 
        '📥 LOAD MESSAGES -> chatId=${event.chatId} conversationId=${event.conversationId} key=$key count=${page.messages.length}',
      );

      final updatedMessages = Map<String, List<ChatMessage>>.from(
        state.messages,
      );

      updatedMessages[key] = _mergeMessages(
        state.messages[key] ?? const <ChatMessage>[],
        page.messages,
      );

      _messageNextCursor[key] = page.nextCursor;
      _messageHasMore[key] =
          page.hasMore &&
          page.nextCursor != null &&
          page.nextCursor!.isNotEmpty;

      AppLogger.d('ChatBloc', 
        '📌 PAGINATION STATE | key=$key '
        'hasMore=${_messageHasMore[key]} '
        'nextCursor=${_messageNextCursor[key]}',
      );

      final nextCursors = Map<String, String?>.from(state.messageNextCursor);
      final hasMoreMap = Map<String, bool>.from(state.messageHasMore);
      nextCursors[key] = page.nextCursor;
      hasMoreMap[key] = _messageHasMore[key] ?? false;

      emit(
        state.copyWith(
          messages: updatedMessages,
          messageNextCursor: nextCursors,
          messageHasMore: hasMoreMap,
        ),
      );
    } catch (e, st) {
      AppLogger.e('ChatBloc', '❌ LOAD MESSAGES ERROR: $e');
      debugPrintStack(stackTrace: st);
      // Do not replace existing messages with an empty list on failure.
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
        AppLogger.i('ChatBloc', '✅ message:read applied to ${event.messageId}');
        return;
      }
      AppLogger.w('ChatBloc', 
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
        AppLogger.i('ChatBloc', 
          '✅ message:read applied to conversation ${event.conversationId}',
        );
      }
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  void joinConversation(String conversationId) {
    // The "Card Showcase" dummy thread (see ChatRepository.demoAllCardsUser)
    // never existed on the backend, so joining it on the real socket would
    // just be a wasted/failing round-trip. Its messages are served entirely
    // from local demo data, so there's nothing to join.
    // if (conversationId == ChatRepository.demoAllCardsUserId) return;

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

    final id = conversationId.trim();
    final updatedAllChats = state.allChats.map((chat) {
      final cId = (chat.conversationId ?? '').trim();
      if ((cId == id || chat.id == id) && chat.unread > 0) {
        return chat.copyWith(unread: 0);
      }
      return chat;
    }).toList();

    final updatedFilteredChats = state.filteredChats.map((chat) {
      final cId = (chat.conversationId ?? '').trim();
      if ((cId == id || chat.id == id) && chat.unread > 0) {
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

    AppLogger.d('ChatBloc', '📖 Mark conversation read locally: $conversationId');
    // Do NOT emit message:read with conversationId here.
    // The backend message:read contract is messageId-based; ChatDetailScreen
    // emits one message:read event for every unread incoming message.

    final id = conversationId.trim();
    final updatedAllChats = state.allChats.map((chat) {
      final cId = (chat.conversationId ?? '').trim();
      if ((cId == id || chat.id == id) && chat.unread > 0) {
        return chat.copyWith(unread: 0);
      }
      return chat;
    }).toList();

    final updatedFilteredChats = state.filteredChats.map((chat) {
      final cId = (chat.conversationId ?? '').trim();
      if ((cId == id || chat.id == id) && chat.unread > 0) {
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

    AppLogger.i('ChatBloc', '✅ MESSAGE READ EVENT SENT: $conversationId');
  }

  //<navneet>
  String _getSocketMessageType(SendMessageEvent event) {
    // IMAGE MUST ALWAYS BE IMAGE
    if (event.type == ChatMessageType.image) {
      return 'IMAGE';
    }

    // typemsg IMAGE bhi IMAGE hi rahega
    if ((event.typemsg ?? '').trim().toUpperCase() == 'IMAGE') {
      return 'IMAGE';
    }

    if (event.type == ChatMessageType.video ||
        (event.typemsg ?? '').trim().toUpperCase() == 'VIDEO') {
      return 'VIDEO';
    }

    if (event.type == ChatMessageType.audio) {
      return 'AUDIO';
    }
    if (event.type == ChatMessageType.effect) {
      return 'EFFECT';
    }
    if (event.type == ChatMessageType.gift) {
      return 'GIFT';
    }

    if (event.type == ChatMessageType.eventInvite) {
      return 'EVENT';
    }
    if (event.type == ChatMessageType.contact) {
      return 'CONTACT';
    }
    if (event.type == ChatMessageType.location) {
      return 'LOCATION';
    }
    if (event.type == ChatMessageType.DATECONFIRMED) {
      return 'DATE_CONFIRMED';
    }
    return 'TEXT';
  }

  Future<void> _sendRelationshipTagProposal(
    SendRelationshipTagProposalEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        relationshipTagLoading: true,
        relationshipTagAction: 'CREATE',
        relationshipTagActionProposalId: null,
        relationshipTagError: null,
      ),
    );
    try {
      await repository.sendRelationshipTagProposal(
        receiverId: event.receiverId,
        tag: event.tag,
        message: event.message,
      );
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'CREATE_SUCCESS',
          relationshipTagError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'CREATE_ERROR',
          relationshipTagError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _acceptRelationshipTagProposal(
    AcceptRelationshipTagProposalEvent event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.proposalId.trim();
    if (id.isEmpty) {
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'ACCEPT_ERROR',
          relationshipTagActionProposalId: id,
          relationshipTagError: 'Proposal ID is missing',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        relationshipTagLoading: true,
        relationshipTagAction: 'ACCEPT',
        relationshipTagActionProposalId: id,
        relationshipTagError: null,
      ),
    );
    try {
      await repository.acceptRelationshipTagProposal(id);
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'ACCEPT_SUCCESS',
          relationshipTagActionProposalId: id,
          relationshipTagError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'ACCEPT_ERROR',
          relationshipTagActionProposalId: id,
          relationshipTagError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _rejectRelationshipTagProposal(
    RejectRelationshipTagProposalEvent event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.proposalId.trim();
    if (id.isEmpty) {
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'REJECT_ERROR',
          relationshipTagActionProposalId: id,
          relationshipTagError: 'Proposal ID is missing',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        relationshipTagLoading: true,
        relationshipTagAction: 'REJECT',
        relationshipTagActionProposalId: id,
        relationshipTagError: null,
      ),
    );
    try {
      await repository.rejectRelationshipTagProposal(id);
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'REJECT_SUCCESS',
          relationshipTagActionProposalId: id,
          relationshipTagError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          relationshipTagLoading: false,
          relationshipTagAction: 'REJECT_ERROR',
          relationshipTagActionProposalId: id,
          relationshipTagError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _sendMessage(SendMessageEvent event, Emitter<ChatState> emit) {
    // ==========================================================
    // 1. CHECK MESSAGE TYPE
    // ==========================================================

    final String eventTypeMsg = (event.typemsg ?? '').trim().toUpperCase();

    final bool isImage =
        event.type == ChatMessageType.image || eventTypeMsg == 'IMAGE';

    final bool isVideo =
        event.type == ChatMessageType.video || eventTypeMsg == 'VIDEO';

    final bool isAudio =
        event.type == ChatMessageType.audio || eventTypeMsg == 'AUDIO';

    final bool isFile =
        event.type == ChatMessageType.document || eventTypeMsg == 'FILE';

    final bool isContact =
        event.type == ChatMessageType.contact || eventTypeMsg == 'CONTACT';

    final bool isLocation =
        event.type == ChatMessageType.location || eventTypeMsg == 'LOCATION';

    final bool isMedia = isImage || isVideo || isAudio || isFile;

    // ==========================================================
    // 2. SOCKET MESSAGE TYPE
    // ==========================================================

    final String socketMessageType = isImage
        ? 'IMAGE'
        : isVideo
        ? 'VIDEO'
        : isAudio
        ? 'AUDIO'
        : isFile
        ? 'FILE'
        : isContact
        ? 'CONTACT'
        : isLocation
        ? 'LOCATION'
        : _getSocketMessageType(event);

    // ==========================================================
    // 3. CREATE SOCKET PAYLOAD
    // ==========================================================

    final socketPayload = <String, dynamic>{
      'conversationId': event.conversationId,

      // IMAGE / VIDEO / AUDIO / FILE / CONTACT / LOCATION => null
      'content': (isMedia || isContact || isLocation)
          ? null
          : (event.message ?? ''),

      'messageType': socketMessageType,
    };

    // ==========================================================
    // 4. MEDIA URL
    // ==========================================================

    if (isImage && (event.imageUrl ?? '').trim().isNotEmpty) {
      socketPayload['mediaUrl'] = event.imageUrl!.trim();
    }

    if (isVideo && (event.videoUrl ?? '').trim().isNotEmpty) {
      socketPayload['mediaUrl'] = event.videoUrl!.trim();
    }

    if (isAudio && (event.audioUrl ?? '').trim().isNotEmpty) {
      socketPayload['mediaUrl'] = event.audioUrl!.trim();
    }

    if (isFile && (event.fileUrl ?? '').trim().isNotEmpty) {
      socketPayload['mediaUrl'] = event.fileUrl!.trim();
    }

    // ==========================================================
    // 5. CONTACT
    // ==========================================================

    if (isContact) {
      socketPayload['mediaUrl'] = null;

      socketPayload['metadata'] = {
        'contact': {
          'name': event.contactName ?? '',
          'phoneNumber': event.contactPhoneNumber ?? '',
        },
      };
    }
    if (socketMessageType == 'GIFT') {
      final giftId = int.tryParse('${event.giftId}');

      socketPayload['mediaUrl'] = event.imageUrl;

      socketPayload['metadata'] = {
        'giftId': giftId,
        'giftName': event.giftName,
        'giftEmoji': event.giftEmoji,
        'giftCoins': event.giftCoins,
        'giftClaimed': event.giftClaimed,
        'messageProgress': event.messageProgress,
        'messageTarget': event.messageTarget,
        'expiresIn': event.expiresIn,
      };
      AppLogger.d('ChatBloc', '🎁 GIFT SEND');
      AppLogger.d('ChatBloc', '🎁 giftId => $giftId');
      AppLogger.d('ChatBloc', '🎁 payload => $socketPayload');
    }

    // ==========================================================
    // 6. LOCATION
    // ==========================================================

    if (isLocation) {
      socketPayload['mediaUrl'] = null;

      socketPayload['metadata'] = {
        'location': {
          'latitude': event.latitude,
          'longitude': event.longitude,
          'label': event.locationLabel ?? '',
        },
      };
    }

    // ==========================================================
    // 7. DEBUG LOG
    // ==========================================================

    AppLogger.d('ChatBloc', '========================================');
    AppLogger.d('ChatBloc', '📤 MESSAGE SEND');
    AppLogger.d('ChatBloc', '📌 type => $eventTypeMsg');
    AppLogger.d('ChatBloc', '📌 messageType => $socketMessageType');

    AppLogger.d('ChatBloc', '🖼️ imageUrl => ${event.imageUrl}');
    AppLogger.d('ChatBloc', '🎬 videoUrl => ${event.videoUrl}');
    AppLogger.d('ChatBloc', '🎵 audioUrl => ${event.audioUrl}');
    AppLogger.d('ChatBloc', '📄 fileUrl => ${event.fileUrl}');

    if (isContact) {
      AppLogger.d('ChatBloc', '👤 contactName => ${event.contactName}');
      AppLogger.d('ChatBloc', '📞 contactPhoneNumber => ${event.contactPhoneNumber}');
    }

    if (isLocation) {
      AppLogger.d('ChatBloc', '📍 LOCATION');
      AppLogger.d('ChatBloc', '🌐 latitude => ${event.latitude}');
      AppLogger.d('ChatBloc', '🌐 longitude => ${event.longitude}');
      AppLogger.d('ChatBloc', '🏷️ label => ${event.locationLabel}');
    }

    AppLogger.d('ChatBloc', '📦 SOCKET PAYLOAD => $socketPayload');
    AppLogger.d('ChatBloc', '========================================');

    // ==========================================================
    // 8. SEND THROUGH SOCKET
    // ==========================================================

    // if (event.conversationId != ChatRepository.demoAllCardsUserId) {
    socketService.emitWhenConnected('message:send', socketPayload);
    // }

    // ==========================================================
    // 9. GET OLD MESSAGES
    // ==========================================================

    final messageKey = _messageKey(event.chatId, event.conversationId);

    final oldMessages = state.messages[messageKey] ?? const <ChatMessage>[];

    // ==========================================================
    // 10. CREATE LOCAL MESSAGE
    // ==========================================================

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),

      // ========================================================
      // TEXT
      // ========================================================
      text: (isMedia || isContact || isLocation) ? '' : (event.message ?? ''),

      // ========================================================
      // MESSAGE TYPE
      // ========================================================
      typemsg: isImage
          ? 'IMAGE'
          : isVideo
          ? 'VIDEO'
          : isAudio
          ? 'AUDIO'
          : isFile
          ? 'FILE'
          : isContact
          ? 'CONTACT'
          : isLocation
          ? 'LOCATION'
          : event.typemsg,

      time: DateTime.now().toIso8601String(),

      isMine: true,

      // Dynamic type
      type: event.type,

      // ========================================================
      // IMAGE
      // ========================================================
      imageUrl: event.imageUrl,

      // ========================================================
      // VIDEO
      // ========================================================
      videoUrl: event.videoUrl,

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
      // CONTACT
      // ========================================================
      contactName: isContact ? event.contactName : null,

      contactPhoneNumber: isContact ? event.contactPhoneNumber : null,

      // ========================================================
      // LOCATION
      // ========================================================
      latitude: isLocation ? event.latitude : null,

      longitude: isLocation ? event.longitude : null,

      locationLabel: event.locationLabel,

      // ========================================================
      // REPLY
      // ========================================================
      replyToId: event.replyToId,
      replyText: event.replyText,
      replyImageUrl: event.replyImageUrl,
      replyFileUrl: event.replyFileUrl,
      replyType: event.replyType,

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
    // 11. UPDATE LOCAL MESSAGE LIST
    // ==========================================================

    final updatedMessages = Map<String, List<ChatMessage>>.from(state.messages);

    updatedMessages[messageKey] = _mergeMessages(oldMessages, [message]);

    // ==========================================================
    // 12. UPDATE CHAT LIST
    // ==========================================================

    final chatList = List<ChatUser>.from(state.allChats);

    final conversationId = (event.conversationId ?? '').trim();

    final chatIndex = chatList.indexWhere((chat) {
      final cId = (chat.conversationId ?? '').trim();
      return chat.id == event.chatId ||
          (conversationId.isNotEmpty &&
              (cId == conversationId || chat.id == conversationId));
    });

    if (chatIndex >= 0) {
      final oldChat = chatList[chatIndex];

      // ========================================================
      // PREVIEW
      // ========================================================

      final String sentPreview = isImage
          ? _mediaPreviewLabel('IMAGE')!
          : isVideo
          ? _mediaPreviewLabel('VIDEO')!
          : isAudio
          ? _mediaPreviewLabel('AUDIO')!
          : isFile
          ? _mediaPreviewLabel('FILE')!
          : isContact
          ? 'Contact'
          : isLocation
          ? 'Location'
          : (event.message ?? '').trim();

      // ========================================================
      // UPDATED CHAT
      // ========================================================

      final updatedChat = oldChat.copyWith(
        preview: sentPreview.isEmpty ? oldChat.preview : sentPreview,

        time: ChatUser.formatConversationTime(message.time),

        unread: 0,
      );

      // ========================================================
      // REMOVE CURRENT CHAT
      // ========================================================

      chatList.removeAt(chatIndex);

      // ========================================================
      // PUT AT TOP
      // ========================================================

      chatList.insert(0, updatedChat);

      AppLogger.i('ChatBloc', '📋 CHAT LIST LIVE UPDATE SUCCESS');

      AppLogger.d('ChatBloc', '📋 updated chat = ${updatedChat.name}');

      AppLogger.d('ChatBloc', '📋 preview = ${updatedChat.preview}');
    } else {
      AppLogger.w('ChatBloc', 
        '⚠️ CHAT LIST LIVE UPDATE: '
        'chat not found | '
        'chatId=${event.chatId} | '
        'conversationId=$conversationId',
      );
    }

    // ==========================================================
    // 13. APPLY FILTER
    // ==========================================================

    final filtered = _applyFilter(List<ChatUser>.from(chatList), state.filter);

    // ==========================================================
    // 14. APPLY SEARCH
    // ==========================================================

    final query = state.search.trim().toLowerCase();

    final searched = query.isEmpty
        ? filtered
        : filtered.where((chat) {
            return chat.name.toLowerCase().contains(query) ||
                chat.preview.toLowerCase().contains(query);
          }).toList();

    // ==========================================================
    // 15. EMIT UPDATED STATE
    // ==========================================================

    emit(
      state.copyWith(
        messages: updatedMessages,
        allChats: chatList,
        filteredChats: searched,
      ),
    );
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

    final payloadConversationId =
        (payload['conversationId'] ?? payload['conversation_id'] ?? '')
            .toString()
            .trim();
    final key = _messageKey(
      event.chatId,
      payloadConversationId.isEmpty ? null : payloadConversationId,
    );

    final oldMessages = state.messages[key] ?? const <ChatMessage>[];

    final updatedMessages = Map<String, List<ChatMessage>>.from(state.messages);

    updatedMessages[key] = _mergeIncomingMessage(oldMessages, incoming);

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

  // List<ChatMessage> _mergeIncomingMessage(
  //   List<ChatMessage> existing,
  //   ChatMessage incoming,
  // ) {
  //   if (incoming.isMine) {
  //     final incomingType = (incoming.typemsg ?? '').trim().toUpperCase();
  //     final isMedia = const {
  //       'IMAGE',
  //       'VIDEO',
  //       'AUDIO',
  //       'FILE',
  //     }.contains(incomingType);

  //     int matchIndex = -1;
  //     if (isMedia) {
  //       DateTime? oldestTime;
  //       for (int i = 0; i < existing.length; i++) {
  //         final message = existing[i];
  //         if (!message.isMine || !_tempIdPattern.hasMatch(message.id)) continue;
  //         if ((message.typemsg ?? '').trim().toUpperCase() != incomingType)
  //           continue;

  //         final parsedTime = DateTime.tryParse(message.time);
  //         if (matchIndex == -1 ||
  //             (parsedTime != null &&
  //                 (oldestTime == null || parsedTime.isBefore(oldestTime)))) {
  //           matchIndex = i;
  //           oldestTime = parsedTime ?? oldestTime;
  //         }
  //       }
  //     } else {
  //       matchIndex = existing.indexWhere((message) {
  //         if (!message.isMine || !_tempIdPattern.hasMatch(message.id))
  //           return false;
  //         if (const {
  //           'IMAGE',
  //           'VIDEO',
  //           'AUDIO',
  //           'FILE',
  //         }.contains((message.typemsg ?? '').trim().toUpperCase()))
  //           return false;
  //         return message.text.isNotEmpty && message.text == incoming.text;
  //       });
  //     }

  //     if (matchIndex != -1) {
  //       final local = existing[matchIndex];
  //       final replaced = List<ChatMessage>.from(existing);

  //       // Preserve local metadata if the socket echo does not return it.
  //       replaced[matchIndex] = incoming.copyWith(
  //         fileName: incoming.fileName ?? local.fileName,
  //         fileSize: incoming.fileSize ?? local.fileSize,
  //         fileUrl: incoming.fileUrl ?? local.fileUrl,
  //         imageUrl: incoming.imageUrl ?? local.imageUrl,
  //         videoUrl: incoming.videoUrl ?? local.videoUrl,
  //         audioUrl: incoming.audioUrl ?? local.audioUrl,
  //       );

  //       replaced.sort((a, b) => ChatMessage.compareByTime(b, a));
  //       return replaced;
  //     }
  //   }

  //   return _mergeMessages(existing, [incoming]);
  // }

  List<ChatMessage> _mergeIncomingMessage(
    List<ChatMessage> existing,
    ChatMessage incoming,
  ) {
    if (incoming.isMine) {
      final incomingType = (incoming.typemsg ?? '').trim().toUpperCase();

      final isMedia = const {
        'IMAGE',
        'VIDEO',
        'AUDIO',
        'FILE',
      }.contains(incomingType);

      final isContact = incomingType == 'CONTACT';
      final isLocation = incomingType == 'LOCATION';

      int matchIndex = -1;

      // ============================================================
      // GIFT
      // ============================================================
      // Reconcile the server echo with the optimistic gift by giftId.
      // The optimistic message uses a local timestamp id, while the server
      // echo has a real id.
      if (incoming.type == ChatMessageType.gift || incoming.giftId != null) {
        final incomingGiftId = (incoming.giftId ?? '').trim();
        if (incomingGiftId.isNotEmpty) {
          matchIndex = existing.indexWhere((message) {
            return message.isMine &&
                _tempIdPattern.hasMatch(message.id) &&
                message.type == ChatMessageType.gift &&
                (message.giftId ?? '').trim() == incomingGiftId;
          });
        }

        if (matchIndex == -1) {
          final incomingName = (incoming.giftName ?? '').trim();
          final incomingEmoji = (incoming.giftEmoji ?? '').trim();
          matchIndex = existing.indexWhere((message) {
            if (!message.isMine || !_tempIdPattern.hasMatch(message.id)) {
              return false;
            }
            if (message.type != ChatMessageType.gift) return false;
            final nameMatch =
                incomingName.isEmpty ||
                (message.giftName ?? '').trim() == incomingName;
            final emojiMatch =
                incomingEmoji.isEmpty ||
                (message.giftEmoji ?? '').trim() == incomingEmoji;
            return nameMatch && emojiMatch;
          });
        }
      }
      // ============================================================
      // CONTACT
      // ============================================================
      else if (isContact) {
        final incomingName = (incoming.contactName ?? '').trim();
        final incomingPhone = (incoming.contactPhoneNumber ?? '').trim();

        for (int i = 0; i < existing.length; i++) {
          final message = existing[i];

          // Only match optimistic local message
          if (!message.isMine) continue;
          if (!_tempIdPattern.hasMatch(message.id)) continue;

          final localType = (message.typemsg ?? '').trim().toUpperCase();

          if (localType != 'CONTACT') continue;

          final localName = (message.contactName ?? '').trim();

          final localPhone = (message.contactPhoneNumber ?? '').trim();

          if (localName == incomingName && localPhone == incomingPhone) {
            matchIndex = i;
            break;
          }
        }
      }
      // ============================================================
      // LOCATION
      // ============================================================
      else if (isLocation) {
        final incomingLatitude = incoming.latitude;
        final incomingLongitude = incoming.longitude;
        final incomingLabel = (incoming.locationLabel ?? '').trim();

        for (int i = 0; i < existing.length; i++) {
          final message = existing[i];

          // Only match optimistic local message
          if (!message.isMine) continue;
          if (!_tempIdPattern.hasMatch(message.id)) continue;

          final localType = (message.typemsg ?? '').trim().toUpperCase();

          if (localType != 'LOCATION') continue;

          final localLatitude = message.latitude;
          final localLongitude = message.longitude;
          final localLabel = (message.locationLabel ?? '').trim();

          // Match coordinates first.
          bool coordinatesMatch = false;

          if (incomingLatitude != null &&
              incomingLongitude != null &&
              localLatitude != null &&
              localLongitude != null) {
            coordinatesMatch =
                (localLatitude - incomingLatitude).abs() < 0.000001 &&
                (localLongitude - incomingLongitude).abs() < 0.000001;
          }

          // Fallback to label if coordinates are unavailable.
          final bool labelMatch =
              incomingLabel.isNotEmpty &&
              localLabel.isNotEmpty &&
              incomingLabel == localLabel;

          if (coordinatesMatch || labelMatch) {
            matchIndex = i;
            break;
          }
        }
      }
      // ============================================================
      // IMAGE / VIDEO / AUDIO / FILE
      // ============================================================
      else if (isMedia) {
        DateTime? oldestTime;

        for (int i = 0; i < existing.length; i++) {
          final message = existing[i];

          if (!message.isMine || !_tempIdPattern.hasMatch(message.id)) {
            continue;
          }

          if ((message.typemsg ?? '').trim().toUpperCase() != incomingType) {
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
      }
      // ============================================================
      // TEXT / OTHER
      // ============================================================
      else {
        matchIndex = existing.indexWhere((message) {
          if (!message.isMine || !_tempIdPattern.hasMatch(message.id)) {
            return false;
          }

          if (const {
            'IMAGE',
            'VIDEO',
            'AUDIO',
            'FILE',
            'CONTACT',
            'LOCATION',
          }.contains((message.typemsg ?? '').trim().toUpperCase())) {
            return false;
          }

          return message.text.isNotEmpty && message.text == incoming.text;
        });
      }

      // ============================================================
      // REPLACE OPTIMISTIC MESSAGE WITH SERVER MESSAGE
      // ============================================================
      if (matchIndex != -1) {
        final local = existing[matchIndex];

        final replaced = List<ChatMessage>.from(existing);

        replaced[matchIndex] = incoming.copyWith(
          // ========================================================
          // Media metadata
          // ========================================================
          fileName: incoming.fileName ?? local.fileName,
          fileSize: incoming.fileSize ?? local.fileSize,
          fileUrl: incoming.fileUrl ?? local.fileUrl,
          imageUrl: incoming.imageUrl ?? local.imageUrl,
          videoUrl: incoming.videoUrl ?? local.videoUrl,
          audioUrl: incoming.audioUrl ?? local.audioUrl,

          // ========================================================
          // CONTACT metadata
          // ========================================================
          contactName: incoming.contactName ?? local.contactName,
          contactPhoneNumber:
              incoming.contactPhoneNumber ?? local.contactPhoneNumber,

          // ========================================================
          // LOCATION metadata
          // ========================================================
          latitude: incoming.latitude ?? local.latitude,
          longitude: incoming.longitude ?? local.longitude,
          locationLabel: incoming.locationLabel ?? local.locationLabel,

          // ========================================================
          // Reply metadata
          // ========================================================
          replyToId: incoming.replyToId ?? local.replyToId,
          replyText: incoming.replyText ?? local.replyText,
          replyImageUrl: incoming.replyImageUrl ?? local.replyImageUrl,
          replyFileUrl: incoming.replyFileUrl ?? local.replyFileUrl,
          replyType: incoming.replyType ?? local.replyType,

          // Gift fields are protected from partial socket/API echoes.
          giftId: incoming.giftId ?? local.giftId,
          giftName: incoming.giftName ?? local.giftName,
          giftEmoji: incoming.giftEmoji ?? local.giftEmoji,
          giftCoins: _preferNonZero(incoming.giftCoins, local.giftCoins),
          giftClaimed: incoming.giftClaimed || local.giftClaimed,
          messageProgress: incoming.messageProgress ?? local.messageProgress,
          messageTarget: incoming.messageTarget ?? local.messageTarget,
          expiresIn: incoming.expiresIn ?? local.expiresIn,
          // imageUrl: incoming.imageUrl ?? local.imageUrl,
        );

        replaced.sort((a, b) => ChatMessage.compareByTime(b, a));

        return replaced;
      }
    }

    // ============================================================
    // NO OPTIMISTIC MESSAGE MATCHED
    // ============================================================
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

  String? _preferNonZero(String? incoming, String? existing) {
    final incomingValue = (incoming ?? '').trim();
    final existingValue = (existing ?? '').trim();
    final incomingNumber = int.tryParse(
      incomingValue.replaceAll(RegExp(r'[^0-9-]'), ''),
    );
    final existingNumber = int.tryParse(
      existingValue.replaceAll(RegExp(r'[^0-9-]'), ''),
    );

    if (incomingNumber != null && incomingNumber > 0) return incomingValue;
    if (existingNumber != null && existingNumber > 0) return existingValue;
    return incomingValue.isNotEmpty ? incomingValue : existing;
  }

  ChatMessage _mergeMessagePreservingRichData(
    ChatMessage oldMessage,
    ChatMessage newMessage,
  ) {
    if (oldMessage.type != ChatMessageType.gift &&
        newMessage.type != ChatMessageType.gift &&
        oldMessage.giftId == null &&
        newMessage.giftId == null) {
      return newMessage;
    }

    return newMessage.copyWith(
      giftId: newMessage.giftId ?? oldMessage.giftId,
      giftName: newMessage.giftName ?? oldMessage.giftName,
      giftEmoji: newMessage.giftEmoji ?? oldMessage.giftEmoji,
      giftCoins: _preferNonZero(newMessage.giftCoins, oldMessage.giftCoins),
      giftClaimed: newMessage.giftClaimed || oldMessage.giftClaimed,
      messageProgress: newMessage.messageProgress ?? oldMessage.messageProgress,
      messageTarget: newMessage.messageTarget ?? oldMessage.messageTarget,
      expiresIn: newMessage.expiresIn ?? oldMessage.expiresIn,
      imageUrl: newMessage.imageUrl ?? oldMessage.imageUrl,
    );
  }

  List<ChatMessage> _mergeMessages(
    List<ChatMessage> existing,
    List<ChatMessage> incoming,
  ) {
    final byId = <String, ChatMessage>{
      for (final message in existing) message.id: message,
    };

    for (final message in incoming) {
      final exact = byId[message.id];
      if (exact != null) {
        byId[message.id] = _mergeMessagePreservingRichData(exact, message);
        continue;
      }

      // Reconcile optimistic gift -> API/socket message using giftId.
      if (message.type == ChatMessageType.gift || message.giftId != null) {
        final giftId = (message.giftId ?? '').trim();
        if (giftId.isNotEmpty) {
          String? optimisticId;
          for (final entry in byId.entries) {
            final old = entry.value;
            if (old.isMine &&
                _tempIdPattern.hasMatch(old.id) &&
                old.type == ChatMessageType.gift &&
                (old.giftId ?? '').trim() == giftId) {
              optimisticId = entry.key;
              break;
            }
          }
          if (optimisticId != null) {
            final old = byId.remove(optimisticId)!;
            byId[message.id] = _mergeMessagePreservingRichData(old, message);
            continue;
          }
        }
      }

      byId[message.id] = message;
    }

    final result = byId.values.toList();
    result.sort((a, b) => ChatMessage.compareByTime(b, a));
    return result;
  }

  // ============================================================
  // CURRENT TIME
  // ============================================================

  @override
  Future<void> close() {
    socketService.offListener(
      'conversation:update',
      _onConversationUpdateSocket,
    );
    socketService.offListener('message:delivered', _onMessageDeliveredSocket);
    socketService.offListener('message:read', _onMessageReadSocket);
    socketService.offListener('message:receive', _onMessageReceiveSocket);
    socketService.offListener('user:online', _onUserOnlineSocket);
    socketService.offListener('user:offline', _onUserOfflineSocket);
    return super.close();
  }

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
