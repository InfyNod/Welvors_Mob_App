import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_bloc/chat_state.dart';

class ChatMessagesPage {
  final List<ChatMessage> messages;
  final bool hasMore;
  final String? nextCursor;

  const ChatMessagesPage({
    required this.messages,
    required this.hasMore,
    required this.nextCursor,
  });
}

class ChatRepository {
  /// Logged-in user id. Real API messages use this id to decide sender/receiver.
  final String currentUserId;

  ChatRepository({this.currentUserId = 'current_user'});

  /// Decodes the logged-in user's id straight out of the JWT so callers
  /// don't have to keep a hardcoded id in sync with whoever is logged in.
  static String userIdFromToken(String? token, {String fallback = ''}) {
    try {
      if (token == null || token.isEmpty) return fallback;

      final parts = token.split('.');
      if (parts.length != 3) return fallback;

      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      if (payload is Map) {
        final value = payload['userId'] ?? payload['user_id'] ?? payload['id'];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    } catch (_) {
      // Fall through to fallback below.
    }

    return fallback;
  }

  /// Deletes one message. The backend authorizes the operation, so the
  /// current user can only delete messages they are allowed to delete.
  Future<void> deleteMessage(String messageId) async {
    final cleanId = messageId.trim();
    if (cleanId.isEmpty) {
      throw Exception('Message id is empty');
    }
    var token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs";

    debugPrint("token>>>>>>>>${token}");
    debugPrint("messageId>>>>>>>>${messageId}");
    final response = await http.delete(
      Uri.parse('https://api.welvors.com/api/user/chat/messages/$cleanId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    debugPrint('DELETE MESSAGE status: ${response.statusCode}');
    debugPrint('DELETE MESSAGE uri: ${response.request}');
    debugPrint('DELETE MESSAGE body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to delete message (${response.statusCode})');
    }
  }

  final List<ChatMessage> aanyaMessages = const [
    // ----------------------------------------------------------
    // ROSE RECEIVED
    // ----------------------------------------------------------
    ChatMessage(
      id: 'rose_received_1',
      text: 'I read your whole profile before this. The ambition bit got me.',
      time: '9:14 AM',
      isMine: false,
      type: ChatMessageType.rose,
      coinAmount: '10',
      hintLine: "Aanya has sent only 2 roses this month — you're one of them.",
    ),

    // ----------------------------------------------------------
    // ROSE SENT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'rose_sent_1',
      text: "Not a pickup line — I'd genuinely like to take you for coffee.",
      time: 'Sent yesterday · 8:50 PM',
      isMine: true,
      type: ChatMessageType.rose,
      coinAmount: '10',
      seen: true,
      hintLine:
          'Roses get 4× more replies than a plain message. She opened yours in 6 minutes.',
    ),

    // ----------------------------------------------------------
    // IMAGE FROM AANYA
    // ----------------------------------------------------------
    ChatMessage(
      id: 'photo_from_aanya',
      text: '',
      time: '8:42 PM',
      isMine: false,
      type: ChatMessageType.image,
      imageUrl:
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=700&q=80',
    ),

    // ----------------------------------------------------------
    // NORMAL TEXT (reply to photo)
    // ----------------------------------------------------------
    ChatMessage(
      id: 'message_reply_photo',
      text: 'Love this look! 🌹 You look incredible here.',
      time: '8:45 PM',
      isMine: true,
      type: ChatMessageType.text,
    ),

    // ----------------------------------------------------------
    // IMAGE SENT WITH A ROSE
    // ----------------------------------------------------------
    ChatMessage(
      id: 'photo_castle',
      text:
          'You keep making my ordinary days feel special. Coffee this weekend?',
      time: '8:47 PM',
      isMine: true,
      type: ChatMessageType.image,
      imageUrl:
          'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=700&q=80',
    ),

    // ----------------------------------------------------------
    // PREMIUM ROSE (sent by me)
    // ----------------------------------------------------------
    ChatMessage(
      id: 'gift_rose',
      text: 'A token of my appreciation',
      time: '',
      isMine: true,
      type: ChatMessageType.gift,
      giftName: 'Premium Rose',
      giftEmoji: '🌹',
      giftCoins: '+500 Coins',
      giftClaimed: true,
    ),

    // ----------------------------------------------------------
    // VIRTUAL COFFEE (from Aanya)
    // ----------------------------------------------------------
    ChatMessage(
      id: 'gift_coffee',
      text: 'Thinking of you this morning!',
      time: '',
      isMine: false,
      type: ChatMessageType.gift,
      giftName: 'Virtual Coffee',
      giftEmoji: '☕',
      giftCoins: '+100 Coins',
      giftClaimed: false,
      messageProgress: 18,
      messageTarget: 25,
      expiresIn: '5d 10h 42m',
    ),

    // ----------------------------------------------------------
    // NORMAL TEXT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'message_1',
      text:
          'How was your meeting earlier? I hope it went as well as we talked about! ✨',
      time: '9:16 AM',
      isMine: false,
      type: ChatMessageType.text,
    ),

    // ----------------------------------------------------------
    // PROPOSAL
    // ----------------------------------------------------------
    ChatMessage(
      id: 'proposal_1',
      text: 'Exclusively Dating',
      time: '9:16 AM',
      isMine: false,
      type: ChatMessageType.proposal,
    ),

    // ----------------------------------------------------------
    // COMPLIMENT SENT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'compliment_sent_1',
      text:
          'Your energy in that photo is unreal — you make ordinary days look like a film still.',
      time: '9:20 AM',
      isMine: true,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      seen: true,
      locationLabel: 'hero photo',
    ),

