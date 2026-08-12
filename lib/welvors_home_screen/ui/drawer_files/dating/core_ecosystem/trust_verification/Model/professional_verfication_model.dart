import 'package:flutter/material.dart';
import 'verification_method.dart';

class ProfessionalVerificationResponse {
  final String title;
  final String bannerMessage;
  final String bannertitle;
  final Color bannerColor;
  final List<VerificationMethod> methods;
  // final VerificationInfo info;

  const ProfessionalVerificationResponse({
    required this.title,
    required this.bannerMessage,
    required this.bannertitle,
    required this.bannerColor,
    required this.methods,
    // required this.info,
  });
}
