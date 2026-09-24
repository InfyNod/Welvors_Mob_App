import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../chat_bloc/chat_state.dart';
import 'chat_attachment_bubble.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

/// Card for shared contacts with tap to dial
class ChatContactCard extends StatelessWidget {
  final ChatMessage message;

  const ChatContactCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () async {
          final phone = message.contactPhoneNumber?.trim();
          if (phone == null || phone.isEmpty) return;

          final Uri phoneUri = Uri(scheme: 'tel', path: phone);
          try {
            await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
          } catch (e) {
            AppLogger.e('ChatContactCard', '❌ Call error: $e');
          }
        },
        child: ChatAttachmentBubble(
          icon: Icons.person_rounded,
          iconColor: const Color(0xFF8A8680),
          title: message.contactName.toString(),
          subtitle: message.contactPhoneNumber.toString(),
          isMine: message.isMine,
        ),
      ),
    );
  }
}
