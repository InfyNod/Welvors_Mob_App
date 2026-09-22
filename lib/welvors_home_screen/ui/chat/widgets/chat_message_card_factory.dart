import 'package:flutter/material.dart';
import '../chat_bloc/chat_state.dart';
import 'cards/chat_text_card.dart';
import 'cards/chat_image_card.dart';
import 'cards/chat_video_card.dart';
import 'cards/chat_audio_card.dart';
import 'cards/chat_document_card.dart';
import 'cards/chat_location_card.dart';
import 'cards/chat_contact_card.dart';
import 'cards/chat_gift_card.dart';
import 'cards/chat_rose_card.dart';
import 'cards/chat_compliment_card.dart';
import 'cards/chat_date_plan_card.dart';
import 'cards/chat_event_invite_card.dart';
import 'cards/chat_relationship_tag_card.dart';

/// Factory widget that chooses and renders the appropriate card widget for a ChatMessage
class ChatMessageCardFactory extends StatelessWidget {
  final ChatMessage message;
  final String peerName;
  final String liveName;
  final int liveAge;
  final bool isAudioPlaying;
  final String? playingAudioPath;
  final VoidCallback? onTapReply;
  final VoidCallback onTapImage;
  final VoidCallback? onTapReplyOverlay;
  final VoidCallback onToggleAudio;
  final VoidCallback onOpenDocument;
  final void Function(String emoji, String label) onPlayEffect;
  final VoidCallback onAcceptRelationshipTag;
  final VoidCallback onRejectRelationshipTag;
  final void Function(ChatMessage message) onDeleteMessage;

  const ChatMessageCardFactory({
    super.key,
    required this.message,
    required this.peerName,
    required this.liveName,
    required this.liveAge,
    required this.isAudioPlaying,
    required this.playingAudioPath,
    this.onTapReply,
    required this.onTapImage,
    this.onTapReplyOverlay,
    required this.onToggleAudio,
    required this.onOpenDocument,
    required this.onPlayEffect,
    required this.onAcceptRelationshipTag,
    required this.onRejectRelationshipTag,
    required this.onDeleteMessage,
  });

  Widget _buildCard(BuildContext context) {
    if ((message.type == ChatMessageType.ENGAGEMENT) &&
        message.giftId != null) {
      return ChatEngagementBundleCard(message: message);
    }

    if (message.type == ChatMessageType.rose) {
      return ChatRoseCard(message: message, peerName: peerName);
    }

    if (message.type == ChatMessageType.ENGAGEMENT) {
      return ChatRoseCard(message: message, peerName: peerName);
    }

    switch (message.type) {
      case ChatMessageType.text:
        return ChatTextCard(
          message: message,
          peerName: peerName,
          onTapReply: onTapReply,
        );

      case ChatMessageType.effect:
        return ChatEffectCard(
          message: message,
          onPlayEffect: onPlayEffect,
        );

      case ChatMessageType.image:
        return ChatImageCard(
          message: message,
          onTapImage: onTapImage,
          onTapReplyOverlay: onTapReplyOverlay,
        );

      case ChatMessageType.video:
        return ChatVideoCard(message: message);

      case ChatMessageType.audio:
        final path = message.audioUrl ?? message.fileUrl;
        final isPlaying =
            path != null && path == playingAudioPath && isAudioPlaying;
        return ChatAudioCard(
          message: message,
          isPlaying: isPlaying,
          onToggleAudio: onToggleAudio,
        );

      case ChatMessageType.document:
        return ChatDocumentCard(
          message: message,
          onOpen: onOpenDocument,
        );

      case ChatMessageType.location:
        return ChatLocationCard(message: message);

      case ChatMessageType.contact:
        return ChatContactCard(message: message);

      case ChatMessageType.gift:
        return ChatGiftCard(message: message, peerName: peerName);

      case ChatMessageType.ENGAGEMENT:
        return ChatRoseCard(message: message, peerName: peerName);

      case ChatMessageType.RELATIONSHIP_TAG_PROPOSAL:
      case ChatMessageType.RELATIONSHIP_TAG_ACCEPTED:
        return ChatRelationshipTagCard(
          message: message,
          peerName: peerName,
          onAccept: onAcceptRelationshipTag,
          onReject: onRejectRelationshipTag,
        );

      case ChatMessageType.rose:
        return ChatRoseCard(message: message, peerName: peerName);

      case ChatMessageType.compliment:
        return ChatComplimentCard(message: message, peerName: peerName);

      case ChatMessageType.dateInvite:
      case ChatMessageType.DATECONFIRMED:
        return ChatDatePlanCard(
          message: message,
          liveName: liveName,
          liveAge: liveAge,
        );

      case ChatMessageType.eventInvite:
        return ChatEventInviteCard(message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);

    if (!message.isMine) return card;

    return GestureDetector(
      onLongPress: () => onDeleteMessage(message),
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
