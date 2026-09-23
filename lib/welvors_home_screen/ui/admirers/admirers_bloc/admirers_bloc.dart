import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/logger_service.dart';
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

  Future<void> _onLoadAdmirersData(
    LoadAdmirersData event,
    Emitter<AdmirersState> emit,
  ) async {
    String currentActiveTab = 'received';
    if (state is AdmirersLoaded) {
      currentActiveTab = (state as AdmirersLoaded).activeTab;
    }

    emit(AdmirersLoading());

    try {
      final responses = await Future.wait([
        _apiService.getReceivedLikes().catchError((e) {
          AppLogger.e('AdmirersBloc', 'getReceivedLikes error: $e');
          return <String, dynamic>{'data': []};
        }),
        _apiService.getSentLikes().catchError((e) {
          AppLogger.e('AdmirersBloc', 'getSentLikes error: $e');
          return <String, dynamic>{'data': []};
        }),
        _apiService.getReceivedRoses().catchError((e) {
          AppLogger.e('AdmirersBloc', 'getReceivedRoses error: $e');
          return <String, dynamic>{'data': []};
        }),
        _apiService.getSentRoses().catchError((e) {
          AppLogger.e('AdmirersBloc', 'getSentRoses error: $e');
          return <String, dynamic>{'data': []};
        }),
      ]);

      final Map<String, dynamic> receivedResponse = responses[0];
      final Map<String, dynamic> sentResponse = responses[1];
      final Map<String, dynamic> roseResponse = responses[2];
      final Map<String, dynamic> sentRoseResponse = responses[3];

      final List<dynamic> rawReceivedData = receivedResponse['data'] is List ? receivedResponse['data'] : [];
      final bool isLocked = receivedResponse['isLocked'] ?? false;
      final int? receivedLikesCount = receivedResponse['receivedLikesCount'];

      final List<dynamic> rawSentData = sentResponse['data'] is List ? sentResponse['data'] : [];
      final List<dynamic> rawRoseData = roseResponse['data'] is List ? roseResponse['data'] : [];
      final List<dynamic> rawSentRoseData = sentRoseResponse['data'] is List ? sentRoseResponse['data'] : [];

      // Map Received Likes API response
      final List<Map<String, dynamic>> mappedLikes = rawReceivedData.map((
        item,
      ) {
        final user = item['user'] is Map ? item['user'] : {};

        return {
          'id':
              item['interactionId'] ??
              user['id'] ??
              DateTime.now().millisecondsSinceEpoch,
          'userId': user['id'] ?? item['interactionId'] ?? DateTime.now().millisecondsSinceEpoch,
          'name': user['name'] ?? 'Unknown',
          'age': (user['age'] ?? '25').toString(),
          'matchPercent': '${user['matchScore'] ?? 85}%',
          'distance': '${user['distanceKm'] ?? 5} km',
          'imageUrl':
              user['profileImage'] ??
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
          'isBlurred': isLocked,
        };
      }).toList();

      // Map Sent Likes API response
      final List<Map<String, dynamic>> mappedSentLikes = rawSentData.map((
        item,
      ) {
        final user = item['user'] is Map ? item['user'] : {};
        final likeStatus = item['likeStatus'] is Map ? item['likeStatus'] : {};
        final bool isMatched = likeStatus['matched'] == true;
        final bool isSeen = likeStatus['seen'] == true;
        
        int progressState = 0;
        String statusText = 'Awaiting reply';
        int statusTextColor = 0xFF8A6011;
        int statusBgColor = 0xFFFFF6E6;

        if (isMatched) {
          progressState = 2;
          statusText = 'Matched';
          statusTextColor = 0xFF1B7F53;
          statusBgColor = 0xFFE9F7F0;
        } else if (isSeen) {
          progressState = 1;
          statusText = 'Seen';
          statusTextColor = 0xFF3563C1;
          statusBgColor = 0xFFE9F2FF;
        }

        return {
          'id':
              item['interactionId'] ??
              user['id'] ??
              DateTime.now().millisecondsSinceEpoch,
          'userId': user['id'] ?? item['interactionId'] ?? DateTime.now().millisecondsSinceEpoch,
          'name': user['name'] ?? 'Unknown',
          'age': (user['age'] ?? '25').toString(),
          'timeElapsed': item['timeAgo'] ?? 'Recently',
          'matchPercent': '${user['matchScore'] ?? 0}% Match',
          'imageUrl':
              user['profileImage'] ??
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
          'statusText': statusText,
          'statusTextColor': statusTextColor,
          'statusBgColor': statusBgColor,
          'progressState': progressState,
          'actionText': 'Send a rose',
          'actionIconColor': 0xFFFFFFFF,
          'actionBgColor': 0xFFE43A6A,
          'actionTextColor': 0xFFFFFFFF,
          'location': user['distanceKm'] != null ? '${user['distanceKm']} km' : 'Not specified',
          'quote': '"Hi there! 👋"', // Fallback if no message in API
        };
      }).toList();

      // Map Received Roses API response
      final List<Map<String, dynamic>> mappedRoses = rawRoseData.map((item) {
        final user = item['user'] is Map ? item['user'] : {};

        return {
          'id':
              item['interactionId'] ??
              user['id'] ??
              DateTime.now().millisecondsSinceEpoch,
          'userId': user['id'] ?? item['interactionId'] ?? DateTime.now().millisecondsSinceEpoch,
          'name': user['name'] ?? 'Unknown',
          'age': (user['age'] ?? '25').toString(),
          'distance': '${user['distanceKm'] ?? 5} km',
          'message':
              item['message'] ??
              '"Your profile caught my eye! ✨"', // Fallback since API currently lacks this
          'imageUrl':
              user['profileImage'] ??
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
        };
      }).toList();

      // Map Sent Roses API response
      final List<Map<String, dynamic>> mappedSentRoses = rawSentRoseData.map((
        item,
      ) {
        final user = item['user'] is Map ? item['user'] : {};
        final bool isMatch = item['isMatch'] ?? false;

        return {
          'id':
              item['interactionId'] ??
              user['id'] ??
              DateTime.now().millisecondsSinceEpoch,
          'userId': user['id'] ?? item['interactionId'] ?? DateTime.now().millisecondsSinceEpoch,
          'name': user['name'] ?? 'Unknown',
          'age': (user['age'] ?? '25').toString(),
          'timeInfo':
              '${item['timeAgo'] ?? 'Recently'}',
          'imageUrl':
              user['profileImage'] ??
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
          'statusText': isMatch ? '✓ Matched · Chat' : '○ Pending',
          'statusTextColor': isMatch ? 0xFF2CAF6B : 0xFF757575,
          'statusBgColor': isMatch ? 0xFFE9F7EF : 0xFFEEEEEE,
        };
      }).toList();

      emit(
        AdmirersLoaded(
          coins: 1280,
          likes: mappedLikes,
          sentLikes: mappedSentLikes,
          roses: mappedRoses,
          sentRoses: mappedSentRoses,
          activeTab: currentActiveTab,
          isLocked: isLocked,
          receivedLikesCount: receivedLikesCount,
        ),
      );
    } catch (e, st) {
      AppLogger.e('AdmirersBloc', 'API Fetch failed: $e', error: e, stackTrace: st);
      emit(
        AdmirersLoaded(
          coins: 1280,
          likes: const [],
          sentLikes: const [],
          roses: const [],
          sentRoses: const [],
          activeTab: currentActiveTab,
        ),
      );
    }
  }

  void _onChangeAdmirersTab(
    ChangeAdmirersTab event,
    Emitter<AdmirersState> emit,
  ) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      emit(currentState.copyWith(activeTab: event.tab));
    }
  }

  void _onRemoveLike(RemoveLike event, Emitter<AdmirersState> emit) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      final newLikes = List<Map<String, dynamic>>.from(currentState.likes)
        ..removeWhere((like) => like['id'] == event.id);
      emit(currentState.copyWith(likes: newLikes));
    }
  }

  void _onRemoveRose(RemoveRose event, Emitter<AdmirersState> emit) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      final newRoses = List<Map<String, dynamic>>.from(currentState.roses)
        ..removeWhere((rose) => rose['id'] == event.id);
      emit(currentState.copyWith(roses: newRoses));
    }
  }
}
