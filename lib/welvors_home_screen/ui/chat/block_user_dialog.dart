import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/main.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_repository.dart';
import 'package:velvors/welvors_home_screen/ui/chat/report_user_dialog.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class BlockUserDialog extends StatefulWidget {
  final String userName;
  final int userAge;
  final String userId;
  final Future<void> Function(String selectedOption)? onBlock;

  const BlockUserDialog({
    super.key,
    required this.userName,
    required this.userAge,
    required this.userId,
    this.onBlock,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  String? selectedOption;
  bool shouldReport = false;

  // ============================================================
  // Helper: open ReportUserDialog on the ROOT navigator.
  // Used both from "Block & report" flow and from the
  // "Also report her" flow after the success sheet.
  // Does NOT depend on this State's `mounted` flag because by the
  // time this runs, `BlockUserDialog` (Sheet A) has usually already
  // been popped and disposed.
  // ============================================================
  void _openReportDialog({required bool isBlocked}) {
    final rootContext = navigatorKey.currentContext;

    if (rootContext == null) {
      AppLogger.e('BlockUserDialog', '❌ rootContext is null, cannot open report sheet');
      return;
    }

    AppLogger.d('BlockUserDialog', '🟢 OPENING REPORT SHEET (isBlocked: $isBlocked)');

    showModalBottomSheet(
      context: rootContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (reportContext) {
        Widget child = ReportUserDialog(
          userName: widget.userName,
          userAge: widget.userAge,
          isBlocked: isBlocked,
          onSubmit: (reason, description, alsoBlock) async {
            try {
              final prefs = await SharedPreferences.getInstance();
              final reportedId = prefs.getString("reciverId")?.trim() ?? '';

              AppLogger.d('BlockUserDialog', '🚫 REPORT USER CLICKED');
              AppLogger.d('BlockUserDialog', '🚫 reportedId => $reportedId');
              AppLogger.d('BlockUserDialog', '🚫 reason => $reason');
              AppLogger.d('BlockUserDialog', '🚫 description => $description');
              AppLogger.d('BlockUserDialog', '🚫 alsoBlock => $alsoBlock');

              if (reportedId.isEmpty) {
                throw Exception('User ID is missing');
              }

              final repository = ChatRepository();

              // Block first if requested (matches original ordering
              // used in the "block_and_report" path).
              if (alsoBlock) {
                await repository.blockUser(reportedId);
                AppLogger.i('BlockUserDialog', '✅ USER BLOCK SUCCESS');
              }

              await repository.reportUser(
                reportedId: reportedId,
                reason: reason,
                description: description,
              );

              AppLogger.i('BlockUserDialog', '✅ USER REPORT SUCCESS');

              final ctx = navigatorKey.currentContext;
              if (ctx == null) return;

              Navigator.of(reportContext).pop();

              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('User reported successfully'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              AppLogger.e('BlockUserDialog', '❌ REPORT USER ERROR: $e');

              final errorMessage = e.toString().replaceFirst('Exception: ', '');

              // "already reported" isn't something retrying will fix —
              // close the sheet instead of leaving the user stuck on it.
              final isAlreadyReported = errorMessage.toLowerCase().contains(
                'already reported',
              );

              if (isAlreadyReported) {
                Navigator.of(reportContext).pop();
              }

              final ctx = navigatorKey.currentContext;
              if (ctx == null) return;

              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        );

        // Preserve the heightFactor behaviour that the
        // "Also report her" flow originally used.
        return FractionallySizedBox(heightFactor: 0.7, child: child);
      },
    );
  }

  Future<void> _confirmBlock() async {
    if (selectedOption == null) return;

    // Hit the real block API first. Only continue with the UI success state
    // when the API succeeds.
    try {
      await widget.onBlock?.call(selectedOption!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      return;
    }

    if (selectedOption == 'block_and_report') {
      // Close Sheet A (this dialog) first.
      Navigator.pop(context);

      // NOTE: we intentionally do NOT check `this.mounted` below —
      // this State is already disposed once we've popped it. We only
      // need the root navigator's context, which stays alive for the
      // app's lifetime.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openReportDialog(isBlocked: true);
      });
      return;
    }

    // 'block_only' path
    Navigator.pop(context);
    final shouldReport = await _showBlockSuccessDialog(selectedOption);

    AppLogger.d('BlockUserDialog', '🟢 shouldReport = $shouldReport');
  }

  Future<bool?> _showBlockSuccessDialog(String? selectedOption) {
    final rootContext = navigatorKey.currentContext!;

    return showModalBottomSheet<bool>(
      context: rootContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE6F4E6),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF70B97A),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.userName} is blocked',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'She can no longer contact you or see your profile. '
                  'Manage blocked people in Account Settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D7D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    AppLogger.d('BlockUserDialog', '🟢 ALSO REPORT HER CLICKED');
                    // Close current sheet and return true.
                    Navigator.of(sheetContext).pop(true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Also report her',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((onValue) async {
      AppLogger.i('BlockUserDialog', '🟢 BLOCK SUCCESS SHEET CLOSED');
      AppLogger.d('BlockUserDialog', '🟢 RESULT => $onValue');

      if (onValue == true) {
        // Small delay lets the previous sheet's closing animation
        // finish before we push the next one on the same navigator.
        await Future.delayed(const Duration(milliseconds: 250));

        // IMPORTANT: no `this.mounted` check here — this State is
        // long disposed by this point (Sheet A was popped earlier).
        // We only rely on the root navigator being alive.
        _openReportDialog(isBlocked: false);
      }

      return onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Block ${widget.userName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose what happens after you block her.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Mycolor.pinkffeef2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Blocking: ${widget.userName}, ${widget.userAge} · she\'s never told',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE85D7D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'How do you want to block? *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOption = 'block_only';
                        });
                      },
                      child: _buildBlockOption(
                        'Block only',
                        'She can\'t message you, see your profile, or match with you again. No report is filed.',
                        'block_only',
                        Icons.cancel_outlined,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOption = 'block_and_report';
                        });
                      },
                      child: _buildBlockOption(
                        'Block & report',
                        'Blocks her and sends her profile to our safety team. Use this if she broke a rule — it protects others too.',
                        'block_and_report',
                        Icons.warning_outlined,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Note:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can unblock her anytime from Account Settings → Blocked people.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedOption == null ? null : _confirmBlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D7D),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Block ${widget.userName}',
                      style: TextStyle(
                        color: selectedOption == null
                            ? Colors.grey[600]
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockOption(
    String title,
    String description,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = selectedOption == value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFFE85D7D) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFFE85D7D) : Colors.grey[400]!,
                width: 2,
              ),
              color: isSelected ? const Color(0xFFE85D7D) : Colors.transparent,
            ),
            child: isSelected
                ? const Center(
                    child: Icon(Icons.check, size: 12, color: Colors.white),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
