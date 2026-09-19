import 'package:equatable/equatable.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_state.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatsEvent extends ChatEvent {
  final String type;

  const LoadChatsEvent({this.type = 'all'});

  @override
  List<Object?> get props => [type];
}

class SearchChatsEvent extends ChatEvent {
  final String query;

  const SearchChatsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectFilterEvent extends ChatEvent {
  final String filter;

  const SelectFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class LoadMessagesEvent extends ChatEvent {
  /// UI/state key. Usually the other user's id or ChatUser.id.
  final String chatId;

  /// Real backend conversation id used by the messages endpoint.
  final String? conversationId;
  final String? cursor;

  const LoadMessagesEvent(this.chatId, {this.conversationId, this.cursor});

  @override
  List<Object?> get props => [chatId, conversationId, cursor];
}

class ConversationUpdateEvent extends ChatEvent {
  final Map<String, dynamic> payload;

  const ConversationUpdateEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class IncomingMessageEvent extends ChatEvent {
  final String chatId;
  final Map<String, dynamic> payload;

  const IncomingMessageEvent({required this.chatId, required this.payload});

  @override
  List<Object?> get props => [chatId, payload];
}

class SendRelationshipTagProposalEvent extends ChatEvent {
  final String receiverId;
  final String tag;
  final String message;
  const SendRelationshipTagProposalEvent({
    required this.receiverId,
    required this.tag,
    required this.message,
  });
  @override
  List<Object?> get props => [receiverId, tag, message];
}

class AcceptRelationshipTagProposalEvent extends ChatEvent {
  final String proposalId;
  const AcceptRelationshipTagProposalEvent({required this.proposalId});
  @override
  List<Object?> get props => [proposalId];
}

class RejectRelationshipTagProposalEvent extends ChatEvent {
  final String proposalId;
  const RejectRelationshipTagProposalEvent({required this.proposalId});
  @override
  List<Object?> get props => [proposalId];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final ChatMessageType type;

  final String? conversationId;

  // Common message
  final String? typemsg;
  final String? message;

  // Image
  final String? imageUrl;

  // Video
  final String? videoUrl;

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
  final String? hintLine;

  // Compliment / Location
  final String? locationLabel;

  // LOCATION
  final double? latitude;
  final double? longitude;

  final bool isNew;

  // Proposal
  final String? proposalId;

  // CONTACT
  final String? contactName;
  final String? contactPhoneNumber;

  // Date Invite
  final String? inviteTitle;
  final String? inviteVenue;
  final String? inviteStatus;

  const SendMessageEvent({
    required this.chatId,
    required this.type,
    required this.typemsg,

    this.conversationId,

    // Common
    this.message,

    // Image
    this.imageUrl,

    // Video
    this.videoUrl,

    // CONTACT
    this.contactName,
    this.contactPhoneNumber,

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
    this.hintLine,

    // LOCATION
    this.locationLabel,
    this.latitude,
    this.longitude,

    this.isNew = false,

    // Proposal
    this.proposalId,

    // Date Invite
    this.inviteTitle,
    this.inviteVenue,
    this.inviteStatus,
  });

  @override
  List<Object?> get props => [
    chatId,
    type,
    conversationId,

    // Common
    typemsg,
    message,

    // Image
    imageUrl,

    // Video
    videoUrl,

    // Reply
    replyToId,
    replyText,
    replyImageUrl,
    replyFileUrl,
    replyType,

    // Audio
    audioUrl,

    // Document
    fileUrl,
    fileName,
    fileSize,

    // Gift
    giftId,
    giftName,
    giftEmoji,
    giftCoins,
    giftClaimed,

    // Gift progress
    messageProgress,
    messageTarget,
    expiresIn,

    // Rose / Compliment
    coinAmount,
    seen,
    hintLine,

    // LOCATION
    locationLabel,
    latitude,
    longitude,

    isNew,

    // Proposal
    proposalId,

    // CONTACT
    contactName,
    contactPhoneNumber,

    // Date Invite
    inviteTitle,
    inviteVenue,
    inviteStatus,
  ];
}

class UserOnlineSocketEvent extends ChatEvent {
  final String userId;

  const UserOnlineSocketEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserOfflineSocketEvent extends ChatEvent {
  final String userId;

  const UserOfflineSocketEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class IncomingSocketMessageListEvent extends ChatEvent {
  final Map<String, dynamic> payload;

  const IncomingSocketMessageListEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class MessageDeliveredSocketEvent extends ChatEvent {
  final String? messageId;
  final String? conversationId;

  const MessageDeliveredSocketEvent({this.messageId, this.conversationId});

  @override
  List<Object?> get props => [messageId, conversationId];
}

class DeleteMessageEvent extends ChatEvent {
  final String chatId;
  final String messageId;

  const DeleteMessageEvent({required this.chatId, required this.messageId});

  @override
  List<Object?> get props => [chatId, messageId];
}

class MessageReadSocketEvent extends ChatEvent {
  final String? messageId;
  final String? conversationId;

  const MessageReadSocketEvent({this.messageId, this.conversationId});

  @override
  List<Object?> get props => [messageId, conversationId];
}

class DeleteConversationEvent extends ChatEvent {
  final String conversationId;
  const DeleteConversationEvent({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

class ClearConversationEvent extends ChatEvent {
  final String conversationId;
  const ClearConversationEvent({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}
