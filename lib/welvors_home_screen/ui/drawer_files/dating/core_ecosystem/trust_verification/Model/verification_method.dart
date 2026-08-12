import 'package:flutter/material.dart';

class VerificationMethod {
  final String id;
  final String icon;
  final String title;
  final String type;
  final String subtitle;
  final bool recommended;
  final bool arrow;
  final Color iconBackground;

  const VerificationMethod({
    required this.id,
    required this.icon,
    required this.title,
    required this.type,
    required this.subtitle,
    required this.recommended,
    required this.arrow,
    required this.iconBackground,
  });
}
