import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:velvors/config/app_cached_image.dart';

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
            child: Builder(
              builder: (context) {
                final allUrls = galleryImages!.map((img) {
                  if (img is Map) return img['imageUrl']?.toString() ?? '';
                  return img.toString();
                }).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allUrls.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoCard(context, allUrls, index);
                  },
                );
              },
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

  Widget _buildPhotoCard(
    BuildContext context,
    List<String> allUrls,
    int initialIndex,
  ) {
    String currentUrl = allUrls[initialIndex];
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            final pageController = PageController(initialPage: initialIndex);
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF0F5), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: pageController,
                            itemCount: allUrls.length,
                            onPageChanged: (index) {
                              setState(() {});
                            },
                            itemBuilder: (context, idx) {
                              return InteractiveViewer(
                                panEnabled: true,
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: AppCachedImage(
                                    imageUrl: allUrls[idx],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Image Counter
                          if (allUrls.length > 1)
                            Positioned(
                              top: 16,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${(pageController.hasClients ? (pageController.page?.round() ?? initialIndex) : initialIndex) + 1} / ${allUrls.length}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Cancel Button
                          Positioned(
                            top: 12,
                            right: 12,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black87,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Dots
                          if (allUrls.length > 1)
                            Positioned(
                              bottom: 16,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(allUrls.length, (index) {
                                  final isCurrent = pageController.hasClients
                                      ? (pageController.page?.round() == index)
                                      : (initialIndex == index);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    height: 8,
                                    width: isCurrent ? 24 : 8,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? const Color(0xFFE43A6A)
                                          : Colors.grey.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
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
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(currentUrl),
            fit: BoxFit.cover,
          ),
        ),
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
