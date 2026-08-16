import 'package:flutter/material.dart';

class EventsCards extends StatelessWidget {
  const EventsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          // Highlighted / Promoted Events (Horizontal Scroll)
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPromotedCard(),
                const SizedBox(width: 12),
                _buildFeaturedCard(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Standard Events (Vertical)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStandardCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotedCard() {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/concert.jpeg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85A7A).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROMOTED tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE85A7A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 10, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'PROMOTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'This weekend · Mumbai',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Rooftop Singles Night',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '60 verified singles · Live music · Limited seats',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Book now',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: Colors.black87),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/speed.jpeg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FEATURED tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFED86A), // rgba(254, 216, 106)
                    Color(0xFFE9A73F), // rgba(233, 167, 63)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✦',
                    style: TextStyle(color: Colors.black87, fontSize: 10),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'Sat, Oct 19 · Bandra',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Speed Dating · 25–32',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '15 curated matches in one evening',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: Colors.black87),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Action Icons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.star_border,
                  color: Color(0xFFE85A7A),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '67',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFFE85A7A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '12',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.ios_share,
                  color: Color(0xFFE85A7A),
                  size: 22,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatars & Interested
                Row(
                  children: [
                    SizedBox(
                      width: 72, // 4 avatars
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: const NetworkImage(
                                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80',
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 10.5,
                                backgroundImage: const NetworkImage(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 32,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 10.5,
                                backgroundImage: const NetworkImage(
                                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 48,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 10.5,
                                backgroundColor: const Color(0xFFE85A7A),
                                child: const Text(
                                  '+64',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '67+ ',
                            style: TextStyle(
                              color: Color(0xFFE85A7A),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: 'interested',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                const Text(
                  'SIGNATURE MIXER',
                  style: TextStyle(
                    color: Color(0xFFE85A7A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                // Title & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Sunset Soirée for Singles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '₹1,250',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Date
                Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Sat, Oct 12 · 7:00 PM – 10:00 PM',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'The Rooftop Lounge, Bandra',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
