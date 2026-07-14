import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final List<ProfileModel> _dummyProfiles = [
    const ProfileModel(
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      name: 'Shraddha',
      age: 21,
      location: 'Pune, Maharashtra',
      job: "Fashion Designer",
      intent: 'Serious relationship',
      matchPercentage: '92% Match',
      trustPercentage: '98% Trust',
      replyTime: '~5m Replies',
      about:
          'Building products by day, planning my next trek by night. Looking for someone equally driven and equally curious.',
      lookingFor: 'Long-term, marriage-open',
      height: '5\'5" • 165 cm',
      religion: 'Hindu • Marathi',
      motherTongue: 'Marathi',
    ),
    const ProfileModel(
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      name: 'Priya',
      age: 23,
      location: 'Mumbai, Maharashtra',
      job: "Software Engineer",
      intent: 'Casual dating',
      matchPercentage: '85% Match',
      trustPercentage: '90% Trust',
      replyTime: '~2m Replies',
      about:
          'Coffee addict and weekend painter. Always down for a late-night drive.',
      lookingFor: 'Short-term, open to long',
      height: '5\'6" • 167 cm',
      religion: 'Hindu • Gujarati',
      motherTongue: 'Gujarati',
    ),
    const ProfileModel(
      imageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
      name: 'Ananya',
      age: 25,
      location: 'Delhi, India',
      job: "Architect",
      intent: 'Serious relationship',
      matchPercentage: '95% Match',
      trustPercentage: '99% Trust',
      replyTime: '~1m Replies',
      about:
          'Designing spaces and chasing sunsets. Let\'s explore the city together.',
      lookingFor: 'Life partner',
      height: '5\'7" • 170 cm',
      religion: 'Hindu • Punjabi',
      motherTongue: 'Punjabi',
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
          final updatedProfiles = List<ProfileModel>.from(currentState.profiles)
            ..removeAt(0);
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
