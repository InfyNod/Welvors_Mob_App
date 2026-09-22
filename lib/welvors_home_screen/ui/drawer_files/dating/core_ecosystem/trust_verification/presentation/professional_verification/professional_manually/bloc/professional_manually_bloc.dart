import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../../services/logger_service.dart' show AppLogger;
import '../../../../export.dart';
import 'professional_event.dart';
import 'professional_state.dart';

class ProfessionalManuallyBloc
    extends Bloc<ProfessionalManuallyEvent, ProfessionalManuallyState> {
  ProfessionalManuallyBloc() : super(const ProfessionalManuallyState()) {
    // =========================================================
    // COMPANY
    // =========================================================

    on<CompanyChanged>((event, emit) {
      emit(state.copyWith(company: event.value));
    });

    // =========================================================
    // DESIGNATION
    // =========================================================

    on<DesignationChanged>((event, emit) {
      emit(state.copyWith(designation: event.value));
    });

    // =========================================================
    // WORK EMAIL
    // =========================================================

    on<WorkEmailChanged>((event, emit) {
      emit(state.copyWith(workEmail: event.value));
    });

    // =========================================================
    // CONFIRMATION
    // =========================================================

    on<ConfirmationChanged>((event, emit) {
      emit(state.copyWith(isConfirmed: event.value));
    });

    // =========================================================
    // UPLOAD DOCUMENT
    // =========================================================

    on<UploadProfessionalDocument>(_uploadProfessionalDocument);

    // =========================================================
    // SUBMIT
    // =========================================================

    on<SubmitProfessional>(_submitProfessional);
  }

  // ===========================================================
  // UPLOAD PROFESSIONAL DOCUMENT
  // ===========================================================

  Future<void> _uploadProfessionalDocument(
    UploadProfessionalDocument event,
    Emitter<ProfessionalManuallyState> emit,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result == null) {
        return;
      }

      final path = result.files.single.path;

      if (path == null || path.isEmpty) {
        return;
      }

      final file = File(path);

      // Max 5 MB
      final fileSize = await file.length();

      const maxSize = 5 * 1024 * 1024;

      if (fileSize > maxSize) {
        emit(
          state.copyWith(
            status: ProfessionalStatus.failure,
            errorMessage: 'File size must be less than 5MB',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          file: file,
          status: ProfessionalStatus.initial,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          errorMessage: 'Unable to select document',
        ),
      );
    }
  }

  // ===========================================================
  // SUBMIT PROFESSIONAL
  // ===========================================================

  Future<void> _submitProfessional(
    SubmitProfessional event,
    Emitter<ProfessionalManuallyState> emit,
  ) async {
    AppLogger.d(
      'ProfessionalManuallyBloc',
      'Submit professional - Company: ${state.company}, Designation: ${state.designation}, Work Email: ${state.workEmail}, File: ${state.file?.path}, Confirmed: ${state.isConfirmed}',
    );

    // =========================================================
    // VALIDATION
    // =========================================================

    if (state.company.trim().isEmpty) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          errorMessage: 'Please enter company / employer',
        ),
      );
      return;
    }

    if (state.designation.trim().isEmpty) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          errorMessage: 'Please enter designation',
        ),
      );
      return;
    }

    // Work email is OPTIONAL
    if (state.workEmail.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

      if (!emailRegex.hasMatch(state.workEmail.trim())) {
        emit(
          state.copyWith(
            status: ProfessionalStatus.failure,
            errorMessage: 'Please enter a valid work email',
          ),
        );
        return;
      }
    }

    if (state.file == null) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          errorMessage: 'Please upload bank statement',
        ),
      );
      return;
    }

    if (!state.isConfirmed) {
      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          errorMessage: 'Please confirm your details',
        ),
      );
      return;
    }

    // =========================================================
    // LOADING
    // =========================================================

    emit(
      state.copyWith(status: ProfessionalStatus.loading, errorMessage: null),
    );

    try {
      // =======================================================
      // API / REPOSITORY CALL
      // =======================================================

      AppLogger.i('ProfessionalManuallyBloc', 'PROFESSIONAL API CALL START');

      // Temporary API simulation
      await Future.delayed(const Duration(seconds: 2));

      AppLogger.i('ProfessionalManuallyBloc', 'PROFESSIONAL SUBMIT SUCCESS');

      // =======================================================
      // SUCCESS
      // =======================================================

      emit(
        state.copyWith(status: ProfessionalStatus.success, errorMessage: null),
      );
    } catch (e, st) {
      AppLogger.e('ProfessionalManuallyBloc', 'PROFESSIONAL SUBMIT ERROR', error: e, stackTrace: st);

      emit(
        state.copyWith(
          status: ProfessionalStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
