import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../services/logger_service.dart';
import '../data/instant_verification_repository.dart';

import 'instant_verification_event.dart';
import 'instant_verification_state.dart';

class InstantVerificationBloc
    extends Bloc<InstantVerificationEvent, InstantVerificationState> {
  final InstantVerificationRepository repository;

  Timer? _timer;

  InstantVerificationBloc({required this.repository})
    : super(const InstantVerificationState()) {
    on<SelectDocument>(_onSelectDocument);
    on<ContinueWithDocument>(_onContinueWithDocument);
    on<MobileNumberChanged>(_onMobileNumberChanged);
    on<SendOtp>(_onSendOtp);
    on<OtpChanged>(_onOtpChanged);
    on<VerifyOtp>(_onVerifyOtp);
    on<ResendOtp>(_onResendOtp);
    on<PreviousStep>(_onPreviousStep);
    on<ToggleConsent>(_onToggleConsent);

    on<AllowAndVerify>(_onAllowAndVerify);
    on<_TimerTick>(_onTimerTick);
    on<_TimerFinished>(_onTimerFinished);
  }
  void _onSelectDocument(
    SelectDocument event,
    Emitter<InstantVerificationState> emit,
  ) {
    emit(state.copyWith(selectedDocument: event.document));
  }

  void _onContinueWithDocument(
    ContinueWithDocument event,
    Emitter<InstantVerificationState> emit,
  ) {
    if (state.selectedDocument == null) return;

    emit(state.copyWith(currentStep: 2));
  }

  void _onMobileNumberChanged(
    MobileNumberChanged event,
    Emitter<InstantVerificationState> emit,
  ) {
    final number = event.mobileNumber.replaceAll(RegExp(r'\D'), '');

    emit(state.copyWith(mobileNumber: number));
  }

  Future<void> _onSendOtp(
    SendOtp event,
    Emitter<InstantVerificationState> emit,
  ) async {
    if (state.mobileNumber.length != 10) {
      emit(
        state.copyWith(
          status: InstantVerificationStatus.failure,
          errorMessage: 'Please enter a valid mobile number',
        ),
      );
      return;
    }

    if (state.selectedDocument == null) return;

    emit(state.copyWith(status: InstantVerificationStatus.loading));

    try {
      final success = await repository.sendOtp(
        document: state.selectedDocument!,
        mobileNumber: state.mobileNumber,
      );

      if (!success) {
        emit(
          state.copyWith(
            status: InstantVerificationStatus.failure,
            errorMessage: 'Unable to send OTP',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          currentStep: 3,
          status: InstantVerificationStatus.success,
          otp: '',
          resendSeconds: 16,
          canResend: false,
        ),
      );

      _startTimer();
    } catch (e) {
      emit(
        state.copyWith(
          status: InstantVerificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onOtpChanged(OtpChanged event, Emitter<InstantVerificationState> emit) {
    emit(
      state.copyWith(
        otp: event.otp,
        status: InstantVerificationStatus.initial,
        errorMessage: null,
      ),
    );
  }

  // Future<void> _onVerifyOtp(
  //   VerifyOtp event,
  //   Emitter<InstantVerificationState> emit,
  // ) async {
  //   if (state.otp.length != 6) {
  //     emit(
  //       state.copyWith(
  //         status: InstantVerificationStatus.failure,
  //         errorMessage: 'Please enter 6 digit OTP',
  //       ),
  //     );
  //     return;
  //   }

  //   emit(
  //     state.copyWith(
  //       status: InstantVerificationStatus.loading,
  //       errorMessage: null,
  //     ),
  //   );

  //   try {
  //     final success = await repository.verifyOtp(
  //       mobileNumber: state.mobileNumber,
  //       otp: state.otp,
  //     );

  //     if (success) {
  //       // OTP verified → go to Consent
  //       emit(
  //         state.copyWith(
  //           currentStep: 4,
  //           status: InstantVerificationStatus.success,
  //           errorMessage: null,
  //         ),
  //       );
  //     } else {
  //       emit(
  //         state.copyWith(
  //           status: InstantVerificationStatus.failure,
  //           errorMessage: 'Invalid OTP',
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         status: InstantVerificationStatus.failure,
  //         errorMessage: e.toString(),
  //       ),
  //     );
  //   }
  // }
  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<InstantVerificationState> emit,
  ) async {
    AppLogger.d('InstantVerificationBloc', '🔥 VERIFY OTP CALLED: ${state.otp}');

    if (state.status == InstantVerificationStatus.loading) {
      return;
    }

    if (state.otp.length != 6) {
      emit(
        state.copyWith(
          status: InstantVerificationStatus.failure,
          errorMessage: 'Please enter 6 digit OTP',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: InstantVerificationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final success = await repository.verifyOtp(
        mobileNumber: state.mobileNumber,
        otp: state.otp,
      );

      if (success) {
        AppLogger.i('InstantVerificationBloc', '✅ REPOSITORY SUCCESS');

        emit(
          state.copyWith(
            currentStep: 4,
            status: InstantVerificationStatus.success,
            errorMessage: null,
          ),
        );

        return;
      }

      AppLogger.w('InstantVerificationBloc', '❌ REPOSITORY FALSE');

      emit(
        state.copyWith(
          status: InstantVerificationStatus.failure,
          errorMessage: 'Invalid OTP',
        ),
      );
    } catch (e, st) {
      AppLogger.e('InstantVerificationBloc', 'Error verifying OTP', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: InstantVerificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onResendOtp(
    ResendOtp event,
    Emitter<InstantVerificationState> emit,
  ) async {
    if (!state.canResend) return;

    try {
      final success = await repository.resendOtp(
        mobileNumber: state.mobileNumber,
      );

      if (!success) {
        emit(
          state.copyWith(
            status: InstantVerificationStatus.failure,
            errorMessage: 'Unable to resend OTP',
          ),
        );
        return;
      }

      emit(state.copyWith(resendSeconds: 16, canResend: false));

      _startTimer();
    } catch (e) {
      emit(
        state.copyWith(
          status: InstantVerificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // TIMER
  // ------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.resendSeconds <= 1) {
        _timer?.cancel();

        add(const _TimerFinished());

        return;
      }

      add(const _TimerTick());
    });
  }

  void _onTimerTick(_TimerTick event, Emitter<InstantVerificationState> emit) {
    if (state.resendSeconds <= 0) {
      return;
    }

    emit(state.copyWith(resendSeconds: state.resendSeconds - 1));
  }

  void _onTimerFinished(
    _TimerFinished event,
    Emitter<InstantVerificationState> emit,
  ) {
    emit(state.copyWith(resendSeconds: 0, canResend: true));
  }

  // ------------------------------------------------------------
  // PREVIOUS STEP
  // ------------------------------------------------------------

  void _onPreviousStep(
    PreviousStep event,
    Emitter<InstantVerificationState> emit,
  ) {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onToggleConsent(
    ToggleConsent event,
    Emitter<InstantVerificationState> emit,
  ) {
    emit(state.copyWith(consentAccepted: !state.consentAccepted));
  }

  void _onAllowAndVerify(
    AllowAndVerify event,
    Emitter<InstantVerificationState> emit,
  ) {
    if (!state.consentAccepted) {
      return;
    }

    emit(state.copyWith(status: InstantVerificationStatus.aadhaarVerified));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

// ------------------------------------------------------------
// TIMER EVENTS
// ------------------------------------------------------------

class _TimerTick extends InstantVerificationEvent {
  const _TimerTick();
}

class _TimerFinished extends InstantVerificationEvent {
  const _TimerFinished();
}
