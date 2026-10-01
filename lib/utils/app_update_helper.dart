import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvors/utils/app_update_screen.dart';

/// Helper class for managing App Updates using the `upgrader` package.
///
/// Features:
/// - Automatically detects when a new version is published to Google Play Store.
/// - Shows a beautifully designed Welvors update dialog.
/// - Supports both optional and mandatory (force) updates.
/// - One-line integration in `MaterialApp.builder` or screens.
class AppUpdateHelper {
  AppUpdateHelper._();

  /// Default package name / applicationId for Welvors on Google Play Store
  static const String defaultPackageName = 'com.infynod.welvors';

  /// Shared Upgrader instance configured for Welvors
  static final Upgrader upgrader = Upgrader(
    // debugDisplayAlways: true,
    debugLogging: kDebugMode,
    durationUntilAlertAgain: const Duration(hours: 4),
  );

  /// Current installed version of the app
  static String? get currentInstalledVersion => upgrader.currentInstalledVersion;

  /// Latest version available in app store
  static String? get currentAppStoreVersion => upgrader.currentAppStoreVersion;

  /// Latest release notes from store
  static String? get releaseNotes => upgrader.releaseNotes;

  /// Initializes the upgrader instance
  static Future<void> init() async {
    try {
      await upgrader.initialize();
    } catch (e) {
      debugPrint('AppUpdateHelper init error: $e');
    }
  }

  /// Wraps any widget or app with the Welvors Upgrade Alert listener.
  /// Place this in your `MaterialApp.builder` or root screen.
  static Widget wrapWithUpdateAlert({
    required Widget child,
    GlobalKey<NavigatorState>? navigatorKey,
    bool isForceUpdate = false,
  }) {
    return WelvorsUpgradeAlert(
      upgrader: upgrader,
      navigatorKey: navigatorKey,
      isForceUpdate: isForceUpdate,
      child: child,
    );
  }

  /// Manually launches Google Play Store page for the app
  static Future<void> openPlayStore({String packageName = defaultPackageName}) async {
    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error opening Play Store: $e');
    }
  }

  /// Shows the custom update dialog directly.
  /// Useful for testing UI or triggering manual checks from Settings/Profile.
  static Future<void> showUpdateDialog({
    required BuildContext context,
    String? currentVersion,
    String? latestVersion,
    String? releaseNotes,
    bool isForceUpdate = false,
  }) {
    final installed = currentVersion ?? upgrader.currentInstalledVersion ?? '1.0.0';
    final storeVer = latestVersion ?? upgrader.currentAppStoreVersion ?? '1.0.1';

    return showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (dialogContext) {
        return PopScope(
          canPop: !isForceUpdate,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: AppUpdateContent(
              currentVersion: installed,
              latestVersion: storeVer,
              releaseNotes: releaseNotes ?? upgrader.releaseNotes,
              isForceUpdate: isForceUpdate,
              isDialog: true,
              onUpdate: () async {
                if (!isForceUpdate) {
                  Navigator.of(dialogContext).pop();
                }
                await openPlayStore();
              },
              onLater: isForceUpdate
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
            ),
          ),
        );
      },
    );
  }
}

/// Custom UpgradeAlert widget that presents Welvors branded update screen/dialog
class WelvorsUpgradeAlert extends UpgradeAlert {
  final bool isForceUpdate;

  WelvorsUpgradeAlert({
    super.key,
    super.upgrader,
    super.navigatorKey,
    this.isForceUpdate = false,
    super.child,
  }) : super(
          barrierDismissible: !isForceUpdate,
          dialogStyle: UpgradeDialogStyle.material,
        );

  @override
  WelvorsUpgradeAlertState createState() => WelvorsUpgradeAlertState();
}

class WelvorsUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    if (!context.mounted) return;

    final isBlocked = (widget as WelvorsUpgradeAlert).isForceUpdate || widget.upgrader.blocked();
    final effectiveBarrierDismissible = isBlocked ? false : barrierDismissible;
    final currentVersion = widget.upgrader.currentInstalledVersion ?? '1.0.0';
    final latestVersion = widget.upgrader.currentAppStoreVersion ?? '';

    // Mark as alerted
    widget.upgrader.saveLastAlerted();

    showDialog(
      context: context,
      barrierDismissible: effectiveBarrierDismissible,
      builder: (dialogContext) {
        return PopScope(
          canPop: !isBlocked,
          child: Dialog(
            key: key,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: AppUpdateContent(
              currentVersion: currentVersion,
              latestVersion: latestVersion,
              releaseNotes: releaseNotes ?? widget.upgrader.releaseNotes,
              isForceUpdate: isBlocked,
              isDialog: true,
              onUpdate: () {
                onUserUpdated(dialogContext, !isBlocked);
                // Also trigger direct store launch if upgrader didn't open
                AppUpdateHelper.openPlayStore();
              },
              onLater: isBlocked ? null : () => onUserLater(dialogContext, true),
            ),
          ),
        );
      },
    );
  }
}
