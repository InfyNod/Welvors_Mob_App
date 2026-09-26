import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../education_Instant/bloc/education_state.dart';

import 'education_event.dart';
import 'education_state.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class EducationBloc_manually
    extends Bloc<EducationEvent_manually, EducationState_manually> {
  EducationBloc_manually() : super(const EducationState_manually()) {
    // College
    on<CollegeChanged>((event, emit) {
      emit(state.copyWith(college: event.value));
    });

    // Degree
    on<DegreeChanged>((event, emit) {
      emit(state.copyWith(degree: event.value));
    });

    // Year
    on<YearChanged>((event, emit) {
      emit(state.copyWith(year: event.value));
    });

    // Confirmation
    on<ConfirmationChanged>((event, emit) {
      emit(state.copyWith(isConfirmed: event.value));
    });

    // Upload
    on<UploadDocument>(_uploadDocument);

    // Submit
    on<SubmitEducation>(_submitEducation);
  }

  Future<void> _uploadDocument(
    UploadDocument event,
    Emitter<EducationState_manually> emit,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      emit(state.copyWith(file: File(result.files.single.path!)));
    }
  }

  Future<void> _submitEducation(
    SubmitEducation event,
    Emitter<EducationState_manually> emit,
  ) async {
    AppLogger.d('EducationManuallyBloc', '========== SUBMIT EDUCATION ==========');

    AppLogger.d('EducationManuallyBloc', 'College: ${state.college}');
    AppLogger.d('EducationManuallyBloc', 'Degree: ${state.degree}');
    AppLogger.d('EducationManuallyBloc', 'Year: ${state.year}');
    AppLogger.d('EducationManuallyBloc', 'File: ${state.file?.path}');
    AppLogger.d('EducationManuallyBloc', 'Confirmed: ${state.isConfirmed}');

    if (state.college.trim().isEmpty) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please enter college',
        ),
      );
      return;
    }

    if (state.degree.trim().isEmpty) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please enter degree',
        ),
      );
      return;
    }

    if (state.year.trim().isEmpty) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please enter year',
        ),
      );
      return;
    }

    if (state.file == null) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please upload document',
        ),
      );
      return;
    }

    if (!state.isConfirmed) {
      emit(
        state.copyWith(
          status: EducationStatus.failure,
          errorMessage: 'Please confirm details',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EducationStatus.loading));

    try {
      // API call
      await Future.delayed(const Duration(seconds: 2));

      AppLogger.i('EducationManuallyBloc', 'EDUCATION SUBMIT SUCCESS');

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
