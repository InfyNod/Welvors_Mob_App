import 'package:flutter/material.dart';
import 'detail_drawer.dart';

class CardHistory extends StatelessWidget {
  final String selectedFilter;
  final List<Map<String, dynamic>> plansThisWeek;
  final List<Map<String, dynamic>> plansEarlier;

  const CardHistory({
    super.key, 
    this.selectedFilter = 'All',
    required this.plansThisWeek,
    required this.plansEarlier,
  });

  static List<Map<String, dynamic>> thisWeekPlans = [
    {
      'title': '🍝 Pasta & Long Conversations',
      'date': 'Sat, 2 Aug · 8:00 – 10:30 PM',
      'location': 'Le Petit Bistro · Koregaon Park · 2.1 km',
      'image':
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'MET',
      'partnerName': 'Aanya, 25',
      'partnerAvatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'partnerStatus': 'Met on this plan',
      'rating': 5,
      'note':
          'You both showed up. Dinner ran 30 min over — she asked to meet again.',
      'views': 214,
      'requests': 7,
      'split': 'Split (TTMM)',
    },
    {
      'title': '🚶 Riverside Evening Walk',
      'date': 'Thu, 24 Jul · 6:30 – 8:00 PM',
      'location': 'Mula Riverfront · Baner · 4.6 km',
      'image':
          'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'MET',
      'partnerName': 'Riya, 26',
      'partnerAvatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'partnerStatus': 'Met on this plan',
      'rating': 4,
      'note':
          'Walked, then coffee after. Good conversation, no spark for a second date.',
      'views': 96,
      'requests': 4,
      'split': 'I paid',
    },
    {
      'title': '☕ Sunday Filter Coffee',
      'date': 'Sun, 27 Jul · 10:30 AM – 12:00 PM',
      'location': 'Blue Tokai · Bandra · 1.2 km',
      'image':
          'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'EXPIRED',
      'note':
          '2 requests came in but you didn’t approve anyone before the time passed.',
      'views': 58,
      'requests': 2,
      'split': 'Split (TTMM)',
    },
  ];

  static List<Map<String, dynamic>> earlierPlans = [
    {
      'title': '🍸 Rooftop Sundowner',
      'date': 'Fri, 18 Jul · 7:00 – 9:00 PM',
      'location': 'The Terrace · Viman Nagar · 6.3 km',
      'image':
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'NO-SHOW',
      'partnerName': 'Meher, 24',
      'partnerAvatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'partnerStatus': 'Approved · didn’t show',
      'note':
          'You approved Meher and waited 40 min. She didn’t arrive and didn’t message.',
      'views': 187,
      'requests': 6,
      'split': 'Decide there',
    },
    {
      'title': '🎨 Gallery Hop & Chai',
      'date': 'Sun, 13 Jul · 4:00 – 6:00 PM',
      'location': 'Monalisa Kalagram · Koregaon Park · 2.8 km',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK3K1CU66l6qqVot2o0lnC_CoIhnHhy890WoqnSYVDm7wCxVKhbrDpX_8&s=10',
      'status': 'CANCELLED',
      'note':
          'You cancelled 4 hours before. All 3 requesters were notified automatically.',
      'views': 71,
      'requests': 3,
      'split': 'Split (TTMM)',
    },
    {
      'title': '🥐 Lazy Sunday Brunch',
      'date': 'Sun, 6 Jul · 11:00 AM – 1:00 PM',
      'location': 'Baker’s Table · Kalyani Nagar · 3.4 km',
      'image':
          'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'EXPIRED',
      'note':
          'No requests came in. Try a boost or an earlier time slot next Sunday.',
      'views': 23,
      'requests': 0,
      'split': 'Split (TTMM)',
    },
  ];

