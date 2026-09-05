import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  static const String _baseUrl = 'https://api.welvors.com';
  static const Duration _heartbeatInterval = Duration(seconds: 75);

  IO.Socket? socket;

  Timer? _presenceHeartbeatTimer;
  Timer? _manualReconnectTimer;
  Future<void>? _connectingFuture;
  Completer<void>? _connectionCompleter;

  final Map<String, List<Function(dynamic)>> _pendingListeners = {};
  final Set<String> _onlineUsers = <String>{};

  bool get isConnected => socket?.connected == true;
  Set<String> get onlineUserIds => Set<String>.unmodifiable(_onlineUsers);
  bool isUserOnline(String userId) => _onlineUsers.contains(userId.trim());

  // ============================================================
  // CONNECTION
  // ============================================================

  Future<void> ensureConnected() {
    if (socket?.connected == true) return Future.value();

    return _connectingFuture ??= _connectFromSavedToken().whenComplete(() {
      _connectingFuture = null;
    });
  }

  Future<void> _connectFromSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token')?.trim() ?? '';
    // ✅ FIX: was `startsWith('')`, which is true for every string, so this
    // always chopped off the first 7 characters — including of tokens that
    // never had a "Bearer " prefix, corrupting the token used to
    // authenticate the socket (and therefore conversation:join / real-time
    // updates) for any real logged-in user.
    final rawToken = savedToken.toLowerCase().startsWith('bearer ')
        ? savedToken.substring(7).trim()
        : savedToken;

    if (rawToken.isEmpty) {
      debugPrint('❌ SOCKET: auth_token missing');
      return;
    }

    await _createAndConnect(rawToken);
  }

  Future<void> _createAndConnect(String rawToken) async {
    if (socket?.connected == true) return;

    // If a socket already exists, its auth options may belong to an old token.
    // Recreate it with forceNew so Socket.IO cannot reuse a cached Manager.
    if (socket != null) {
      try {
        socket!.dispose();
      } catch (_) {}
      socket = null;
    }

    debugPrint('🔵 SOCKET: creating connection');
    debugPrint('🌐 SOCKET URL: $_baseUrl');

    final bearerr = '$rawToken';

    socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.infinity)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .enableForceNew()
          // Send the token in BOTH places. Different Socket.IO backends read
          // either handshake.auth or handshake.headers.
          .setAuth({
            'authorization': bearerr,
            'Authorization': bearerr,
            'token': rawToken,
          })
          .setExtraHeaders({'Authorization': bearerr, 'authorization': bearerr})
          .build(),
    );

    _registerCoreSocketListeners();
    _registerPendingListeners();

    _connectionCompleter = Completer<void>();

    debugPrint('🔌 SOCKET: calling connect()');
    socket!.connect();

    try {
      await _connectionCompleter!.future.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      debugPrint('⏱️ SOCKET: connection timeout');
    } finally {
      _connectionCompleter = null;
    }
  }

  void connect({required String token}) {
    final rawToken = token.toLowerCase().startsWith('bearer ')
        ? token.substring(7).trim()
        : token.trim();

    if (rawToken.isEmpty) {
      debugPrint('❌ SOCKET: connect called with empty token');
      return;
    }

    if (socket?.connected == true) {
      debugPrint('🟢 SOCKET ALREADY CONNECTED');
      return;
    }

    _connectingFuture ??= _createAndConnect(rawToken).whenComplete(() {
      _connectingFuture = null;
    });
  }

  void _registerCoreSocketListeners() {
    final s = socket;
    if (s == null) return;

    s.onConnect((_) {
      debugPrint('🟢 SOCKET CONNECTED');
      debugPrint('🆔 SOCKET ID: ${s.id}');

      _manualReconnectTimer?.cancel();
      _connectionCompleter?.complete();
      _connectionCompleter = null;

      // Presence heartbeat is sent immediately and then every 75 seconds.
      _emitPresenceHeartbeat();
      _startPresenceHeartbeat();
    });

    s.onDisconnect((reason) {
      debugPrint('🔴 SOCKET DISCONNECTED: $reason');
      _presenceHeartbeatTimer?.cancel();
      _presenceHeartbeatTimer = null;

      // socket_io_client has reconnection enabled. This timer is a safety net
      // for cases where the manager gives up after a transport/auth failure.
      _scheduleManualReconnect();
    });

    s.onConnectError((error) {
      debugPrint('❌ SOCKET CONNECT ERROR: $error');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(error);
      }
    });

    s.onError((error) {
      debugPrint('❌ SOCKET ERROR: $error');
    });

    s.on('user:online', _handleUserOnline);
    s.on('user:offline', _handleUserOffline);

    s.onAny((event, data) {
      debugPrint('📡 SOCKET EVENT <= $event | $data');
    });
  }

  void _registerPendingListeners() {
    final s = socket;
    if (s == null) return;

    final pending = Map<String, List<Function(dynamic)>>.from(
      _pendingListeners,
    );
    _pendingListeners.clear();

    for (final entry in pending.entries) {
      for (final callback in entry.value) {
        s.on(entry.key, callback);
      }
    }
  }

  void _scheduleManualReconnect() {
    if (_manualReconnectTimer?.isActive == true) return;
    if (socket == null) return;

    _manualReconnectTimer = Timer(const Duration(seconds: 5), () {
      if (socket?.connected == true) return;
      debugPrint('🔁 SOCKET: manual reconnect attempt');
      socket?.connect();
    });
  }

  // ============================================================
  // PRESENCE HEARTBEAT
  // ============================================================

  void _startPresenceHeartbeat() {
    _presenceHeartbeatTimer?.cancel();
    _presenceHeartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _emitPresenceHeartbeat();
    });
    debugPrint('💓 SOCKET: presence heartbeat timer started (75s)');
  }

  void _emitPresenceHeartbeat() {
    final s = socket;
    if (s?.connected != true) {
      debugPrint('💓 SOCKET: heartbeat skipped - not connected');
      return;
    }

    debugPrint('💓 SOCKET EVENT OUT => presence:heartbeat');
    s!.emit('presence:heartbeat');
  }

  String? _extractUserId(dynamic payload) {
    dynamic data = payload;
    if (data is List) {
      if (data.isEmpty) return null;
      data = data.first;
    }

    for (var i = 0; i < 4; i++) {
      if (data is! Map) return null;
      final map = Map<String, dynamic>.from(data);
      final id = map['userId'] ?? map['user_id'] ?? map['id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString().trim();
      }
      if (map['data'] is Map) {
        data = map['data'];
        continue;
      }
      if (map['user'] is Map) {
        data = map['user'];
        continue;
      }
      return null;
    }
    return null;
  }

  void _handleUserOnline(dynamic payload) {
    final userId = _extractUserId(payload);
    if (userId == null) return;
    _onlineUsers.add(userId);
    debugPrint('🟢 PRESENCE ONLINE => $userId');
  }

  void _handleUserOffline(dynamic payload) {
    final userId = _extractUserId(payload);
    if (userId == null) return;
    _onlineUsers.remove(userId);
    debugPrint('🔴 PRESENCE OFFLINE => $userId');
  }

  // ============================================================
  // MESSAGE READ
  // ============================================================

  void markMessageAsRead(String messageId) {
    final id = messageId.trim();
    if (id.isEmpty) return;

    debugPrint('📖 MESSAGE READ => $id');
    emitWhenConnected('message:read', {'messageId': id});
  }

  // ============================================================
  // EMIT
  // ============================================================

  void emit(String event, [dynamic data]) {
    final s = socket;
    if (s == null || s.connected != true) {
      debugPrint('⏳ SOCKET: $event queued until connection');
      emitWhenConnected(event, data);
      return;
    }

    debugPrint('📤 SOCKET EVENT OUT => $event');
    if (data != null) debugPrint('📦 SOCKET DATA => $data');
    data == null ? s.emit(event) : s.emit(event, data);
  }

  void emitWhenConnected(String event, [dynamic data]) {
    final s = socket;

    if (s == null) {
      ensureConnected().then((_) {
        if (socket?.connected == true) {
          emitWhenConnected(event, data);
        } else {
          debugPrint('❌ SOCKET: unable to send $event - no connection');
        }
      });
      return;
    }

    if (s.connected) {
      debugPrint('📤 SOCKET EVENT OUT => $event');
      if (data != null) debugPrint('📦 SOCKET DATA => $data');
      data == null ? s.emit(event) : s.emit(event, data);
      return;
    }

    debugPrint('⏳ SOCKET: waiting for connect => $event');
    s.once('connect', (_) {
      if (socket?.connected != true) return;
      debugPrint('🟢 SOCKET CONNECTED -> sending queued event $event');
      data == null ? socket!.emit(event) : socket!.emit(event, data);
    });

    ensureConnected();
  }

  // ============================================================
  // LISTENERS
  // ============================================================

  void on(String event, Function(dynamic) callback) {
    final s = socket;
    if (s == null) {
      final callbacks = _pendingListeners.putIfAbsent(
        event,
        () => <Function(dynamic)>[],
      );
      if (!callbacks.contains(callback)) callbacks.add(callback);
      debugPrint('⏳ SOCKET: queued listener => $event');
      ensureConnected();
      return;
    }

    debugPrint('👂 SOCKET LISTENER => $event');
    s.on(event, callback);

    // Replay cached online presence for screens that open after the event was
    // already emitted. This fixes the common missed-user:online race.
    if (event == 'user:online') {
      for (final userId in _onlineUsers) {
        scheduleMicrotask(() => callback({'userId': userId}));
      }
    }
  }

  void onAny(void Function(String event, dynamic data) callback) {
    socket?.onAny((event, data) => callback(event.toString(), data));
  }

  void offAny() => socket?.offAny();

  void off(String event) {
    // Kept for backwards compatibility, but screen code should use
    // offListener so it cannot remove another screen's listener.
    socket?.off(event);
  }

  void offListener(String event, dynamic callback) {
    _pendingListeners[event]?.remove(callback);
    if (_pendingListeners[event]?.isEmpty == true) {
      _pendingListeners.remove(event);
    }
    socket?.off(event, callback);
  }

  // ============================================================
  // DISCONNECT
  // ============================================================

  void disconnect() {
    _presenceHeartbeatTimer?.cancel();
    _presenceHeartbeatTimer = null;
    _manualReconnectTimer?.cancel();
    _manualReconnectTimer = null;
    _onlineUsers.clear();

    try {
      socket?.offAny();
      socket?.disconnect();
      socket?.dispose();
    } catch (_) {}

    socket = null;
    _pendingListeners.clear();
    _connectionCompleter = null;
    _connectingFuture = null;
  }
}
