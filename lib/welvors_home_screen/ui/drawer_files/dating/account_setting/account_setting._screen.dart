import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../edit_profile/bloc/profile_edit_cubit.dart';
import '../edit_profile/bloc/profile_edit_state.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  bool _emailNotifications = true;

  int _calculateAge(String dobString) {
    try {
      final parts = dobString.split(' / ');
      if (parts.length == 3) {
        int year = int.parse(parts[2]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[0]);
        final selectedDate = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - selectedDate.year;
        if (now.month < selectedDate.month ||
            (now.month == selectedDate.month && now.day < selectedDate.day)) {
          age--;
        }
        return age;
      }
    } catch (e) {}
    return 26; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Profile Card
          BlocBuilder<ProfileEditCubit, ProfileEditState>(
            builder: (context, state) {
              final name = state.fullName.isNotEmpty ? state.fullName : 'Welvors User';
              final age = _calculateAge(state.dob);
              final email = state.email.isNotEmpty ? state.email : 'user@gmail.com';
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFE4A99B), Color(0xFFA66657)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name, $age',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$email • +91 ••••• 43210',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F6EF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '✓ Verified • Level 3',
                              style: TextStyle(
                                color: Color(0xFF299955),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('ACCOUNT'),
          _buildCard(
            children: [
              _buildListItem(
                iconWidget: const Icon(Icons.person, color: Color(0xFF4A89DC)),
                iconBgColor: const Color(0xFFE6F0FA),
                title: 'Personal Information',
                subtitle: 'Name, email, phone, date of birth',
              ),
              const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF0F0F0)),
              _buildListItem(
                iconWidget: const Text('💎', style: TextStyle(fontSize: 18)),
                iconBgColor: const Color(0xFFE6F9FA),
                title: 'Membership Plan',
                subtitle: 'VIP • renews 12 Aug 2026',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('PAYMENTS & PAYOUTS'),
          _buildCard(
            children: [
              _buildListItem(
                iconWidget: const Text('🏦', style: TextStyle(fontSize: 18)),
                iconBgColor: const Color(0xFFE6FAE6),
                title: 'Bank & UPI',
                subtitle: '1 bank • 2 UPI IDs',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('PRIVACY'),
          _buildCard(
            children: [
              _buildListItem(
                iconWidget: const Text('🔒', style: TextStyle(fontSize: 18)),
                iconBgColor: const Color(0xFFF9F5E6),
                title: 'Privacy Controls',
                subtitle: 'Visibility, contacts, blocked users',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('NOTIFICATIONS'),
          _buildCard(
            children: [
              _buildListItem(
                iconWidget: const Text('🔔', style: TextStyle(fontSize: 18)),
                iconBgColor: const Color(0xFFFDF6E3),
                title: 'Push Notifications',
                subtitle: 'Matches, messages, likes',
              ),
              const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF0F0F0)),
              _buildListItem(
                iconWidget: const Text('✉️', style: TextStyle(fontSize: 18)),
                iconBgColor: const Color(0xFFEEF2F6),
                title: 'Email Notifications',
                isToggle: true,
                toggleValue: _emailNotifications,
                onToggle: (val) {
                  setState(() => _emailNotifications = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('DANGER ZONE'),
          _buildCard(
            children: [
              _buildListItem(
                iconWidget: const Icon(Icons.delete_outline, color: Color(0xFFE43A6A)),
                iconBgColor: const Color(0xFFFDF0F3),
                title: 'Delete Account',
                subtitle: 'Permanently remove your account and data',
                isDanger: true,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListItem({
    required Widget iconWidget,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    bool isToggle = false,
    bool toggleValue = false,
    Function(bool)? onToggle,
    bool isDanger = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: iconWidget,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDanger ? const Color(0xFFE43A6A) : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            )
          : null,
      trailing: isToggle
          ? CupertinoSwitch(
              value: toggleValue,
              activeColor: const Color(0xFFE43A6A),
              onChanged: onToggle,
            )
          : const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
      onTap: isToggle ? null : () {},
    );
  }
}
