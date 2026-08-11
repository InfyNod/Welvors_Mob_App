import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../services/home_api_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final List<ProfileModel> _swipedProfiles = [];
  bool _isLoadingMore = false;

  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<SwipeProfileEvent>(_onSwipeProfile);
    on<UndoSwipeEvent>(_onUndoSwipe);
    on<FetchProfileDetailsEvent>(_onFetchProfileDetails);
  }

  Future<void> _onLoadHomeData(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    if (event.isRefresh) {
      _swipedProfiles.clear();
      _isLoadingMore = false;
      emit(const HomeLoading());
    } else if (state is HomeInitial) {
      emit(const HomeLoading());
    }

    String? currentCursor;
    List<ProfileModel> currentProfiles = [];
    
    if (state is HomeLoaded && !event.isRefresh) {
      currentProfiles = (state as HomeLoaded).profiles;
      currentCursor = (state as HomeLoaded).cursor;
    }

    final response = await HomeApiService.fetchFeed(limit: 10, cursor: currentCursor);
    
    if (response != null && response['users'] != null) {
      final List<dynamic> usersJson = response['users'];
      final String? nextCursor = response['nextCursor'];
      
      final List<ProfileModel> newProfiles = usersJson.map((json) => ProfileModel.fromFeedJson(json)).toList();
      
      final updatedProfiles = [...currentProfiles, ...newProfiles];
      
      if (updatedProfiles.isEmpty) {
        emit(HomeEmpty(remainingSwipes: state.remainingSwipes, cursor: nextCursor));
      } else {
        emit(HomeLoaded(
          profiles: updatedProfiles,
          remainingSwipes: state.remainingSwipes,
          cursor: nextCursor,
        ));
        
        // Auto-fetch details for the first few profiles if not loaded
        for (int i = 0; i < updatedProfiles.length && i < 3; i++) {
          if (!updatedProfiles[i].detailsLoaded) {
            add(FetchProfileDetailsEvent(updatedProfiles[i].id));
          }
        }
      }
    } else {
      if (currentProfiles.isEmpty) {
        emit(HomeEmpty(remainingSwipes: state.remainingSwipes, cursor: currentCursor));
      } else {
        emit(HomeLoaded(
          profiles: currentProfiles,
          remainingSwipes: state.remainingSwipes,
          cursor: currentCursor,
        ));
      }
    }
    _isLoadingMore = false;
  }

  Future<void> _onSwipeProfile(SwipeProfileEvent event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (currentState.profiles.isNotEmpty) {
        _swipedProfiles.add(currentState.profiles.first);
        
        final updatedProfiles = List<ProfileModel>.from(currentState.profiles)..removeAt(0);
        final newSwipes = currentState.remainingSwipes > 0 ? currentState.remainingSwipes - 1 : 0;
        
        if (updatedProfiles.isEmpty) {
          emit(HomeEmpty(remainingSwipes: newSwipes, cursor: currentState.cursor));
          if (!_isLoadingMore && currentState.cursor != null) {
            _isLoadingMore = true;
            add(const LoadHomeDataEvent());
          }
        } else {
          emit(HomeLoaded(profiles: updatedProfiles, remainingSwipes: newSwipes, cursor: currentState.cursor));
          
          // Auto-fetch details for the new top profiles
          for (int i = 0; i < updatedProfiles.length && i < 3; i++) {
            if (!updatedProfiles[i].detailsLoaded) {
              add(FetchProfileDetailsEvent(updatedProfiles[i].id));
            }
          }

          // Pre-fetch if running low (e.g. 4 profiles left)
          if (updatedProfiles.length <= 4 && !_isLoadingMore && currentState.cursor != null) {
            _isLoadingMore = true;
            add(const LoadHomeDataEvent());
          }
        }
      }
    }
  }

  void _onUndoSwipe(UndoSwipeEvent event, Emitter<HomeState> emit) {
    if (_swipedProfiles.isNotEmpty) {
      final lastSwiped = _swipedProfiles.removeLast();
      final newSwipes = state.remainingSwipes < 25 ? state.remainingSwipes + 1 : 25;
      
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final updatedProfiles = [lastSwiped, ...currentState.profiles];
        emit(HomeLoaded(profiles: updatedProfiles, remainingSwipes: newSwipes, cursor: currentState.cursor));
        
        if (!lastSwiped.detailsLoaded) {
          add(FetchProfileDetailsEvent(lastSwiped.id));
        }
      } else if (state is HomeEmpty) {
        final currentState = state as HomeEmpty;
        emit(HomeLoaded(profiles: [lastSwiped], remainingSwipes: newSwipes, cursor: currentState.cursor));
        
        if (!lastSwiped.detailsLoaded) {
          add(FetchProfileDetailsEvent(lastSwiped.id));
        }
      }
    }
  }

  Future<void> _onFetchProfileDetails(FetchProfileDetailsEvent event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      final profileIndex = currentState.profiles.indexWhere((p) => p.id == event.userId);
      if (profileIndex != -1) {
        final profile = currentState.profiles[profileIndex];
        
        // Don't fetch if already loaded
        if (profile.detailsLoaded) return;
        
        final detailsResponse = await HomeApiService.fetchUserDetails(event.userId);
        
        if (detailsResponse != null) {
          // Refetch state after await to prevent race conditions from concurrent prefetching
          if (state is HomeLoaded) {
            final latestState = state as HomeLoaded;
            final latestProfileIndex = latestState.profiles.indexWhere((p) => p.id == event.userId);
            
            if (latestProfileIndex != -1) {
              final updatedProfile = latestState.profiles[latestProfileIndex].copyWithDetails(detailsResponse);
              
              final updatedProfiles = List<ProfileModel>.from(latestState.profiles);
              updatedProfiles[latestProfileIndex] = updatedProfile;
              
              emit(HomeLoaded(
                profiles: updatedProfiles,
                remainingSwipes: latestState.remainingSwipes,
                cursor: latestState.cursor,
              ));
            }
          }
        }
      }
    }
  }
}