  List<Map<String, dynamic>> _filterPlans(List<Map<String, dynamic>> plans) {
    if (selectedFilter.toLowerCase() == 'all') {
      return plans;
    }
    return plans.where((plan) {
      final status = plan['status'].toString().toLowerCase();
      final filter = selectedFilter.toLowerCase();
      // Special case for 'No-show' vs 'NO-SHOW'
      if (filter == 'no-show' && status == 'no-show') return true;
      return status == filter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredThisWeek = _filterPlans(plansThisWeek);
    final filteredEarlier = _filterPlans(plansEarlier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredThisWeek.isNotEmpty) ...[
          _buildSectionHeader('THIS WEEK', filteredThisWeek.length),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredThisWeek.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(context, filteredThisWeek[index]);
            },
          ),
        ],
        if (filteredEarlier.isNotEmpty) ...[
          _buildSectionHeader('EARLIER', filteredEarlier.length),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEarlier.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(context, filteredEarlier[index]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> plan) {
    final status = plan['status'] as String;

    // Determine colors based on status
    Color borderColor;
    Color badgeBgColor;
    Color badgeTextColor;

    switch (status) {
      case 'MET':
        borderColor = const Color(0xFF1EA95B); // Green
        badgeBgColor = const Color(0xFFE8F6ED);
        badgeTextColor = const Color(0xFF1EA95B);
        break;
      case 'EXPIRED':
        borderColor = Colors.grey.shade400; // Grey
        badgeBgColor = Colors.grey.shade200;
        badgeTextColor = Colors.grey.shade600;
        break;
      case 'NO-SHOW':
        borderColor = const Color(0xFFF59E0B); // Amber/Orange
        badgeBgColor = const Color(0xFFFEF3C7);
        badgeTextColor = const Color(0xFFB45309);
        break;
      case 'CANCELLED':
        borderColor = const Color(0xFFEF4444); // Red
        badgeBgColor = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFFEF4444);
        break;
      case 'ACTIVE':
        borderColor = const Color(0xFF3B82F6); // Blue
        badgeBgColor = const Color(0xFFEFF6FF);
        badgeTextColor = const Color(0xFF3B82F6);
        break;
      case 'BOOKED':
        borderColor = const Color(0xFF8B5CF6); // Purple
        badgeBgColor = const Color(0xFFF5F3FF);
        badgeTextColor = const Color(0xFF8B5CF6);
        break;
      default:
        borderColor = Colors.grey;
        badgeBgColor = Colors.grey.shade200;
        badgeTextColor = Colors.black;
    }

    final hasPartnerInfo =
        plan.containsKey('partnerName') && plan['partnerName'] != null;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: borderColor, width: 4.0)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row (Image, Title, Date, Location, Status)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with rocket icon
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              plan['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (plan['boost'] != null && plan['boost'] != 'No') // Show rocket only if boosted
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '🚀',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title, Date, Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan['date'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  plan['location'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                if (hasPartnerInfo) ...[
                  const SizedBox(height: 12),
                  // Partner Info Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFBF4ED,
                      ), // Light yellowish-orange tint
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(plan['partnerAvatar']),
                          radius: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['partnerName'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan['partnerStatus'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating stars or warning
                        if (status == 'MET')
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 16,
                                color: index < plan['rating']
                                    ? const Color(0xFFF2A93B) // Gold star
                                    : Colors.grey.shade300,
                              );
                            }),
                          )
                        else if (status == 'NO-SHOW')
                          const Text('⚠️', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Note
                Text(
                  plan['note'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Dotted Divider
                Row(
                  children: List.generate(
                    40,
                    (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index.isEven
                            ? Colors.grey.shade300
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSmallStatPill(
                              Icons.visibility,
                              '${plan['views']}',
                            ),
                            const SizedBox(width: 8),
                            _buildSmallStatPill(
                              Icons.mail_outline,
                              '${plan['requests']} requests',
                            ),
                            const SizedBox(width: 8),
                            _buildSmallStatPill(
                              Icons.handshake_outlined,
                              plan['split'],
                              iconColor: const Color(0xFFF2A93B),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        showHistoryDetailDrawer(context, plan);
                      },
                      child: const Text(
                        'Details ›',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE43A6A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatPill(
    IconData icon,
    String text, {
    Color iconColor = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EF), // Light grey background like in image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: iconColor == Colors.grey ? Colors.black54 : iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
