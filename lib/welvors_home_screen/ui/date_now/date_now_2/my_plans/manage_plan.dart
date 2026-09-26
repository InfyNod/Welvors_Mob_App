import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../post_a_plan/activity_1.dart';
import '../post_a_plan/bloc/post_plan_state.dart';
import '../history/card_history.dart';
import 'my_plan_screen.dart';
import '../../date_api_service/date_now_api_service.dart';

void _showFeedbackSavedSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 24),
      duration: const Duration(seconds: 3),
      content: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    ),
  );
}

PostPlanState _parseRawPlanToState(Map<String, dynamic> rawPlan) {
  final activity = rawPlan['activity'] ?? {};
  final venue = rawPlan['venue'] ?? {};

  TimeOfDay? parsedTime;
  if (rawPlan['eventTime'] != null) {
    try {
      final timeStr = rawPlan['eventTime'].toString().toLowerCase();
      final isPm = timeStr.contains('pm');
      final cleanStr = timeStr.replaceAll(RegExp(r'[a-z ]'), '');
      final parts = cleanStr.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        final min = int.parse(parts[1]);
        if (isPm && hour < 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
        parsedTime = TimeOfDay(hour: hour, minute: min);
      }
    } catch (_) {}
  }

  String durationStr = rawPlan['duration']?.toString() ?? '120';
  if (durationStr == '120') {
    durationStr = '2 hours';
  } else if (durationStr == '60')
    durationStr = '1 hour';
  else if (durationStr == '180')
    durationStr = '3 hours';

  String extractLabel(dynamic field, String fallback) {
    if (field is Map) {
      return field['label']?.toString() ??
          field['name']?.toString() ??
          fallback;
    }
    return field?.toString() ?? fallback;
  }

  String limitStr = rawPlan['participantLimit']?.toString() ?? '1';
  String groupSizeVal = '1 person';
  if (limitStr == '2') {
    groupSizeVal = '2 people';
  } else if (limitStr != '1' && limitStr != '0')
    groupSizeVal = 'Small group';

  return PostPlanState(
    currentStep: 4,
    planId: rawPlan['id']?.toString(),
    selectedActivityName: activity['label']?.toString() ?? 'General',
    selectedActivityImage:
        activity['icon']?.toString() ?? rawPlan['photoUrl']?.toString(),
    title: rawPlan['title']?.toString() ?? '',
    description: rawPlan['note']?.toString() ?? '',
    tags: const [],
    locationName: venue['name']?.toString() ?? '',
    locationSubtitle: venue['address']?.toString() ?? '',
    landmark: '',
    whenDate: rawPlan['eventDate']?.toString() ?? 'Today',
    time: parsedTime,
    howLong: durationStr,
    whoPays: extractLabel(rawPlan['whoPays'], '🤝 Split'),
    groupSize: groupSizeVal,
    whoCanRequest: extractLabel(rawPlan['joinRequestGender'], 'Anyone'),
    visibility: extractLabel(rawPlan['visibility'], 'Premium 👑'),
    finalWhoCanJoin: groupSizeVal,
    verifiedMembersOnly: true,
    autoApproveRequests: false,
  );
}

String _getPlanEmoji(Map<String, dynamic> plan) {
  // User requested a single generic emoji for all plans
  // because the backend returns full photos for activity icons
  // which look weird as tiny 40x40 icons in the bottom sheet.
  return "⭐️";
}

void showManageBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  VoidCallback onPlanClosed,
) {
  String rawTitle = plan['title'] ?? '';
  String emoji = _getPlanEmoji(plan);
  String cleanTitle = rawTitle;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.only(
          top: 16,
          left: 24,
          right: 24,
          bottom: 16,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Emoji Icon
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFA6A85).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: emoji.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: emoji,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          errorWidget: (context, error, stackTrace) =>
                              const Text('☕', style: TextStyle(fontSize: 32)),
                        ),
                      )
                    : Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                cleanTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                plan['subtitle'] ?? 'Today · 6:00 PM · Blue Tokai',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              // Option 1: Edit plan details
              buildManageOptionRow(
                icon: '✏️',
                title: 'Edit plan details',
                subtitle: 'Change time, venue or bill',
                onTap: () {
                  Navigator.pop(context);
                  PostPlanState? stateToEdit;

                  if (plan.containsKey('originalState')) {
                    stateToEdit = plan['originalState'] as PostPlanState;
                  } else if (plan.containsKey('rawPlan')) {
                    stateToEdit = _parseRawPlanToState(plan['rawPlan']);
                  }

                  if (stateToEdit != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Activity1Screen(
                          initialState: stateToEdit,
                          initialStep: 4, // Step 4 is Review4View
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              // Option 2: End & review
              buildManageOptionRow(
                icon: '✔️',
                title: 'End & review',
                subtitle: 'After you\'ve met — leave feedback',
                onTap: () {
                  Navigator.pop(context); // Close manage bottom sheet
                  showReviewBottomSheet(
                    context,
                    plan,
                    onPlanClosed,
                  ); // Show review bottom sheet
                },
              ),
              const SizedBox(height: 12),
              // Option 3: Cancel plan
              buildManageOptionRow(
                icon: '🚫',
                title: 'Cancel plan',
                titleColor: const Color(0xFFDE2957),
                subtitle:
                    '${(plan['requests'] as List?)?.length ?? 3} people will be notified',
                backgroundColor: const Color(0xFFFA6A85).withValues(alpha: 0.08),
                onTap: () {
                  Navigator.pop(context);
                  showCancelPlanBottomSheet(context, plan, onPlanClosed);
                },
              ),
              const SizedBox(height: 24),
              // Close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildManageOptionRow({
  required String icon,
  required String title,
  required String subtitle,
  Color? titleColor,
  Color? backgroundColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF6F4EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void showReviewBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  VoidCallback onPlanClosed,
) {
  String rawTitle = plan['title'] ?? '';
  String emoji = _getPlanEmoji(plan);
  String cleanTitle = rawTitle;

  String? selectedOption; // To track selection: 'yes' or 'no'

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Emoji Icon
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA6A85).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: emoji.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: emoji,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, error, stackTrace) =>
                                  const Text(
                                    '☕',
                                    style: TextStyle(fontSize: 32),
                                  ),
                            ),
                          )
                        : Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'How did your plan go?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: cleanTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' · ${plan['subtitle'] ?? 'Today · 6:00 PM · Blue Tokai'} just wrapped. A quick recap helps us keep dates safe & real.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Question
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Did anyone come to meet you?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Options
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedOption = 'yes'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selectedOption == 'yes'
                                  ? const Color(0xFFFA6A85).withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: selectedOption == 'yes'
                                  ? Border.all(
                                      color: const Color(0xFFFA6A85),
                                      width: 1.5,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 1.5,
                                    ),
                              boxShadow: [
                                if (selectedOption != 'yes')
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.13),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🙌',
                                  style: TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Yes, we met',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Someone showed up',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedOption = 'no'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selectedOption == 'no'
                                  ? const Color(0xFFFA6A85).withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: selectedOption == 'no'
                                  ? Border.all(
                                      color: const Color(0xFFFA6A85),
                                      width: 1.5,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 1.5,
                                    ),
                              boxShadow: [
                                if (selectedOption != 'no')
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.13),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '😕',
                                  style: TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No one came',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nobody showed up',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Continue button
                  GestureDetector(
                    onTap: () {
                      if (selectedOption != null) {
                        final status = selectedOption == 'yes'
                            ? 'MET'
                            : 'NO_SHOW';
                        DateNowApiService.submitFeedbackIsMeet(
                          plan['id']?.toString() ?? '',
                          status,
                        );
                      }

                      if (selectedOption == 'yes') {
                        Navigator.pop(context);
                        showWhoCameBottomSheet(context, plan, onPlanClosed);
                      } else if (selectedOption == 'no') {
                        Navigator.pop(context);
                        showNoOneCameBottomSheet(context, plan, onPlanClosed);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedOption != null
                            ? null
                            : const Color(0xFFF1B4C3),
                        gradient: selectedOption != null
                            ? const LinearGradient(
                                colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Skip for now button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showWhoCameBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  VoidCallback onPlanClosed,
) {
  String rawTitle = plan['title'] ?? '';
  String cleanTitle = rawTitle;
  int firstSpaceIndex = rawTitle.indexOf(' ');
  if (firstSpaceIndex != -1 && firstSpaceIndex < 4) {
    cleanTitle = rawTitle.substring(firstSpaceIndex + 1).trim();
  }

  final List<dynamic> rawRequests = plan['requests'] ?? [];
  final List<Map<String, dynamic>> attendees = rawRequests
      .where((req) => req['status'] == 'approved')
      .map((req) {
        return {
          'id': req['userId']?.toString() ?? req['id']?.toString() ?? '',
          'name': '${req['name'] ?? ''}, ${req['age'] ?? ''}'.trim(),
          'match': req['match'] != null ? '${req['match']} match' : '',
          'avatar': req['avatar'] ?? '',
        };
      })
      .toList();

  int? selectedIndex;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Who came to meet you?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick the person you met from $cleanTitle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  // List of attendees
                  ...List.generate(attendees.length, (index) {
                    final isSelected = selectedIndex == index;
                    final attendee = attendees[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFA6A85).withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFFFA6A85),
                                  width: 1.5,
                                )
                              : Border.all(
                                  color: Colors.transparent,
                                  width: 1.5,
                                ),
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: attendee['avatar'] != null &&
                                      attendee['avatar'].toString().isNotEmpty
                                  ? CachedNetworkImageProvider(attendee['avatar'])
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        attendee['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    attendee['match'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Checkmark circle
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFFFA6A85)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFA6A85)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // Next button
                  GestureDetector(
                    onTap: () {
                      if (selectedIndex != null) {
                        final attendee = attendees[selectedIndex!];
                        DateNowApiService.submitFeedbackMetUser(
                          plan['id']?.toString() ?? '',
                          attendee['id']?.toString() ?? '',
                        );

                        Navigator.pop(context);
                        showFeedbackBottomSheet(
                          context,
                          plan,
                          attendee,
                          onPlanClosed,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedIndex != null
                            ? null
                            : const Color(0xFFF1B4C3),
                        gradient: selectedIndex != null
                            ? const LinearGradient(
                                colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showReviewBottomSheet(context, plan, onPlanClosed);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showFeedbackBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  Map<String, dynamic> attendee,
  VoidCallback onPlanClosed,
) {
  String rawTitle = plan['title'] ?? '';
  String emoji = _getPlanEmoji(plan);
  String cleanTitle = rawTitle;

  // Extract name (before comma)
  String attendeeName = attendee['name'].toString().split(',').first.trim();

  int overallExperience = 5;
  int ratePerson = 5;
  Set<String> selectedTags = {};

  final List<String> tags = [
    'Respectful',
    'Great conversation',
    'On time',
    'Genuine',
    'Fun',
    'Would meet again',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Widget buildStarRating(int rating, Function(int) onRatingChanged) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => onRatingChanged(index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.star_rounded,
                      color: index < rating
                          ? const Color(0xFFFFB800)
                          : Colors.grey.shade300,
                      size: 32,
                    ),
                  ),
                );
              }),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.9, // Avoid full screen
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle (fixed at top)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 0,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top profile card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F4EF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: attendee['avatar'] != null &&
                                            attendee['avatar'].toString().isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            attendee['avatar'],
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          attendeeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$emoji $cleanTitle',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Overall Experience
                            const Text(
                              'How was your overall experience?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildStarRating(
                              overallExperience,
                              (r) => setState(() => overallExperience = r),
                            ),
                            const SizedBox(height: 16),
                            // Rate Person
                            Text(
                              'Rate $attendeeName',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildStarRating(
                              ratePerson,
                              (r) => setState(() => ratePerson = r),
                            ),
                            const SizedBox(height: 16),
                            // What stood out
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: 'What stood out? '),
                                  TextSpan(
                                    text: '· optional',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tags wrap
                            Wrap(
                              spacing: 6,
                              runSpacing: 10,
                              children: tags.map((tag) {
                                final isSelected = selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedTags.remove(tag);
                                      } else {
                                        selectedTags.add(tag);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(
                                              0xFFFA6A85,
                                            ).withValues(alpha: 0.1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFA6A85)
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? const Color(0xFFFA6A85)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            // Text area
                            TextField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Anything else about the date? (private)',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFA6A85),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fixed Bottom Buttons
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Submit button
                          GestureDetector(
                            onTap: () {
                              if (overallExperience > 0 && ratePerson > 0) {
                                final apiTags = selectedTags
                                    .map(
                                      (tag) => tag.toUpperCase().replaceAll(
                                        ' ',
                                        '_',
                                      ),
                                    )
                                    .toList();
                                DateNowApiService.submitFeedbackExperience(
                                  plan['id']?.toString() ?? '',
                                  overallExperience,
                                  ratePerson,
                                  apiTags,
                                );

                                Navigator.pop(context);
                                showThanksBottomSheet(
                                  context,
                                  plan,
                                  attendee,
                                  overallExperience,
                                  ratePerson,
                                  onPlanClosed,
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: (overallExperience > 0 && ratePerson > 0)
                                    ? const Color(0xFFE43A6A)
                                    : const Color(0xFFF1B4C3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Submit feedback',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Back button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showWhoCameBottomSheet(
                                context,
                                plan,
                                onPlanClosed,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showThanksBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  Map<String, dynamic> attendee,
  int overallExperience,
  int ratePerson,
  VoidCallback onPlanClosed,
) {
  String attendeeName = attendee['name'].toString().split(',').first.trim();

  Widget buildSmallStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          color: index < rating
              ? const Color(0xFFFFB800)
              : const Color(0xFFFA6A85).withValues(alpha: 0.05),
          size: 20,
        );
      }),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Thanks for sharing 💜',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your feedback on the date with $attendeeName is saved. It helps us protect everyone and surface genuine people.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F4EF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Experience',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  buildSmallStarRating(overallExperience),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    attendeeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  buildSmallStarRating(ratePerson),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 16,
                    bottom: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          showReportIssueBottomSheet(
                            context,
                            plan,
                            attendee,
                            onPlanClosed,
                            overallExperience,
                            ratePerson,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFFA6A85).withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '⚠',
                                  style: TextStyle(
                                    color: Color(0xFFDE2957),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Report an issue',
                                  style: TextStyle(
                                    color: Color(0xFFDE2957),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // Move to history as MET
                          CardHistory.thisWeekPlans.insert(0, {
                            'title': plan['title'],
                            'date':
                                (plan['subtitle'] as String).split('·').length >
                                    1
                                ? (plan['subtitle'] as String)
                                      .split('·')[1]
                                      .trim()
                                : plan['subtitle'],
                            'location':
                                (plan['subtitle'] as String).split('·').length >
                                    2
                                ? (plan['subtitle'] as String)
                                      .split('·')[2]
                                      .trim()
                                : plan['subtitle'],
                            'image': plan['imageUrl'],
                            'status': 'MET',
                            'partnerName': attendee['name'],
                            'partnerAvatar': attendee['avatar'],
                            'partnerStatus': 'Met on this plan',
                            'rating': ratePerson,
                            'note': 'You both showed up. Good experience!',
                            'views': 120,
                            'requests':
                                (plan['requests'] as List?)?.length ?? 0,
                            'split': (plan['tags'] as List).isNotEmpty
                                ? plan['tags'][0]
                                : 'Split',
                            'boost': 'No',
                          });
                          MyPlanScreen.myHostedPlans.remove(plan);

                          Navigator.pop(context);
                          _showFeedbackSavedSnackBar(
                            context,
                            'Plan closed · feedback saved',
                          );
                          onPlanClosed();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showReportIssueBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  Map<String, dynamic> attendee,
  VoidCallback onPlanClosed, [
  int overallExperience = 0,
  int ratePerson = 0,
]) {
  Set<String> selectedTags = {};
  String issueDescription = '';
  final List<String> tags = [
    'Didn\'t show as described',
    'Made me uncomfortable',
    'Inappropriate behaviour',
    'Fake profile',
    'Safety concern',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 16,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFA6A85).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.warning_rounded,
                                  size: 32,
                                  color: Color(0xFFDE2957),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Report an issue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your safety matters. Tell us what went wrong — this is confidential and reviewed by our team.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: tags.map((tag) {
                                final isSelected = selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedTags.remove(tag);
                                      } else {
                                        selectedTags.add(tag);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(
                                              0xFFFA6A85,
                                            ).withValues(alpha: 0.1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFA6A85)
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? const Color(0xFFFA6A85)
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              maxLines: 4,
                              onChanged: (val) =>
                                  setState(() => issueDescription = val),
                              decoration: InputDecoration(
                                hintText: 'Describe what happened...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFA6A85),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 16,
                        bottom: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (issueDescription.trim().isNotEmpty) {
                                String reportReason = selectedTags.isNotEmpty
                                    ? selectedTags.first
                                          .toUpperCase()
                                          .replaceAll('\'', '')
                                          .replaceAll(' ', '_')
                                    : 'SAFETY_CONCERN';

                                DateNowApiService.submitReportIssue(
                                  plan['id']?.toString() ?? '',
                                  reportReason,
                                  issueDescription.trim(),
                                );

                                // Move to history as REPORTED/NO-SHOW
                                CardHistory.thisWeekPlans.insert(0, {
                                  'title': plan['title'],
                                  'date':
                                      (plan['subtitle'] as String)
                                              .split('·')
                                              .length >
                                          1
                                      ? (plan['subtitle'] as String)
                                            .split('·')[1]
                                            .trim()
                                      : plan['subtitle'],
                                  'location':
                                      (plan['subtitle'] as String)
                                              .split('·')
                                              .length >
                                          2
                                      ? (plan['subtitle'] as String)
                                            .split('·')[2]
                                            .trim()
                                      : plan['subtitle'],
                                  'image': plan['imageUrl'],
                                  'status': ratePerson > 0 ? 'MET' : 'NO-SHOW',
                                  'partnerName': attendee['name'],
                                  'partnerAvatar': attendee['avatar'],
                                  'partnerStatus': ratePerson > 0
                                      ? 'Met on this plan'
                                      : 'Reported issue',
                                  'rating': ratePerson,
                                  'note':
                                      'Reported an issue: ${issueDescription.trim()}',
                                  'views': 120,
                                  'requests':
                                      (plan['requests'] as List?)?.length ?? 0,
                                  'split': (plan['tags'] as List).isNotEmpty
                                      ? plan['tags'][0]
                                      : 'Split',
                                  'boost': 'No',
                                });
                                MyPlanScreen.myHostedPlans.remove(plan);

                                Navigator.pop(context);
                                _showFeedbackSavedSnackBar(
                                  context,
                                  'Report submitted',
                                );
                                onPlanClosed();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: issueDescription.trim().isNotEmpty
                                    ? null
                                    : const Color(0xFFF1B4C3),
                                gradient: issueDescription.trim().isNotEmpty
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFA6A85),
                                          Color(0xFFDE2957),
                                        ],
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Submit report',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showThanksBottomSheet(
                                context,
                                plan,
                                attendee,
                                overallExperience,
                                ratePerson,
                                onPlanClosed,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showNoOneCameBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  VoidCallback onPlanClosed,
) {
  int planQuality = 0;
  Set<String> selectedTags = {};
  final List<String> tags = [
    'Timing was off',
    'Venue too far',
    'Short notice',
    'Approved too late',
    'Not sure',
  ];

  Widget buildStarRating(int rating, Function(int) onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              Icons.star_rounded,
              color: index < rating
                  ? const Color(0xFFFFB800)
                  : const Color(0xFFFA6A85).withValues(alpha: 0.1),
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          bool isFormValid = planQuality > 0;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 16,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0E6),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '😞',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Sorry no one showed up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'It happens. Your honest take helps us improve who sees your plans next time.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Plan quality
                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Was your plan itself good?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            buildStarRating(
                              planQuality,
                              (r) => setState(() => planQuality = r),
                            ),
                            const SizedBox(height: 24),
                            // What happened tags
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'What do you think happened? ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '· optional',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: tags.map((tag) {
                                  final isSelected = selectedTags.contains(tag);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedTags.remove(tag);
                                        } else {
                                          selectedTags.add(tag);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(
                                                0xFFFA6A85,
                                              ).withValues(alpha: 0.1)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFFA6A85)
                                              : Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFFFA6A85)
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Submit button
                          GestureDetector(
                            onTap: () {
                              if (isFormValid) {
                                String noShowReason = selectedTags.isNotEmpty
                                    ? selectedTags.first
                                          .toUpperCase()
                                          .replaceAll(' ', '_')
                                    : 'NOT_SURE';

                                DateNowApiService.submitFeedbackNoShow(
                                  plan['id']?.toString() ?? '',
                                  planQuality,
                                  noShowReason,
                                );

                                // Move to history as NO-SHOW
                                CardHistory.thisWeekPlans.insert(0, {
                                  'title': plan['title'],
                                  'date':
                                      (plan['subtitle'] as String)
                                              .split('·')
                                              .length >
                                          1
                                      ? (plan['subtitle'] as String)
                                            .split('·')[1]
                                            .trim()
                                      : plan['subtitle'],
                                  'location':
                                      (plan['subtitle'] as String)
                                              .split('·')
                                              .length >
                                          2
                                      ? (plan['subtitle'] as String)
                                            .split('·')[2]
                                            .trim()
                                      : plan['subtitle'],
                                  'image': plan['imageUrl'],
                                  'status': 'NO-SHOW',
                                  'note': 'No one came. Feedback recorded.',
                                  'views': 120,
                                  'requests':
                                      (plan['requests'] as List?)?.length ?? 0,
                                  'split': (plan['tags'] as List).isNotEmpty
                                      ? plan['tags'][0]
                                      : 'Split',
                                  'boost': 'No',
                                });
                                MyPlanScreen.myHostedPlans.remove(plan);

                                Navigator.pop(context);
                                _showFeedbackSavedSnackBar(
                                  context,
                                  'Plan closed · feedback saved',
                                );
                                onPlanClosed();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isFormValid
                                    ? const Color(0xFFE43A6A)
                                    : const Color(0xFFF1B4C3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Submit & close plan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Back button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showReviewBottomSheet(
                                context,
                                plan,
                                onPlanClosed,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showCancelPlanBottomSheet(
  BuildContext context,
  Map<String, dynamic> plan,
  VoidCallback onPlanClosed,
) {
  String rawTitle = plan['title'] ?? '';
  String cleanTitle = rawTitle;
  int firstSpaceIndex = rawTitle.indexOf(' ');
  if (firstSpaceIndex != -1 && firstSpaceIndex < 4) {
    cleanTitle = rawTitle.substring(firstSpaceIndex + 1).trim();
  }
  int numRequests = (plan['requests'] as List?)?.length ?? 3;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFA6A85).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🚫', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Cancel this plan?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Your plan '),
                            TextSpan(
                              text: cleanTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const TextSpan(text: ' will be taken down. '),
                            TextSpan(
                              text: '$numRequests',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' people who requested will be notified it\'s cancelled.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Cancel plan button
                      GestureDetector(
                        onTap: () {
                          DateNowApiService.cancelDatePlan(
                            plan['id']?.toString() ?? '',
                          );

                          // Move to history
                          CardHistory.thisWeekPlans.insert(0, {
                            'title': plan['title'],
                            'date':
                                (plan['subtitle'] as String).split('·').length >
                                    1
                                ? (plan['subtitle'] as String)
                                      .split('·')[1]
                                      .trim()
                                : plan['subtitle'],
                            'location':
                                (plan['subtitle'] as String).split('·').length >
                                    2
                                ? (plan['subtitle'] as String)
                                      .split('·')[2]
                                      .trim()
                                : plan['subtitle'],
                            'image': plan['imageUrl'],
                            'status': 'CANCELLED',
                            'note':
                                'You cancelled this plan. All requesters were notified automatically.',
                            'views': 120,
                            'requests':
                                (plan['requests'] as List?)?.length ?? 0,
                            'split': (plan['tags'] as List).isNotEmpty
                                ? plan['tags'][0]
                                : 'Split',
                            'boost': 'No',
                          });

                          // Remove from active plans
                          MyPlanScreen.myHostedPlans.remove(plan);

                          Navigator.pop(context);
                          _showFeedbackSavedSnackBar(context, 'Plan cancelled');
                          onPlanClosed();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDC4D4D), Color(0xFFC63333)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Back button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          showManageBottomSheet(context, plan, onPlanClosed);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
