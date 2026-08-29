import 'package:flutter_bloc/flutter_bloc.dart';
import 'admirers_event.dart';
import 'admirers_state.dart';

import '../service_admire/admirers_api_service.dart';

class AdmirersBloc extends Bloc<AdmirersEvent, AdmirersState> {
  final AdmirersApiService _apiService = AdmirersApiService();

  AdmirersBloc() : super(AdmirersInitial()) {
    on<LoadAdmirersData>(_onLoadAdmirersData);
    on<ChangeAdmirersTab>(_onChangeAdmirersTab);
    on<RemoveLike>(_onRemoveLike);
    on<RemoveRose>(_onRemoveRose);
  }

  Future<void> _onLoadAdmirersData(LoadAdmirersData event, Emitter<AdmirersState> emit) async {
    emit(AdmirersLoading());

    try {
      final Map<String, dynamic> response = await _apiService.getReceivedLikes();
      final List<dynamic> rawData = response['data'] ?? [];
      final bool isLocked = response['isLocked'] ?? false;
      
      // Map API response to the format expected by the UI
      final List<Map<String, dynamic>> mappedLikes = rawData.map((item) {
        final user = item['user'] ?? {};
        
        return {
          'id': item['interactionId'] ?? user['id'] ?? DateTime.now().millisecondsSinceEpoch,
          'name': user['name'] ?? 'Unknown',
          'age': (user['age'] ?? '25').toString(),
          'matchPercent': '${user['matchScore'] ?? 85}%',
          'distance': '${user['distanceKm'] ?? 5} km',
          'imageUrl': user['profileImage'] ?? 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
          'badgeText': '💬 Sent a note', // Backend team is not sending real badge data yet, so keeping it static
          'badgeColor': 0xFFFFFFFF,
          'badgeTextColor': 0xDD000000,
          'isBlurred': isLocked,
        };
      }).toList();

      emit(AdmirersLoaded(
        coins: 1280,
        likes: [...mappedLikes, ..._getMockLikes()], // Added dummy data for testing
        roses: _getMockRoses(),
        activeTab: 'likes',
      ));
    } catch (e) {
      // If API fails, fallback to mock data so UI doesn't break
      print("API Fetch failed: $e");
      emit(AdmirersLoaded(
        coins: 1280,
        likes: _getMockLikes(),
        roses: _getMockRoses(),
        activeTab: 'likes',
      ));
    }
  }

  List<Map<String, dynamic>> _getMockLikes() {
    return [
      {
        'id': 0,
        'name': 'Marcus',
        'age': '29',
        'matchPercent': '75%',
        'distance': '8 km',
        'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
        'badgeText': '💬 Sent a note',
        'badgeColor': 0xFFFFFFFF,
        'badgeTextColor': 0xDD000000,
        'isBlurred': false,
      },
      {
        'id': 1,
        'name': 'Jordan',
        'age': '27',
        'matchPercent': '88%',
        'distance': '5 km',
        'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=500&q=80',
        'badgeText': '✓ VERIFIED',
        'badgeColor': 0xFF2CAF6B,
        'badgeTextColor': 0xFFFFFFFF,
        'isBlurred': false,
      },
      {
        'id': 2,
        'name': 'Sarah',
        'age': '25',
        'matchPercent': '92%',
        'distance': '3 km',
        'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80',
        'badgeText': null,
        'badgeColor': 0xFF2CAF6B,
        'badgeTextColor': 0xFFFFFFFF,
        'isBlurred': true,
      },
      {
        'id': 3,
        'name': 'Emily',
        'age': '23',
        'matchPercent': '81%',
        'distance': '6 km',
        'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
        'badgeText': null,
        'badgeColor': 0xFF2CAF6B,
        'badgeTextColor': 0xFFFFFFFF,
        'isBlurred': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockRoses() {
    return [
      {
        'id': 0,
        'name': 'Dev',
        'age': '27',
        'distance': '3 km',
        'message': '"Your trekking photos are amazing — Ladakh next year?"',
        'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=500&q=80',
      },
      {
        'id': 1,
        'name': 'Arjun',
        'age': '28',
        'distance': '6 km',
        'message': '"Fellow IIM grad here — chai > coffee, agree?"',
        'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
      },
      {
        'id': 2,
        'name': 'Kabir',
        'age': '30',
        'distance': '11 km',
        'message': '"Saw you love indie music — Prateek Kuhad gig next month?"',
        'imageUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=500&q=80',
      },
    ];
  }

  void _onChangeAdmirersTab(ChangeAdmirersTab event, Emitter<AdmirersState> emit) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      emit(currentState.copyWith(activeTab: event.tab));
    }
  }

  void _onRemoveLike(RemoveLike event, Emitter<AdmirersState> emit) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      final newLikes = List<Map<String, dynamic>>.from(currentState.likes)..removeWhere((like) => like['id'] == event.id);
      emit(currentState.copyWith(likes: newLikes));
    }
  }

  void _onRemoveRose(RemoveRose event, Emitter<AdmirersState> emit) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      final newRoses = List<Map<String, dynamic>>.from(currentState.roses)..removeWhere((rose) => rose['id'] == event.id);
      emit(currentState.copyWith(roses: newRoses));
    }
  }
}
