import 'package:flutter/material.dart';

class EventMoreDetailsSection extends StatelessWidget {
  final bool isTrekkingEvent;

  const EventMoreDetailsSection({super.key, this.isTrekkingEvent = false});

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
            children: [
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'An exclusive evening of meaningful connections at Bandra\'s most elegant rooftop lounge. Curated for verified professionals — signature cocktails, live ambient jazz, and our "connection icebreakers" designed to spark real conversation.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
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
            children: [
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
                    'Hosted rounds mean you never stand alone — 78% of guests leave with a connection.',
              ),
            ],
          ),
        ),
      ],
    );
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '4-Day Trek Itinerary',
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Full day-by-day plan · guided by certified trek leaders · all meals & stays included',
              style: TextStyle(color: Color(0xFFE43A6A), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
                amenities: '✓ Trek completed',
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
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFE43A6A),
                  shape: BoxShape.circle,
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
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day $day · $title',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFFE43A6A)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Color(0xFFE43A6A), fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...schedule.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 65,
                        child: Text(
                          item['time']!,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['desc']!,
                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    amenities,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
