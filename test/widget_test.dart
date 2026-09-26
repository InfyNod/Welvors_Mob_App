import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'BASE_URL=https://api.welvors.com/\nAPI_BASE_URL=https://api.welvors.com/api/\n');
  });

  group('Core Architecture Unit Tests', () {
    test('EnvConfig URL sanitization trims trailing slash', () {
      expect(EnvConfig.baseUrl, 'https://api.welvors.com');
      expect(EnvConfig.apiBaseUrl, 'https://api.welvors.com/api');
      expect(EnvConfig.baseUrl.endsWith('/'), isFalse);
      expect(EnvConfig.apiBaseUrl.endsWith('/'), isFalse);
    });

    test('AppLogger initializes and formats logs without crashing', () {
      AppLogger.init();
      expect(() => AppLogger.d('TestTag', 'Debug message'), returnsNormally);
      expect(() => AppLogger.i('TestTag', 'Info message'), returnsNormally);
      expect(() => AppLogger.w('TestTag', 'Warning message'), returnsNormally);
      expect(() => AppLogger.v('TestTag', 'Verbose message'), returnsNormally);
      expect(() => AppLogger.e('TestTag', 'Error message'), returnsNormally);
      expect(() => AppLogger.json('TestTag', {'key': 'value'}), returnsNormally);
    });
  });
}
