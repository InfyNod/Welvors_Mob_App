import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/completion_image.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/video.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/about_you.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/your_intenshion.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_detail.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/location.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/who_you_seeing.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/prompts.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/lifestyle_card.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/education_career.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/family.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/intrested.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _selectedTab = 0; // 0 for Edit, 1 for Preview

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileEditCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Action for Done
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFFE43A6A), // Pink color
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            _buildToggle(),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedTab == 0 ? _buildEditBody() : _buildPreviewBody(),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 16,
              top: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Match scaffold background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // Save logic goes here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE43A6A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              alignment: _selectedTab == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _selectedTab == 0
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade600,
                        fontWeight: _selectedTab == 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _selectedTab == 1
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade600,
                        fontWeight: _selectedTab == 1
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: const Text('Preview'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder for Edit tab
  Widget _buildEditBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompletionAndPhotosSection(),
          const SizedBox(height: 32),
          const VideoSection(),
          const SizedBox(height: 32),
          const AboutYouSection(),
          const SizedBox(height: 32),
          const YourIntentionsSection(),
          const SizedBox(height: 32),
          const BasicDetailsSection(),
          const SizedBox(height: 32),
          const WhoYouAreSeeingSection(),
          const SizedBox(height: 32),
          const LifestyleSection(),
          const SizedBox(height: 32),
          const EducationCareerSection(),
          const SizedBox(height: 32),
          const FamilySection(),
          const SizedBox(height: 32),
          const InterestsSection(),
          const SizedBox(height: 32),
          const PromptsSection(),
          const SizedBox(height: 32),
          const LocationSection(),
          const SizedBox(height: 20), // Extra scrolling space for later
        ],
      ),
    );
  }

  // Placeholder for Preview tab
  Widget _buildPreviewBody() {
    return const Center(
      child: Text(
        'Preview Content Goes Here...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
