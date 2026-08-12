import 'dart:io';

import '../models/upload_id_model.dart';

enum UploadIdStatus { initial, loading, success, failure }

class UploadIdState {
  final IdType selectedIdType;
  final String idNumber;
  final String fullName;

  final File? frontFile;
  final File? backFile;

  final bool isConfirmed;

  final UploadIdStatus status;
  final String? errorMessage;

  const UploadIdState({
    this.selectedIdType = IdType.aadhaar,
    this.idNumber = '',
    this.fullName = '',
    this.frontFile,
    this.backFile,
    this.isConfirmed = false,
    this.status = UploadIdStatus.initial,
    this.errorMessage,
  });

  UploadIdState copyWith({
    IdType? selectedIdType,
    String? idNumber,
    String? fullName,
    File? frontFile,
    File? backFile,
    bool? isConfirmed,
    UploadIdStatus? status,
    String? errorMessage,
  }) {
    return UploadIdState(
      selectedIdType: selectedIdType ?? this.selectedIdType,
      idNumber: idNumber ?? this.idNumber,
      fullName: fullName ?? this.fullName,
      frontFile: frontFile ?? this.frontFile,
      backFile: backFile ?? this.backFile,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  bool get isAadhaar => selectedIdType == IdType.aadhaar;

  bool get canSubmit {
    if (fullName.trim().isEmpty) {
      return false;
    }

    if (frontFile == null) {
      return false;
    }

    if (backFile == null) {
      return false;
    }

    if (!isConfirmed) {
      return false;
    }

    if (isAadhaar && idNumber.length != 12) {
      return false;
    }

    return true;
  }
}
