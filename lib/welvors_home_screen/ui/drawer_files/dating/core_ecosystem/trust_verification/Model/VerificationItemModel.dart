import 'package:flutter/material.dart';

class VerificationItemModel {
  final String icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String points;
  final bool isCompleted;
  final bool isVerfiyed;
  final bool islocked;
  final Color? ptsColor;
  final Color? ptstextcolor;
  final String? buttonIds;

  const VerificationItemModel({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.points,
    this.isCompleted = false,
    this.isVerfiyed = false,
    this.islocked = false,
    this.ptsColor,
    this.ptstextcolor,
    this.buttonIds,
  });

  VerificationItemModel copyWith({
    String? icon,
    Color? iconBackground,
    String? title,
    String? subtitle,
    String? points,
    bool? isCompleted,
    bool? isVerfiyed,
    bool? islocked,
    Color? ptsColor,
    Color? ptstextcolor,
    String? buttonIds,
  }) {
    return VerificationItemModel(
      icon: icon ?? this.icon,
      iconBackground: iconBackground ?? this.iconBackground,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      isVerfiyed: isVerfiyed ?? this.isVerfiyed,
      islocked: islocked ?? this.islocked,
      ptsColor: ptsColor ?? this.ptsColor,
      ptstextcolor: ptstextcolor ?? this.ptstextcolor,
      buttonIds: buttonIds ?? this.buttonIds,
    );
  }
}
