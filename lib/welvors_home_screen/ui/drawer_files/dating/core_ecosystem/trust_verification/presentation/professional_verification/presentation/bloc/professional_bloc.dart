import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/professional_repository.dart';

import 'professional_event.dart';
import 'professional_state.dart';

class ProfessionalBloc extends Bloc<ProfessionalEvent, ProfessionalState> {
  final ProfessionalRepository repository;

  Timer? _timer;

  ProfessionalBloc({required this.repository})
    : super(const ProfessionalState()) {
    on<EmailChangedEvent>(_onEmailChanged);
    on<CodeChangedEvent>(_onCodeChanged);

    on<SendCodeEvent>(_onSendCode);
    on<VerifyCodeEvent>(_onVerifyCode);
    on<ResendCodeEvent>(_onResendCode);

    on<ChangeEmailEvent>(_onChangeEmail);

    on<StartResendTimerEvent>(_onStartTimer);
    on<TickResendTimerEvent>(_onTickTimer);
  }

  void _onEmailChanged(
    EmailChangedEvent event,
    Emitter<ProfessionalState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        status: ProfessionalStatus.initial,
        clearError: true,
      ),
    );
  }

  void _onCodeChanged(CodeChangedEvent event, Emitter<ProfessionalState> emit) {
    emit(state.copyWith(code: event.code, clearError: true));
  }

  Future<void> _onSendCode(
    SendCodeEvent event,
    Emitter<ProfessionalState> emit,
  ) async {
    // Already sending/requested → ignore duplicate event
    if (state.status == ProfessionalStatus.loading) {
      return;
    }

    final email = event.email.trim();

    if (email.isEmpty) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          error: 'Please enter your work email',
        ),
      );
      return;
    }

    if (!_isValidWorkEmail(email)) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          error: 'Please enter a valid work email',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ProfessionalStatus.loading,
        email: email,
        clearError: true,
      ),
    );

    try {
      await repository.sendCode(email);

      // Only one successful state
      emit(
        state.copyWith(
          status: ProfessionalStatus.codeSent,
          email: email,
          code: '',
          resendSeconds: 15,
          clearError: true,
        ),
      );

      add(StartResendTimerEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          error: 'Unable to send code. Please try again.',
        ),
      );
    }
  }

  Future<void> _onVerifyCode(
    VerifyCodeEvent event,
    Emitter<ProfessionalState> emit,
  ) async {
    final code = event.code.trim();

    if (code.length != 6) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          error: 'Please enter the 6-digit code',
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: ProfessionalStatus.verifying, clearError: true),
    );

    try {
      final isVerified = await repository.verifyCode(
        email: event.email,
        code: code,
      );

      if (isVerified) {
        emit(
          state.copyWith(status: ProfessionalStatus.success, clearError: true),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfessionalStatus.failure,
            error: 'Invalid verification code',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          error: 'Verification failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onResendCode(
    ResendCodeEvent event,
    Emitter<ProfessionalState> emit,
  ) async {
    if (state.resendSeconds > 0) {
      return;
    }

    try {
      await repository.resendCode(event.email);

      emit(state.copyWith(resendSeconds: 15, clearError: true));

      add(StartResendTimerEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          error: 'Unable to resend code.',
        ),
      );
    }
  }

  void _onChangeEmail(ChangeEmailEvent event, Emitter<ProfessionalState> emit) {
    _timer?.cancel();

    emit(
      ProfessionalState(email: state.email, status: ProfessionalStatus.initial),
    );
  }

  void _onStartTimer(
    StartResendTimerEvent event,
    Emitter<ProfessionalState> emit,
  ) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TickResendTimerEvent());
    });
  }

  void _onTickTimer(
    TickResendTimerEvent event,
    Emitter<ProfessionalState> emit,
  ) {
    if (state.resendSeconds <= 1) {
      _timer?.cancel();

      emit(state.copyWith(resendSeconds: 0));

      return;
    }

    emit(state.copyWith(resendSeconds: state.resendSeconds - 1));
  }

  bool _isValidWorkEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    return regex.hasMatch(email);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
