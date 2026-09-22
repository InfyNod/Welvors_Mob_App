import 'package:flutter/material.dart';
import '../../chat_bloc/chat_state.dart';
import 'chat_attachment_bubble.dart';

/// Card for document (PDF/file) attachments
class ChatDocumentCard extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onOpen;

  const ChatDocumentCard({
    super.key,
    required this.message,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onOpen,
        child: ChatAttachmentBubble(
          icon: Icons.insert_drive_file_rounded,
          iconColor: const Color(0xFF3D8BE8),
          title: message.fileName ?? 'Document',
          subtitle: message.fileSize ?? 'Document',
          isMine: message.isMine,
        ),
      ),
    );
  }
}
