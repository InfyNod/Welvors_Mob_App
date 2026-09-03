import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../onbording_allpage/theme/app_colors.dart';
import '../../../../../../onbording_allpage/theme/app_text.dart';
import '../../../../../../onbording_allpage/widgets/primary_button.dart';
import '../edit_profile/bloc/profile_edit_cubit.dart';
import '../edit_profile/bloc/profile_edit_state.dart';

import 'splash_logout.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashLogout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
        title: Text('Log out', style: AppText.h2.copyWith(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lottie Animation
              Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: Lottie.asset(
                    'assets/logout.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                'Log out of Welvors?',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(fontSize: 24, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "You'll need your number and a one-time code to get back in.",
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Profile Card
              // BlocBuilder<ProfileEditCubit, ProfileEditState>(
              //   builder: (context, state) {
              //     final String name = state.fullName.isNotEmpty
              //         ? state.fullName.split(' ').first
              //         : 'Welvors User';

              //     // Construct location string
              //     final List<String> locParts = [];
              //     if (state.city.isNotEmpty) locParts.add(state.city);
              //     if (state.stateLocation.isNotEmpty)
              //       locParts.add(state.stateLocation);
              //     final String location = locParts.isEmpty
              //         ? 'India'
              //         : locParts.join(', ');

              //     final String subtitle = '$location · Platinum Member';

              //     final photo = state.photos.firstWhere(
              //       (p) => p != null,
              //       orElse: () => null,
              //     );

              //     return Container(
              //       padding: const EdgeInsets.all(12),
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(16),
              //         boxShadow: AppColors.shadow,
              //       ),
              //       child: Row(
              //         children: [
              //           // Profile Avatar
              //           Container(
              //             width: 48,
              //             height: 48,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               color: AppColors.soft,
              //               image:
              //                   photo != null && photo.url?.isNotEmpty == true
              //                   ? DecorationImage(
              //                       image: NetworkImage(photo.url!),
              //                       fit: BoxFit.cover,
              //                     )
              //                   : null,
              //             ),
              //             child: (photo == null || (photo.url?.isEmpty ?? true))
              //                 ? const Icon(Icons.person, color: AppColors.muted)
              //                 : null,
              //           ),
              //           const SizedBox(width: 12),

              //           // Name & Subtitle
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   name,
              //                   style: AppText.h2.copyWith(fontSize: 16),
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //                 const SizedBox(height: 2),
              //                 Text(
              //                   subtitle,
              //                   style: AppText.sub.copyWith(
              //                     fontSize: 11,
              //                     color: AppColors.muted,
              //                   ),
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ],
              //             ),
              //           ),

              //           // THIS DEVICE badge
              //           Container(
              //             padding: const EdgeInsets.symmetric(
              //               horizontal: 8,
              //               vertical: 4,
              //             ),
              //             decoration: BoxDecoration(
              //               color: AppColors.pinkSoft,
              //               borderRadius: BorderRadius.circular(100),
              //             ),
              //             child: Text(
              //               'THIS DEVICE',
              //               style: AppText.eyebrow.copyWith(
              //                 color: AppColors.pinkDeep,
              //                 fontSize: 9,
              //                 letterSpacing: 0.5,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     );
              //   },
              // ),
              const SizedBox(height: 10),

              // WHAT STAYS SAFE
              Text(
                'WHAT STAYS SAFE',
                style: AppText.eyebrow.copyWith(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),

              // Info List Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.shadow,
                ),
                child: Column(
                  children: [
                    _buildInfoItem(
                      icon: Icons.check,
                      iconColor: AppColors.green,
                      iconBgColor: AppColors.greenSoft,
                      title: 'Matches & chats',
                      subtitle: 'Every conversation stays exactly where it is',
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      icon: Icons.check,
                      iconColor: AppColors.green,
                      iconBgColor: AppColors.greenSoft,
                      title: 'Wallet & plan',
                      subtitle: '₹3,240 and your plan stay active',
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      icon: Icons.check,
                      iconColor: AppColors.green,
                      iconBgColor: AppColors.greenSoft,
                      title: 'Bookings & plans',
                      subtitle: 'Event tickets and date plans unaffected',
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      icon: Icons.priority_high, // Close enough to the alert !
                      iconColor: AppColors.gold,
                      iconBgColor: const Color(0xFFFFF6E5),
                      title: 'Notifications pause',
                      subtitle: "You won't get match or message alerts",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Device info block
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: AppColors.soft,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Padding(
              //         padding: EdgeInsets.only(top: 2),
              //         child: Icon(
              //           Icons.phone_iphone,
              //           size: 14,
              //           color: AppColors.ink60,
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       // Expanded(
              //       //   child: Text(
              //       //     'This device · last active just now\nOther signed-in devices stay logged in.',
              //       //     style: AppText.sub.copyWith(
              //       //       fontSize: 12,
              //       //       color: AppColors.ink60,
              //       //       height: 1.4,
              //       //     ),
              //       //   ),
              //       // ),
              //     ],
              //   ),
              //),
              // End of scrollable content
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            // border: Border(top: BorderSide(color: AppColors.line, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                'Log out of this device',
                onTap: () => _handleLogout(context),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    'Stay logged in',
                    style: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppText.sub.copyWith(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56.0),
      child: Container(height: 1, color: AppColors.line.withOpacity(0.5)),
    );
  }
}
