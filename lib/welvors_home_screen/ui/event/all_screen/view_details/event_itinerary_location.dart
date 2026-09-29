import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';
import 'package:velvors/config/custom_snackbar.dart';

class EventItineraryAndLocationSection extends StatefulWidget {
  final List<dynamic>? itinerary;
  final String? locationTitle;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String? googleMapUrl;

  const EventItineraryAndLocationSection({
    super.key,
    this.itinerary,
    this.locationTitle,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.googleMapUrl,
  });

  @override
  State<EventItineraryAndLocationSection> createState() =>
      _EventItineraryAndLocationSectionState();
}

class _EventItineraryAndLocationSectionState
    extends State<EventItineraryAndLocationSection> {
  final Map<String, bool> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedItinerary = {};
    if (widget.itinerary != null && widget.itinerary!.isNotEmpty) {
      for (var item in widget.itinerary!) {
        final dayNumber = item['dayNumber']?.toString();
        final date = item['date']?.toString();
        String groupKey = '';

        if (dayNumber != null && dayNumber != 'null' && dayNumber.isNotEmpty) {
          groupKey = 'Day $dayNumber';
        } else if (date != null && date != 'null' && date.isNotEmpty) {
          groupKey = date;
        } else {
          groupKey = 'Schedule';
        }

        groupedItinerary.putIfAbsent(groupKey, () => []).add(item);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Itinerary
        if (widget.itinerary != null && widget.itinerary!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Event Itinerary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: groupedItinerary.entries.map((entry) {
                final groupKey = entry.key;
                final items = entry.value;
                final isExpanded = _expandedGroups[groupKey] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header for the Group (only if it's explicitly a Day or we have multiple groups)
                      if (groupedItinerary.length > 1 || groupKey != 'Schedule')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(
                              0xFFFFF0F5,
                            ), // Light pink background for header
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            groupKey,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE43A6A),
                            ),
                          ),
                        ),
                      // Items inside the group
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              ...items
                                  .asMap()
                                  .entries
                                  .where((itemEntry) {
                                    return isExpanded || itemEntry.key < 1;
                                  })
                                  .map((itemEntry) {
                                    final index = itemEntry.key;
                                    final item = itemEntry.value;
                                    final isLastVisible = isExpanded
                                        ? index == items.length - 1
                                        : (index == 0 ||
                                              index == items.length - 1);
                                    return _buildTimelineItem(
                                      item: item as Map<String, dynamic>,
                                      isLast: isLastVisible,
                                    );
                                  })
                                  ,
                              if (items.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _expandedGroups[groupKey] = !isExpanded;
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isExpanded
                                                ? 'Show Less'
                                                : 'Show More',
                                            style: const TextStyle(
                                              color: Color(0xFFE43A6A),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: const Color(0xFFE43A6A),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 5),
        ],

        // Location
        if ((widget.locationTitle != null &&
                widget.locationTitle!.isNotEmpty) ||
            (widget.fullAddress != null && widget.fullAddress!.isNotEmpty)) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStylizedMap(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openGoogleMaps(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE43A6A).withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          color: Color(0xFFE43A6A), // Pink icon
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.locationTitle != null &&
                                widget.locationTitle!.isNotEmpty) ...[
                              Text(
                                widget.locationTitle!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (widget.fullAddress != null &&
                                widget.fullAddress!.isNotEmpty)
                              Text(
                                widget.fullAddress!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions,
                          color: Color(0xFFE43A6A),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildTimelineItem({
    required Map<String, dynamic> item,
    required bool isLast,
  }) {
    final String timeStr = item['time']?.toString() ?? '';
    final String title = item['title']?.toString() ?? '';
    final String subtitle = item['description']?.toString() ?? '';

    final String? elevation = item['elevation']?.toString();
    final String? distance = item['distance']?.toString();
    final String? meals = item['meals']?.toString();
    final String? accommodation = item['accommodation']?.toString();
    final String? location = item['location']?.toString();

    String headerText = timeStr;

    final hasExtraDetails =
        (elevation != null && elevation != 'null' && elevation.isNotEmpty) ||
        (distance != null && distance != 'null' && distance.isNotEmpty) ||
        (meals != null && meals != 'null' && meals.isNotEmpty) ||
        (accommodation != null &&
            accommodation != 'null' &&
            accommodation.isNotEmpty) ||
        (location != null && location != 'null' && location.isNotEmpty);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE43A6A), // Pink dot
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.5, color: Colors.grey.shade200),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 8 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      children: [
                        if (headerText.isNotEmpty) ...[
                          TextSpan(
                            text: headerText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' · '),
                        ],
                        TextSpan(
                          text: title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (hasExtraDetails) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (location != null &&
                            location != 'null' &&
                            location.isNotEmpty)
                          _buildItineraryChip(
                            Icons.location_on,
                            location,
                            isLocation: true,
                          ),
                        if (distance != null &&
                            distance != 'null' &&
                            distance.isNotEmpty)
                          _buildItineraryChip(Icons.directions_walk, distance),
                        if (elevation != null &&
                            elevation != 'null' &&
                            elevation.isNotEmpty)
                          _buildItineraryChip(Icons.terrain, elevation),
                        if (meals != null &&
                            meals != 'null' &&
                            meals.isNotEmpty)
                          _buildItineraryChip(Icons.restaurant, meals),
                        if (accommodation != null &&
                            accommodation != 'null' &&
                            accommodation.isNotEmpty)
                          _buildItineraryChip(Icons.hotel, accommodation),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryChip(
    IconData icon,
    String label, {
    bool isLocation = false,
  }) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocation ? const Color(0xFFFFF0F3) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLocation
              ? const Color(0xFFE43A6A).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFE43A6A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isLocation ? const Color(0xFFE43A6A) : Colors.black87,
            ),
          ),
        ],
      ),
    );

    if (isLocation) {
      return InkWell(
        onTap: () => _openGoogleMaps(customQuery: label),
        borderRadius: BorderRadius.circular(6),
        child: chip,
      );
    }
    return chip;
  }

  Widget _buildStylizedMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGoogleMaps(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFD4E6EC), // Light blue map background
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dummy map lines for styling
                  Positioned(
                    left: -50,
                    top: 20,
                    child: Container(
                      width: 500,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -100,
                    bottom: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 50,
                    child: Container(
                      width: 3,
                      height: 200,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  // Location Pin
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFE43A6A), // Pink pin
                    size: 40,
                  ),
                  // Floating "Open in Maps" badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.near_me,
                            color: Color(0xFFE43A6A),
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Open Maps',
                            style: TextStyle(
                              color: Color(0xFFE43A6A),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps({String? customQuery}) async {
    // 1. If custom query is provided (e.g. from itinerary stop)
    if (customQuery != null && customQuery.trim().isNotEmpty) {
      final query = Uri.encodeComponent(customQuery.trim());
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
      );
      await _launchMapUrl(url);
      return;
    }

    // 2. Direct map URL if available
    final mapUrl = widget.googleMapUrl;
    if (mapUrl != null &&
        mapUrl.trim().isNotEmpty &&
        mapUrl.startsWith('http')) {
      final uri = Uri.tryParse(mapUrl.trim());
      if (uri != null) {
        final success = await _launchMapUrl(uri);
        if (success) return;
      }
    }

    // 3. Latitude & Longitude if available
    if (widget.latitude != null && widget.longitude != null) {
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
      );
      await _launchMapUrl(url);
      return;
    }

    // 4. Fallback to address string
    final address = (widget.fullAddress != null &&
            widget.fullAddress!.trim().isNotEmpty &&
            widget.fullAddress != 'Venue details will be shared')
        ? widget.fullAddress!.trim()
        : widget.locationTitle?.trim();

    if (address != null && address.isNotEmpty && address != 'Location') {
      final query = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
      );
      await _launchMapUrl(url);
      return;
    }

    if (mounted) {
      CustomSnackBar.showInfo(
        context,
        'Location details will be shared closer to the event date.',
        title: 'Location Notice',
      );
    }
  }

  Future<bool> _launchMapUrl(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return true;
    } catch (e) {
      AppLogger.e('EventItineraryAndLocation', 'Could not open map: $e');
      if (mounted) {
        CustomSnackBar.showError(
          context,
          'Unable to open map application. Please try again.',
          title: 'Map Error',
        );
      }
      return false;
    }
  }
}
