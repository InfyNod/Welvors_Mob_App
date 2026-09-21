import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_bloc/chat_state.dart';

import 'package:velvors/config/env_config.dart';

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
  Future<void> sendRelationshipTagProposal({
    required String receiverId,
    required String tag,
    required String message,
  }) async {
    await _relationshipTagRequest(
      '${EnvConfig.apiBaseUrl}/user/relationship-tags/create-proposals',
      {
        'receiverId': receiverId.trim(),
        'tag': tag.trim(),
        'message': message.trim(),
      },
    );
  }

  Future<void> acceptRelationshipTagProposal(String proposalId) async {
    await _relationshipTagRequest(
      '${EnvConfig.apiBaseUrl}/user/relationship-tags/proposals/${proposalId.trim()}/accept',
      {},
    );
  }

  Future<void> rejectRelationshipTagProposal(String proposalId) async {
    await _relationshipTagRequest(
      '${EnvConfig.apiBaseUrl}/user/relationship-tags/proposals/${proposalId.trim()}/reject',
      {},
    );
  }

  Future<void> _relationshipTagRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    if (url.contains('/proposals//')) throw Exception('Proposal ID is missing');
    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';
    if (rawToken.isEmpty) throw Exception('Authentication token is missing');
    final token = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';
    debugPrint('💗 RELATIONSHIP API: $url');
    debugPrint('💗 RELATIONSHIP BODY: ${jsonEncode(body)}');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode(body),
    );
    debugPrint('💗 RELATIONSHIP STATUS: ${response.statusCode}');
    debugPrint('💗 RELATIONSHIP RESPONSE: ${response.body}');
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data?['success'] == false) {
      throw Exception(
        data?['message']?.toString() ?? 'Relationship tag request failed',
      );
    }
  }

  /// Blocks a user using the backend block endpoint.
  Future<void> blockUser(String blockedId) async {
    final cleanId = blockedId.trim();

    debugPrint('========== BLOCK USER API ==========');
    debugPrint('blockedId: $cleanId');

    if (cleanId.isEmpty) {
      throw Exception('Blocked user id is empty');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';

    debugPrint('auth_token exists: ${rawToken.isNotEmpty}');

    if (rawToken.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    // auth_token may already contain "Bearer ". Do not add it twice.
    final authorization = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final uri = Uri.parse('${EnvConfig.apiBaseUrl}/user/block');
    final body = jsonEncode(<String, dynamic>{'blockedId': cleanId});

    debugPrint('METHOD: POST');
    debugPrint('URL: $uri');
    debugPrint('BODY: $body');

    final response = await http.patch(
      uri,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': authorization,
      },
      body: body,
    );

    debugPrint('BLOCK USER STATUS: ${response.statusCode}');
    debugPrint('BLOCK USER RESPONSE: ${response.body}');
    debugPrint('===================================');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to block user (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body.trim();
        }
      }
      throw Exception(message);
    }
  }

  /// Reports a user.
  Future<void> reportUser({
    required String reportedId,
    required String reason,
    String description = '',
  }) async {
    final cleanReportedId = reportedId.trim();
    final cleanReason = reason.trim();
    final cleanDescription = description.trim();

    if (cleanReportedId.isEmpty) {
      throw Exception('Reported user id is empty');
    }
    if (cleanReason.isEmpty) {
      throw Exception('Report reason is required');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';
    if (rawToken.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    final authorization = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final uri = Uri.parse('${EnvConfig.apiBaseUrl}/user/reports');
    final body = jsonEncode(<String, dynamic>{
      'reportedId': cleanReportedId,
      'reason': cleanReason,
      'description': cleanDescription,
    });

    debugPrint('========== REPORT USER API ==========');
    debugPrint('METHOD: POST');
    debugPrint('URL: $uri');
    debugPrint('BODY: $body');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': authorization,
      },
      body: body,
    );

    debugPrint('REPORT USER STATUS: ${response.statusCode}');
    debugPrint('REPORT USER RESPONSE: ${response.body}');
    debugPrint('====================================');

    Map<String, dynamic>? decoded;
    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) {
        decoded = json;
      }
    } catch (_) {}

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded?['success'] == false) {
      throw Exception(
        decoded?['message']?.toString() ??
            'Unable to report user (${response.statusCode})',
      );
    }
  }

  Future<void> UnblockUser(String blockedId) async {
    final cleanId = blockedId.trim();

    debugPrint('========== BLOCK USER API ==========');
    debugPrint('blockedId: $cleanId');

    if (cleanId.isEmpty) {
      throw Exception('Blocked user id is empty');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';

    debugPrint('auth_token exists: ${rawToken.isNotEmpty}');

    if (rawToken.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    // auth_token may already contain "Bearer ". Do not add it twice.
    final authorization = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final uri = Uri.parse('${EnvConfig.apiBaseUrl}/user/unblock/$cleanId');
    // final body = jsonEncode(<String, dynamic>{'blockedId': cleanId});

    debugPrint('METHOD: POST');
    debugPrint('URL: $uri');
    // debugPrint('BODY: $body');

    final response = await http.delete(
      uri,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': authorization,
      },
      // body: body,
    );

    debugPrint('BLOCK USER STATUS: ${response.statusCode}');
    debugPrint('BLOCK USER RESPONSE: ${response.body}');
    debugPrint('===================================');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to block user (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body.trim();
        }
      }
      throw Exception(message);
    }
  }

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
        // Different auth versions use different JWT claims. Prefer the
        // // explicit user id, then fall back to `sub` (standard JWT subject).
        // // Some backends also nest the logged-in user inside `user`.
        // final nestedUser = payload['user'];
        // final nested = nestedUser is Map
        //     ? Map<String, dynamic>.from(nestedUser)
        //     : const <String, dynamic>{};

        // final value =
        //     payload['userId'] ??
        //     payload['user_id'] ??
        //     payload['id'] ??
        //     payload['sub'] ??
        //     nested['userId'] ??
        //     nested['user_id'] ??
        //     nested['id'];

        // if (value != null && value.toString().trim().isNotEmpty) {
        //   return value.toString().trim();
        // }
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    debugPrint("token>>>>>>>>$token");
    debugPrint("messageId>>>>>>>>$messageId");
    final response = await http.delete(
      Uri.parse('${EnvConfig.apiBaseUrl}/user/chat/messages/$cleanId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token?.isNotEmpty == true)
          'Authorization': token!.toLowerCase().startsWith('bearer ')
              ? token
              : 'Bearer $token',
      },
    );

    debugPrint('DELETE MESSAGE status: ${response.statusCode}');
    debugPrint('DELETE MESSAGE uri: ${response.request}');
    debugPrint('DELETE MESSAGE body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to delete message (${response.statusCode})');
    }
  }

  final List<ChatMessage> aanyaMessages = [
    // ----------------------------------------------------------
    // ROSE RECEIVED
    // ----------------------------------------------------------
    ChatMessage(
      id: 'rose_received_1',
      text: 'I read your whole profile before this. The ambition bit got me.',
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.rose,
      coinAmount: '10',
      hintLine: "Aanya has sent only 2 roses this month — you're one of them.",
      messageProgress: 18,
      messageTarget: 25,
    ),

    // ----------------------------------------------------------
    // ROSE SENT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'rose_sent_1',
      text: "Not a pickup line — I'd genuinely like to take you for coffee.",
      time: '2026-09-01T04:43:55.238Z',
      isMine: true,
      type: ChatMessageType.rose,
      coinAmount: '10',
      seen: true,
      hintLine:
          'Roses get 4× more replies than a plain message. She opened yours in 6 minutes.',
      messageProgress: 14,
      messageTarget: 25,
    ),

    // ----------------------------------------------------------
    // IMAGE FROM AANYA
    // ----------------------------------------------------------
    ChatMessage(
      id: 'photo_from_aanya',
      text: '',
      time: '2026-09-01T04:43:55.238Z',
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
      time: '2026-09-01T04:43:55.238Z',
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
      time: '2026-09-01T04:43:55.238Z',
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
      time: '2026-09-01T04:43:55.238Z',
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
      time: '2026-09-01T04:43:55.238Z',
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
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.text,
    ),

    // ----------------------------------------------------------
    // PROPOSAL
    // ----------------------------------------------------------
    ChatMessage(
      id: 'proposal_1',
      text: 'Exclusively Dating',
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.RELATIONSHIP_TAG_PROPOSAL,
    ),

    // ----------------------------------------------------------
    // COMPLIMENT SENT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'compliment_sent_1',
      text:
          'Your energy in that photo is unreal — you make ordinary days look like a film still.',
      time: '2026-09-01T04:43:55.238Z',
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
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      isNew: true,
      locationLabel: 'About section',
    ),

    // ----------------------------------------------------------
    // COMPLIMENT SENT — ON A PHOTO (image reply card)
    // ----------------------------------------------------------
    ChatMessage(
      id: 'compliment_sent_photo_1',
      text:
          'You keep making my ordinary days feel special — and that smile in your hero photo is unfair.',
      time: '2026-09-01T04:43:55.238Z',
      isMine: true,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      seen: true,
      locationLabel: 'hero photo',
      // complimentImageUrl:
      //     'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=700&q=80',
    ),

    // ----------------------------------------------------------
    // COMPLIMENT SENT — PROFILE FACT (lifestyle)
    // ----------------------------------------------------------
    ChatMessage(
      id: 'compliment_sent_fact_1',
      text:
          "Trekking, yoga and a cat parent — that's a whole personality and I'm into it.",
      time: '2026-09-01T04:43:55.238Z',
      isMine: true,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      seen: true,
      // complimentIcon: '🌿',
      // complimentFactTitle: 'Her Lifestyle',
      // complimentFactSubtitle: 'Vegetarian · Gym 4×/week · Cat parent · Night owl',
    ),

    // ----------------------------------------------------------
    // COMPLIMENT RECEIVED — PROFILE FACT (career)
    // ----------------------------------------------------------
    ChatMessage(
      id: 'compliment_received_fact_1',
      text:
          "Building your own studio by 28? That's not a plan, that's a decision. Respect.",
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      // complimentIcon: '💼',
      // complimentFactTitle: 'Your Career & Ambition',
      // complimentFactSubtitle: 'Senior PM · "Building my own studio, settled by 28"',
    ),

    // ----------------------------------------------------------
    // NORMAL TEXT
    // ----------------------------------------------------------
    ChatMessage(
      id: 'message_2',
      text:
          'Good morning! I just sent that proposal because I really feel like we have something special. What do you think? 🌹',
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.text,
    ),

    // ----------------------------------------------------------
    // DATE INVITES
    // ----------------------------------------------------------
    ChatMessage(
      id: 'invite_dinner',
      text: 'Would love to try that new French spot with you this Friday!',
      time: '2026-09-01T04:43:55.238Z',
      isMine: true,
      type: ChatMessageType.dateInvite,
      inviteTitle: 'Dinner Invitation',
      inviteVenue: 'Le Petit Bistro · 8:00 PM',
      inviteStatus: 'ACCEPTED',
      eventMenEntryPrice: '₹1,250',
      eventWomenEntryPrice: '₹1,250',
    ),

    ChatMessage(
      id: 'invite_coffee',
      text: '',
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.dateInvite,
      inviteStatus: 'LIVE',
      inviteEyebrow: 'DATE NOW PLAN · SHARED BY AANYA',
      inviteImageUrl:
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=900&q=80',
      inviteBadge: 'LIVE NOW',
      inviteTitle: 'Iced Coffee Deep Talks',
      inviteVenue: 'Blue Tokai, Bandra · 1.2 km away',
      inviteDateDay: '6',
      inviteDateMonth: 'TODAY\nPM',
      inviteTimeRange: '6:00 PM – 8:00 PM',
      inviteSubline: 'Requests close in 2h 40m · 1 spot left',
      inviteQuote:
          'No small talk, just the good stuff. Come find me at the corner table.',
      inviteStats: const {
        '🤝 Bill': 'Split (TTMM)',
        '👥 Joining': 'Just 1 person',
        '🔥 Interest': '7 people asked',
        '🎗 Match': '92% with you',
      },
      inviteSafetyNote:
          'Only the venue is shared — never your exact location. Aanya approves who joins.',
      inviteButtonPrimary: 'Request to join',
      inviteButtonSecondary: 'View plan',
      eventMenEntryPrice: '₹1,250',
      eventWomenEntryPrice: '₹1,250',
    ),

    // ----------------------------------------------------------
    // EVENT INVITE
    // ----------------------------------------------------------
    ChatMessage(
      id: 'event_soiree',
      text: '',
      time: '2026-09-01T04:43:55.238Z',
      isMine: false,
      type: ChatMessageType.eventInvite,
      inviteEyebrow: 'EVENT INVITE',
      inviteBadge: 'AWAITING RSVP',

      inviteTitle: 'Sunset Soirée for Singles',
      inviteDateDay: '12',
      inviteDateMonth: 'SAT\nOCT',
      inviteTimeRange: '7:00 PM',
      inviteSubline: 'RSVP by Fri 6 PM · doors open 30 min early',
      inviteVenue: 'The Rooftop Lounge, Bandra',
      invitePrice: '₹1,250 per person',
      inviteSafetyNote: 'Verified-only entry · safety team on site',
      inviteQuote: "Come with me? — pick how you'd like to book. 💜",
      inviteButtonPrimary: "I'll book both",
      inviteButtonPrimarySub: '2 tickets · ₹1,250 × 2',
      inviteButtonSecondary: 'Book separately',
      inviteButtonSecondarySub: '1 ticket each · ₹1,250',
      eventMenEntryPrice: '₹1,250',
      eventWomenEntryPrice: '₹1,250',
      eventHeroImage:
          'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=900&q=80',
      eventType: 'Social Gathering',
      // eventDressCode: 'Smart Casual',
      // eventAgeRange: '25–35',
      // eventMaxCapacity: '50 people',
      // eventRSVPDeadline: 'Fri 6 PM',
    ),
  ];

  // ============================================================
  // STATIC DEMO USER — showcases every card type in one thread
  // ============================================================
  //
  // This user always appears at the top of the chat list and never hits the
  // network — opening it renders `demoAllCardsMessages` straight away, so
  // every card style (text, image, audio, document, location, contact,
  // gift, proposal, rose, compliment, date invite, event invite) can be
  // reviewed in one place.

  // static const String demoAllCardsUserId = 'demo_all_cards_user';

  // static final ChatUser demoAllCardsUser = ChatUser(
  //   id: demoAllCardsUserId,
  //   conversationId: demoAllCardsUserId,
  //   userId: demoAllCardsUserId,
  //   name: 'Card Showcase',
  //   age: 0,
  //   image:
  //       'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
  //   preview: 'Every message card style, in one chat',
  //   time: '10:30 AM',
  //   match: '—',
  //   trust: '—',
  //   online: true,
  //   unread: 0,
  //   progress: '',
  //   reward: '',
  //   progressCurrent: 0,
  //   progressTarget: 0,
  //   progressPercentage: 0,
  //   progressLabel: '',
  //   progressType: '',
  //   giftName: '',
  //   progressExpiresAt: DateTime.parse('2026-09-14T09:30:53.592Z'),
  // );

  // // ============================================================
  // DEMO CARD SHOWCASE — SCREENSHOT 1 → SCREENSHOT 6
  // Each message below maps directly to the supplied UI references.
  // ============================================================
  static final List<ChatMessage> demoAllCardsMessages = [
    // SCREENSHOT 1 — Gift received / Chocolate Box / 18 of 25 replies
    ChatMessage(
      id: 'demo_card_1_chocolate',
      text: "You said you'd had a long week. Consider this a small fix.",
      time: '2026-09-01T20:44:00.000Z',
      isMine: false,
      type: ChatMessageType.gift,
      giftId: 'demo_chocolate_box',
      giftName: 'Chocolate Box',
      giftEmoji: '🍫',
      giftCoins: '650',
      giftClaimed: false,
      messageProgress: 18,
      messageTarget: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1549007994-cb92caebd54b?auto=format&fit=crop&w=1000&q=85',
    ),

    // SCREENSHOT 2 — Gift sent / Premium Rose / 25 of 25 unlocked
    ChatMessage(
      id: 'demo_card_2_rose_gift',
      text: 'A token of my appreciation.',
      time: '2026-09-01T20:58:00.000Z',
      isMine: true,
      type: ChatMessageType.gift,
      giftId: 'demo_premium_rose',
      giftName: 'Premium Rose',
      giftEmoji: '🌹',
      giftCoins: '500',
      giftClaimed: true,
      messageProgress: 25,
      messageTarget: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1527061011665-3652c757a4d4?auto=format&fit=crop&w=1000&q=85',
    ),

    // SCREENSHOT 3 — Gift sent / Luxury Watch / 14 of 25 replies
    ChatMessage(
      id: 'demo_card_3_watch',
      text: 'Saw this and thought of you — hope it makes you smile.',
      time: '2026-09-01T21:18:00.000Z',
      isMine: true,
      type: ChatMessageType.gift,
      giftId: 'demo_luxury_watch',
      giftName: 'Luxury Watch',
      giftEmoji: '⌚',
      giftCoins: '3,200',
      giftClaimed: false,
      messageProgress: 14,
      messageTarget: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=1000&q=85',
    ),

    // SCREENSHOT 4 — Compliment received / hero photo
    ChatMessage(
      id: 'demo_card_4_compliment_photo',
      text:
          'That first photo of yours is so you — steady, warm, no posing. I like that.',
      time: '2026-09-01T20:40:00.000Z',
      isMine: false,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      locationLabel: 'hero photo',
      complimentImageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1000&q=85',
      isNew: false,
    ),

    // SCREENSHOT 5A — Compliment sent / Her Lifestyle
    ChatMessage(
      id: 'demo_card_5_lifestyle',
      text:
          "Trekking, yoga and a cat parent — that's a whole personality and I'm into it.",
      time: '2026-09-01T20:47:00.000Z',
      isMine: true,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      complimentIcon: '🌿',
      complimentFactTitle: 'Her Lifestyle',
      complimentFactSubtitle:
          'Vegetarian · Gym 4×/week · Cat parent · Night owl',
      seen: true,
    ),

    // SCREENSHOT 5B — Compliment received / Your Career & ambition
    ChatMessage(
      id: 'demo_card_5_career',
      text:
          "Building your own studio by 28? That's not a plan, that's a decision. Respect.",
      time: '2026-09-01T20:52:00.000Z',
      isMine: false,
      type: ChatMessageType.compliment,
      coinAmount: '30',
      complimentIcon: '💼',
      complimentFactTitle: 'Your Career & ambition',
      complimentFactSubtitle:
          'Senior PM · Building my own studio, settled by 28',
    ),

    // SCREENSHOT 6 — Proposal message
    ChatMessage(
      id: 'demo_card_6_proposal',
      text:
          'Good morning! I just sent that proposal because I really feel like we have something special. What do you think? 🌹',
      time: '2026-09-01T09:20:00.000Z',
      isMine: false,
      type: ChatMessageType.text,
      typemsg: 'Text',
    ),

    // Remaining card types — kept in the same showcase user so every
    // existing ChatMessageType remains testable from one conversation.
    ChatMessage(
      id: 'demo_extra_text',
      text: 'Hey! Here is a normal text message too.',
      time: '2026-09-01T09:21:00.000Z',
      isMine: true,
      type: ChatMessageType.text,
    ),
    ChatMessage(
      id: 'demo_extra_image',
      text: '',
      time: '2026-09-01T09:22:00.000Z',
      isMine: false,
      type: ChatMessageType.image,
      imageUrl:
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=900&q=85',
    ),
    ChatMessage(
      id: 'demo_extra_audio',
      text: '',
      time: '2026-09-01T09:23:00.000Z',
      isMine: true,
      type: ChatMessageType.audio,
      audioUrl: '',
    ),
    ChatMessage(
      id: 'demo_extra_document',
      text: '',
      time: '2026-09-01T09:24:00.000Z',
      isMine: false,
      type: ChatMessageType.document,
      fileName: 'Weekend_Plan.pdf',
      fileSize: '1.2 MB',
    ),
    ChatMessage(
      id: 'demo_extra_location',
      text: 'Blue Tokai, Bandra · 1.2 km away',
      time: '2026-09-01T09:25:00.000Z',
      isMine: true,
      type: ChatMessageType.location,
    ),
    ChatMessage(
      id: 'demo_extra_contact',
      text: 'Aanya Sharma',
      time: '2026-09-01T09:26:00.000Z',
      isMine: false,
      type: ChatMessageType.contact,
      fileName: '+91 98765 43210',
    ),
    ChatMessage(
      id: 'demo_extra_date',
      text: 'Would love to try that new French spot with you this Friday!',
      time: '2026-09-01T09:27:00.000Z',
      isMine: true,
      type: ChatMessageType.dateInvite,
      inviteTitle: 'Dinner Invitation',
      inviteVenue: 'Le Petit Bistro · 8:00 PM',
      inviteStatus: 'ACCEPTED',
    ),
    ChatMessage(
      id: 'demo_extra_NOWPLAN',
      text: '',
      time: '2026-09-01T09:28:00.000Z',
      isMine: true,
      type: ChatMessageType.DATECONFIRMED,
      inviteEyebrow: 'EVENT INVITE',
      inviteBadge: 'AWAITING RSVP',
      eventMenEntryPrice: '₹1,250',
      eventWomenEntryPrice: '₹1,250',
      eventHeroImage:
          'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=900&q=80',

      inviteTitle: 'Sunset Soirée for Singles',
      inviteDateDay: '12',
      inviteDateMonth: 'SAT\nOCT',
      inviteTimeRange: '7:00 PM',
      inviteVenue: 'The Rooftop Lounge, Bandra',
      invitePrice: '₹1,250 per person',
      inviteQuote: 'Come with me? — pick how you\'d like to book. 💜',
      inviteButtonPrimary: "I'll book both",
      inviteButtonSecondary: 'Book separately',
      eventType: 'Social Gathering',
      eventDate: '2026-09-01T09:28:00.000Z',
      eventStartTime: '2026-09-01T09:28:00.000Z',
      eventEndTime: '2026-09-01T10:28:00.000Z',
      eventTitle: "eventTitle11",
      eventFullAddress: "eventFullAddress",
      inviteStats: {
        '🤝 Bill': 'Split (TTMM)',
        '👥 Joining': 'Just 1 person',
        '🔥 Interest': '7 people asked',
        '🎗 Match': '92% with you',
      },
      inviteSafetyNote:
          "nly the venue is shared — never your exact location. Aanya approves who joins.",
      eventVenueName: "Requests close in 2h 40m · 1 spot left",
    ),
    ChatMessage(
      id: 'demo_extra_event',
      text: '',
      time: '2026-09-01T09:28:00.000Z',
      isMine: true,
      type: ChatMessageType.eventInvite,
      inviteEyebrow: 'EVENT INVITE',
      inviteBadge: 'AWAITING RSVP',
      eventMenEntryPrice: '₹1,250',
      eventWomenEntryPrice: '₹1,250',
      eventHeroImage:
          'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=900&q=80',

      inviteTitle: 'Sunset Soirée for Singles111111',
      inviteDateDay: '12',
      inviteDateMonth: 'SAT\nOCT',
      inviteTimeRange: '7:00 PM',
      inviteVenue: 'The Rooftop Lounge, Bandra',
      invitePrice: '₹1,250 per person',
      inviteQuote: 'Come with me? — pick how you\'d like to book. 💜',
      inviteButtonPrimary: "I'll book both",
      inviteButtonSecondary: 'Book separately',
      eventType: 'Social Gathering',
      eventDate: '2026-09-01T09:28:00.000Z',
      eventStartTime: '2026-09-01T09:28:00.000Z',
      eventEndTime: '2026-09-01T09:28:00.000Z',
      eventTitle: "eventTitle22",
      eventFullAddress: "eventFullAddress",
    ),
  ];

  Future<void> deleteConversation(String conversationId) async {
    final id = conversationId.trim();
    if (id.isEmpty) throw Exception('Conversation id is empty');

    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';

    if (rawToken.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    // auth_token may already contain the Bearer prefix.
    final authorization = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final url = '${EnvConfig.apiBaseUrl}/user/chat/conversations/$id';

    debugPrint('========== DELETE CONVERSATION API ==========');
    debugPrint('URL: DELETE $url');
    debugPrint('conversationId: $id');

    final response = await http.delete(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'Authorization': authorization},
    );

    debugPrint('DELETE CONVERSATION STATUS: ${response.statusCode}');
    debugPrint('DELETE CONVERSATION RESPONSE: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to delete conversation (${response.statusCode})';

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
      }

      throw Exception(message);
    }

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['success'] == false) {
          throw Exception(
            decoded['message']?.toString() ?? 'Delete conversation failed',
          );
        }
      } catch (e) {
        if (e is Exception &&
            e.toString().contains('Delete conversation failed')) {
          rethrow;
        }
        // Some DELETE APIs return an empty/non-JSON success response.
      }
    }
  }

  Future<void> clearConversation(String conversationId) async {
    final id = conversationId.trim();
    if (id.isEmpty) throw Exception('Conversation id is empty');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    final response = await http.delete(
      Uri.parse(
        '${EnvConfig.apiBaseUrl}/user/chat/conversations/$id/clear',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token?.isNotEmpty == true)
          'Authorization': token!.toLowerCase().startsWith('bearer ')
              ? token
              : 'Bearer $token',
      },
    );

    debugPrint('CLEAR CONVERSATION [$id] => ${response.statusCode}');
    debugPrint('CLEAR CONVERSATION BODY => ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to clear chat (${response.statusCode})');
    }

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['success'] == false) {
          throw Exception(
            decoded['message']?.toString() ?? 'Clear chat failed',
          );
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('Clear chat failed')) {
          rethrow;
        }
      }
    }
  }

  /// Fetch chat conversations from the production REST API.
  ///
  /// Endpoint:
  /// GET https://dating-app-backend-plum.vercel.app/api/user/chat/conversations
  ///
  /// The API expects the same `auth_token` already used by the rest of the
  /// application and returns conversationId + user + lastMessage data.
  // Future<List<ChatUser>> fetchChats() async {

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     // ✅ FIX: this was a hardcoded test JWT, so the chat list (and its
  //     // unread counts) always loaded for one fixed dummy account instead
  //     // of whoever is actually logged in.
  //     final token = await _chatAuthToken();
  //     final response = await http.get(
  //       Uri.parse('${EnvConfig.apiBaseUrl}/user/chat/conversations'),
  //       // Uri.parse(
  //       //   'https://dating-app-backend-plum.vercel.app/api/user/chat/conversations',
  //       // ),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         if (token != null && token.isNotEmpty)
  //           'Authorization': '$token',
  //       },
  //     );

  //     debugPrint('Chat conversations status: ${response.statusCode}');
  //     final body = response.body;

  //     const chunkSize = 800;

  //     for (var i = 0; i < body.length; i += chunkSize) {
  //       final end = (i + chunkSize < body.length) ? i + chunkSize : body.length;

  //       debugPrint(body.substring(i, end));
  //     }

  //     if (response.statusCode < 200 || response.statusCode >= 300) {
  //       throw Exception(
  //         'Unable to load conversations (${response.statusCode})',
  //       );
  //     }

  //     final decoded = jsonDecode(response.body);
  //     if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
  //       throw Exception('Chat conversations API returned success=false');
  //     }

  //     final rawData = decoded['data'];
  //     if (rawData is! List) return const <ChatUser>[];

  //     return rawData
  //         .whereType<Map>()
  //         .map(
  //           (item) =>
  //               ChatUser.fromConversationJson(Map<String, dynamic>.from(item)),
  //         )
  //         .toList();
  //   } catch (e, stackTrace) {
  //     debugPrint('Error fetching chat conversations: $e');
  //     debugPrintStack(stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

  Future<List<ChatUser>> fetchChats({String type = 'all'}) async {
    // [  //  ChatUser(
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
    //     ),]
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}/user/chat/conversations',
        // "https://dating-app-backend-plum.vercel.app/api/user/chat/conversations",
      ).replace(queryParameters: {'type': type});

      debugPrint('📥 Chat conversations API => $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token?.isNotEmpty == true)
            'Authorization': token!.toLowerCase().startsWith('bearer ')
                ? token
                : 'Bearer $token',
        },
      );

      debugPrint('📥 Chat conversations status: ${response.statusCode}');

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

      if (rawData is! List) {
        return const <ChatUser>[];
      }

      final chats = rawData
          .whereType<Map>()
          .map(
            (item) =>
                ChatUser.fromConversationJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      debugPrint(
        '✅ Chat conversations loaded '
        'type=$type count=${chats.length}',
      );

      return [...chats];
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Error fetching chat conversations '
        'type=$type: $e',
      );

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  /// Fetch the live conversation/user details shown on the chat-details
  /// screen header (name, age, package type, online status, last seen,
  /// blocked flag, match score, profile image).
  ///
  /// GET /api/user/chat/{conversationId}/details
  ///
  /// The exact same JSON shape is also pushed in real time over the
  /// `profile:details` socket event while the chat screen is open, so both
  /// paths are parsed with [ConversationProfileDetails.fromJson].
  Future<ConversationProfileDetails> fetchConversationUserDetails(
    String conversationId,
  ) async {
    final cleanId = conversationId.trim();

    if (cleanId.isEmpty) {
      throw Exception('conversationId is empty');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse(
      '${EnvConfig.apiBaseUrl}/user/chat/$cleanId/details',
    );

    debugPrint('👤 Conversation user details API => $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token?.isNotEmpty == true)
          'Authorization': token!.toLowerCase().startsWith('bearer ')
              ? token
              : 'Bearer $token',
      },
    );

    debugPrint('👤 Conversation user details status: ${response.statusCode}');
    debugPrint('👤 Conversation user details body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Unable to load conversation user details (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('Conversation user details API returned success=false');
    }

    return ConversationProfileDetails.fromJson(decoded);
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
  /// GET /api/user/chat/conversations/{conversationId}/messages?type=all&limit=10&cursor=...
  ///
  /// [type] filters the message list and accepts:
  /// 'all' | 'rose' | 'gift' | 'compliment' | 'date'
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
    // 'all' | 'rose' | 'gift' | 'compliment' | 'date'
    String type = 'all',
  }) async {
    // Static demo thread — never hits the network, always returns the full
    // card showcase so it's available even without a signed-in session.
    // if (chatId == demoAllCardsUserId || conversationId == demoAllCardsUserId) {
    //   return ChatMessagesPage(
    //     messages: demoAllCardsMessages,
    //     hasMore: false,
    //     nextCursor: null,
    //   );
    // }

    final id = (conversationId ?? chatId).trim();
    if (id.isEmpty) {
      throw ArgumentError('conversationId is required to load messages');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    final query = <String, String>{
      'type': type,
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final uri = Uri.parse(
      '${EnvConfig.apiBaseUrl}/user/chat/conversations/$id/messages',
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
        if (token?.isNotEmpty == true)
          'Authorization': token!.toLowerCase().startsWith('bearer ')
              ? token
              : 'Bearer $token',
      },
    );

    debugPrint('Chat messages status: ${response.statusCode}');
    debugPrint('Chat messages body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load messages (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Chat messages API returned invalid JSON');
    }
    if (decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Chat messages API returned success=false',
      );
    }

    // Backend has returned different wrappers across chat endpoints.
    // Normalize them here so first-open never becomes an empty UI just
    // because messages are inside data.messages/data.items.
    dynamic rawData = decoded['data'];
    if (rawData is Map) {
      final map = Map<String, dynamic>.from(rawData as Map);
      rawData =
          map['messages'] ?? map['items'] ?? map['results'] ?? map['data'];
    }
    if (rawData is! List) rawData = const <dynamic>[];
    final effectiveUserId = currentUserId.trim().isNotEmpty
        ? currentUserId.trim()
        : _userIdFromJwt(token).trim();

    debugPrint('================ CHAT DEBUG ================');
    debugPrint('CURRENT USER ID: [$effectiveUserId]');
    debugPrint('MESSAGE RAW COUNT: ${(rawData as List).length}');

    final messages = ChatMessage.fromJsonList(
      rawData,
      currentUserId: effectiveUserId,
    );
    debugPrint('MESSAGE MAPPED COUNT: ${messages.length}');
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

  //unused this place
  /// Unmatches the current user with another user.
  Future<void> unmatchUser({
    required String otherUserId,
    required String reason,
    String? note,
  }) async {
    final cleanOtherUserId = otherUserId.trim();
    final cleanReason = reason.trim();
    final cleanNote = note?.trim();

    if (cleanOtherUserId.isEmpty) {
      throw Exception('Other user id is empty');
    }

    if (cleanReason.isEmpty) {
      throw Exception('Unmatch reason is required');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';

    if (rawToken.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    final authorization = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final uri = Uri.parse(
      '${EnvConfig.apiBaseUrl}/user/unmatch/$cleanOtherUserId',
    );

    final body = <String, dynamic>{
      'reason': cleanReason,
      if (cleanNote != null && cleanNote.isNotEmpty) 'note': cleanNote,
    };

    debugPrint('========== UNMATCH USER API ==========');
    debugPrint('METHOD: POST');
    debugPrint('URL: $uri');
    debugPrint('BODY: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': authorization,
      },
      body: jsonEncode(body),
    );

    debugPrint('UNMATCH STATUS: ${response.statusCode}');
    debugPrint('UNMATCH RESPONSE: ${response.body}');
    debugPrint('======================================');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to unmatch user (${response.statusCode})';

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body.trim();
        }
      }

      throw Exception(message);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['success'] == false) {
        throw Exception(
          decoded['message']?.toString() ?? 'Unable to unmatch user',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
    }
  }
}
