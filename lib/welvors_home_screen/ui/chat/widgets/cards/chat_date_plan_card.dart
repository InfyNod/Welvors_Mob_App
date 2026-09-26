import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/send_request_drawer.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';

/// Card for DateNow plans with event details, timings, and Request to Join button
class ChatDatePlanCard extends StatelessWidget {
  final ChatMessage message;
  final String liveName;
  final int liveAge;

  const ChatDatePlanCard({
    super.key,
    required this.message,
    required this.liveName,
    required this.liveAge,
  });

  @override
  Widget build(BuildContext context) {
    final hasStats =
        message.inviteStats != null && message.inviteStats!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: message.isMine ? 20 : 0,
        right: message.isMine ? 0 : 20,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(message.isMine ? 24 : 0),
            bottomRight: Radius.circular(message.isMine ? 0 : 24),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.eventHeroImage != null)
              Stack(
                children: [
                  SizedBox(
                    height: 165,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                        child: SizedBox(
                          width: double.infinity,
                          height: 185,
                          child: CachedNetworkImage(
                            imageUrl: message.eventHeroImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (_, _, _) => const Center(
                              child: Icon(Icons.image_not_supported_outlined, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (message.inviteBadge != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: message.inviteBadge != 'LIVE NOW'
                              ? const Color(0xfffff4e0)
                              : const Color(0xff3d945f),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message.inviteBadge == 'LIVE NOW'
                              ? "● LIVE NOW"
                              : "● AWAITING RSVP",
                          style: AppText.pill.copyWith(
                            color: message.inviteBadge != 'LIVE NOW'
                                ? const Color(0xff8a6010)
                                : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 160,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.eventTitle != null)
                            Text(
                              message.eventTitle!,
                              style: AppText.h2.copyWith(fontSize: 18, color: Colors.white),
                            ),
                          if (message.inviteVenue != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    message.inviteVenue!,
                                    style: AppText.body.copyWith(color: Colors.white, fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.inviteStatus == 'LIVE') hSized20,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.eventDate != null)
                        Builder(
                          builder: (context) {
                            final date = DateTime.tryParse(message.eventDate!);
                            if (date == null) return const SizedBox.shrink();

                            const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                            const months = [
                              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                            ];

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.colorf3d4dc, width: 1),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    days[date.weekday - 1],
                                    style: AppText.pill.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: AppText.h2.copyWith(
                                      color: Colors.black,
                                      fontSize: 20,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    months[date.month - 1],
                                    style: AppText.pill.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.eventStartTime != null)
                              Row(
                                children: [
                                  Text(
                                    ChatFormatUtils.formatMessageTime(message.eventStartTime!),
                                    style: AppText.h2.copyWith(fontSize: 16),
                                  ),
                                  if (message.eventEndTime != null)
                                    Text(
                                      " - ${ChatFormatUtils.formatMessageTime(message.eventEndTime!)}",
                                      style: AppText.h2.copyWith(fontSize: 16),
                                    ),
                                ],
                              ),
                            if (message.eventVenueName != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                message.eventVenueName!,
                                style: AppText.body.copyWith(
                                  color: AppColors.colorc7395e,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  hSized5,
                  Divider(height: 20, thickness: 1, color: AppColors.line),
                  hSized5,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xfff3d4dc),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      wSized10,
                      Expanded(
                        child: Text(
                          '"Come with me? — pick how you\'d like to book. 💜"',
                          style: AppText.body.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.ink60,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (hasStats) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final entry in message.inviteStats!.entries) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppText.body.copyWith(
                                      color: AppColors.ink60,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style: AppText.body.copyWith(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (entry.key != message.inviteStats!.entries.last.key)
                              const Divider(height: 2, color: Color(0xFFF3E2E6)),
                          ],
                        ],
                      ),
                    ),
                  ],
                  hSized10,
                  const SizedBox(height: 10),
                  if (message.isMine)
                    const Text(
                      "You sent a date plan",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    )
                  else if (message.isAlreadyRequested != true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final requestSent = await showRequestDateBottomSheet(
                                  context,
                                  {
                                    "id": message.dateplanid,
                                    "imageUrl": message.imageUrl,
                                    "location": message.inviteSafetyNote ?? '',
                                    "date": "📅 ${message.eventDate?.toString().substring(0, 10) ?? ''}",
                                    "time": "🕔 ${message.eventType?.toString() ?? ''}",
                                    "type": message.eventType,
                                    "title": message.eventTitle,
                                    "people": "⏱️ ${message.inviteStats} mins",
                                    "pay": message.inviteStats,
                                    "name": "$liveName, $liveAge",
                                    "userId": message.senderId,
                                    "verified": "false",
                                    "nameSubtitle": "Host",
                                    "avatarUrl": "https://ik.imagekit.io/hzyuadmua/user-photos/upload_1788931884236_znX2xo652.jpg",
                                  },
                                );

                                if (requestSent == true) {
                                  message.isAlreadyRequested = true;
                                }
                              },
                              child: _buildButton(label: "Request to join", primary: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "🛡️ Venue: ${message.inviteSafetyNote ?? ""}",
                            style: AppText.body.copyWith(
                              color: AppColors.green,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  hSized10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        ChatFormatUtils.formatMessageTime(message.time),
                        style: AppText.body.copyWith(
                          color: const Color(0xff928d89),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ((message.isMine)
                            ? (message.seen ? ' ✓✓' : '  ✓')
                            : ""),
                        style: AppText.body.copyWith(
                          color: message.seen
                              ? AppColors.primary
                              : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required bool primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: primary ? AppColors.colore85a7a : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: primary
            ? Border.all(color: AppColors.colore85a7a)
            : Border.all(color: AppColors.line),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(
            color: primary ? AppColors.white : AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
