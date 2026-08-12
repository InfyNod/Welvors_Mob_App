import 'package:flutter/material.dart';
import 'verification_method.dart';

class GovernmentVerificationResponse {
  final String title;
  final String bannerMessage;
  final Color bannerColor;
  final List<VerificationMethod> methods;

  const GovernmentVerificationResponse({
    required this.title,
    required this.bannerMessage,
    required this.bannerColor,
    required this.methods,
  });
}
