import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/event_details.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';

/// Card for event invites and RSVP cards with rich banner, date badge, details, and Book Now button
class ChatEventInviteCard extends StatelessWidget {
  final ChatMessage message;

  const ChatEventInviteCard({
    super.key,
    required this.message,
  });

  static String getEventPrice(BuildContext context, ChatMessage message) {
    final gender =
        context
            .read<ProfileEditCubit>()
            .state
            .gender
            .toString()
            .trim()
            .toLowerCase();

    String? originalPrice;
    String? discountedPrice;

    if (gender == 'woman') {
      originalPrice = message.eventWomenEntryPrice;
      discountedPrice = message.eventWomenDiscountedPrice;
    } else if (gender == 'man') {
      originalPrice = message.eventMenEntryPrice;
      discountedPrice = message.eventMenDiscountedPrice;
    } else {
      discountedPrice = message.eventOtherDiscountedPrice;
    }

    final discounted = double.tryParse(discountedPrice ?? '');
    if (discounted != null && discounted > 0) {
      return discounted == discounted.truncateToDouble()
          ? '₹${discounted.toInt()}'
          : '₹${discounted.toStringAsFixed(1)}';
    }

    final original = double.tryParse(originalPrice ?? '');
    if (original != null && original > 0) {
      return original == original.truncateToDouble()
          ? '₹${original.toInt()}'
          : '₹${original.toStringAsFixed(1)}';
    }

    return 'Free';
  }

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
                      padding: (message.inviteBadge == 'LIVE NOW')
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(top: 35),
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
                  if (message.inviteBadge != 'LIVE NOW')
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Mycolor.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  if (message.eventType != 'LIVE NOW')
                    Positioned(
                      top: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        decoration: BoxDecoration(
                          color: message.eventType == 'LIVE NOW'
                              ? AppColors.green
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "🎟️ ",
                              style: AppText.pill.copyWith(
                                color: Mycolor.redlight,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              message.eventType.toString(),
                              style: AppText.pill.copyWith(
                                color: Mycolor.redlight,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
                  if (message.inviteBadge == 'LIVE NOW' && message.inviteEyebrow != null)
                    SizedBox(
                      height: 150,
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
                                style: AppText.h2.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            if (message.inviteVenue != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      message.inviteVenue!,
                                      style: AppText.body.copyWith(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                      ),
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
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      hSized10,
                      if (message.eventTitle != null)
                        Text(
                          message.eventTitle!,
                          style: AppText.h2.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      hSized10,
                    ],
                  ),
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
                              Text(
                                ChatFormatUtils.formatMessageTime(message.eventStartTime!),
                                style: AppText.h2.copyWith(fontSize: 16),
                              ),
                            if (message.eventVenueName != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                message.eventVenueName!,
                                style: AppText.body.copyWith(
                                  color: AppColors.colorc7395e,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
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
                  if (message.inviteStatus == 'LIVE') ...[
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
                  ],
                  if (message.eventFullAddress != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "📍 ${message.eventFullAddress}",
                            style: AppText.body.copyWith(
                              color: AppColors.ink60,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (message.eventMenEntryPrice != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "🎫  ₹ ${message.eventMenEntryPrice!} per person",
                          style: AppText.body.copyWith(
                            color: AppColors.ink60,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "🛡  Verified-only entry · safety team on site",
                          style: AppText.body.copyWith(
                            color: AppColors.ink60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  hSized5,
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                  if (message.isMine) ...[
                    hSized10,
                    Text(
                      "BOOKING",
                      style: AppText.body.copyWith(
                        color: AppColors.ink60,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (!message.isEventBook)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              final featureTags =
                                  (message.eventSafetyFeatures as List? ?? [])
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final index = entry.key;
                                        final feature = entry.value;
                                        return {
                                          'id': feature is Map
                                              ? feature['id']?.toString() ?? ''
                                              : '',
                                          'label': feature is Map
                                              ? feature['label']?.toString() ?? ''
                                              : feature.toString(),
                                          'displayOrder': index,
                                        };
                                      })
                                      .toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                    eventId: message.eventId.toString(),
                                    title: message.eventTitle.toString(),
                                    date: message.eventDate.toString(),
                                    location: message.eventFullAddress.toString(),
                                    imageUrl: message.eventHeroImage.toString(),
                                    status: message.eventType.toString(),
                                    price: getEventPrice(context, message),
                                    featureTags: featureTags,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.80,
                              decoration: BoxDecoration(
                                color: Mycolor.pink,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(
                                    color: Mycolor.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  hSized10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        ChatFormatUtils.formatMessageTime(message.time) +
                            ((message.isMine)
                                ? (message.seen ? ' ✓✓' : ' ✓')
                                : ""),
                        style: AppText.body.copyWith(
                          color: const Color(0xff928d89),
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
}
