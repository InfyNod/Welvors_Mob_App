import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final List<ProfileModel> _dummyProfiles = [
    const ProfileModel(
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      name: 'Shraddha',
      age: 21,
      location: 'Pune • 7 km away',
      job: "Fashion Designer • 5'4\"",
      intent: 'Serious relationship',
      matchPercentage: '74% Match',
      trustPercentage: '98% Trust',
      replyTime: '~5m Reply',
    ),
    const ProfileModel(
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      name: 'Priya',
      age: 23,
      location: 'Mumbai • 15 km away',
      job: "Software Engineer • 5'6\"",
      intent: 'Casual dating',
      matchPercentage: '85% Match',
      trustPercentage: '90% Trust',
      replyTime: '~2m Reply',
    ),
    const ProfileModel(
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
      name: 'Ananya',
      age: 25,
      location: 'Delhi • 10 km away',
      job: "Architect • 5'7\"",
      intent: 'Serious relationship',
      matchPercentage: '92% Match',
      trustPercentage: '99% Trust',
      replyTime: '~1m Reply',
    ),
  ];

  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeDataEvent>((event, emit) {
      emit(HomeLoaded(profiles: List.from(_dummyProfiles)));
    });

    on<SwipeProfileEvent>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        if (currentState.profiles.isNotEmpty) {
          final updatedProfiles = List<ProfileModel>.from(currentState.profiles)..removeAt(0);
          if (updatedProfiles.isEmpty) {
            emit(HomeEmpty());
          } else {
            emit(HomeLoaded(profiles: updatedProfiles));
          }
        }
      }
    });
  }
}
