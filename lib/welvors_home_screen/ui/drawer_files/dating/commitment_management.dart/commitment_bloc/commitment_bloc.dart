import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_event.dart';
import 'commitment_state.dart';

class CommitmentBloc extends Bloc<CommitmentEvent, CommitmentState> {
  CommitmentBloc() : super(CommitmentInitial()) {
    on<LoadCommitmentData>(_onLoadCommitmentData);
    on<EndExclusiveStatusRequested>(_onEndExclusiveStatusRequested);
    on<ApproveRequestEvent>(_onApproveRequestEvent);
  }

  Future<void> _onApproveRequestEvent(
    ApproveRequestEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is CommitmentLoaded) {
      // Avoid emitting CommitmentLoading() so the screen doesn't flicker
      emit(CommitmentLoaded(
        partnerName: event.partnerName,
        duration: currentState.duration,
        intent: currentState.intent,
        isIdentityVerified: currentState.isIdentityVerified,
      ));
    }
  }

  Future<void> _onLoadCommitmentData(
    LoadCommitmentData event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Load dummy data based on design
      emit(const CommitmentLoaded(
        partnerName: 'Priya',
        duration: '12 Jun',
        intent: 'Dating to marry',
        isIdentityVerified: true,
      ));
    } catch (e) {
      emit(CommitmentError(e.toString()));
    }
  }

  Future<void> _onEndExclusiveStatusRequested(
    EndExclusiveStatusRequested event,
    Emitter<CommitmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is CommitmentLoaded) {
      emit(CommitmentLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(CommitmentEnded(
        partnerName: currentState.partnerName,
        userName: 'Rahul', // Replace with dynamic user logic if available
      ));
    }
  }
}
