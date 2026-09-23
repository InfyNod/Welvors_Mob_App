import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:velvors/main.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';
import 'package:velvors/welvors_home_screen/ui/network/no_internet_screen.dart';

/// Centralized service to monitor network connectivity throughout the Welvors app.
///
/// Automatically pushes [NoInternetScreen] when internet connection is lost or unstable,
/// and automatically pops it when the connection is restored, returning the user
/// to their previous screen.
class NetworkConnectivityService {
  NetworkConnectivityService._internal();

  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._internal();

  /// Singleton instance of [NetworkConnectivityService].
  static NetworkConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Holds the current connection state. True if connected with real internet, false otherwise.
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);

  /// Getter for public observation of connectivity changes.
  ValueNotifier<bool> get isConnected => isConnectedNotifier;

  bool _isNoInternetScreenOpen = false;
  bool _isChecking = false;
  Timer? _debounceTimer;

  /// Initializes the connectivity listener and performs the initial check.
  Future<void> initialize() async {
    AppLogger.i('NetworkConnectivityService', 'Initializing network connectivity service...');

    // Perform initial check
    await checkConnectivity(isInitial: true);

    // Cancel any previous stream
    await _subscription?.cancel();

    // Listen to device network changes
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChanged);
  }

  /// Handles network interface changes with a short debounce to avoid
  /// screen flickering during rapid network transitions (e.g. WiFi <-> Mobile).
  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final hasInterface = results.any((r) => r != ConnectivityResult.none);

      if (!hasInterface) {
        AppLogger.w('NetworkConnectivityService', 'No network interface detected.');
        _updateConnectionStatus(false);
      } else {
        // Physical interface exists; verify real internet reachability
        final hasInternet = await _hasRealInternetAccess();
        _updateConnectionStatus(hasInternet);
      }
    });
  }

  /// Actively checks for real internet reachability using DNS lookup with fallback.
  Future<bool> _hasRealInternetAccess() async {
    try {
      final results = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      if (results.isNotEmpty && results[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    // Fallback 1: Cloudflare DNS check via socket
    try {
      final socket = await Socket.connect(
        '1.1.1.1',
        53,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (_) {}

    // Fallback 2: Google DNS check via socket
    try {
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (_) {}

    return false;
  }

  /// Public method to trigger an immediate connectivity check (e.g. from Retry button).
  Future<bool> checkConnectivity({bool isInitial = false, bool manual = false}) async {
    if (_isChecking) return isConnectedNotifier.value;
    _isChecking = true;

    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasInterface =
          connectivityResults.any((r) => r != ConnectivityResult.none);

      if (!hasInterface) {
        if (!isInitial) {
          _updateConnectionStatus(false);
        }
        return false;
      }

      final hasInternet = await _hasRealInternetAccess();
      if (!isInitial || !hasInternet) {
        _updateConnectionStatus(hasInternet);
      }
      return hasInternet;
    } catch (e) {
      AppLogger.e('NetworkConnectivityService', 'Error checking connectivity: $e');
      if (!isInitial) {
        _updateConnectionStatus(false);
      }
      return false;
    } finally {
      _isChecking = false;
    }
  }

  /// Updates the internal status and manages push/pop of the NoInternetScreen.
  void _updateConnectionStatus(bool isConnected) {
    if (isConnectedNotifier.value == isConnected &&
        _isNoInternetScreenOpen == !isConnected) {
      return;
    }

    isConnectedNotifier.value = isConnected;

    if (!isConnected) {
      _showNoInternetScreen();
    } else {
      _dismissNoInternetScreen();
    }
  }

  /// Pushes the [NoInternetScreen] on top of the current screen.
  void _showNoInternetScreen() {
    if (_isNoInternetScreenOpen) return;

    final navState = navigatorKey.currentState;
    if (navState == null) {
      // Navigator is not mounted yet; schedule after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoInternetScreen();
      });
      return;
    }

    _isNoInternetScreenOpen = true;
    AppLogger.w('NetworkConnectivityService', 'Connection lost: Pushing NoInternetScreen');

    navState.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NoInternetScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        settings: const RouteSettings(name: '/no-internet'),
      ),
    ).then((_) {
      // In case the screen was closed externally
      _isNoInternetScreenOpen = false;
    });
  }

  /// Automatically pops the [NoInternetScreen] once the internet is restored.
  void _dismissNoInternetScreen() {
    if (!_isNoInternetScreenOpen) return;

    final navState = navigatorKey.currentState;
    if (navState != null && navState.canPop()) {
      AppLogger.i(
        'NetworkConnectivityService',
        'Connection restored: Dismissing NoInternetScreen and returning to previous screen',
      );
      _isNoInternetScreenOpen = false;
      navState.pop();
    } else {
      _isNoInternetScreenOpen = false;
    }
  }

  /// Disposes timers and listeners.
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    isConnectedNotifier.dispose();
  }
}
