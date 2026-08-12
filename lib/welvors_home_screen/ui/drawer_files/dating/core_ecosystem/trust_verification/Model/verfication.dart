import 'package:flutter/material.dart';
import 'VerificationItemModel.dart';

class VerificationSectionModel {
  final String index;
  final String title;
  final String subtitle;
  final bool verified;

  final Color countTextBoxColor;
  final Color verifiedColor;
  final Color buttonFirstColor;
  final Color buttonSecondColor;
  final Color buttonTextColor;

  final String buttonText;

  // Progress
  final double min;
  final double max;
  final double progress;
  final String progressLabel;

  final List<VerificationItemModel> items;

  final String tip;
  final Color tipBackground;
  final Color tipTextColor;

  const VerificationSectionModel({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.verified,
    required this.countTextBoxColor,
    required this.verifiedColor,
    required this.buttonFirstColor,
    required this.buttonSecondColor,
    required this.buttonTextColor,
    required this.buttonText,

    // Progress
    this.min = 0,
    required this.max,
    required this.progress,
    required this.progressLabel,

    required this.items,
    required this.tip,
    required this.tipBackground,
    required this.tipTextColor,
  });

  VerificationSectionModel copyWith({
    String? index,
    String? title,
    String? subtitle,
    bool? verified,
    Color? countTextBoxColor,
    Color? verifiedColor,
    Color? buttonFirstColor,
    Color? buttonSecondColor,
    Color? buttonTextColor,
    String? buttonText,

    // Progress
    double? min,
    double? max,
    double? progress,
    String? progressLabel,

    List<VerificationItemModel>? items,

    String? tip,
    Color? tipBackground,
    Color? tipTextColor,
  }) {
    return VerificationSectionModel(
      index: index ?? this.index,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      verified: verified ?? this.verified,

      countTextBoxColor: countTextBoxColor ?? this.countTextBoxColor,

      verifiedColor: verifiedColor ?? this.verifiedColor,

      buttonFirstColor: buttonFirstColor ?? this.buttonFirstColor,

      buttonSecondColor: buttonSecondColor ?? this.buttonSecondColor,

      buttonTextColor: buttonTextColor ?? this.buttonTextColor,

      buttonText: buttonText ?? this.buttonText,

      // Progress
      min: min ?? this.min,
      max: max ?? this.max,
      progress: progress ?? this.progress,
      progressLabel: progressLabel ?? this.progressLabel,

      items: items ?? this.items,

      tip: tip ?? this.tip,
      tipBackground: tipBackground ?? this.tipBackground,
      tipTextColor: tipTextColor ?? this.tipTextColor,
    );
  }
}
