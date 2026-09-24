import 'package:flutter_bloc/flutter_bloc.dart';

import 'education_event.dart';
import 'education_state.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class EducationBloc_instant
    extends Bloc<EducationEvent, EducationState_instant> {
  EducationBloc_instant() : super(const EducationState_instant()) {
    on<MobileNumberChanged_instant>(_onMobileNumberChanged);
    on<FetchDegree>(_onFetchDegree);
  }

  void _onMobileNumberChanged(
    MobileNumberChanged_instant event,
    Emitter<EducationState_instant> emit,
  ) {
    final number = event.mobileNumber.replaceAll(RegExp(r'\D'), '');

    emit(
      state.copyWith(
        mobileNumber: number,
        status: EducationStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onFetchDegree(
    FetchDegree event,
    Emitter<EducationState_instant> emit,
  ) async {
    final number = state.mobileNumber.replaceAll(RegExp(r'\D'), '');

    AppLogger.d('EducationInstantBloc', 'Mobile Number: "$number"');
    AppLogger.d('EducationInstantBloc', 'Mobile Length: ${number.length}');

    // Empty
    if (number.isEmpty) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please enter mobile number',
        ),
      );
      return;
    }

    // // 10 digit + starts with 6-9
    // if (!RegExp(r'^[6-9]\d{9}$').hasMatch(number)) {
    //   emit(
    //     state.copyWith(
    //       status: EducationStatus.failure,
    //       errorMessage: 'Please enter a valid 10-digit mobile number',
    //     ),
    //   );
    //   return;
    // }
    // Exactly 10 digits
    if (!RegExp(r'^\d{10}$').hasMatch(number)) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please enter a valid 10-digit mobile number',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EducationStatus.loading, errorMessage: null));

    try {
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(status: EducationStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
