import 'package:flutter/material.dart';

class EventMoreDetailsSection extends StatelessWidget {
  final bool isTrekkingEvent;
  final String? aboutEvent;
  final List<dynamic>? galleryImages;
  final List<dynamic>? whyShouldCome;

  const EventMoreDetailsSection({
    super.key, 
    this.isTrekkingEvent = false,
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
            children: galleryImages != null && galleryImages!.isNotEmpty
                ? galleryImages!.map((img) {
                    String url = '';
                    if (img is Map) {
                      url = img['imageUrl']?.toString() ?? '';
                    } else {
                      url = img.toString();
                    }
                    return _buildPhotoCard(url);
                  }).toList()
                : [
                    _buildPhotoCard(
                      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=300&q=80',
                    ),
                    _buildPhotoCard(
                      'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?auto=format&fit=crop&w=300&q=80',
                    ),
                    _buildPhotoCard(
                      'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=300&q=80',
                    ),
                  ],
          ),
        ),
        const SizedBox(height: 20),

        // About the Event
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
            aboutEvent ?? 'An exclusive evening of meaningful connections at Bandra\'s most elegant rooftop lounge. Curated for verified professionals — signature cocktails, live ambient jazz, and our "connection icebreakers" designed to spark real conversation.',
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        
        if (isTrekkingEvent)
          const TrekItinerarySection(),

        // Why You Should Come
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
            children: whyShouldCome != null && whyShouldCome!.isNotEmpty
                ? whyShouldCome!.asMap().entries.map((entry) {
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
                  }).toList()
                : [
                    _buildWhyItem(
                      icon: const Text('💭', style: TextStyle(fontSize: 18)),
                      iconBgColor: const Color(0xFFF3E5F5), // Light purple
                      title: 'Meet matches in real life',
                      subtitle:
                          'Skip weeks of chatting — a 5-minute conversation tells you more than 100 messages.',
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildWhyItem(
                      icon: const Icon(Icons.check, size: 18, color: Colors.black87),
                      iconBgColor: const Color(0xFFE8F5E9), // Light green
                      title: '100% verified guests',
                      subtitle:
                          'Every attendee is ID-verified. No fake profiles, no surprises.',
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildWhyItem(
                      icon: const Text('🎯', style: TextStyle(fontSize: 18)),
                      iconBgColor: const Color(0xFFFFF3E0), // Light orange
                      title: 'Curated compatibility',
                      subtitle:
                          'Guest list is matched by age range, interests and intent — you\'ll fit right in.',
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildWhyItem(
                      icon: const Text('🤝', style: TextStyle(fontSize: 18)),
                      iconBgColor: const Color(0xFFE3F2FD), // Light blue
                      title: 'Icebreakers that work',
                      subtitle:
                          'Our hosts facilitate low-pressure activities to get the conversation flowing naturally.',
                    ),
                  ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, // Slightly smaller icon box
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: icon,
          ),
          const SizedBox(width: 12), // Reduced spacing
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
                  const SizedBox(height: 2), // Reduced spacing
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.3, // Tighter line height
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

class TrekItinerarySection extends StatelessWidget {
  const TrekItinerarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beautiful Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE43A6A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map_rounded, color: Color(0xFFE43A6A), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                '4-Day Trek Itinerary',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Highlight Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFA6A85).withOpacity(0.15), const Color(0xFFDE2957).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFA6A85).withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFA6A85).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.verified, color: Color(0xFFE43A6A), size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Full day-by-day plan · Guided by certified leaders · Meals & stays included',
                    style: TextStyle(
                      color: Color(0xFFD62851),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Timeline Items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildDayItem(
                day: '1',
                title: 'Arrival & briefing',
                date: 'Fri, Nov 14',
                location: 'Manebhanjan (2,130 m) · base village',
                schedule: [
                  {'time': '2:00 PM', 'desc': 'Reach base, check into homestay'},
                  {'time': '5:00 PM', 'desc': 'Gear check + route & safety briefing'},
                  {'time': '8:00 PM', 'desc': 'Group dinner & icebreakers 🔥'},
                ],
                amenities: '🛏️ Homestay · 🍽️ Dinner',
                isLast: false,
              ),
              _buildDayItem(
                day: '2',
                title: 'The climb begins',
                date: 'Sat, Nov 15',
                location: 'Manebhanjan → Tumling (2,970 m) · ~11 km',
                schedule: [
                  {'time': '6:30 AM', 'desc': 'Sunrise, breakfast, warm-up'},
                  {'time': '8:00 AM', 'desc': 'Trek through Singalila forest trail'},
                  {'time': '1:00 PM', 'desc': 'Packed lunch at Chitrey'},
                  {'time': '4:30 PM', 'desc': 'Reach Tumling · tea + rest'},
                ],
                amenities: '🛏️ Trekker\'s hut · 🍽️ All meals',
                isLast: false,
              ),
              _buildDayItem(
                day: '3',
                title: 'Summit push',
                date: 'Sun, Nov 16',
                location: 'Tumling → Sandakphu (3,636 m) · ~14 km',
                schedule: [
                  {'time': '5:00 AM', 'desc': 'Early start for the ridge'},
                  {'time': '12:00 PM', 'desc': 'Lunch at Kalapokhri'},
                  {'time': '4:00 PM', 'desc': 'Summit · Sleeping Buddha & Everest views 🏔️'},
                  {'time': '7:00 PM', 'desc': 'Bonfire dinner at the top'},
                ],
                amenities: '🛏️ Summit lodge · 🍽️ All meals',
                isLast: false,
              ),
              _buildDayItem(
                day: '4',
                title: 'Sunrise & descent',
                date: 'Mon, Nov 17',
                location: 'Sandakphu → Sepi → Darjeeling',
                schedule: [
                  {'time': '5:15 AM', 'desc': 'Golden sunrise over the Himalayas'},
                  {'time': '8:00 AM', 'desc': 'Breakfast + descent by trail/jeep'},
                  {'time': '2:00 PM', 'desc': 'Reach Darjeeling · farewell & photos'},
                ],
                amenities: 'Trek completed',
                isSuccessBadge: true,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDayItem({
    required String day,
    required String title,
    required String date,
    required String location,
    required List<Map<String, String>> schedule,
    required String amenities,
    required bool isLast,
    bool isSuccessBadge = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Timeline Indicator
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE43A6A).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE43A6A).withOpacity(0.6),
                          const Color(0xFFE43A6A).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Premium Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Day $day · $title',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          date,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location Pin
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE43A6A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, size: 12, color: Color(0xFFE43A6A)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Color(0xFFE43A6A), fontSize: 13, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 14),
                  // Schedule
                  ...schedule.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 65,
                          child: Text(
                            item['time']!,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item['desc']!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 4),
                  // Amenities / Success Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSuccessBadge ? Colors.green.withOpacity(0.12) : const Color(0xFFE43A6A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSuccessBadge ? Colors.green.withOpacity(0.4) : const Color(0xFFE43A6A).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSuccessBadge) ...[
                          const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          amenities,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isSuccessBadge ? Colors.green.shade700 : const Color(0xFFD62851),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
