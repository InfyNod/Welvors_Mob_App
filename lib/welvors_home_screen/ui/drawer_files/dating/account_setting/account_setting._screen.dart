import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../edit_profile/bloc/profile_edit_cubit.dart';
import '../edit_profile/bloc/profile_edit_state.dart';
import 'account_pages/personal_info.dart';
import 'account_pages/membership_plan/membership_plan.dart';
import 'account_pages/bank_upi.dart';
import 'account_pages/privacy_controls/privacy_controls_screen.dart';
import 'account_pages/push_notification.dart';
import 'account_pages/pause_delete_drawer.dart';
import 'account_pages/pause_delete_drawer.dart';
import '../edit_profile/bloc/profile_edit_state.dart';
import 'service_account_Setting.dart';
import '../edit_profile/services/edit_profile_api_service.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  bool _emailNotifications = true;
  int _bankCount = 0;
  int _upiCount = 0;
  bool _isAccountPaused = false;

  String _apiPhone = '+91 ••••• 43210';

  @override
  void initState() {
    super.initState();
    _fetchCounts();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    try {
      final response = await EditProfileApiService.getProfileDetails();
      if (response['error'] == null && response['data'] != null) {
        final data = response['data'];
        final basicDetails = data['basicDetails'] ?? {};
        
        String rawPhone = basicDetails['phoneNumber']?.toString() ?? data['phoneNumber']?.toString() ?? basicDetails['phone']?.toString() ?? '';
        
        if (rawPhone.isNotEmpty) {
          String phone = rawPhone.replaceAll(RegExp(r'\D'), '');
          if (phone.length > 10) {
            phone = phone.substring(phone.length - 10);
          }
          if (phone.isNotEmpty && mounted) {
            setState(() {
              _apiPhone = '+91 $phone';
              // Check if account is paused
              _isAccountPaused = data['isPaused'] == true || 
                                 data['accountStatus'] == 'PAUSED' || 
                                 data['accountStatus'] == 'paused' ||
                                 data['account_status'] == 'PAUSED' ||
                                 data['account_status'] == 'paused' ||
                                 data['paused_at'] != null;
            });
          }
        } else if (mounted) {
          setState(() {
             _isAccountPaused = data['isPaused'] == true || 
                                data['accountStatus'] == 'PAUSED' || 
                                data['accountStatus'] == 'paused' ||
                                data['account_status'] == 'PAUSED' ||
                                data['account_status'] == 'paused' ||
                                data['paused_at'] != null;
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchCounts() async {
    final data = await AccountSettingService.getBankAndUpi();
    if (data != null && data['success'] == true && data['data'] != null && mounted) {
      final dataObj = data['data'];
      final banks = List<Map<String, dynamic>>.from(dataObj['bankAccounts'] ?? []);
      final upis = List<Map<String, dynamic>>.from(dataObj['upiIds'] ?? []);
      
      setState(() {
        _bankCount = banks.length;
        _upiCount = upis.length;
      });
    }
  }

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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
          'Account Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Profile Card
          BlocBuilder<ProfileEditCubit, ProfileEditState>(
            builder: (context, state) {
              final name = state.fullName.isNotEmpty
                  ? state.fullName
                  : 'Welvors User';
              final age = _calculateAge(state.dob);
              final email = state.email.isNotEmpty
                  ? state.email
                  : 'user@gmail.com';

              final firstPhoto = state.photos.isNotEmpty
                  ? state.photos.first
                  : null;
              final hasPhoto = firstPhoto != null && !firstPhoto.isEmpty;
              ImageProvider? imageProvider;
              if (hasPhoto) {
                if (firstPhoto.isNetwork) {
                  imageProvider = NetworkImage(firstPhoto.url!);
                } else if (firstPhoto.isLocal) {
                  imageProvider = FileImage(File(firstPhoto.localFile!.path));
                }
              }

              return Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasPhoto
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFE4A99B), Color(0xFFA66657)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        image: hasPhoto && imageProvider != null
                            ? DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
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
                            '$email • $_apiPhone',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
            },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen(),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                indent: 60,
                endIndent: 20,
                color: Color(0xFFF0F0F0),
              ),
              _buildListItem(
                iconWidget: const Text('💎', style: TextStyle(fontSize: 18)),
                iconBgColor: const Color(0xFFE6F9FA),
                title: 'Membership Plan',
                subtitle: 'VIP • renews 12 Aug 2026',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MembershipPlanScreen(),
                    ),
                  );
                },
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
                subtitle: '$_bankCount bank • $_upiCount UPI IDs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankUpiScreen(),
                    ),
                  ).then((_) {
                    _fetchCounts();
                  });
                },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyControlsScreen(),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PushNotificationScreen(),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                indent: 60,
                endIndent: 20,
                color: Color(0xFFF0F0F0),
              ),
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
                iconWidget: Text(_isAccountPaused ? '▶️' : '⏸️', style: const TextStyle(fontSize: 18)),
                iconBgColor: _isAccountPaused ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                title: _isAccountPaused ? 'Resume Account' : 'Pause Account',
                subtitle: _isAccountPaused ? 'Make your profile visible again' : 'Hide your profile temporarily',
                onTap: () async {
                  if (_isAccountPaused) {
                    final result = await showResumeAccountBottomSheet(context);
                    if (result == true) {
                      setState(() => _isAccountPaused = false);
                    }
                  } else {
                    final result = await showPauseAccountBottomSheet(context);
                    if (result == true) {
                      setState(() => _isAccountPaused = true);
                    }
                  }
                },
              ),
              const Divider(
                height: 1,
                indent: 60,
                endIndent: 20,
                color: Color(0xFFF0F0F0),
              ),
              _buildListItem(
                iconWidget: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE43A6A),
                ),
                iconBgColor: const Color(0xFFFDF0F3), // Light Red
                title: 'Delete Account',
                subtitle: 'Permanently erase everything',
                isDanger: true,
                onTap: () => showDeleteAccountBottomSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Footer Text
          Center(
            child: Text(
              'Welvors v3.2.1 • Terms • Privacy Policy',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
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

  Widget _buildListItem({
    required Widget iconWidget,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    bool isToggle = false,
    bool toggleValue = false,
    Function(bool)? onToggle,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isToggle ? null : (onTap ?? () {}),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDanger
                          ? const Color(0xFFE43A6A)
                          : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            isToggle
                ? CupertinoSwitch(
                    value: toggleValue,
                    activeColor: const Color(0xFFE43A6A),
                    onChanged: onToggle,
                  )
                : Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade300,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }
}
