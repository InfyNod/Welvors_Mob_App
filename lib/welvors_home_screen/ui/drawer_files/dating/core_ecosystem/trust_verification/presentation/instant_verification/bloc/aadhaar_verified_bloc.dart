import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/aadhaar_verified_repository.dart';

import 'aadhaar_verified_event.dart';
import 'aadhaar_verified_state.dart';

class AadhaarVerifiedBloc
    extends Bloc<AadhaarVerifiedEvent, AadhaarVerifiedState> {
  final AadhaarVerifiedRepository repository;

  AadhaarVerifiedBloc({required this.repository})
    : super(const AadhaarVerifiedState()) {
    on<LoadAadhaarVerified>(_onLoadAadhaarVerified);
  }

  Future<void> _onLoadAadhaarVerified(
    LoadAadhaarVerified event,
    Emitter<AadhaarVerifiedState> emit,
  ) async {
    emit(state.copyWith(status: AadhaarVerifiedStatus.loading));

    try {
      final trustScore = await repository.getTrustScore();

      emit(
        state.copyWith(
          status: AadhaarVerifiedStatus.success,
          trustScore: trustScore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AadhaarVerifiedStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
