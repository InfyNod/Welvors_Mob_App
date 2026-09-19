import 'package:equatable/equatable.dart';

enum ChatMessageDirection { sender, receiver }

enum _SwipeDirection { none, reply, delete }

_SwipeDirection _swipeDirection = _SwipeDirection.none;

bool _replyTriggered = false;
bool _deleteTriggered = false;

enum ChatMessageType {
  text,
  image,
  video,
  audio,
  document,
  location,
  contact,
  RELATIONSHIP_TAG_PROPOSAL,
  RELATIONSHIP_TAG_ACCEPTED,
  gift,
  rose,
  effect,
  ENGAGEMENT,
  compliment,
  dateInvite,
  DATECONFIRMED,
  eventInvite,
}

// ============================================================================
// CHAT MESSAGE
// ============================================================================

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final String time;
  final bool isMine;

  final String? senderId;
  final String? receiverId;
  final String? typemsg;
  final ChatMessageType type;

  // ==========================================================
  // OPTIMISTIC UPLOAD
  // ==========================================================

  final bool isPendingUpload;

  // ==========================================================
  // IMAGE
  // ==========================================================

  final String? imageUrl;
  final String? videoUrl;

  // ==========================================================
  // REPLY
  // ==========================================================

  final String? replyToId;
  final String? replyText;
  final String? replyImageUrl;
  final String? replyFileUrl;
  final ChatMessageType? replyType;

  // ==========================================================
  // AUDIO
  // ==========================================================

  final String? audioUrl;

  // ==========================================================
  // DOCUMENT / FILE
  // ==========================================================

  final String? fileUrl;
  final String? fileName;
  final String? fileSize;

  // ==========================================================
  // GIFT
  // ==========================================================

  final String? giftId;
  final String? giftName;
  final String? giftEmoji;
  final String? giftCoins;
  final bool giftClaimed;

  // ==========================================================
  // MESSAGE PROGRESS
  // ==========================================================

  final int? messageProgress;
  final int? messageTarget;
  final String? expiresIn;

  // ==========================================================
  // ROSE / COMPLIMENT
  // ==========================================================

  final String? coinAmount;
  final bool seen;
  final bool delivered;
  final String? hintLine;

  // ==========================================================
  // LOCATION
  // ==========================================================

  final String? locationLabel;
  final double? latitude;
  final double? longitude;
  final bool isNew;

  // ==========================================================
  // COMPLIMENT
  // ==========================================================

  final String? complimentImageUrl;
  final String? complimentIcon;
  final String? complimentFactTitle;
  final String? complimentFactSubtitle;

  // ==========================================================
  // ENGAGEMENT / BUNDLE
  // ==========================================================

  final String? roseId;
  final String? complimentId;
  final String? engagementGiftId;
  final bool isBundle;

  // ==========================================================
  // ENGAGEMENT COMPLIMENT
  // ==========================================================

  final String? complimentMessage;
  final String? complimentIdeaId;
  final String? complimentStatus;

  // ==========================================================
  // ENGAGEMENT ROSE
  // ==========================================================

  final int? roseRequiredMessages;
  final int? roseMessagesSent;
  final bool roseUnlocked;
  final String? roseExpiresAt;

  // ==========================================================
  // ENGAGEMENT PROGRESS
  // ==========================================================

  final int? progressCurrent;
  final int? progressTarget;
  final int? progressPercentage;
  final String? progressLabel;
  final String? progressType;
  final String? progressExpiresAt;

  // ==========================================================
  // PROPOSAL
  // ==========================================================

  final String? proposalId;

  // ==========================================================
  // DATE INVITE
  // ==========================================================

  final String? inviteTitle;
  final String? inviteVenue;
  final String? inviteStatus;

  // ==========================================================
  // RICH INVITE
  // ==========================================================

  final String? inviteEyebrow;
  final String? inviteImageUrl;
  final String? inviteBadge;
  final String? inviteDateDay;
  final String? inviteDateMonth;
  final String? inviteTimeRange;
  final String? inviteSubline;
  final String? inviteQuote;
  final String? invitePrice;
  final String? inviteSafetyNote;
  final Map<String, String>? inviteStats;
  final String? inviteButtonPrimary;
  final String? inviteButtonPrimarySub;
  final String? inviteButtonSecondary;
  final String? inviteButtonSecondarySub;

  // ==========================================================
  // EVENT INVITE
  // ==========================================================

  final String? eventId;
  final String? eventType;
  final String? eventTitle;
  final String? eventCity;
  final String? eventTag;
  final String? eventDate;
  final String? eventStartTime;
  final String? eventEndTime;
  final String? eventVenueName;
  final String? eventFullAddress;
  final String? eventMenEntryPrice;
  final String? eventWomenEntryPrice;
  final String? eventOtherCapacity;
  final String? eventMenDiscountedPrice;
  final String? eventWomenDiscountedPrice;
  final String? eventOtherDiscountedPrice;
  final String? eventHeroImage;
  final String? dateplanid;
  final List<String>? eventSafetyFeatures;

  // ==========================================================
  // CONTACT / RELATIONSHIP
  // ==========================================================

  final String? contactName;
  final String? contactPhoneNumber;

  final String? relationproposalId;
  final String? relationshipTag;
  final String? relationshipStatus;
  final String? relationshipMessage;
  final String? relationshipSenderId;
  final String? relationshipReceiverId;
  final bool isEventBook;
  bool? isAlreadyRequested;
  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  ChatMessage({
    required this.id,
    this.text = '',
    required this.time,
    required this.isMine,

    this.senderId,
    this.receiverId,
    this.typemsg,
    this.type = ChatMessageType.text,

    this.isPendingUpload = false,

    // Image
    this.imageUrl,
    this.videoUrl,

    // Reply
    this.replyToId,
    this.replyText,
    this.replyImageUrl,
    this.replyFileUrl,
    this.replyType,

    // Audio
    this.audioUrl,

    // File
    this.fileUrl,
    this.fileName,
    this.fileSize,

    // Contact
    this.contactName,
    this.contactPhoneNumber,

    // Relationship
    this.relationproposalId,
    this.relationshipTag,
    this.relationshipStatus,
    this.relationshipMessage,
    this.relationshipSenderId,
    this.relationshipReceiverId,

    // Gift
    this.giftId,
    this.giftName,
    this.giftEmoji,
    this.giftCoins,
    this.giftClaimed = false,

    // Progress
    this.messageProgress,
    this.messageTarget,
    this.expiresIn,

    // General
    this.coinAmount,
    this.seen = false,
    this.delivered = false,
    this.hintLine,

    // Location
    this.locationLabel,
    this.latitude,
    this.longitude,
    this.isNew = false,

    // Compliment
    this.complimentImageUrl,
    this.complimentIcon,
    this.complimentFactTitle,
    this.complimentFactSubtitle,

    // Engagement
    this.roseId,
    this.complimentId,
    this.engagementGiftId,
    this.isBundle = false,

    // Engagement compliment
    this.complimentMessage,
    this.complimentIdeaId,
    this.complimentStatus,

    // Engagement rose
    this.roseRequiredMessages,
    this.roseMessagesSent,
    this.roseUnlocked = false,
    this.roseExpiresAt,

    // Engagement progress
    this.progressCurrent,
    this.progressTarget,
    this.progressPercentage,
    this.progressLabel,
    this.progressType,
    this.progressExpiresAt,

    // Proposal
    this.proposalId,

    // Date invite
    this.inviteTitle,
    this.inviteVenue,
    this.inviteStatus,

    // Rich invite
    this.inviteEyebrow,
    this.inviteImageUrl,
    this.inviteBadge,
    this.inviteDateDay,
    this.inviteDateMonth,
    this.inviteTimeRange,
    this.inviteSubline,
    this.inviteQuote,
    this.invitePrice,
    this.inviteSafetyNote,
    this.inviteStats,
    this.inviteButtonPrimary,
    this.inviteButtonPrimarySub,
    this.inviteButtonSecondary,
    this.inviteButtonSecondarySub,

    // Event invite
    this.eventId,
    this.eventType,
    this.eventTitle,
    this.eventCity,
    this.eventTag,
    this.eventDate,
    this.eventStartTime,
    this.eventEndTime,
    this.eventVenueName,
    this.eventFullAddress,
    this.eventMenEntryPrice,
    this.eventWomenEntryPrice,
    this.eventOtherCapacity,
    this.eventMenDiscountedPrice,
    this.eventWomenDiscountedPrice,
    this.eventOtherDiscountedPrice,
    this.eventHeroImage,
    this.eventSafetyFeatures,
    this.dateplanid,
    this.isEventBook = false,
    this.isAlreadyRequested = false,
  });

  // ==========================================================
  // DIRECTION
  // ==========================================================

  ChatMessageDirection get direction =>
      isMine ? ChatMessageDirection.sender : ChatMessageDirection.receiver;

  // ==========================================================
  // FROM JSON
  // ==========================================================

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    // ========================================================
    // IDS
    // ========================================================

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

    // ========================================================
    // MESSAGE TYPE
    // ========================================================

    final type = _messageType(
      json['type'] ??
          json['messageType'] ??
          json['message_type'] ??
          json['contentType'] ??
          json['content_type'] ??
          json['typemsg'],
    );

    // ========================================================
    // NESTED OBJECTS
    // ========================================================

    final rose = _map(json['rose']);

    final compliment = _map(json['compliment']);

    final gift = _map(json['gift']);
    // ========================================================
    // GIFT
    // ========================================================

    final giftData = json['gift'] is Map
        ? Map<String, dynamic>.from(json['gift'])
        : <String, dynamic>{};

    final giftMaster = giftData['gift'] is Map
        ? Map<String, dynamic>.from(giftData['gift'])
        : <String, dynamic>{};

    final socketGiftMetadata = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'])
        : <String, dynamic>{};

    final giftImageUrl =
        (giftMaster['image'] ??
                giftData['image'] ??
                json['giftImage'] ??
                json['giftImageUrl'] ??
                json['imageUrl'] ??
                socketGiftMetadata['giftImage'] ??
                socketGiftMetadata['giftImageUrl'])
            ?.toString()
            .trim();
    final parsedGiftId = _string(
      json['giftId'] ??
          json['gift_id'] ??
          gift?['giftId'] ??
          gift?['gift_id'] ??
          gift?['id'] ??
          socketGiftMetadata['giftId'] ??
          socketGiftMetadata['gift_id'],
    );

    final parsedGiftName = _string(
      json['giftName'] ??
          json['gift_name'] ??
          gift?['giftName'] ??
          gift?['gift_name'] ??
          gift?['name'] ??
          giftMaster?['name'] ??
          socketGiftMetadata['giftName'] ??
          socketGiftMetadata['gift_name'],
    );

    final parsedGiftEmoji = _string(
      json['giftEmoji'] ??
          json['gift_emoji'] ??
          gift?['giftEmoji'] ??
          gift?['gift_emoji'] ??
          gift?['emoji'] ??
          socketGiftMetadata['giftEmoji'] ??
          socketGiftMetadata['gift_emoji'],
    );

    final parsedGiftCoins = _string(
      json['giftCoins'] ??
          json['gift_coins'] ??
          json['coins'] ??
          gift?['giftCoins'] ??
          gift?['gift_coins'] ??
          gift?['coins'] ??
          gift?['pricePaid'] ??
          giftMaster?['coinCost'] ??
          socketGiftMetadata['giftCoins'] ??
          socketGiftMetadata['gift_coins'],
    );
    final nestedGift = gift is Map && gift!['gift'] is Map
        ? Map<String, dynamic>.from(gift['gift'] as Map)
        : <String, dynamic>{};

    final parsedGiftImageUrl = _string(
      json['mediaUrl'] ??
          json['imageUrl'] ??
          json['giftImageUrl'] ??
          (gift is Map ? gift!['image'] : null) ??
          nestedGift['image'] ??
          giftMaster?['image'] ??
          socketGiftMetadata['giftImage'] ??
          socketGiftMetadata['giftImageUrl'],
    );
    // final parsedGiftImageUrl = _string(
    //   json['giftImage'] ??
    //       json['gift_image'] ??
    //       json['giftImageUrl'] ??
    //       json['gift_image_url'] ??
    //       gift?['image'] ??
    //       gift?['imageUrl'] ??
    //       gift?['image_url'] ??
    //       giftMaster?['image'],
    // );
    final progress = _map(json['progress']);

    // ========================================================
    // METADATA
    // ========================================================

    final metadata = _map(json['metadata']);

    // ========================================================
    // RELATIONSHIP
    // ========================================================

    final relationproposalId = _string(
      metadata?['proposalId'] ?? metadata?['proposal_id'],
    );

    final relationshipTag = _string(metadata?['tag']);

    final relationshipStatus = _string(metadata?['status']);

    final relationshipMessage = _string(metadata?['message']);

    final relationshipSenderId = _string(
      metadata?['senderId'] ?? metadata?['sender_id'],
    );

    final relationshipReceiverId = _string(
      metadata?['receiverId'] ?? metadata?['receiver_id'],
    );

    // ========================================================
    // CONTACT
    // ========================================================

    final contact = _map(metadata?['contact']);

    final contactName = contact?['name']?.toString();

    final contactPhoneNumber = contact?['phoneNumber']?.toString();

    // ========================================================
    // LOCATION
    // ========================================================

    final location = _map(metadata?['location']);

    final latitude = _double(location?['latitude']);

    final longitude = _double(location?['longitude']);

    final parsedLocationLabel = location?['label']?.toString();

    // ========================================================
    // EVENT
    // ========================================================

    final event = _map(json['event']);

    final bool isEventBook =
        _bool(event?['is_event_book'] ?? event?['isEventBook']) ?? false;
    // ========================================================
    // DATE CONFIRMED / DATE PLAN
    // ========================================================

    final datePlan = _map(json['datePlan'] ?? json['date_plan']);

    final bool isAlreadyRequested =
        _bool(
          datePlan?['is_already_requested'] ?? datePlan?['isAlreadyRequested'],
        ) ??
        false;
    final datePlanActivity = _map(datePlan?['activity']);
    final datePlanWhoPays = _map(datePlan?['whoPays'] ?? datePlan?['who_pays']);
    final datePlanJoinGender = _map(
      datePlan?['joinRequestGender'] ?? datePlan?['join_request_gender'],
    );
    final datePlanVisibility = _map(datePlan?['visibility']);

    final datePlanDateTime = _string(
      datePlan?['eventDateTime'] ?? datePlan?['event_date_time'],
    );
    final datePlanDuration = _int(datePlan?['duration']);

    String? datePlanEndTime;
    if (datePlanDateTime != null) {
      final start = DateTime.tryParse(datePlanDateTime);
      if (start != null) {
        datePlanEndTime = start
            .add(Duration(minutes: datePlanDuration ?? 0))
            .toIso8601String();
      }
    }

    // ========================================================
    // BUNDLE
    // ========================================================

    final bool isBundle =
        _bool(
          metadata?['isBundle'] ??
              metadata?['is_bundle'] ??
              json['isBundle'] ??
              json['is_bundle'],
        ) ??
        false;

    // ========================================================
    // ENGAGEMENT IDS
    // ========================================================

    final roseId = _string(json['roseId'] ?? json['rose_id'] ?? rose?['id']);

    final complimentId = _string(
      json['complimentId'] ?? json['compliment_id'] ?? compliment?['id'],
    );

    final engagementGiftId = _string(
      json['giftId'] ??
          json['gift_id'] ??
          gift?['id'] ??
          gift?['giftId'] ??
          gift?['gift_id'],
    );

    // ========================================================
    // COMPLIMENT DETAILS
    // ========================================================

    final complimentMessage = _string(compliment?['message']);

    final complimentIdeaId = _string(
      compliment?['ideaId'] ?? compliment?['idea_id'],
    );

    final complimentStatus = _string(compliment?['status']);

    // ========================================================
    // ROSE DETAILS
    // ========================================================

    final roseRequiredMessages = _int(
      rose?['requiredMessages'] ?? rose?['required_messages'],
    );

    final roseMessagesSent = _int(
      rose?['messagesSent'] ?? rose?['messages_sent'],
    );

    final roseUnlocked =
        _bool(rose?['isUnlocked'] ?? rose?['is_unlocked']) ?? false;

    final roseExpiresAt = _string(rose?['expiresAt'] ?? rose?['expires_at']);

    // ========================================================
    // PROGRESS
    // ========================================================

    final progressCurrent = _int(progress?['current']);

    final progressTarget = _int(progress?['target']);

    final progressPercentage = _int(progress?['percentage']);

    final progressLabel = _string(progress?['label']);

    final progressType = _string(progress?['type']);

    final progressExpiresAt = _string(
      progress?['expiresAt'] ?? progress?['expires_at'],
    );

    // ========================================================
    // TEXT
    // ========================================================

    final text =
        _string(
          json['text'] ??
              json['message'] ??
              json['content'] ??
              (type == ChatMessageType.location ? parsedLocationLabel : null) ??
              complimentMessage,
        ) ??
        '';

    // ========================================================
    // GIFT
    // ========================================================

    // ========================================================
    // MESSAGE PROGRESS
    // ========================================================

    final parsedMessageProgress = _int(
      json['messageProgress'] ?? json['message_progress'] ?? progressCurrent,
    );

    final parsedMessageTarget = _int(
      json['messageTarget'] ?? json['message_target'] ?? progressTarget,
    );

    final parsedExpiresIn = _string(
      json['expiresIn'] ?? json['expires_in'] ?? progressExpiresAt,
    );

    // ========================================================
    // EVENT SAFETY FEATURES
    // ========================================================

    final eventSafetyFeatures = _stringList(event?['safetyFeatures']);
    final dateplanid = _string(datePlan?['id']);

    // ========================================================
    // RETURN MESSAGE
    // ========================================================

    return ChatMessage(
      // ------------------------------------------------------
      // BASIC
      // ------------------------------------------------------
      id:
          _string(json['id'] ?? json['_id'] ?? json['messageId']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),

      text: text,

      time:
          _string(json['time'] ?? json['createdAt'] ?? json['created_at']) ??
          '',

      isMine: isMine,

      senderId: senderId,

      receiverId: receiverId,

      typemsg: _string(
        json['typemsg'] ?? json['messageType'] ?? json['message_type'],
      ),

      type: type,

      // ------------------------------------------------------
      // IMAGE
      // ------------------------------------------------------
      imageUrl:
          type == ChatMessageType.gift || type == ChatMessageType.ENGAGEMENT
          ? parsedGiftImageUrl
          : _string(
              json['imageUrl'] ??
                  json['image_url'] ??
                  json['mediaUrl'] ??
                  json['media_url'] ??
                  json['image'],
            ),

      // ------------------------------------------------------
      // VIDEO
      // ------------------------------------------------------
      videoUrl: _string(
        json['videoUrl'] ??
            json['video_url'] ??
            (type == ChatMessageType.video
                ? (json['mediaUrl'] ?? json['media_url'])
                : null),
      ),

      // ------------------------------------------------------
      // AUDIO
      // ------------------------------------------------------
      audioUrl: _string(
        json['audioUrl'] ??
            json['audio_url'] ??
            (type == ChatMessageType.audio
                ? (json['mediaUrl'] ?? json['media_url'])
                : null),
      ),

      // ------------------------------------------------------
      // FILE
      // ------------------------------------------------------
      fileUrl: _string(
        json['fileUrl'] ??
            json['file_url'] ??
            (type == ChatMessageType.document
                ? (json['mediaUrl'] ?? json['media_url'])
                : null),
      ),

      fileName: _string(json['fileName'] ?? json['file_name']),

      fileSize: _string(json['fileSize'] ?? json['file_size']),

      // ------------------------------------------------------
      // CONTACT
      // ------------------------------------------------------
      contactName: contactName,

      contactPhoneNumber: contactPhoneNumber,

      // ------------------------------------------------------
      // RELATIONSHIP
      // ------------------------------------------------------
      relationproposalId: relationproposalId,

      relationshipTag: relationshipTag,

      relationshipStatus: relationshipStatus,

      relationshipMessage: relationshipMessage,

      relationshipSenderId: relationshipSenderId,

      relationshipReceiverId: relationshipReceiverId,

      // ------------------------------------------------------
      // LOCATION
      // ------------------------------------------------------
      latitude: latitude,

      longitude: longitude,

      locationLabel:
          parsedLocationLabel ??
          _string(json['locationLabel'] ?? json['location_label']),

      // ------------------------------------------------------
      // REPLY
      // ------------------------------------------------------
      replyToId: _string(json['replyToId'] ?? json['reply_to_id']),

      replyText: _string(json['replyText'] ?? json['reply_text']),

      replyImageUrl: _string(json['replyImageUrl'] ?? json['reply_image_url']),

      replyFileUrl: _string(json['replyFileUrl'] ?? json['reply_file_url']),

      replyType: _messageTypeNullable(json['replyType'] ?? json['reply_type']),

      // ------------------------------------------------------
      // GIFT
      // ------------------------------------------------------
      giftId: parsedGiftId,

      giftName: parsedGiftName,

      giftEmoji: parsedGiftEmoji,

      giftCoins: parsedGiftCoins,

      giftClaimed:
          _bool(
            json['giftClaimed'] ??
                json['gift_claimed'] ??
                gift?['giftClaimed'] ??
                gift?['gift_claimed'] ??
                gift?['claimed'],
          ) ??
          false,

      // ------------------------------------------------------
      // PROGRESS
      // ------------------------------------------------------
      messageProgress: parsedMessageProgress,

      messageTarget: parsedMessageTarget,

      expiresIn: parsedExpiresIn,

      // ------------------------------------------------------
      // GENERAL
      // ------------------------------------------------------
      coinAmount: _string(
        json['coinAmount'] ?? json['coin_amount'] ?? json['coins'],
      ),

      seen:
          _bool(
            json['seen'] ??
                json['isRead'] ??
                json['is_read'] ??
                json['readAt'] != null, // 👈 yahi logic
          ) ??
          false,

      delivered:
          _bool(
            json['delivered'] ??
                json['isDelivered'] ??
                json['is_delivered'] ??
                json['deliveredAt'] != null,
          ) ??
          false,

      hintLine: _string(json['hintLine'] ?? json['hint_line']),

      isNew: _bool(json['isNew'] ?? json['is_new']) ?? false,

      // ------------------------------------------------------
      // COMPLIMENT
      // ------------------------------------------------------
      complimentImageUrl: _string(
        json['complimentImageUrl'] ?? json['compliment_image_url'],
      ),

      complimentIcon: _string(
        json['complimentIcon'] ?? json['compliment_icon'],
      ),

      complimentFactTitle: _string(
        json['complimentFactTitle'] ?? json['compliment_fact_title'],
      ),

      complimentFactSubtitle: _string(
        json['complimentFactSubtitle'] ?? json['compliment_fact_subtitle'],
      ),

      // ------------------------------------------------------
      // ENGAGEMENT
      // ------------------------------------------------------
      roseId: roseId,

      complimentId: complimentId,

      engagementGiftId: engagementGiftId,

      isBundle: isBundle,

      // ------------------------------------------------------
      // ENGAGEMENT COMPLIMENT
      // ------------------------------------------------------
      complimentMessage: complimentMessage,

      complimentIdeaId: complimentIdeaId,

      complimentStatus: complimentStatus,

      // ------------------------------------------------------
      // ENGAGEMENT ROSE
      // ------------------------------------------------------
      roseRequiredMessages: roseRequiredMessages,

      roseMessagesSent: roseMessagesSent,

      roseUnlocked: roseUnlocked,

      roseExpiresAt: roseExpiresAt,

      // ------------------------------------------------------
      // ENGAGEMENT PROGRESS
      // ------------------------------------------------------
      progressCurrent: progressCurrent,

      progressTarget: progressTarget,

      progressPercentage: progressPercentage,

      progressLabel: progressLabel,

      progressType: progressType,

      progressExpiresAt: progressExpiresAt,

      // ------------------------------------------------------
      // PROPOSAL
      // ------------------------------------------------------
      proposalId: _string(
        json['proposalId'] ??
            json['proposal_id'] ??
            (json['proposal'] is Map ? json['proposal']['id'] : null),
      ),

      // ------------------------------------------------------
      // DATE INVITE
      // ------------------------------------------------------
      inviteTitle: _string(
        json['inviteTitle'] ?? json['invite_title'] ?? datePlan?['title'],
      ),

      inviteVenue: _string(
        json['inviteVenue'] ??
            json['invite_venue'] ??
            datePlan?['venueName'] ??
            datePlan?['venue_name'],
      ),

      inviteStatus: _string(
        json['inviteStatus'] ??
            json['invite_status'] ??
            metadata?['status'] ??
            datePlan?['status'],
      ),

      // ------------------------------------------------------
      // RICH INVITE
      // ------------------------------------------------------
      // DATE_CONFIRMED API -> existing rich-card fields.
      // Keep the card UI/design unchanged; only populate its existing model fields.
      inviteEyebrow: _string(
        json['inviteEyebrow'] ??
            json['invite_eyebrow'] ??
            (type == ChatMessageType.DATECONFIRMED ? 'EVENT INVITE' : null),
      ),

      inviteImageUrl: _string(
        json['inviteImageUrl'] ??
            json['invite_image_url'] ??
            datePlan?['photoUrl'] ??
            datePlan?['photo_url'] ??
            datePlanActivity?['icon'],
      ),

      inviteBadge: _string(
        json['inviteBadge'] ??
            json['invite_badge'] ??
            (type == ChatMessageType.DATECONFIRMED ? 'AWAITING RSVP' : null),
      ),

      inviteDateDay: _string(
        json['inviteDateDay'] ??
            json['invite_date_day'] ??
            (datePlanDateTime != null
                ? DateTime.tryParse(datePlanDateTime)?.day.toString()
                : null),
      ),

      inviteDateMonth: _string(
        json['inviteDateMonth'] ??
            json['invite_date_month'] ??
            (datePlanDateTime != null
                ? _inviteDateMonth(datePlanDateTime)
                : null),
      ),

      inviteTimeRange: _string(
        json['inviteTimeRange'] ??
            json['invite_time_range'] ??
            (datePlanDateTime != null
                ? _formatInviteTimeRange(datePlanDateTime, datePlanEndTime)
                : null),
      ),

      inviteSubline: _string(json['inviteSubline'] ?? json['invite_subline']),

      inviteQuote: _string(json['inviteQuote'] ?? json['invite_quote']),

      invitePrice: _string(json['invitePrice'] ?? json['invite_price']),

      inviteSafetyNote: _string(
        json['inviteSafetyNote'] ??
            json['invite_safety_note'] ??
            (datePlan?['venueAddress'] != null
                ? '${datePlan!['venueAddress']}'
                : null) ??
            'Date confirmed',
      ),

      inviteStats: _stringMap(
        json['inviteStats'] ??
            json['invite_stats'] ??
            (datePlan != null
                ? <String, String>{
                    if (_string(datePlanActivity?['label']) != null)
                      'Activity': _string(datePlanActivity?['label'])!,
                    if (datePlanDuration != null)
                      'Duration': '$datePlanDuration min',
                    if (_string(datePlanWhoPays?['label']) != null)
                      'Who pays': _string(datePlanWhoPays?['label'])!,
                    if (_string(datePlanJoinGender?['label']) != null)
                      'Joining': _string(datePlanJoinGender?['label'])!,
                    if (_string(datePlanVisibility?['label']) != null)
                      'Visibility': _string(datePlanVisibility?['label'])!,
                  }
                : null),
      ),

      inviteButtonPrimary: _string(
        json['inviteButtonPrimary'] ?? json['invite_button_primary'],
      ),

      inviteButtonPrimarySub: _string(
        json['inviteButtonPrimarySub'] ?? json['invite_button_primary_sub'],
      ),

      inviteButtonSecondary: _string(
        json['inviteButtonSecondary'] ?? json['invite_button_secondary'],
      ),

      inviteButtonSecondarySub: _string(
        json['inviteButtonSecondarySub'] ?? json['invite_button_secondary_sub'],
      ),

      // ------------------------------------------------------
      // EVENT INVITE
      // ------------------------------------------------------
      eventId: _string(event?['id']),

      eventType: _string(
        event?['eventType'] ??
            datePlanActivity?['label'] ??
            datePlanActivity?['value'],
      ),

      eventTitle: _string(
        event?['title'] ?? event?['eventTitle'] ?? datePlan?['title'],
      ),

      eventCity: _string(event?['city']),

      eventTag: _string(event?['eventTag']),

      eventDate: _string(event?['eventDate'] ?? datePlanDateTime),

      eventStartTime: _string(event?['startTime'] ?? datePlanDateTime),

      eventEndTime: _string(event?['endTime'] ?? datePlanEndTime),

      eventVenueName: _string(
        event?['venueName'] ??
            datePlan?['venueName'] ??
            datePlan?['venue_name'],
      ),

      eventFullAddress: _string(
        event?['fullAddress'] ??
            datePlan?['venueAddress'] ??
            datePlan?['venue_address'],
      ),

      eventMenEntryPrice: _string(event?['menEntryPrice']),

      eventWomenEntryPrice: _string(event?['womenEntryPrice']),

      eventOtherCapacity: _string(event?['otherCapacity']),

      eventMenDiscountedPrice: _string(event?['menDiscountedPrice']),

      eventWomenDiscountedPrice: _string(event?['womenDiscountedPrice']),

      eventOtherDiscountedPrice: _string(event?['otherDiscountedPrice']),

      eventHeroImage: _string(
        event?['heroImage'] ??
            datePlan?['photoUrl'] ??
            datePlan?['photo_url'] ??
            datePlanActivity?['icon'],
      ),

      eventSafetyFeatures: eventSafetyFeatures,
      dateplanid: dateplanid,
      isEventBook: isEventBook,
      isAlreadyRequested: isAlreadyRequested,
    );
  }

  static String? _inviteDateMonth(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return null;

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[date.month - 1];
  }

  static String? _formatInviteTimeRange(String startValue, String? endValue) {
    final start = DateTime.tryParse(startValue);
    if (start == null) return null;

    String format(DateTime value) {
      final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
      final minute = value.minute.toString().padLeft(2, '0');
      final period = value.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }

    final end = endValue == null ? null : DateTime.tryParse(endValue);
    return end == null ? format(start) : '${format(start)} - ${format(end)}';
  }

  // ==========================================================
  // MAP HELPER
  // ==========================================================

  static Map<String, dynamic>? _map(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  // ==========================================================
  // DOUBLE
  // ==========================================================

  static double? _double(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  // ==========================================================
  // STRING MAP
  // ==========================================================

  static Map<String, String>? _stringMap(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return null;
  }

  // ==========================================================
  // STRING LIST
  // ==========================================================

  static List<String>? _stringList(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => _string(item['title']))
          .whereType<String>()
          .toList();
    }

    return null;
  }

  // ==========================================================
  // MESSAGE TYPE
  // ==========================================================

  static ChatMessageType _messageType(dynamic value) {
    return _messageTypeNullable(value) ?? ChatMessageType.text;
  }

  static ChatMessageType? _messageTypeNullable(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is ChatMessageType) {
      return value;
    }

    final raw = value
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '');

    const aliases = <String, ChatMessageType>{
      // Text
      'text': ChatMessageType.text,
      'message': ChatMessageType.text,

      // Image
      'image': ChatMessageType.image,
      'photo': ChatMessageType.image,

      // Video
      'video': ChatMessageType.video,

      // Audio
      'audio': ChatMessageType.audio,
      'voice': ChatMessageType.audio,

      // Document
      'document': ChatMessageType.document,
      'file': ChatMessageType.document,

      // Location
      'location': ChatMessageType.location,

      // Contact
      'contact': ChatMessageType.contact,

      // Proposal
      'proposal': ChatMessageType.RELATIONSHIP_TAG_PROPOSAL,
      'relationshiptagproposal': ChatMessageType.RELATIONSHIP_TAG_PROPOSAL,
      'relationshipproposal': ChatMessageType.RELATIONSHIP_TAG_PROPOSAL,
      'relationshiptagaccepted': ChatMessageType.RELATIONSHIP_TAG_ACCEPTED,

      // Gift
      'gift': ChatMessageType.gift,
      'giftmessage': ChatMessageType.gift,
      'giftcard': ChatMessageType.gift,

      // Rose
      'rose': ChatMessageType.rose,

      // Compliment
      'compliment': ChatMessageType.compliment,
      'complimentmessage': ChatMessageType.compliment,

      // Engagement
      'engagement': ChatMessageType.ENGAGEMENT,

      // Date
      'dateinvite': ChatMessageType.dateInvite,
      'date': ChatMessageType.dateInvite,
      'dateconfirmed': ChatMessageType.DATECONFIRMED,
      // Event
      'eventinvite': ChatMessageType.eventInvite,
      'event': ChatMessageType.eventInvite,
    };

    return aliases[raw];
  }

  // ==========================================================
  // BOOL
  // ==========================================================

  static bool? _bool(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final raw = value.toString().trim().toLowerCase();

    if (raw == 'true' || raw == '1' || raw == 'yes') {
      return true;
    }

    if (raw == 'false' || raw == '0' || raw == 'no') {
      return false;
    }

    return null;
  }

  // ==========================================================
  // INT
  // ==========================================================

  static int? _int(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  // ==========================================================
  // STRING
  // ==========================================================

  static String? _string(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  // ==========================================================
  // FROM JSON LIST
  // ==========================================================

  static List<ChatMessage> fromJsonList(
    dynamic data, {
    required String currentUserId,
  }) {
    if (data is! List) {
      return const [];
    }

    final messages = <ChatMessage>[];

    for (final item in data) {
      if (item is! Map) {
        continue;
      }

      try {
        messages.add(
          ChatMessage.fromJson(
            Map<String, dynamic>.from(item),
            currentUserId: currentUserId,
          ),
        );
      } catch (_) {
        // Ignore malformed individual message.
      }
    }

    // Newest first.
    messages.sort((a, b) => ChatMessage.compareByTime(b, a));

    return messages;
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  ChatMessage copyWith({
    String? id,
    String? text,
    String? time,
    String? textmsg,
    bool? isMine,
    String? senderId,
    String? receiverId,
    ChatMessageType? type,

    bool? isPendingUpload,

    // Image / Video
    String? imageUrl,
    String? videoUrl,

    // Reply
    String? replyToId,
    String? replyText,
    String? replyImageUrl,
    String? replyFileUrl,
    ChatMessageType? replyType,

    // Audio
    String? audioUrl,

    // File
    String? fileUrl,
    String? fileName,
    String? fileSize,

    // Contact
    String? contactName,
    String? contactPhoneNumber,

    // ========================================================
    // RELATIONSHIP
    // ========================================================
    String? relationproposalId,
    String? relationshipTag,
    String? relationshipStatus,
    String? relationshipMessage,
    String? relationshipSenderId,
    String? relationshipReceiverId,

    // Gift
    String? giftId,
    String? giftName,
    String? giftEmoji,
    String? giftCoins,
    bool? giftClaimed,

    // Progress
    int? messageProgress,
    int? messageTarget,
    String? expiresIn,

    // General
    String? coinAmount,
    bool? seen,
    bool? delivered,
    String? hintLine,

    // Location
    String? locationLabel,
    double? latitude,
    double? longitude,
    bool? isNew,

    // Compliment
    String? complimentImageUrl,
    String? complimentIcon,
    String? complimentFactTitle,
    String? complimentFactSubtitle,

    // Engagement
    String? roseId,
    String? complimentId,
    String? engagementGiftId,
    bool? isBundle,

    String? complimentMessage,
    String? complimentIdeaId,
    String? complimentStatus,

    int? roseRequiredMessages,
    int? roseMessagesSent,
    bool? roseUnlocked,
    String? roseExpiresAt,

    int? progressCurrent,
    int? progressTarget,
    int? progressPercentage,
    String? progressLabel,
    String? progressType,
    String? progressExpiresAt,

    // Proposal
    String? proposalId,

    // Date Invite
    String? inviteTitle,
    String? inviteVenue,
    String? inviteStatus,

    // Rich Date Invite
    String? inviteEyebrow,
    String? inviteImageUrl,
    String? inviteBadge,
    String? inviteDateDay,
    String? inviteDateMonth,
    String? inviteTimeRange,
    String? inviteSubline,
    String? inviteQuote,
    String? invitePrice,
    String? inviteSafetyNote,
    Map<String, String>? inviteStats,
    String? inviteButtonPrimary,
    String? inviteButtonPrimarySub,
    String? inviteButtonSecondary,
    String? inviteButtonSecondarySub,

    // Event
    String? eventId,
    String? eventType,
    String? eventTitle,
    String? eventCity,
    String? eventTag,
    String? eventDate,
    String? eventStartTime,
    String? eventEndTime,
    String? eventVenueName,
    String? eventFullAddress,
    String? eventMenEntryPrice,
    String? eventWomenEntryPrice,
    String? eventOtherCapacity,
    String? eventMenDiscountedPrice,
    String? eventWomenDiscountedPrice,
    String? eventOtherDiscountedPrice,
    String? eventHeroImage,
    String? dateplanid,
    List<String>? eventSafetyFeatures, // NEW
    bool? isEventBook,
    bool? isAlreadyRequested,
  }) {
    return ChatMessage(
      // ========================================================
      // BASIC
      // ========================================================
      id: id ?? this.id,

      text: text ?? this.text,

      time: time ?? this.time,

      isMine: isMine ?? this.isMine,

      senderId: senderId ?? this.senderId,

      receiverId: receiverId ?? this.receiverId,

      typemsg: textmsg ?? this.typemsg,

      type: type ?? this.type,

      isPendingUpload: isPendingUpload ?? this.isPendingUpload,

      // ========================================================
      // IMAGE
      // ========================================================
      imageUrl: imageUrl ?? this.imageUrl,

      videoUrl: videoUrl ?? this.videoUrl,

      // ========================================================
      // REPLY
      // ========================================================
      replyToId: replyToId ?? this.replyToId,

      replyText: replyText ?? this.replyText,

      replyImageUrl: replyImageUrl ?? this.replyImageUrl,

      replyFileUrl: replyFileUrl ?? this.replyFileUrl,

      replyType: replyType ?? this.replyType,

      // ========================================================
      // AUDIO
      // ========================================================
      audioUrl: audioUrl ?? this.audioUrl,

      // ========================================================
      // FILE
      // ========================================================
      fileUrl: fileUrl ?? this.fileUrl,

      fileName: fileName ?? this.fileName,

      fileSize: fileSize ?? this.fileSize,

      // ========================================================
      // CONTACT
      // ========================================================
      contactName: contactName ?? this.contactName,

      contactPhoneNumber: contactPhoneNumber ?? this.contactPhoneNumber,

      // ========================================================
      // RELATIONSHIP
      // ========================================================
      relationproposalId: relationproposalId ?? this.relationproposalId,

      relationshipTag: relationshipTag ?? this.relationshipTag,

      relationshipStatus: relationshipStatus ?? this.relationshipStatus,

      relationshipMessage: relationshipMessage ?? this.relationshipMessage,

      relationshipSenderId: relationshipSenderId ?? this.relationshipSenderId,

      relationshipReceiverId:
          relationshipReceiverId ?? this.relationshipReceiverId,

      // ========================================================
      // GIFT
      // ========================================================
      giftId: giftId ?? this.giftId,

      giftName: giftName ?? this.giftName,

      giftEmoji: giftEmoji ?? this.giftEmoji,

      giftCoins: giftCoins ?? this.giftCoins,

      giftClaimed: giftClaimed ?? this.giftClaimed,

      // ========================================================
      // PROGRESS
      // ========================================================
      messageProgress: messageProgress ?? this.messageProgress,

      messageTarget: messageTarget ?? this.messageTarget,

      expiresIn: expiresIn ?? this.expiresIn,

      // ========================================================
      // GENERAL
      // ========================================================
      coinAmount: coinAmount ?? this.coinAmount,

      seen: seen ?? this.seen,

      delivered: delivered ?? this.delivered,

      hintLine: hintLine ?? this.hintLine,

      // ========================================================
      // LOCATION
      // ========================================================
      locationLabel: locationLabel ?? this.locationLabel,

      latitude: latitude ?? this.latitude,

      longitude: longitude ?? this.longitude,

      isNew: isNew ?? this.isNew,

      // ========================================================
      // COMPLIMENT
      // ========================================================
      complimentImageUrl: complimentImageUrl ?? this.complimentImageUrl,

      complimentIcon: complimentIcon ?? this.complimentIcon,

      complimentFactTitle: complimentFactTitle ?? this.complimentFactTitle,

      complimentFactSubtitle:
          complimentFactSubtitle ?? this.complimentFactSubtitle,

      // ========================================================
      // ENGAGEMENT
      // ========================================================
      roseId: roseId ?? this.roseId,

      complimentId: complimentId ?? this.complimentId,

      engagementGiftId: engagementGiftId ?? this.engagementGiftId,

      isBundle: isBundle ?? this.isBundle,

      // ========================================================
      // ENGAGEMENT COMPLIMENT
      // ========================================================
      complimentMessage: complimentMessage ?? this.complimentMessage,

      complimentIdeaId: complimentIdeaId ?? this.complimentIdeaId,

      complimentStatus: complimentStatus ?? this.complimentStatus,

      // ========================================================
      // ENGAGEMENT ROSE
      // ========================================================
      roseRequiredMessages: roseRequiredMessages ?? this.roseRequiredMessages,

      roseMessagesSent: roseMessagesSent ?? this.roseMessagesSent,

      roseUnlocked: roseUnlocked ?? this.roseUnlocked,

      roseExpiresAt: roseExpiresAt ?? this.roseExpiresAt,

      // ========================================================
      // ENGAGEMENT PROGRESS
      // ========================================================
      progressCurrent: progressCurrent ?? this.progressCurrent,

      progressTarget: progressTarget ?? this.progressTarget,

      progressPercentage: progressPercentage ?? this.progressPercentage,

      progressLabel: progressLabel ?? this.progressLabel,

      progressType: progressType ?? this.progressType,

      progressExpiresAt: progressExpiresAt ?? this.progressExpiresAt,

      // ========================================================
      // PROPOSAL
      // ========================================================
      proposalId: proposalId ?? this.proposalId,

      // ========================================================
      // DATE INVITE
      // ========================================================
      inviteTitle: inviteTitle ?? this.inviteTitle,

      inviteVenue: inviteVenue ?? this.inviteVenue,

      inviteStatus: inviteStatus ?? this.inviteStatus,

      // ========================================================
      // RICH INVITE
      // ========================================================
      inviteEyebrow: inviteEyebrow ?? this.inviteEyebrow,

      inviteImageUrl: inviteImageUrl ?? this.inviteImageUrl,

      inviteBadge: inviteBadge ?? this.inviteBadge,

      inviteDateDay: inviteDateDay ?? this.inviteDateDay,

      inviteDateMonth: inviteDateMonth ?? this.inviteDateMonth,

      inviteTimeRange: inviteTimeRange ?? this.inviteTimeRange,

      inviteSubline: inviteSubline ?? this.inviteSubline,

      inviteQuote: inviteQuote ?? this.inviteQuote,

      invitePrice: invitePrice ?? this.invitePrice,

      inviteSafetyNote: inviteSafetyNote ?? this.inviteSafetyNote,

      inviteStats: inviteStats ?? this.inviteStats,

      inviteButtonPrimary: inviteButtonPrimary ?? this.inviteButtonPrimary,

      inviteButtonPrimarySub:
          inviteButtonPrimarySub ?? this.inviteButtonPrimarySub,

      inviteButtonSecondary:
          inviteButtonSecondary ?? this.inviteButtonSecondary,

      inviteButtonSecondarySub:
          inviteButtonSecondarySub ?? this.inviteButtonSecondarySub,

      // ========================================================
      // EVENT
      // ========================================================
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,

      eventTitle: eventTitle ?? this.eventTitle,

      eventCity: eventCity ?? this.eventCity,

      eventTag: eventTag ?? this.eventTag,

      eventDate: eventDate ?? this.eventDate,

      eventStartTime: eventStartTime ?? this.eventStartTime,

      eventEndTime: eventEndTime ?? this.eventEndTime,

      eventVenueName: eventVenueName ?? this.eventVenueName,

      eventFullAddress: eventFullAddress ?? this.eventFullAddress,

      eventMenEntryPrice: eventMenEntryPrice ?? this.eventMenEntryPrice,

      eventWomenEntryPrice: eventWomenEntryPrice ?? this.eventWomenEntryPrice,

      eventOtherCapacity: eventOtherCapacity ?? this.eventOtherCapacity,

      eventMenDiscountedPrice:
          eventMenDiscountedPrice ?? this.eventMenDiscountedPrice,

      eventWomenDiscountedPrice:
          eventWomenDiscountedPrice ?? this.eventWomenDiscountedPrice,

      eventOtherDiscountedPrice:
          eventOtherDiscountedPrice ?? this.eventOtherDiscountedPrice,

      eventHeroImage: eventHeroImage ?? this.eventHeroImage,

      eventSafetyFeatures: eventSafetyFeatures ?? this.eventSafetyFeatures,
      dateplanid: dateplanid ?? this.dateplanid,
    );
  }

  // ==========================================================
  // COMPARE TIME
  // ==========================================================

  static int compareByTime(ChatMessage a, ChatMessage b) {
    final ad = DateTime.tryParse(a.time);

    final bd = DateTime.tryParse(b.time);

    if (ad != null && bd != null) {
      return ad.compareTo(bd);
    }

    return 0;
  }

  // ==========================================================
  // EQUATABLE
  // ==========================================================

  @override
  List<Object?> get props => [
    id,
    text,
    time,
    isMine,
    senderId,
    receiverId,
    typemsg,
    type,
    isPendingUpload,

    // Image
    imageUrl,
    videoUrl,

    // Reply
    replyToId,
    replyText,
    replyImageUrl,
    replyFileUrl,
    replyType,

    // Audio
    audioUrl,

    // File
    fileUrl,
    fileName,
    fileSize,

    // Contact
    contactName,
    contactPhoneNumber,

    // ========================================================
    // RELATIONSHIP
    // ========================================================
    relationproposalId,
    relationshipTag,
    relationshipStatus,
    relationshipMessage,
    relationshipSenderId,
    relationshipReceiverId,

    // Gift
    giftId,
    giftName,
    giftEmoji,
    giftCoins,
    giftClaimed,

    // Progress
    messageProgress,
    messageTarget,
    expiresIn,

    // General
    coinAmount,
    seen,
    delivered,
    hintLine,

    // Location
    locationLabel,
    latitude,
    longitude,
    isNew,

    // Compliment
    complimentImageUrl,
    complimentIcon,
    complimentFactTitle,
    complimentFactSubtitle,

    // Engagement
    roseId,
    complimentId,
    engagementGiftId,
    isBundle,

    complimentMessage,
    complimentIdeaId,
    complimentStatus,

    roseRequiredMessages,
    roseMessagesSent,
    roseUnlocked,
    roseExpiresAt,

    progressCurrent,
    progressTarget,
    progressPercentage,
    progressLabel,
    progressType,
    progressExpiresAt,

    // Proposal
    proposalId,

    // Date
    inviteTitle,
    inviteVenue,
    inviteStatus,

    // Rich Invite
    inviteEyebrow,
    inviteImageUrl,
    inviteBadge,
    inviteDateDay,
    inviteDateMonth,
    inviteTimeRange,
    inviteSubline,
    inviteQuote,
    invitePrice,
    inviteSafetyNote,
    inviteStats,
    inviteButtonPrimary,
    inviteButtonPrimarySub,
    inviteButtonSecondary,
    inviteButtonSecondarySub,

    // Event
    eventId,
    eventType,
    eventTitle,
    eventCity,
    eventTag,
    eventDate,
    eventStartTime,
    eventEndTime,
    eventVenueName,
    eventFullAddress,
    eventMenEntryPrice,
    eventWomenEntryPrice,
    eventOtherCapacity,
    eventMenDiscountedPrice,
    eventWomenDiscountedPrice,
    eventOtherDiscountedPrice,
    eventHeroImage,
    eventSafetyFeatures, dateplanid,
  ];
}

// ============================================================================
// CHAT USER
// ============================================================================

class ChatUser extends Equatable {
  final String id;
  final String? conversationId;

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

  // ==========================================================
  // PROGRESS
  // ==========================================================

  final String progress;
  final String reward;
  final int progressCurrent;
  final int progressTarget;
  final double progressPercentage;
  final String progressLabel;
  final String progressType;
  final String giftName;
  final DateTime? progressExpiresAt;

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

    // Progress
    required this.progress,
    required this.reward,
    required this.progressCurrent,
    required this.progressTarget,
    required this.progressPercentage,
    required this.progressLabel,
    required this.progressType,
    required this.giftName,
    required this.progressExpiresAt,
  });

  // ==========================================================
  // FROM CONVERSATION JSON
  // ==========================================================

  factory ChatUser.fromConversationJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};

    final lastMessage = json['lastMessage'] is Map
        ? Map<String, dynamic>.from(json['lastMessage'] as Map)
        : const <String, dynamic>{};

    // ==========================================================
    // BASIC DATA
    // ==========================================================

    final id = (json['id'] ?? '').toString();

    final conversationId = (json['conversationId'] ?? '').toString();

    final profileId = (user['id'] ?? '').toString();

    final fullName = (user['fullName'] ?? 'Unknown').toString();

    final matchPercentage = (user['matchPercentage'] ?? 'Unknown').toString();

    final trustPercentage = (user['trustPercentage'] ?? 'Unknown').toString();

    final isOnline = user['isOnline'] == true;

    // ==========================================================
    // AGE
    // ==========================================================

    final ageValue = user['age'];

    final age = ageValue is num
        ? ageValue.toInt()
        : int.tryParse(ageValue?.toString() ?? '') ?? 0;

    // ==========================================================
    // LAST MESSAGE
    // ==========================================================

    final content = (lastMessage['content'] ?? '').toString();

    final rawType =
        (lastMessage['type'] ??
                lastMessage['messageType'] ??
                lastMessage['typemsg'] ??
                '')
            .toString()
            .trim()
            .toUpperCase();

    final mediaLabel = _mediaPreviewLabel(rawType);

    final createdAt = (lastMessage['createdAt'] ?? json['updatedAt'] ?? '')
        .toString();

    // ==========================================================
    // PROGRESS
    // ==========================================================

    final progressData = json['progress'] is Map
        ? Map<String, dynamic>.from(json['progress'] as Map)
        : null;

    int progressCurrent = 0;
    int progressTarget = 0;
    double progressPercentage = 0.0;
    String progressLabel = '';
    String progressType = '';
    String giftName = '';
    DateTime? progressExpiresAt;

    if (progressData != null) {
      progressCurrent = toInt(progressData['current']);

      progressTarget = toInt(progressData['target']);

      final percentageValue = progressData['percentage'];

      if (percentageValue is num) {
        progressPercentage = percentageValue.toDouble();
      } else {
        progressPercentage =
            double.tryParse(percentageValue?.toString() ?? '') ?? 0.0;
      }

      progressPercentage = progressPercentage.clamp(0.0, 100.0);

      progressLabel = (progressData['label'] ?? '').toString();

      progressType = (progressData['type'] ?? '').toString();

      giftName = (progressData['giftName'] ?? '').toString();

      final expiresAtValue = progressData['expiresAt'];

      if (expiresAtValue != null && expiresAtValue.toString().isNotEmpty) {
        progressExpiresAt = DateTime.tryParse(expiresAtValue.toString());
      }
    }

    final progressString = '${progressPercentage.toStringAsFixed(0)}%';

    final rewardString = giftName.isNotEmpty ? giftName : progressLabel;

    return ChatUser(
      id: id,

      conversationId: conversationId,

      userId: profileId,

      name: fullName,

      age: age,

      image: (user['profilePhoto'] ?? '').toString(),

      preview: content.isNotEmpty ? content : (mediaLabel ?? 'No messages yet'),

      time: formatConversationTime(createdAt),

      match: matchPercentage,

      trust: trustPercentage,

      online: isOnline,

      unread: toInt(json['unreadCount']),

      progress: progressString,

      reward: rewardString,

      progressCurrent: progressCurrent,

      progressTarget: progressTarget,

      progressPercentage: progressPercentage,

      progressLabel: progressLabel,

      progressType: progressType,

      giftName: giftName,

      progressExpiresAt: progressExpiresAt,
    );
  }

  // ==========================================================
  // MEDIA PREVIEW
  // ==========================================================

  static String? _mediaPreviewLabel(String type) {
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

      case 'LOCATION':
        return '📍 Location';

      case 'CONTACT':
        return 'Contact';

      default:
        return null;
    }
  }

  // ==========================================================
  // INT
  // ==========================================================

  static int toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ==========================================================
  // DOUBLE
  // ==========================================================

  static double toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  // ==========================================================
  // TIME
  // ==========================================================

  static String formatConversationTime(String value) {
    if (value.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(value)?.toLocal();

    if (date == null) {
      return value;
    }

    final now = DateTime.now();

    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  ChatUser copyWith({
    String? conversationId,
    String? preview,
    String? time,
    int? unread,
    bool? online,

    String? progress,
    String? reward,
    int? progressCurrent,
    int? progressTarget,
    double? progressPercentage,
    String? progressLabel,
    String? progressType,
    String? giftName,
    DateTime? progressExpiresAt,
  }) {
    return ChatUser(
      id: id,

      conversationId: conversationId ?? this.conversationId,

      userId: userId,

      name: name,

      age: age,

      image: image,

      preview: preview ?? this.preview,

      time: time ?? this.time,

      match: match,

      trust: trust,

      online: online ?? this.online,

      unread: unread ?? this.unread,

      progress: progress ?? this.progress,

      reward: reward ?? this.reward,

      progressCurrent: progressCurrent ?? this.progressCurrent,

      progressTarget: progressTarget ?? this.progressTarget,

      progressPercentage: progressPercentage ?? this.progressPercentage,

      progressLabel: progressLabel ?? this.progressLabel,

      progressType: progressType ?? this.progressType,

      giftName: giftName ?? this.giftName,

      progressExpiresAt: progressExpiresAt ?? this.progressExpiresAt,
    );
  }

  // ==========================================================
  // EQUATABLE
  // ==========================================================

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
    progressCurrent,
    progressTarget,
    progressPercentage,
    progressLabel,
    progressType,
    giftName,
    progressExpiresAt,
  ];
}

