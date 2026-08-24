import 'package:equatable/equatable.dart';

enum ChatMessageDirection { sender, receiver }

enum ChatMessageType {
  text,
  image,
  audio,
  document,
  location,
  contact,
  proposal,
  gift,
  rose,
  compliment,
  dateInvite,
}

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final String time;
  final bool isMine;
  final String? senderId;
  final String? receiverId;
  final String? typemsg;
  final ChatMessageType type;

  // Image
  final String? imageUrl;

  // Reply
  final String? replyToId;
  final String? replyText;
  final String? replyImageUrl;
  final String? replyFileUrl;
  final ChatMessageType? replyType;

  // Audio
  final String? audioUrl;

  // Document / File
  final String? fileUrl;
  final String? fileName;
  final String? fileSize;

  // Gift
  final String? giftId;
  final String? giftName;
  final String? giftEmoji;
  final String? giftCoins;
  final bool giftClaimed;

  // Gift progress
  final int? messageProgress;
  final int? messageTarget;
  final String? expiresIn;

  // Rose / Compliment
  final String? coinAmount;
  final bool seen;

  /// True when the backend has confirmed that the recipient received this message.
  final bool delivered;
  final String? hintLine;

  // Compliment
  final String? locationLabel;
  final bool isNew;

  // Proposal
  final String? proposalId;

  // Date Invite
  final String? inviteTitle;
  final String? inviteVenue;
  final String? inviteStatus;

  const ChatMessage({
    required this.id,
    this.text = '',
    required this.time,
    required this.isMine,
    this.senderId,
    this.receiverId,
    this.typemsg,
    this.type = ChatMessageType.text,

    // Image
    this.imageUrl,

    // Reply
    this.replyToId,
    this.replyText,
    this.replyImageUrl,
    this.replyFileUrl,
    this.replyType,

    // Audio
    this.audioUrl,

    // Document
    this.fileUrl,
    this.fileName,
    this.fileSize,

    // Gift
    this.giftId,
    this.giftName,
    this.giftEmoji,
    this.giftCoins,
    this.giftClaimed = false,

    // Gift progress
    this.messageProgress,
    this.messageTarget,
    this.expiresIn,

    // Rose / Compliment
    this.coinAmount,
    this.seen = false,
    this.delivered = false,
    this.hintLine,

    // Compliment
    this.locationLabel,
    this.isNew = false,

    // Proposal
    this.proposalId,

    // Date Invite
    this.inviteTitle,
    this.inviteVenue,
    this.inviteStatus,
  });

  ChatMessageDirection get direction =>
      isMine ? ChatMessageDirection.sender : ChatMessageDirection.receiver;

  /// Converts an API/socket message into the UI model.
  ///
  /// `currentUserId` is the logged-in user's id. The message is considered
  /// sent by the current user when `senderId == currentUserId`; otherwise it
  /// is considered received. If an API already sends `isMine`, that value is
  /// used as a fallback when sender ids are missing.
  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = _string(
      json['senderId'] ?? json['sender_id'] ?? json['fromId'],
    );

    final receiverId = _string(
      json['receiverId'] ?? json['receiver_id'] ?? json['toId'],
    );

    final normalizedCurrentUserId = currentUserId.trim();
    final normalizedSenderId = senderId?.trim();

    final bool isMine =
        normalizedSenderId != null &&
        normalizedSenderId.isNotEmpty &&
        normalizedSenderId == normalizedCurrentUserId;

    // debugPrint(
    //   'MESSAGE: ${json['content']} | '
    //   'senderId: $normalizedSenderId | '
    //   'currentUserId: $normalizedCurrentUserId | '
    //   'isMine: $isMine',
    // );

    final type = _messageType(
      json['type'] ??
          json['messageType'] ??
          json['message_type'] ??
          json['contentType'] ??
          json['content_type'] ??
          json['typemsg'],
    );

    return ChatMessage(
      id:
          _string(json['id'] ?? json['_id'] ?? json['messageId']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),

      text: _string(json['text'] ?? json['message'] ?? json['content']) ?? '',

      time:
          _string(json['time'] ?? json['createdAt'] ?? json['created_at']) ??
          '',

      isMine: isMine,

      senderId: senderId,
      receiverId: receiverId,

      typemsg: _string(json['typemsg'] ?? json['messageType']),

      type: type,

      imageUrl: _string(json['imageUrl'] ?? json['image_url'] ?? json['image']),

      replyToId: _string(json['replyToId'] ?? json['reply_to_id']),

      replyText: _string(json['replyText'] ?? json['reply_text']),

      replyImageUrl: _string(json['replyImageUrl'] ?? json['reply_image_url']),

      replyFileUrl: _string(json['replyFileUrl'] ?? json['reply_file_url']),

      replyType: _messageTypeNullable(json['replyType'] ?? json['reply_type']),

      audioUrl: _string(json['audioUrl'] ?? json['audio_url']),

      fileUrl: _string(json['fileUrl'] ?? json['file_url']),

      fileName: _string(json['fileName'] ?? json['file_name']),

      fileSize: _string(json['fileSize'] ?? json['file_size']),

      giftId: _string(json['giftId'] ?? json['gift_id']),

      giftName: _string(json['giftName'] ?? json['gift_name']),

      giftEmoji: _string(json['giftEmoji'] ?? json['gift_emoji']),

      giftCoins: _string(
        json['giftCoins'] ?? json['gift_coins'] ?? json['coins'],
      ),

      giftClaimed: _bool(json['giftClaimed'] ?? json['gift_claimed']) ?? false,

      messageProgress: _int(
        json['messageProgress'] ?? json['message_progress'],
      ),

      messageTarget: _int(json['messageTarget'] ?? json['message_target']),

      expiresIn: _string(json['expiresIn'] ?? json['expires_in']),

      coinAmount: _string(json['coinAmount'] ?? json['coin_amount']),

      seen: _bool(json['seen']) ?? false,
      delivered:
          _bool(
            json['delivered'] ?? json['isDelivered'] ?? json['is_delivered'],
          ) ??
          false,

      hintLine: _string(json['hintLine'] ?? json['hint_line']),

      locationLabel: _string(json['locationLabel'] ?? json['location_label']),

      isNew: _bool(json['isNew'] ?? json['is_new']) ?? false,

      proposalId: _string(json['proposalId'] ?? json['proposal_id']),

      inviteTitle: _string(json['inviteTitle'] ?? json['invite_title']),

      inviteVenue: _string(json['inviteVenue'] ?? json['invite_venue']),

      inviteStatus: _string(json['inviteStatus'] ?? json['invite_status']),
    );
  }
  static ChatMessageType _messageType(dynamic value) {
    return _messageTypeNullable(value) ?? ChatMessageType.text;
  }

  static ChatMessageType? _messageTypeNullable(dynamic value) {
    if (value == null) return null;
    if (value is ChatMessageType) return value;

    final raw = value
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '');

    const aliases = <String, ChatMessageType>{
      'text': ChatMessageType.text,
      'message': ChatMessageType.text,
      'image': ChatMessageType.image,
      'photo': ChatMessageType.image,
      'audio': ChatMessageType.audio,
      'voice': ChatMessageType.audio,
      'document': ChatMessageType.document,
      'file': ChatMessageType.document,
      'location': ChatMessageType.location,
      'contact': ChatMessageType.contact,
      'proposal': ChatMessageType.proposal,
      'gift': ChatMessageType.gift,
      'rose': ChatMessageType.rose,
      'compliment': ChatMessageType.compliment,
      'dateinvite': ChatMessageType.dateInvite,
      'date': ChatMessageType.dateInvite,
    };

    return aliases[raw];
  }

  static int compareByTime(ChatMessage a, ChatMessage b) {
    final ad = DateTime.tryParse(a.time);
    final bd = DateTime.tryParse(b.time);

    if (ad != null && bd != null) {
      return ad.compareTo(bd);
    }

    // If the API uses non-ISO time strings, keep the original order.
    return 0;
  }

  static bool _directionIsSender(dynamic value) {
    if (value == null) return false;
    final raw = value.toString().toLowerCase();
    return raw == 'sender' ||
        raw == 'sent' ||
        raw == 'mine' ||
        raw == 'outgoing';
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    final result = value.toString();
    return result.isEmpty ? null : result;
  }

  static bool? _bool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value.toString().toLowerCase();
    if (raw == 'true' || raw == '1' || raw == 'yes') return true;
    if (raw == 'false' || raw == '0' || raw == 'no') return false;
    return null;
  }

  static int? _int(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static List<ChatMessage> fromJsonList(
    dynamic data, {
    required String currentUserId,
  }) {
    if (data is! List) return const [];
    final messages = data
        .whereType<Map>()
        .map(
          (item) => ChatMessage.fromJson(
            Map<String, dynamic>.from(item),
            currentUserId: currentUserId,
          ),
        )
        .toList();

    // ListView uses reverse:true, therefore keep newest -> oldest.
    messages.sort((a, b) => ChatMessage.compareByTime(b, a));
    return messages;
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    String? time,
    String? textmsg,
    bool? isMine,
    String? senderId,
    String? receiverId,
    ChatMessageType? type,
    String? imageUrl,
    String? replyToId,
    String? replyText,
    String? replyImageUrl,
    String? replyFileUrl,
    ChatMessageType? replyType,
    String? audioUrl,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? giftId,
    String? giftName,
    String? giftEmoji,
    String? giftCoins,
    bool? giftClaimed,
    int? messageProgress,
    int? messageTarget,
    String? expiresIn,
    String? coinAmount,
    bool? seen,
    bool? delivered,
    String? hintLine,
    String? locationLabel,
    bool? isNew,
    String? proposalId,
    String? inviteTitle,
    String? inviteVenue,
    String? inviteStatus,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      typemsg: textmsg ?? this.typemsg,
      time: time ?? this.time,
      isMine: isMine ?? this.isMine,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,

      imageUrl: imageUrl ?? this.imageUrl,

      replyToId: replyToId ?? this.replyToId,
      replyText: replyText ?? this.replyText,
      replyImageUrl: replyImageUrl ?? this.replyImageUrl,
      replyFileUrl: replyFileUrl ?? this.replyFileUrl,
      replyType: replyType ?? this.replyType,

      audioUrl: audioUrl ?? this.audioUrl,

      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,

      giftId: giftId ?? this.giftId,
      giftName: giftName ?? this.giftName,
      giftEmoji: giftEmoji ?? this.giftEmoji,
      giftCoins: giftCoins ?? this.giftCoins,
      giftClaimed: giftClaimed ?? this.giftClaimed,

      messageProgress: messageProgress ?? this.messageProgress,
      messageTarget: messageTarget ?? this.messageTarget,
      expiresIn: expiresIn ?? this.expiresIn,

      coinAmount: coinAmount ?? this.coinAmount,
      seen: seen ?? this.seen,
      delivered: delivered ?? this.delivered,
      hintLine: hintLine ?? this.hintLine,

      locationLabel: locationLabel ?? this.locationLabel,
      isNew: isNew ?? this.isNew,

      proposalId: proposalId ?? this.proposalId,

      inviteTitle: inviteTitle ?? this.inviteTitle,
      inviteVenue: inviteVenue ?? this.inviteVenue,
      inviteStatus: inviteStatus ?? this.inviteStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    time,
    isMine,
    senderId,
    receiverId,
    type,

    imageUrl,
    replyToId,
    replyText,
    replyImageUrl,
    replyFileUrl,
    replyType,
    audioUrl,

    fileUrl,
    fileName,
    fileSize,

    giftId,
    giftName,
    giftEmoji,
    giftCoins,
    giftClaimed,

    messageProgress,
    messageTarget,
    expiresIn,

    coinAmount,
    seen,
    delivered,
    hintLine,

    locationLabel,
    isNew,

    proposalId,

    inviteTitle,
    inviteVenue,
    inviteStatus,
  ];
}

