import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'boost_event.dart';
import 'boost_state.dart';
import '../boost_all_screen/boost/service_boost.dart';
import '../boost_all_screen/super_boost/service_super.dart';
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

    on<FetchBoostWalletEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = BoostApiService();
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
        
        emit(state.copyWith(
          isLoading: false,
          boostBalance: remainingBoosts,
          isActive: isActive,
          expiresAt: expiresAt,
          benefits: benefitsList,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });
    on<FetchSuperBoostWalletEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final service = SuperBoostApiService();
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
        
        emit(state.copyWith(
          isLoading: false,
          superBoostBalance: remainingBoosts,
          superIsActive: isActive,
          superExpiresAt: expiresAt,
          superBenefits: benefitsList,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });
  }
}
