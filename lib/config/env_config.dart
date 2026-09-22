import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
/// Values are loaded from `.env` at app startup (`dotenv.load` in `main.dart`).
class EnvConfig {
  EnvConfig._();

  /// Root domain URL (e.g. `https://api.welvors.com`).
  /// Used for Socket connections and non-`/api` endpoints.
  static String get baseUrl => _trimSlash(dotenv.env['BASE_URL'] ?? '');

  /// REST API base URL (e.g. `https://api.welvors.com/api`).
  static String get apiBaseUrl => _trimSlash(dotenv.env['API_BASE_URL'] ?? '');

  static String _trimSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}