class ChatUser extends Equatable {
  /// Conversation id used when opening the chat.
  final String id;
  final String? conversationId;

  /// Other user's profile id from the conversation response.
  final String userId;

  final String name;
  final int age;
  final String image;
  final String preview;
  final String time;
  final String match;
  final String trust;
  final bool online;
  final int unread;
  final String progress;
  final String reward;

  const ChatUser({
    required this.id,
    this.conversationId,
    this.userId = '',
    required this.name,
    required this.age,
    required this.image,
    required this.preview,
    required this.time,
    required this.match,
    required this.trust,
    required this.online,
    required this.unread,
    required this.progress,
    required this.reward,
  });

  /// Maps the exact response returned by
  /// `/api/user/chat/conversations`.
  factory ChatUser.fromConversationJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    final lastMessage = json['lastMessage'] is Map
        ? Map<String, dynamic>.from(json['lastMessage'] as Map)
        : const <String, dynamic>{};

    final id = (json['id'] ?? '').toString();
    final conversationId = (json['conversationId'] ?? '').toString();
    final profileId = (user['id'] ?? '').toString();
    final fullName = (user['fullName'] ?? 'Unknown').toString();
    final matchPercentage = (user['matchPercentage'] ?? 'Unknown').toString();
    final trustPercentage = (user['trustPercentage'] ?? 'Unknown').toString();
    final isOnline = (user['isOnline'] ?? false);
    final ageValue = user['age'];

