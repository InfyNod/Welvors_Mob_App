import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'who_message.dart';
import 'blocked_users.dart';
import 'who_message.dart';
import 'mute_account.dart';
import '../../service_account_Setting.dart';

class PrivacyControlsScreen extends StatefulWidget {
  const PrivacyControlsScreen({super.key});

  @override
  State<PrivacyControlsScreen> createState() => _PrivacyControlsScreenState();
}

class _PrivacyControlsScreenState extends State<PrivacyControlsScreen> {
  bool hideFromContacts = false;
  bool ghostMode = false;
  String _messagePermissionValue = 'PAID_ONLY';
  int _blockedUsersCount = 0;
  int _mutedUsersCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyControls();
  }

  Future<void> _fetchPrivacyControls() async {
    final data = await AccountSettingService.getPrivacyControls();
    final blockedUsersList = await AccountSettingService.getBlockedUsers();
    final mutedUsersList = await AccountSettingService.getMutedUsers();
    
    if (mounted) {
      setState(() {
        if (data != null) {
          hideFromContacts = data['hideFromContacts'] ?? false;
          ghostMode = data['ghostMode'] ?? false;
          if (data['messagePermission'] != null && data['messagePermission']['value'] != null) {
            _messagePermissionValue = data['messagePermission']['value'];
          }
        }
        
        if (blockedUsersList != null) {
          _blockedUsersCount = blockedUsersList.length;
        }

        if (mutedUsersList != null) {
          _mutedUsersCount = mutedUsersList.length;
        }

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Light beige background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Privacy Controls',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CONTACT & MESSAGING
            _buildSectionTitle('CONTACT & MESSAGING'),
            const SizedBox(height: 12),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCardGroup(
              children: [
                _buildListItem(
                  emoji: '💬',
                  iconBgColor: const Color(0xFFE8F1FC),
                  title: 'Who can message me',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onTap: () {
                    String passedOption = 'paid';
                    if (_messagePermissionValue == 'MATCHES_ONLY') passedOption = 'matches';
                    else if (_messagePermissionValue == 'VERIFIED_ONLY') passedOption = 'verified';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WhoMessageScreen(initialOption: passedOption),
                      ),
                    ).then((_) {
                      _fetchPrivacyControls(); // Refresh when back
                    });
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  emoji: '👥',
                  iconBgColor: const Color(0xFFFCE8EE),
                  title: 'Hide from contacts',
                  subtitle: 'Don\'t show me to phone contacts',
                  trailing: CupertinoSwitch(
                    value: hideFromContacts,
                    onChanged: (val) async {
                      setState(() {
                        hideFromContacts = val;
                      });
                      final success = await AccountSettingService.updatePrivacyControls({
                        "hideFromContacts": val
                      });
                      if (!success && mounted) {
                        setState(() => hideFromContacts = !val);
                      }
                    },
                    activeColor: const Color(0xFFE43A6A),
                  ),
                ),
                _buildDivider(),
                _buildListItem(
                  emoji: '🙊',
                  iconBgColor: const Color.fromARGB(255, 239, 209, 240),
                  title: 'Ghost Mode',
                  subtitle: 'Browse without being seen',
                  trailing: CupertinoSwitch(
                    value: ghostMode,
                    onChanged: (val) async {
                      setState(() {
                        ghostMode = val;
                      });
                      final success = await AccountSettingService.updatePrivacyControls({
                        "ghostMode": val
                      });
                      if (!success && mounted) {
                        setState(() => ghostMode = !val);
                      }
                    },
                    activeColor: const Color(0xFFE43A6A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // SAFETY
            _buildSectionTitle('SAFETY'),
            const SizedBox(height: 12),
            _buildCardGroup(
              children: [
                _buildListItem(
                  emoji: '🚫',
                  iconBgColor: const Color.fromARGB(
                    255,
                    252,
                    232,
                    233,
                  ), // Light red
                  title: 'Blocked users',
                  subtitle: '$_blockedUsersCount people blocked',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlockedUsersScreen(),
                      ),
                    ).then((_) {
                      _fetchPrivacyControls(); // Refresh count when coming back
                    });
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  emoji: '🔕',
                  iconBgColor: const Color(0xFFFBF4E4), // Light yellow
                  title: 'Muted accounts',
                  subtitle: '$_mutedUsersCount muted',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MuteAccountScreen(),
                      ),
                    ).then((_) {
                      _fetchPrivacyControls(); // Refresh count when coming back
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Footer Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'When something is hidden, matches see a range or placeholder instead of your exact info.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildListItem({
    required String emoji,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }
    return content;
  }
}
