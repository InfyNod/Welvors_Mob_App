import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/home/home_screen.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'package:velvors/welvors_home_screen/home_bloc/home_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';

// Mock HomeBloc to feed the current user's data to HomeScreen without changing its code!
class PreviewHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  PreviewHomeBloc(ProfileModel profile)
    : super(HomeLoaded(profiles: [profile])) {
    on<HomeEvent>((event, emit) {
      // Whenever it tries to swipe or refresh, we just give back the same profile
      // so the preview stays on the screen.
      emit(HomeLoaded(profiles: [profile]));
    });
  }
}

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        // Convert current EditProfile state to a ProfileModel for the home screen
        List<String> images = state.photos
            .where((p) => p != null)
            .map((p) => p!.path)
            .toList();

        if (images.isEmpty) {
          images = [
            'https://images.unsplash.com/photo-1517365830460-955ce3ccd263?auto=format&fit=crop&w=800&q=80',
          ]; // Fallback placeholder
        }

        final profile = ProfileModel(
          images: images,
          videoUrl: state.videoPath,
          name: state.fullName.isNotEmpty ? state.fullName : 'Your Name',
          age: _calculateAge(state.dob),
          location: state.area.isNotEmpty
              ? '${state.area}, ${state.city}'
              : 'Your Location',
          job: state.profession.isNotEmpty
              ? state.profession
              : 'Your Profession',
          intent: state.intention.isNotEmpty ? state.intention : 'Your Intent',
          matchPercentage: '100% Match', // Preview dummy data
          trustPercentage: '100% Trust',
          replyTime: '~1m Replies',
          about: state.bio.isNotEmpty
              ? state.bio
              : 'Write something about yourself...',
          lookingFor: state.interestedIn.isNotEmpty
              ? state.interestedIn
              : 'Looking For',
          height: state.height.isNotEmpty ? state.height : 'Your Height',
          religion: state.religionCaste.isNotEmpty
              ? state.religionCaste
              : 'Your Religion',
          motherTongue: state.motherTongue.isNotEmpty
              ? state.motherTongue
              : 'Your Tongue',
        );

        final phoneFrame = Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Power Button (Right)
                  Positioned(
                    right: 0,
                    top: 250,
                    child: Container(
                      width: 4,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3C), // Dark graphite button
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Volume Up (Left)
                  Positioned(
                    left: 0,
                    top: 200,
                    child: Container(
                      width: 4,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Volume Down (Left)
                  Positioned(
                    left: 0,
                    top: 280,
                    child: Container(
                      width: 4,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // The Phone Body
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ), // Space for buttons
                    width: 430,
                    height: 844,
                    padding: const EdgeInsets.all(12), // Bezel thickness
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E), // Dark Graphite Bezel
                      borderRadius: BorderRadius.circular(56),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                          offset: const Offset(0, 20),
                        ),
                        // Inner highlights for 3D casing effect
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(-2, -2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black, // Screen black border
                        borderRadius: BorderRadius.circular(44),
                        border: Border.all(
                          color: Colors.black,
                          width: 6,
                        ), // Screen bezel
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          38,
                        ), // Inner screen corners
                        child: Stack(
                          children: [
                            // Simulated MediaQuery for the app content
                            MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                size: const Size(430, 844),
                                padding: const EdgeInsets.only(
                                  top: 59,
                                  bottom: 34,
                                ), // iPhone 14 Pro Max safe area
                                viewPadding: const EdgeInsets.only(
                                  top: 59,
                                  bottom: 34,
                                ),
                                viewInsets: EdgeInsets.zero,
                              ),
                              child: const TopAndBottomNavScreen(
                                isPreview: true,
                              ),
                            ),

                            // Simulated iPhone Hardware/Status Bar overlay
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Stack(
                                      children: [
                                        // Time
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '9:30',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ),
                                        // Detailed Dynamic Island
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // Simulated Camera Lens reflection
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 12,
                                                  ),
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF141414,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.blueAccent
                                                          .withOpacity(0.15),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Icons
                                        const Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.signal_cellular_4_bar,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.wifi,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.battery_full,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Home Indicator at bottom
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: IgnorePointer(
                                  child: Container(
                                    width: 134,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return Scaffold(
          backgroundColor: const Color(
            0xFFF3F4F6,
          ), // Soft grey background outside the phone
          body: SafeArea(
            child: BlocProvider<HomeBloc>(
              create: (_) => PreviewHomeBloc(profile),
              child:
                  phoneFrame, // Re-use the exact same UI inside the phone frame!
            ),
          ),
        );
      },
    );
  }

  int _calculateAge(String dob) {
    if (dob.isEmpty) return 25; // default fallback
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        final year = int.parse(parts[2]);
        return DateTime.now().year - year;
      }
    } catch (_) {}
    return 25;
  }
}
