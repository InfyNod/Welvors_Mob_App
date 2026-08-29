import 'package:flutter/material.dart';

class EventItineraryAndLocationSection extends StatelessWidget {
  final List<dynamic>? itinerary;
  final String? locationTitle;
  final String? fullAddress;

  const EventItineraryAndLocationSection({
    super.key,
    this.itinerary,
    this.locationTitle,
    this.fullAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Itinerary
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
            children: itinerary != null && itinerary!.isNotEmpty
                ? itinerary!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildTimelineItem(
                      item: item,
                      isLast: index == itinerary!.length - 1,
                    );
                  }).toList()
                : [
                    _buildTimelineItem(
                      item: {
                        'time': '7:00 PM',
                        'title': 'Welcome Drinks',
                        'description':
                            'Arrival and complimentary sparkling wine',
                      },
                      isLast: false,
                    ),
                    _buildTimelineItem(
                      item: {
                        'time': '8:00 PM',
                        'title': 'Icebreaker Rounds',
                        'description': 'Guided 5-minute curated conversations',
                      },
                      isLast: false,
                    ),
                    _buildTimelineItem(
                      item: {
                        'time': '9:30 PM',
                        'title': 'Open Socializing',
                        'description':
                            'Free mixing with live DJ and appetizers',
                      },
                      isLast: true,
                    ),
                  ],
          ),
        ),
        const SizedBox(height: 10),

        // Location
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.map_outlined,
                color: Color(0xFFE43A6A), // Pink icon
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationTitle ?? 'The Rooftop Lounge',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fullAddress ??
                          '452 Linking Road, Floor 12, Bandra West, Mumbai',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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

    final String? dayNumber = item['dayNumber']?.toString();
    final String? date = item['date']?.toString();
    final String? elevation = item['elevation']?.toString();
    final String? distance = item['distance']?.toString();
    final String? meals = item['meals']?.toString();
    final String? accommodation = item['accommodation']?.toString();
    final String? location = item['location']?.toString();

    String headerText = '';
    if (dayNumber != null && dayNumber != 'null' && dayNumber.isNotEmpty) {
      headerText += 'Day $dayNumber';
    }
    if (timeStr.isNotEmpty) {
      if (headerText.isNotEmpty) headerText += ' · ';
      headerText += timeStr;
    }

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
              padding: const EdgeInsets.only(bottom: 24),
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
                          _buildItineraryChip(Icons.location_on, location),
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

  Widget _buildItineraryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFE43A6A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylizedMap() {
    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    color: Colors.white.withOpacity(0.4),
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
                    color: Colors.white.withOpacity(0.4),
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
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            // Location Pin
            const Icon(
              Icons.location_on,
              color: Color(0xFFE43A6A), // Pink pin
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
