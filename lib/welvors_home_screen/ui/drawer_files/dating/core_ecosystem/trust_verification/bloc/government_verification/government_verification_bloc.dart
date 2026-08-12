import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/government_verification_repository.dart';

import 'government_verification_event.dart';
import 'government_verification_state.dart';

class GovernmentVerificationBloc
    extends Bloc<GovernmentVerificationEvent, GovernmentVerificationState> {
  final GovernmentVerificationRepository repository;

  GovernmentVerificationBloc({required this.repository})
    : super(GovernmentVerificationInitial()) {
    on<LoadGovernmentVerificationEvent>(_onLoadGovernmentVerification);
  }

  Future<void> _onLoadGovernmentVerification(
    LoadGovernmentVerificationEvent event,
    Emitter<GovernmentVerificationState> emit,
  ) async {
    emit(GovernmentVerificationLoading());

    try {
      final response = await repository.fetchGovernmentVerification();

      emit(GovernmentVerificationLoaded(response));
    } catch (e) {
      emit(GovernmentVerificationError(e.toString()));
    }
  }
}
