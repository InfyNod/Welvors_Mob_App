import 'package:flutter_test/flutter_test.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_state.dart';

void main() {
  group('Chat Reply Mechanism Tests', () {
    test('ChatMessage.fromJson extracts reply from standard replyToId and replyText', () {
      final json = {
        'id': 'msg_1',
        'text': 'Reply message',
        'replyToId': 'msg_parent',
        'replyText': 'Original message text',
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');

      expect(message.replyToId, equals('msg_parent'));
      expect(message.replyText, equals('Original message text'));
    });

    test('ChatMessage.fromJson extracts reply from populated replyTo object', () {
      final json = {
        'id': 'msg_2',
        'text': 'Reply message 2',
        'replyTo': {
          '_id': 'msg_parent_2',
          'content': 'Populated parent content',
          'messageType': 'TEXT',
        },
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');

      expect(message.replyToId, equals('msg_parent_2'));
      expect(message.replyText, equals('Populated parent content'));
    });

    test('ChatMessage.fromJson extracts reply from nested reply map', () {
      final json = {
        'id': 'msg_3',
        'text': 'Reply message 3',
        'reply': {
          'id': 'msg_parent_3',
          'text': 'Parent in reply map',
          'imageUrl': 'https://example.com/parent.jpg',
        },
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');

      expect(message.replyToId, equals('msg_parent_3'));
      expect(message.replyText, equals('Parent in reply map'));
      expect(message.replyImageUrl, equals('https://example.com/parent.jpg'));
    });

    test('ChatMessage.fromJson extracts reply from metadata map', () {
      final json = {
        'id': 'msg_4',
        'text': 'Reply message 4',
        'metadata': {
          'replyToId': 'msg_parent_4',
          'replyText': 'Parent in metadata',
        },
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');

      expect(message.replyToId, equals('msg_parent_4'));
      expect(message.replyText, equals('Parent in metadata'));
    });

    test('ChatMessage.fromJsonList resolves missing replyText when parent is in list', () {
      final rawList = [
        {
          'id': 'parent_100',
          'text': 'This is the parent text',
          'createdAt': '2026-09-28T10:00:00.000Z',
          'senderId': 'user_2',
        },
        {
          'id': 'child_101',
          'text': 'This is the reply message',
          'replyTo': 'parent_100',
          'createdAt': '2026-09-28T10:05:00.000Z',
          'senderId': 'user_1',
        },
      ];

      final messages = ChatMessage.fromJsonList(rawList, currentUserId: 'user_1');

      final replyMsg = messages.firstWhere((m) => m.id == 'child_101');
      expect(replyMsg.replyToId, equals('parent_100'));
      expect(replyMsg.replyText, equals('This is the parent text'));
    });
  });
}
