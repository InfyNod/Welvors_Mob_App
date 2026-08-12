import 'dart:io';

import 'package:flutter/material.dart';
import '../../education_Instant/bloc/education_state.dart';

@immutable
class EducationState_manually {
  final String college;
  final String degree;
  final String year;
  final File? file;
  final bool isConfirmed;

  final EducationStatus status;
  final String? errorMessage;

  const EducationState_manually({
    this.college = '',
    this.degree = '',
    this.year = '',
    this.file,
    this.isConfirmed = false,
    this.status = EducationStatus.initial,
    this.errorMessage,
  });

  EducationState_manually copyWith({
    String? college,
    String? degree,
    String? year,
    File? file,
    bool? isConfirmed,
    EducationStatus? status,
    String? errorMessage,
  }) {
    return EducationState_manually(
      college: college ?? this.college,
      degree: degree ?? this.degree,
      year: year ?? this.year,
      file: file ?? this.file,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
