import 'package:flutter/material.dart';

abstract class PostPlanEvent {}

class JumpToStepEvent extends PostPlanEvent {
  final int step;
  JumpToStepEvent(this.step);
}

class UpdateStep1Event extends PostPlanEvent {
  final String activityName;
  final String activityImage;
  UpdateStep1Event({required this.activityName, required this.activityImage});
}

class UpdateStep2Event extends PostPlanEvent {
  final String title;
  final String description;
  final List<String> tags;
  UpdateStep2Event({required this.title, required this.description, required this.tags});
}

class UpdateStep3Event extends PostPlanEvent {
  final String locationName;
  final String locationSubtitle;
  final String landmark;
  final String whenDate;
  final TimeOfDay? time;
  final String? howLong;
  final String? whoPays;
  final String? groupSize;
  final String? whoCanRequest;
  final String visibility;

  UpdateStep3Event({
    required this.locationName,
    required this.locationSubtitle,
    required this.landmark,
    required this.whenDate,
    required this.time,
    required this.howLong,
    required this.whoPays,
    required this.groupSize,
    required this.whoCanRequest,
    required this.visibility,
  });
}

class UpdateReviewSettingsEvent extends PostPlanEvent {
  final String? finalWhoCanJoin;
  final bool? verifiedMembersOnly;
  final bool? autoApproveRequests;

  UpdateReviewSettingsEvent({
    this.finalWhoCanJoin,
    this.verifiedMembersOnly,
    this.autoApproveRequests,
  });
}