    final age = ageValue is num
        ? ageValue.toInt()
        : int.tryParse(ageValue?.toString() ?? '') ?? 0;

    final content = (lastMessage['content'] ?? '').toString();
    final createdAt = (lastMessage['createdAt'] ?? json['updatedAt'] ?? '')
        .toString();

    return ChatUser(
      id: id,
      conversationId: conversationId,
      userId: profileId,
      name: fullName,
      age: age,
      image: (user['profilePhoto'] ?? '').toString(),
      preview: content.isEmpty ? 'No messages yet' : content,
      time: formatConversationTime(createdAt),
      // These values are not present in this API response, so keep the
      // existing UI placeholders until the backend provides them.
      match: matchPercentage,
      trust: trustPercentage,
      online: isOnline,
      unread: toInt(json['unreadCount']),
      progress: '0%',
      reward: '',
    );
  }

  static int toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String formatConversationTime(String value) {
    if (value.isEmpty) return '';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;

    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays == 1) return 'Yesterday';

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  ChatUser copyWith({String? preview, String? time, int? unread}) {
    return ChatUser(
      id: id,
      conversationId: conversationId, // ✅ FIX: was being dropped (reset to
      // null) on every copyWith call, e.g. from markConversationRead().
      // That null conversationId then broke the typing-indicator lookup
      // (`_typingConversations[user.conversationId!]`) for that chat
      // forever after it was opened once.
      userId: userId,
      name: name,
      age: age,
      image: image,
      preview: preview ?? this.preview,
      time: time ?? this.time,
      match: match,
      trust: trust,
      online: online,
      unread: unread ?? this.unread,
      progress: progress,
      reward: reward,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    userId,
    name,
    age,
    image,
    preview,
    time,
    match,
    trust,
    online,
    unread,
    progress,
    reward,
  ];
}