    // ----------------------------------------------------------
    // COMPLIMENT RECEIVED
    // ----------------------------------------------------------
    ChatMessage(
      id: 'compliment_received_1',
      text: "You actually listen. That's rarer than you think.",
      time: '',
      isMine: false,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      isNew: true,
      locationLabel: 'On your About section',
    ),

    // ----------------------------------------------------------
    // NORMAL TEXT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'message_2',
      text:
          'Good morning! I just sent that proposal because I really feel like we have something special. What do you think? 🌹',
      time: '9:18 AM',
      isMine: false,
      type: ChatMessageType.text,
    ),

    // ----------------------------------------------------------
    // DATE INVITES
    // ----------------------------------------------------------
    ChatMessage(
      id: 'invite_dinner',
      text: 'Would love to try that new French spot with you this Friday!',
      time: '',
      isMine: true,
      type: ChatMessageType.dateInvite,
      inviteTitle: 'Dinner Invitation',
      inviteVenue: 'Le Petit Bistro · 8:00 PM',
      inviteStatus: 'ACCEPTED',
    ),

    ChatMessage(
      id: 'invite_coffee',
      text: 'Quick catch up before my weekend plans?',
      time: '',
      isMine: false,
      type: ChatMessageType.dateInvite,
      inviteTitle: 'Coffee Date',
      inviteVenue: 'Starbucks Reserve · Sat 11 AM',
      inviteStatus: 'PENDING',
    ),
  ];

  /// Fetch chat conversations from the production REST API.
  ///
  /// Endpoint:
  /// GET https://dating-app-backend-plum.vercel.app/api/user/chat/conversations
  ///
  /// The API expects the same `auth_token` already used by the rest of the
  /// application and returns conversationId + user + lastMessage data.
  Future<List<ChatUser>> fetchChats() async {
    //    return const [
    //     ChatUser(
    //       id: '1',
    //       name: 'Aanya',
    //       age: 25,
    //       image: 'https://randomuser.me/api/portraits/women/44.jpg',
    //       preview: "Can't wait to see you tonight at the...",
    //       time: '2m',
    //       match: '92% Match',
    //       trust: '96% Trust',
    //       online: true,
    //       unread: 2,
    //       progress: '92%',
    //       reward: '🎁 Gift unlocked!',
    //     ),
    //     ChatUser(
    //       id: '2',
    //       name: 'Jordan',
    //       age: 27,
    //       image: 'https://randomuser.me/api/portraits/men/32.jpg',
    //       preview: 'Typing...',
    //       time: 'Now',
    //       match: '88% Match',
    //       trust: '88% Trust',
    //       online: true,
    //       unread: 0,
    //       progress: '62%',
    //       reward: '18/25 for Premium Rose 🌹',
    //     ),
    //     ChatUser(
    //       id: '3',
    //       name: 'Marcus',
    //       age: 29,
    //       image: 'https://randomuser.me/api/portraits/men/11.jpg',
    //       preview: 'That sounds like an amazing hobby! Ho...',
    //       time: '1h',
    //       match: '75% Match',
    //       trust: '72% Trust',
    //       online: true,
    //       unread: 0,
    //       progress: '20%',
    //       reward: '5/25 · Deadline 14h ⏰',
    //     ),
    //     ChatUser(
    //       id: '4',
    //       name: 'Elena',
    //       age: 23,
    //       image: 'https://randomuser.me/api/portraits/women/68.jpg',
    //       preview: "You: Hey! I'm heading over now.",
    //       time: '3h',
    //       match: '95% Match',
    //       trust: '91% Trust',
    //       online: true,
    //       unread: 0,
    //       progress: '78%',
    //       reward: '22/25 for Silver Ring 💍',
    //     ),
    //     ChatUser(
    //       id: '5',
    //       name: 'Rohan',
    //       age: 26,
    //       image: 'https://randomuser.me/api/portraits/men/52.jpg',
    //       preview: "I'm more of a mountain person, but the...",
    //       time: 'Yesterday',
    //       match: '81% Match',
    //       trust: '79% Trust',
    //       online: false,
    //       unread: 0,
    //       progress: '42%',
    //       reward: '12/25 for Virtual Coffee ☕',
    //     ),
    //     ChatUser(
    //       id: '1',
    //       name: 'Aanya',
    //       age: 25,
    //       image: 'https://randomuser.me/api/portraits/women/44.jpg',
    //       preview: "Can't wait to see you tonight at the...",
    //       time: '2m',
    //       match: '92% Match',
    //       trust: '96% Trust',
    //       online: true,
    //       unread: 2,
    //       progress: '92%',
    //       reward: '🎁 Gift unlocked!',
    //     ),
    //     ChatUser(
    //       id: '2',
    //       name: 'Jordan',
    //       age: 27,
    //       image: 'https://randomuser.me/api/portraits/men/32.jpg',
    //       preview: 'Typing...',
    //       time: 'Now',
    //       match: '88% Match',
    //       trust: '88% Trust',
    //       online: true,
    //       unread: 0,
    //       progress: '62%',
    //       reward: '18/25 for Premium Rose 🌹',
    //     ),
    //     ChatUser(
    //       id: '3',
    //       name: 'Marcus',
    //       age: 29,
    //       image: 'https://randomuser.me/api/portraits/men/11.jpg',
    //       preview: 'That sounds like an amazing hobby! Ho...',
    //       time: '1h',
    //       match: '75% Match',
    //       trust: '72% Trust',
    //       online: true,
    //       unread: 0,
    //       progress: '20%',
    //       reward: '5/25 · Deadline 14h ⏰',
    //     ),
    //     ChatUser(
    //       id: '4',
    //       name: 'Elena',
    //       age: 23,
    //       image: 'https://randomuser.me/api/portraits/women/68.jpg',
    //       preview: "You: Hey! I'm heading over now.",
    //       time: '3h',
    //       match: '95% Match',
    //       trust: '91% Trust',
    //       online: true,
    //       unread: 0,
    //       progress: '78%',
    //       reward: '22/25 for Silver Ring 💍',
    //     ),
    //     ChatUser(
    //       id: '5',
    //       name: 'Rohan',
    //       age: 26,
    //       image: 'https://randomuser.me/api/portraits/men/52.jpg',
    //       preview: "I'm more of a mountain person, but the...",
    //       time: 'Yesterday',
    //       match: '81% Match',
    //       trust: '79% Trust',
    //       online: false,
    //       unread: 0,
    //       progress: '42%',
    //       reward: '12/25 for Virtual Coffee ☕',
    //     ),
    //   ];
    // }
    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ FIX: this was a hardcoded test JWT, so the chat list (and its
      // unread counts) always loaded for one fixed dummy account instead
      // of whoever is actually logged in.
      final token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs";

      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/user/chat/conversations'),
        // Uri.parse(
        //   'https://dating-app-backend-plum.vercel.app/api/user/chat/conversations',
        // ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Chat conversations status: ${response.statusCode}');
      final body = response.body;

      const chunkSize = 800;

      for (var i = 0; i < body.length; i += chunkSize) {
        final end = (i + chunkSize < body.length) ? i + chunkSize : body.length;

        debugPrint(body.substring(i, end));
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Unable to load conversations (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
        throw Exception('Chat conversations API returned success=false');
      }

      final rawData = decoded['data'];
      if (rawData is! List) return const <ChatUser>[];

      return rawData
          .whereType<Map>()
          .map(
            (item) =>
                ChatUser.fromConversationJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Error fetching chat conversations: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Map real API/socket response data into the same UI model used by the demo data.
  /// Pass the response list directly from your API layer.
  List<ChatMessage> mapRealMessages(dynamic response) {
    final data = response is Map<String, dynamic>
        ? (response['data'] ??
              response['messages'] ??
              response['items'] ??
              response['results'])
        : response;

    return ChatMessage.fromJsonList(data, currentUserId: currentUserId);
  }

  /// Use this when your API layer already has the response body.
  /// It keeps sender/receiver casting in one place.
  Future<List<ChatMessage>> fetchMessagesFromResponse(
    String chatId,
    dynamic response,
  ) async {
    return mapRealMessages(response);
  }

  /// Fetch messages for a conversation from the production REST API.
  ///
  /// GET /api/user/chat/conversations/{conversationId}/messages?limit=10&cursor=...
  ///
  /// The API response is:
  /// {
  ///   "success": true,
  ///   "data": [...],
  ///   "pagination": {"hasMore": false, "nextCursor": null}
  /// }
  String _userIdFromJwt(String? token) {
    return userIdFromToken(token, fallback: currentUserId);
  }

  Future<ChatMessagesPage> fetchMessages(
    String chatId, {
    String? conversationId,
    int limit = 10,
    String? cursor,
  }) async {
    final id = (conversationId ?? chatId).trim();
    if (id.isEmpty) {
      throw ArgumentError('conversationId is required to load messages');
    }

    final prefs = await SharedPreferences.getInstance();
    final token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs";

    final query = <String, String>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final uri = Uri.parse(
      'https://api.welvors.com/api/user/chat/conversations/$id/messages',
    ).replace(queryParameters: query);

    debugPrint('Chat messages GET: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // ✅ FIX: was a hardcoded test JWT instead of the `token` fetched
        // above, so messages always loaded/authenticated as one fixed
        // dummy account regardless of who was actually logged in.
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Chat messages status: ${response.statusCode}');
    debugPrint('Chat messages body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load messages (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('Chat messages API returned success=false');
    }

    final rawData = decoded['data'];
    final effectiveUserId = currentUserId.trim().isNotEmpty
        ? currentUserId.trim()
        : _userIdFromJwt(token).trim();

    debugPrint('================ CHAT DEBUG ================');
    debugPrint('CURRENT USER ID: [$effectiveUserId]');

    final messages = ChatMessage.fromJsonList(
      rawData,
      currentUserId: effectiveUserId, // ✅ CORRECT
    );
    final pagination = decoded['pagination'] is Map
        ? Map<String, dynamic>.from(decoded['pagination'] as Map)
        : const <String, dynamic>{};

    final hasMore = pagination['hasMore'] == true;
    final nextCursor = pagination['nextCursor']?.toString();

    return ChatMessagesPage(
      messages: messages,
      hasMore: hasMore,
      nextCursor: nextCursor == 'null' ? null : nextCursor,
    );
  }
}
