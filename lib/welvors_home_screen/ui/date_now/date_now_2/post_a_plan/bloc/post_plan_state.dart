import 'package:flutter/material.dart';

class PostPlanState {
  final int currentStep;
  final String? planId;

  // Step 1: Activity
  final String? selectedActivityName;
  final String? selectedActivityImage;

  // Step 2: Details
  final String title;
  final String description;
  final List<String> tags;

  // Step 3: Location & Time
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

  // Step 4: Final Settings
  final String finalWhoCanJoin;
  final bool verifiedMembersOnly;
  final bool autoApproveRequests;

  const PostPlanState({
    this.currentStep = 1,
    this.planId,
    this.selectedActivityName,
    this.selectedActivityImage,
    this.title = '',
    this.description = '',
    this.tags = const [],
    this.locationName = '',
    this.locationSubtitle = '',
    this.landmark = '',
    this.whenDate = 'Today',
    this.time,
    this.howLong,
    this.whoPays,
    this.groupSize,
    this.whoCanRequest,
    this.visibility = 'Premium 👑',
    this.finalWhoCanJoin = '1 person',
    this.verifiedMembersOnly = true,
    this.autoApproveRequests = false,
  });

  PostPlanState copyWith({
    int? currentStep,
    String? planId,
    String? selectedActivityName,
    String? selectedActivityImage,
    String? title,
    String? description,
    List<String>? tags,
    String? locationName,
    String? locationSubtitle,
    String? landmark,
    String? whenDate,
    TimeOfDay? time,
    String? howLong,
    String? whoPays,
    String? groupSize,
    String? whoCanRequest,
    String? visibility,
    String? finalWhoCanJoin,
    bool? verifiedMembersOnly,
    bool? autoApproveRequests,
  }) {
    return PostPlanState(
      currentStep: currentStep ?? this.currentStep,
      planId: planId ?? this.planId,
      selectedActivityName: selectedActivityName ?? this.selectedActivityName,
      selectedActivityImage: selectedActivityImage ?? this.selectedActivityImage,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      locationName: locationName ?? this.locationName,
      locationSubtitle: locationSubtitle ?? this.locationSubtitle,
      landmark: landmark ?? this.landmark,
      whenDate: whenDate ?? this.whenDate,
      time: time ?? this.time,
      howLong: howLong ?? this.howLong,
      whoPays: whoPays ?? this.whoPays,
      groupSize: groupSize ?? this.groupSize,
      whoCanRequest: whoCanRequest ?? this.whoCanRequest,
      visibility: visibility ?? this.visibility,
      finalWhoCanJoin: finalWhoCanJoin ?? this.finalWhoCanJoin,
      verifiedMembersOnly: verifiedMembersOnly ?? this.verifiedMembersOnly,
      autoApproveRequests: autoApproveRequests ?? this.autoApproveRequests,
    );
  }
}
