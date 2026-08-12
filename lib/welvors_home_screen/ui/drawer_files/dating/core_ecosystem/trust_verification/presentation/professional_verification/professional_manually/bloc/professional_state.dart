import 'dart:io';

import 'package:flutter/foundation.dart';

enum ProfessionalStatus { initial, loading, success, failure }

@immutable
class ProfessionalManuallyState {
  final String company;
  final String designation;
  final String workEmail;
  final File? file;
  final bool isConfirmed;

  final ProfessionalStatus status;
  final String? errorMessage;

  const ProfessionalManuallyState({
    this.company = '',
    this.designation = '',
    this.workEmail = '',
    this.file,
    this.isConfirmed = false,
    this.status = ProfessionalStatus.initial,
    this.errorMessage,
  });

  ProfessionalManuallyState copyWith({
    String? company,
    String? designation,
    String? workEmail,
    File? file,
    bool? isConfirmed,
    ProfessionalStatus? status,
    String? errorMessage,
  }) {
    return ProfessionalManuallyState(
      company: company ?? this.company,
      designation: designation ?? this.designation,
      workEmail: workEmail ?? this.workEmail,
      file: file ?? this.file,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