// ============================================================================
// CONVERSATION PROFILE DETAILS
// ============================================================================

class ConversationProfileDetails extends Equatable {
  final String conversationId;
  final String userId;
  final String name;
  final int age;
  final String packageType;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final bool isBlocked;
  final num matchScore;
  final String profileImage;

  const ConversationProfileDetails({
    required this.conversationId,
    required this.userId,
    required this.name,
    required this.age,
    required this.packageType,
    required this.isOnline,
    required this.lastSeenAt,
    required this.isBlocked,
    required this.matchScore,
    required this.profileImage,
  });

  factory ConversationProfileDetails.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;

    if (root['data'] is Map) {
      root = Map<String, dynamic>.from(root['data'] as Map);
    }

    final user = root['user'] is Map
        ? Map<String, dynamic>.from(root['user'] as Map)
        : <String, dynamic>{};

    final conversationId = (root['conversationId'] ?? '').toString();

    final ageValue = user['age'];

    final age = ageValue is num
        ? ageValue.toInt()
        : int.tryParse(ageValue?.toString() ?? '') ?? 0;

    final matchScoreValue = user['matchScore'];

    final matchScore = matchScoreValue is num
        ? matchScoreValue
        : num.tryParse(matchScoreValue?.toString() ?? '') ?? 0;

