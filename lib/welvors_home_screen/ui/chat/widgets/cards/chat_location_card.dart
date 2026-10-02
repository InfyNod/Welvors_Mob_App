import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velvors/utils/navigation/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import '../../chat_bloc/chat_state.dart';
import '../chat_format_utils.dart';

/// Card for shared location with inline GoogleMap preview and tap to full screen
class ChatLocationCard extends StatelessWidget {
  final ChatMessage message;

  const ChatLocationCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final latitude = message.latitude;
    final longitude = message.longitude;
    final hasCoordinates = latitude != null && longitude != null;
    final locationText = (message.locationLabel ?? message.text).trim();
    final address = locationText.isEmpty ? 'Location' : locationText;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasCoordinates
            ? () {
                context.push(
                  AppRoutes.locationMap,
                  extra: {
                    'latitude': latitude,
                    'longitude': longitude,
                    'label': address,
                  },
                );
              }
            : null,
        child: Container(
          width: 310,
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
              bottomLeft: Radius.circular(message.isMine ? 24 : 0),
              bottomRight: Radius.circular(message.isMine ? 0 : 24),
            ),
            boxShadow: AppColors.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 155,
                width: double.infinity,
                child: hasCoordinates
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 15.5,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('chat_${message.id}'),
                            position: LatLng(latitude, longitude),
                          ),
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        liteModeEnabled: true,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      )
                    : Container(
                        color: AppColors.primarySoft,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 50,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: AppText.h2.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            address,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sub.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    if (hasCoordinates)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              // ── Time + seen / unseen ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      ChatFormatUtils.formatMessageTime(message.time),
                      style: AppText.sub.copyWith(
                        fontSize: 12,
                        color: message.isMine
                            ? const Color(0xFFB07B8D)
                            : AppColors.muted,
                      ),
                    ),
                    if (message.isMine) ...[
                      const SizedBox(width: 4),
                      Text(
                        message.seen
                            ? ' ✓✓'
                            : (message.delivered ? ' ✓✓' : '  ✓'),
                        style: AppText.body.copyWith(
                          color: message.seen
                              ? AppColors.primary
                              : const Color(0xFFB07B8D),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
