import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/home/home_screen.dart';
import 'package:velvors/welvors_home_screen/home_bloc/home_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';

// Mock HomeBloc to feed the current user's data to HomeScreen without changing its code!
class PreviewHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  PreviewHomeBloc(ProfileModel profile) : super(HomeLoaded(profiles: [profile])) {
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
            'https://images.unsplash.com/photo-1517365830460-955ce3ccd263?auto=format&fit=crop&w=800&q=80'
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
          job: state.profession.isNotEmpty ? state.profession : 'Your Profession',
          intent: state.intention.isNotEmpty ? state.intention : 'Your Intent',
          matchPercentage: '100% Match', // Preview dummy data
          trustPercentage: '100% Trust',
          replyTime: '~1m Replies',
          about: state.bio.isNotEmpty ? state.bio : 'Write something about yourself...',
          lookingFor:
              state.interestedIn.isNotEmpty ? state.interestedIn : 'Looking For',
          height: state.height.isNotEmpty ? state.height : 'Your Height',
          religion: state.religionCaste.isNotEmpty
              ? state.religionCaste
              : 'Your Religion',
          motherTongue: state.motherTongue.isNotEmpty
              ? state.motherTongue
              : 'Your Tongue',
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: BlocProvider<HomeBloc>(
            create: (_) => PreviewHomeBloc(profile),
            child: const HomeScreen(isPreview: true), // Re-use the exact same UI as Home Screen!
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