    final lastSeenRaw = user['lastSeenAt'];

    final lastSeenAt = lastSeenRaw == null
        ? null
        : DateTime.tryParse(lastSeenRaw.toString());

    return ConversationProfileDetails(
      conversationId: conversationId,

      userId: (user['userId'] ?? user['id'] ?? '').toString(),

      name: (user['name'] ?? user['fullName'] ?? '').toString(),

      age: age,

      packageType: (user['packageType'] ?? 'FREE').toString(),

      isOnline: user['isOnline'] == true,

      lastSeenAt: lastSeenAt,

      isBlocked: user['isBlocked'] == true,

      matchScore: matchScore,

      profileImage: (user['profileImage'] ?? '').toString(),
    );
  }

  ConversationProfileDetails copyWith({
    String? conversationId,
    String? userId,
    String? name,
    int? age,
    String? packageType,
    bool? isOnline,
    DateTime? lastSeenAt,
    bool? isBlocked,
    num? matchScore,
    String? profileImage,
  }) {
    return ConversationProfileDetails(
      conversationId: conversationId ?? this.conversationId,

      userId: userId ?? this.userId,

      name: name ?? this.name,

      age: age ?? this.age,

      packageType: packageType ?? this.packageType,

      isOnline: isOnline ?? this.isOnline,

      lastSeenAt: lastSeenAt ?? this.lastSeenAt,

      isBlocked: isBlocked ?? this.isBlocked,

      matchScore: matchScore ?? this.matchScore,

      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  List<Object?> get props => [
    conversationId,
    userId,
    name,
    age,
    packageType,
    isOnline,
    lastSeenAt,
    isBlocked,
    matchScore,
    profileImage,
  ];
}

// ============================================================================
// CHAT STATE
// ============================================================================

class ChatState extends Equatable {
  final bool loading;

  final List<ChatUser> allChats;

  final List<ChatUser> filteredChats;

  final String search;

  final String filter;

  final Map<String, List<ChatMessage>> messages;

  final Map<String, String?> messageNextCursor;

  final Map<String, bool> messageHasMore;

  final String? chatAction;

  final String? chatActionError;

  // ==========================================================
  // RELATIONSHIP TAG
  // ==========================================================

  final bool relationshipTagLoading;

  final String? relationshipTagAction;

  final String? relationshipTagActionProposalId;

  final String? relationshipTagError;

  const ChatState({
    this.loading = false,
    this.allChats = const [],
    this.filteredChats = const [],
    this.search = '',
    this.filter = 'All',
    this.messages = const {},
    this.messageNextCursor = const {},
    this.messageHasMore = const {},
    this.chatAction,
    this.chatActionError,

    // Relationship
    this.relationshipTagLoading = false,
    this.relationshipTagAction,
    this.relationshipTagActionProposalId,
    this.relationshipTagError,
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
    String? chatAction,
    String? chatActionError,

    // Relationship
    bool? relationshipTagLoading,
    String? relationshipTagAction,
    String? relationshipTagActionProposalId,
    String? relationshipTagError,
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

      chatAction: chatAction,

      chatActionError: chatActionError,

      // ========================================================
      // RELATIONSHIP
      // ========================================================
      relationshipTagLoading:
          relationshipTagLoading ?? this.relationshipTagLoading,

      relationshipTagAction: relationshipTagAction,

      relationshipTagActionProposalId: relationshipTagActionProposalId,

      relationshipTagError: relationshipTagError,
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
    chatAction,
    chatActionError,

    // Relationship
    relationshipTagLoading,
    relationshipTagAction,
    relationshipTagActionProposalId,
    relationshipTagError,
  ];
}
