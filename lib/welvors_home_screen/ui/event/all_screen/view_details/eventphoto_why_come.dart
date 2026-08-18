import 'package:flutter/material.dart';

class EventMoreDetailsSection extends StatelessWidget {
  const EventMoreDetailsSection({super.key});

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
        const SizedBox(height: 40),
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