class ChatState extends Equatable {
  final bool loading;
  final List<ChatUser> allChats;
  final List<ChatUser> filteredChats;
  final String search;
  final String filter;
  final Map<String, List<ChatMessage>> messages;
  final Map<String, String?> messageNextCursor;
  final Map<String, bool> messageHasMore;

  const ChatState({
    this.loading = false,
    this.allChats = const [],
    this.filteredChats = const [],
    this.search = '',
    this.filter = 'All',
    this.messages = const {},
    this.messageNextCursor = const {},
    this.messageHasMore = const {},
  });

  ChatState copyWith({
    bool? loading,
    List<ChatUser>? allChats,
    List<ChatUser>? filteredChats,
    String? search,
    String? filter,
    Map<String, List<ChatMessage>>? messages,
    Map<String, String?>? messageNextCursor,
    Map<String, bool>? messageHasMore,
  }) {
    return ChatState(
      loading: loading ?? this.loading,
      allChats: allChats ?? this.allChats,
      filteredChats: filteredChats ?? this.filteredChats,
      search: search ?? this.search,
      filter: filter ?? this.filter,
      messages: messages ?? this.messages,
      messageNextCursor: messageNextCursor ?? this.messageNextCursor,
      messageHasMore: messageHasMore ?? this.messageHasMore,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    allChats,
    filteredChats,
    search,
    filter,
    messages,
    messageNextCursor,
    messageHasMore,
  ];
}
