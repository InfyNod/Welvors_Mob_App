import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_bloc/chat_state.dart';

void main() {
  group('Chat Reply Mechanism Tests', () {
    setUpAll(() {
      dotenv.loadFromString(
        envString:
            'BASE_URL=https://api.welvors.com\nAPI_BASE_URL=https://api.welvors.com/api',
      );
    });
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

    test('ChatMessage.fromJson normalizes relative audio and media URLs', () {
      final json = {
        'id': 'msg_audio_1',
        'type': 'AUDIO',
        'audioUrl': '/uploads/chat/media/voice_123.m4a',
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');
      expect(message.audioUrl, isNotNull);
      expect(message.audioUrl!.startsWith('http'), isTrue);
      expect(message.audioUrl!.contains('/uploads/chat/media/voice_123.m4a'), isTrue);
    });

    test('ChatMessage.fromJson keeps absolute audio URLs unchanged', () {
      const fullUrl = 'https://s3.amazonaws.com/bucket/voice_456.m4a';
      final json = {
        'id': 'msg_audio_2',
        'type': 'AUDIO',
        'audioUrl': fullUrl,
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');
      expect(message.audioUrl, equals(fullUrl));
    });

    test('ChatMessage.fromJson keeps local device paths unchanged', () {
      const localPath =
          '/data/user/0/com.infynod.welvors/cache/voice_1790574040787.m4a';
      final json = {
        'id': 'msg_audio_3',
        'type': 'AUDIO',
        'audioUrl': localPath,
        'senderId': 'user_1',
      };

      final message = ChatMessage.fromJson(json, currentUserId: 'user_1');
      expect(message.audioUrl, equals(localPath));
    });
  });
}
