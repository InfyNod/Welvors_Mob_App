import 'package:flutter/material.dart';

class EventMoreDetailsSection extends StatelessWidget {
  final String? aboutEvent;
  final List<dynamic>? galleryImages;
  final List<dynamic>? whyShouldCome;

  const EventMoreDetailsSection({
    super.key,
    this.aboutEvent,
    this.galleryImages,
    this.whyShouldCome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Photos
        if (galleryImages != null && galleryImages!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Event Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: galleryImages!.map((img) {
                String url = '';
                if (img is Map) {
                  url = img['imageUrl']?.toString() ?? '';
                } else {
                  url = img.toString();
                }
                return _buildPhotoCard(url);
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // About the Event
        if (aboutEvent != null && aboutEvent!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'About the Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              aboutEvent!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Why You Should Come
        if (whyShouldCome != null && whyShouldCome!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Why You Should Come',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: whyShouldCome!.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final iconName = item['icon'] as String?;
                final iconData = _getIconForString(iconName);
                final bgColor = _getIconBgColor(index);

                return Column(
                  children: [
                    _buildWhyItem(
                      icon: Icon(iconData, size: 18, color: Colors.black87),
                      iconBgColor: bgColor,
                      title: item['title'] ?? '',
                      subtitle: item['description'] ?? '',
                    ),
                    if (index < whyShouldCome!.length - 1)
                      Divider(height: 1, color: Colors.grey.shade100),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getIconForString(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'users':
        return Icons.people_outline;
      case 'building':
        return Icons.business;
      case 'star':
        return Icons.star_border;
      case 'check':
        return Icons.check;
      case 'heart':
        return Icons.favorite_border;
      case 'music':
        return Icons.music_note;
      case 'drink':
        return Icons.local_bar;
      case 'food':
        return Icons.restaurant;
      case 'map':
        return Icons.map_outlined;
      case 'date':
        return Icons.calendar_today;
      case 'time':
        return Icons.access_time;
      case 'shield':
        return Icons.shield_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getIconBgColor(int index) {
    const colors = [
      Color(0xFFF3E5F5), // Light purple
      Color(0xFFE8F5E9), // Light green
      Color(0xFFFFF3E0), // Light orange
      Color(0xFFE3F2FD), // Light blue
      Color(0xFFFFEBEE), // Light red
    ];
    return colors[index % colors.length];
  }

  Widget _buildPhotoCard(String url) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildWhyItem({
    required Widget icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
