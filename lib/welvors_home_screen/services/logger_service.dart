import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Supported log levels for [AppLogger].
enum LogLevel { verbose, debug, info, warning, error }

/// Centralized Logger Service for the Welvors App.
///
/// Features:
/// 1. **Complete Release-Mode Silence**: When compiled in release mode ([kReleaseMode]),
///    ZERO logs, prints, or debugPrints are emitted to console, logcat, or terminal.
/// 2. **Global Print & DebugPrint Interception**: Automatically catches all legacy
///    `print(...)` and `debugPrint(...)` calls throughout the entire app and third-party
///    libraries, funneling them through this service.
/// 3. **Structured Logging**: Provides specialized methods for debug, info, warning,
///    error (with stack traces), JSON data, and API request/response logging.
///
/// Usage:
/// ```dart
/// AppLogger.d('HomeBloc', 'Loading data...');
/// AppLogger.i('AuthService', 'User signed in: $uid');
/// AppLogger.w('TokenHelper', 'Token expiring soon');
/// AppLogger.e('ChatBloc', 'Socket failed', error: e, stackTrace: st);
/// AppLogger.apiRequest('ApiService', method: 'GET', url: '...');
/// AppLogger.apiResponse('ApiService', statusCode: 200, body: '...');
/// AppLogger.json('Payload', jsonMap);
/// ```
class AppLogger {
  AppLogger._();

  /// Whether logging is currently enabled.
  /// Strictly false in release mode ([kReleaseMode] == true) or non-debug mode.
  static bool get isEnabled => !kReleaseMode && kDebugMode;

  /// Initializes the logger service.
  /// Overrides Flutter's global [debugPrint] so that all [debugPrint] calls across
  /// the app and plugins pass through [AppLogger] and are completely silenced in release mode.
  static void init() {
    if (kReleaseMode || !kDebugMode) {
      // In release mode: completely silence debugPrint
      debugPrint = (String? message, {int? wrapWidth}) {};
      return;
    }

    // In debug mode: route debugPrint through AppLogger
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        debugPrintLog(message, wrapWidth: wrapWidth);
      }
    };
  }

  /// Runs the app in a guarded Zone that intercepts all standard Dart [print] calls,
  /// ensuring they pass through [AppLogger] and are completely silenced in release mode.
  /// Also catches and logs uncaught asynchronous errors.
  static void runLoggingApp(FutureOr<void> Function() appRunner) {
    init();

    if (kReleaseMode || !kDebugMode) {
      // In release mode: silence Zone print completely
      runZonedGuarded(
        () {
          appRunner();
        },
        (error, stackTrace) {
          // Release mode: silent (or hook Crashlytics here)
        },
        zoneSpecification: ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
            // SILENT IN RELEASE MODE - do not output anything to console or logs
          },
        ),
      );
      return;
    }

    // In debug mode: capture and format prints and errors
    runZonedGuarded(
      () {
        appRunner();
      },
      (error, stackTrace) {
        e('UNCAUGHT', 'Uncaught asynchronous error', error: error, stackTrace: stackTrace);
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          interceptPrint(line, parent: parent, zone: zone);
        },
      ),
    );
  }

  /// Called when a raw [print] call is intercepted by the zone.
  static void interceptPrint(String line, {ZoneDelegate? parent, Zone? zone}) {
    if (!isEnabled) return;

    developer.log(line, name: 'PRINT');
    if (parent != null && zone != null) {
      parent.print(zone, line);
    }
  }

  /// Called when [debugPrint] is intercepted.
  static void debugPrintLog(String message, {int? wrapWidth}) {
    if (!isEnabled) return;

    developer.log(message, name: 'DEBUG_PRINT');
    debugPrintSynchronously(message, wrapWidth: wrapWidth);
  }

  // ─── Level Logging Methods ────────────────────────────────────

  /// Verbose log
  static void v(String tag, String message) {
    _output(LogLevel.verbose, tag, '🔍 $message');
  }

  /// Debug log (replaces standard debug prints)
  static void d(String tag, String message) {
    _output(LogLevel.debug, tag, '🐛 $message');
  }

  /// Informational log
  static void i(String tag, String message) {
    _output(LogLevel.info, tag, 'ℹ️ $message');
  }

  /// Warning log
  static void w(String tag, String message) {
    _output(LogLevel.warning, tag, '⚠️ $message');
  }

  /// Error log with optional [error] object and [stackTrace].
  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isEnabled) return;

    final buffer = StringBuffer()
      ..writeln('┌──────────────────────────────────────────────────')
      ..writeln('│ ❌ ERROR [$tag]')
      ..writeln('│ $message');
    if (error != null) {
      buffer.writeln('│ 💥 Exception: $error');
    }
    if (stackTrace != null) {
      buffer.writeln('│ 📜 StackTrace:');
      for (final line in stackTrace.toString().split('\n').take(10)) {
        if (line.trim().isNotEmpty) {
          buffer.writeln('│    $line');
        }
      }
    }
    buffer.write('└──────────────────────────────────────────────────');

    final formatted = buffer.toString();
    developer.log(formatted, name: tag, error: error, stackTrace: stackTrace);
    debugPrintSynchronously(formatted);
  }

  /// Pretty-prints a JSON map or string.
  static void json(String tag, dynamic data) {
    if (!isEnabled) return;
    try {
      final pretty = const JsonEncoder.withIndent('  ').convert(
        data is String ? jsonDecode(data) : data,
      );
      _output(LogLevel.debug, tag, '📄 JSON:\n$pretty');
    } catch (_) {
      _output(LogLevel.debug, tag, '📄 DATA: $data');
    }
  }

  /// Logs an outgoing API HTTP request.
  static void apiRequest(
    String tag, {
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) {
    if (!isEnabled) return;

    final buffer = StringBuffer()
      ..writeln('┌──────────────────────────────────────────────────')
      ..writeln('│ 🌐 $method REQUEST [$tag]')
      ..writeln('│ 🔗 URL: $url');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('│ 📋 HEADERS: $headers');
    }
    if (body != null) {
      buffer.writeln('│ 📦 BODY: $body');
    }
    buffer.write('└──────────────────────────────────────────────────');

    final formatted = buffer.toString();
    developer.log(formatted, name: tag);
    debugPrintSynchronously(formatted);
  }

  /// Logs an incoming API HTTP response.
  static void apiResponse(
    String tag, {
    required int statusCode,
    required String body,
  }) {
    if (!isEnabled) return;

    final isSuccess = statusCode >= 200 && statusCode < 300;
    final emoji = isSuccess ? '✅' : '❌';

    final buffer = StringBuffer()
      ..writeln('┌──────────────────────────────────────────────────')
      ..writeln('│ 📥 RESPONSE [$tag] $emoji ($statusCode)')
      ..writeln('│ 📦 BODY: ${_truncate(body, 1000)}')
      ..write('└──────────────────────────────────────────────────');

    final formatted = buffer.toString();
    developer.log(formatted, name: tag);
    debugPrintSynchronously(formatted);
  }

  // ─── Internal Helper ──────────────────────────────────────────

  static void _output(LogLevel level, String tag, String message) {
    if (!isEnabled) return;

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
    final formatted = '[$time] [$tag] $message';

    developer.log(formatted, name: tag);
    debugPrintSynchronously(formatted);
  }

  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... (truncated ${text.length} chars)';
  }
}
