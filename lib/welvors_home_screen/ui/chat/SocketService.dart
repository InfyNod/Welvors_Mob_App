import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;

  bool get isConnected => socket?.connected == true;

  // ============================================================
  // ENSURE CONNECTED
  // ============================================================

  Future<void>? _connectingFuture;

  Future<void> ensureConnected() {
    if (socket != null) {
      if (!isConnected) {
        socket!.connect();
      }

      return Future.value();
    }

    return _connectingFuture ??= _doConnect().whenComplete(() {
      _connectingFuture = null;
    });
  }

  // ============================================================
  // CONNECT FROM SAVED TOKEN
  // ============================================================

  Future<void> _doConnect() async {
    final prefs = await SharedPreferences.getInstance();

    // Production me saved token use karo:
    //
    // final token = prefs.getString('auth_token') ?? '';

    final token =
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

    if (token.isEmpty) {
      debugPrint('❌ SOCKET: no auth_token in prefs - cannot connect');
      return;
    }

    connect(token: token);
  }

  // ============================================================
  // CONNECT SOCKET
  // ============================================================

  void connect({required String token}) {
    if (socket?.connected == true) {
      debugPrint('🟢 SOCKET ALREADY CONNECTED');
      return;
    }

    if (socket != null) {
      debugPrint('🟡 SOCKET EXISTS - CONNECTING...');
      socket!.connect();
      return;
    }

    debugPrint('🔵 CREATING SOCKET...');

    socket = IO.io(
      'https://api.welvors.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': token})
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('🟢 SOCKET CONNECTED');
      debugPrint('🆔 SOCKET ID: ${socket!.id}');
    });

    socket!.onDisconnect((reason) {
      debugPrint('🔴 SOCKET DISCONNECTED: $reason');
    });

    socket!.onConnectError((error) {
      debugPrint('❌ SOCKET CONNECT ERROR: $error');
    });

    socket!.onError((error) {
      debugPrint('❌ SOCKET ERROR: $error');
    });

    socket!.connect();
  }

  // ============================================================
  // MESSAGE READ
  //
  // IMPORTANT:
  // message:read now uses MESSAGE ID.
  //
  // Payload:
  //
  // {
  //   "messageId": "xxxxxxxx"
  // }
  //
  // conversationId is NOT used here.
  // ============================================================

  // ============================================================
  // MESSAGE READ BY MESSAGE ID
  // ============================================================

  void markMessageAsRead(String messageId) {
    if (messageId.isEmpty) {
      debugPrint('❌ MESSAGE READ: messageId is empty');
      return;
    }

    debugPrint('📖 MESSAGE READ: messageId => $messageId');

    emitWhenConnected('message:read', {'messageId': messageId});
  }

  // ============================================================
  // EMIT
  // ============================================================

  void emit(String event, dynamic data) {
    if (socket == null) {
      debugPrint(
        '❌ SOCKET NOT INITIALIZED - '
        'connecting in background: $event',
      );

      ensureConnected();

      return;
    }

    if (!socket!.connected) {
      debugPrint('❌ SOCKET NOT CONNECTED');

      return;
    }

    debugPrint('📤 SOCKET EVENT: $event');

    debugPrint('📦 SOCKET DATA: $data');

    socket!.emit(event, data);
  }

  // ============================================================
  // EMIT WHEN CONNECTED
  // ============================================================

  void emitWhenConnected(String event, dynamic data) {
    if (socket == null) {
      debugPrint(
        '⏳ SOCKET NOT INITIALIZED - '
        'connecting then retrying: $event',
      );

      ensureConnected().then((_) {
        if (socket == null) {
          debugPrint(
            '❌ SOCKET STILL NOT AVAILABLE - '
            'dropping event: $event',
          );
          return;
        }

        emitWhenConnected(event, data);
      });

      return;
    }

    if (socket!.connected) {
      debugPrint('📤 SOCKET EVENT: $event');

      debugPrint('📦 SOCKET DATA: $data');

      socket!.emit(event, data);

      return;
    }

    debugPrint(
      '⏳ SOCKET CONNECTING - '
      'WAITING FOR CONNECTION...',
    );

    socket!.once('connect', (_) {
      debugPrint('🟢 SOCKET CONNECTED → SENDING EVENT');

      debugPrint('📤 SOCKET EVENT: $event');

      debugPrint('📦 SOCKET DATA: $data');

      socket!.emit(event, data);
    });
  }

  // ============================================================
  // LISTENER
  // ============================================================

  void on(String event, Function(dynamic) callback) {
    if (socket == null) {
      debugPrint(
        '⏳ SOCKET NOT INITIALIZED - '
        'connecting then registering: $event',
      );

      ensureConnected().then((_) {
        if (socket == null) {
          debugPrint(
            '❌ SOCKET STILL NOT AVAILABLE. '
            'Cannot listen: $event',
          );
          return;
        }

        socket!.on(event, callback);
      });

      return;
    }

    socket!.on(event, callback);
  }

  // ============================================================
  // LISTEN TO ALL SOCKET EVENTS
  // ============================================================

  void onAny(void Function(String event, dynamic data) callback) {
    if (socket == null) {
      debugPrint(
        '⏳ SOCKET NOT INITIALIZED - '
        'connecting then registering onAny',
      );

      ensureConnected().then((_) {
        if (socket == null) {
          debugPrint(
            '❌ SOCKET STILL NOT AVAILABLE. '
            'Cannot listen to all events',
          );
          return;
        }

        socket!.onAny((event, data) {
          callback(event.toString(), data);
        });
      });

      return;
    }

    socket!.onAny((event, data) {
      callback(event.toString(), data);
    });
  }

  // ============================================================
  // REMOVE ALL onAny LISTENERS
  // ============================================================

  void offAny() {
    socket?.offAny();
  }

  // ============================================================
  // REMOVE EVENT LISTENER
  // ============================================================

  void off(String event) {
    socket?.off(event);
  }

  // ============================================================
  // DISCONNECT
  // ============================================================

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
