import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/upload_id_repository.dart';
import '../models/upload_id_model.dart';
import 'upload_id_event.dart';
import 'upload_id_state.dart';

class UploadIdBloc extends Bloc<UploadIdEvent, UploadIdState> {
  final UploadIdRepository repository;

  UploadIdBloc({required this.repository}) : super(const UploadIdState()) {
    on<SelectIdType>(_onSelectIdType);
    on<AadhaarNumberChanged>(_onAadhaarNumberChanged);
    on<FullNameChanged>(_onFullNameChanged);
    on<FrontDocumentSelected>(_onFrontDocumentSelected);
    on<BackDocumentSelected>(_onBackDocumentSelected);
    on<ConfirmationChanged>(_onConfirmationChanged);
    on<SubmitUploadId>(_onSubmitUploadId);
  }

  void _onSelectIdType(SelectIdType event, Emitter<UploadIdState> emit) {
    emit(
      state.copyWith(
        selectedIdType: event.idType,
        status: UploadIdStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onAadhaarNumberChanged(
    AadhaarNumberChanged event,
    Emitter<UploadIdState> emit,
  ) {
    final value = event.value.replaceAll(RegExp(r'\D'), '');

    if (value.length > 12) {
      return;
    }

    emit(
      state.copyWith(
        idNumber: value,
        status: UploadIdStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onFullNameChanged(FullNameChanged event, Emitter<UploadIdState> emit) {
    emit(
      state.copyWith(
        fullName: event.value,
        status: UploadIdStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onFrontDocumentSelected(
    FrontDocumentSelected event,
    Emitter<UploadIdState> emit,
  ) {
    emit(
      state.copyWith(
        frontFile: event.file,
        status: UploadIdStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onBackDocumentSelected(
    BackDocumentSelected event,
    Emitter<UploadIdState> emit,
  ) {
    emit(
      state.copyWith(
        backFile: event.file,
        status: UploadIdStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onConfirmationChanged(
    ConfirmationChanged event,
    Emitter<UploadIdState> emit,
  ) {
    emit(
      state.copyWith(
        isConfirmed: event.value,
        status: UploadIdStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSubmitUploadId(
    SubmitUploadId event,
    Emitter<UploadIdState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          status: UploadIdStatus.failure,
          errorMessage: _validationMessage(),
        ),
      );

      return;
    }

    emit(state.copyWith(status: UploadIdStatus.loading, errorMessage: null));

    try {
      final model = UploadIdModel(
        idType: state.selectedIdType,
        idNumber: state.idNumber,
        fullName: state.fullName,
        frontFile: state.frontFile,
        backFile: state.backFile,
        isConfirmed: state.isConfirmed,
      );

      final success = await repository.submitDocument(model);

      if (success) {
        emit(state.copyWith(status: UploadIdStatus.success));
      } else {
        emit(
          state.copyWith(
            status: UploadIdStatus.failure,
            errorMessage: 'Unable to submit document',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: UploadIdStatus.failure,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }

  String _validationMessage() {
    if (state.isAadhaar && state.idNumber.length != 12) {
      return 'Please enter valid 12-digit Aadhaar number';
    }

    if (state.fullName.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (state.frontFile == null) {
      return 'Please upload front document';
    }

    if (state.backFile == null) {
      return 'Please upload back document';
    }

    if (!state.isConfirmed) {
      return 'Please confirm the declaration';
    }

    return 'Please complete all required fields';
  }
}
