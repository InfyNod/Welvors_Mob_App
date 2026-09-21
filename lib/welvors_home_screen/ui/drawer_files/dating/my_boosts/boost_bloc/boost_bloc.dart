import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'boost_event.dart';
import 'boost_state.dart';
import '../service_all_flow.dart';
class BoostBloc extends Bloc<BoostEvent, BoostState> {
  BoostBloc() : super(BoostState.initial()) {
    on<AddBoostEvent>((event, emit) {
      emit(state.copyWith(
        boostBalance: state.boostBalance + event.quantity,
      ));
    });

    on<AddSuperBoostEvent>((event, emit) {
      emit(state.copyWith(
        superBoostBalance: state.superBoostBalance + event.quantity,
      ));
    });

    on<ConsumeBoostEvent>((event, emit) {
      if (state.boostBalance > 0) {
        final newItem = BoostHistoryItem(
          title: 'Daily Spotlight Boost',
          date: DateTime.now(),
          reach: 2000 + Random().nextInt(3000),
          likes: 20 + Random().nextInt(30),
          interests: 5 + Random().nextInt(15),
          duration: '1 Hour Duration',
          isSuperBoost: false,
        );
        emit(state.copyWith(
          boostBalance: state.boostBalance - 1,
          history: [newItem, ...state.history],
        ));
      }
    });

    on<ConsumeSuperBoostEvent>((event, emit) {
      if (state.superBoostBalance > 0) {
        final newItem = BoostHistoryItem(
          title: 'Weekend Mega Surge',
          date: DateTime.now(),
          reach: 8000 + Random().nextInt(7000),
          likes: 100 + Random().nextInt(80),
          interests: 30 + Random().nextInt(20),
          duration: '3 Hours Duration',
          isSuperBoost: true,
        );
        emit(state.copyWith(
          superBoostBalance: state.superBoostBalance - 1,
          history: [newItem, ...state.history],
        ));
      }
    });

    on<FetchBoostsDataEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService();
      final data = await service.getBoostsData();
      
      if (data != null) {
        emit(state.copyWith(
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<FetchSuperBoostsDataEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService();
      final data = await service.getSuperBoostsData();
      
      if (data != null) {
        emit(state.copyWith(
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<FetchBoostWalletEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService();
      final data = await service.getBoostWalletDetails();
      
      if (data != null) {
        final remainingBoosts = data['remaining_boosts'] as int? ?? 0;
        final isActive = data['is_active'] as bool? ?? false;
        DateTime? expiresAt;
        if (data['expires_at'] != null) {
          expiresAt = DateTime.tryParse(data['expires_at'].toString())?.toLocal();
        }
        
        List<Map<String, dynamic>> benefitsList = [];
        if (data['benefits'] != null) {
          benefitsList = List<Map<String, dynamic>>.from(data['benefits']);
        }
        
        final userBoostId = data['user_boost_id']?.toString();

        emit(state.copyWith(
          isLoading: false,
          boostBalance: remainingBoosts,
          isActive: isActive,
          expiresAt: expiresAt,
          benefits: benefitsList,
          userBoostId: userBoostId,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<FetchSuperBoostWalletEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService();
      final data = await service.getSuperBoostWalletDetails();
      
      if (data != null) {
        final remainingBoosts = data['remaining_boosts'] as int? ?? 0;
        final isActive = data['is_active'] as bool? ?? false;
        DateTime? expiresAt;
        if (data['expires_at'] != null) {
          expiresAt = DateTime.tryParse(data['expires_at'].toString())?.toLocal();
        }
        
        List<Map<String, dynamic>> benefitsList = [];
        if (data['benefits'] != null) {
          benefitsList = List<Map<String, dynamic>>.from(data['benefits']);
        }
        
        final superUserBoostId = data['user_boost_id']?.toString();

        emit(state.copyWith(
          isLoading: false,
          superBoostBalance: remainingBoosts,
          superIsActive: isActive,
          superExpiresAt: expiresAt,
          superBenefits: benefitsList,
          superUserBoostId: superUserBoostId,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<ActivateBoostEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService();
      final usageId = await service.activateBoost(event.userBoostId);
      if (usageId != null) {
        final newItem = BoostHistoryItem(
          id: usageId.isNotEmpty ? usageId : null,
          title: 'Boost',
          date: DateTime.now(),
          reach: 0,
          likes: 0,
          interests: 0,
          duration: '1h',
          isSuperBoost: false,
        );
        emit(state.copyWith(
          history: [newItem, ...state.history],
        ));
        add(FetchBoostWalletEvent());
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<ActivateSuperBoostEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService(); // Both use the same API structure with their respective IDs
      final usageId = await service.activateBoost(event.userBoostId, type: 'SUPER');
      if (usageId != null) {
        final newItem = BoostHistoryItem(
          id: usageId.isNotEmpty ? usageId : null,
          title: 'Super Boost',
          date: DateTime.now(),
          reach: 0,
          likes: 0,
          interests: 0,
          duration: '3h',
          isSuperBoost: true,
        );
        emit(state.copyWith(
          history: [newItem, ...state.history],
        ));
        add(FetchSuperBoostWalletEvent());
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<FetchBoostHistoryEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostAllApiService();
      final data = await service.getBoostHistory();
      
      if (data != null) {
        final lifetimeImpact = data['lifetimeImpact'] as Map<String, dynamic>?;
        
        int totalReach = 0, newLikes = 0, interests = 0, views = 0, matches = 0;
        
        if (lifetimeImpact != null) {
          totalReach = lifetimeImpact['totalReach'] as int? ?? 0;
          newLikes = lifetimeImpact['newLikes'] as int? ?? 0;
          interests = lifetimeImpact['interests'] as int? ?? 0;
          views = lifetimeImpact['views'] as int? ?? 0;
          matches = lifetimeImpact['matches'] as int? ?? 0;
        }

        final recentEvents = data['recentBoostEvents'] as List<dynamic>? ?? [];
        List<BoostHistoryItem> parsedHistory = [];
        for (var event in recentEvents) {
          final isSuper = event['boostType'] == 'SUPER' || event['title'] == 'Super Boost';
          // Fallback parsing just in case
          parsedHistory.add(BoostHistoryItem(
            id: event['id']?.toString(),
            title: isSuper ? 'Super Boost' : 'Boost',
            date: event['startedAt'] != null ? DateTime.parse(event['startedAt']).toLocal() : (event['created_at'] != null ? DateTime.parse(event['created_at']).toLocal() : DateTime.now()),
            reach: event['reach'] ?? 0,
            likes: event['likes'] ?? 0,
            interests: event['interests'] ?? 0,
            duration: '${event['duration'] ?? (isSuper ? 180 : 30)}m',
            isSuperBoost: isSuper,
            status: event['status'],
            expectedEndAt: event['expectedEndAt'] != null ? DateTime.parse(event['expectedEndAt']).toLocal() : null,
          ));
        }

        emit(state.copyWith(
          isLoading: false,
          totalReach: totalReach,
          newLikes: newLikes,
          interests: interests,
          views: views,
          matches: matches,
          history: parsedHistory.isNotEmpty ? parsedHistory : state.history,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });
  }
}
