import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../events_bloc/events_bloc.dart';
import '../events_bloc/events_state.dart';
import '../events_bloc/events_event.dart';
import 'view_details/event_details.dart';

class EventsCards extends StatefulWidget {
  const EventsCards({super.key});

  @override
  State<EventsCards> createState() => _EventsCardsState();
}

class _EventsCardsState extends State<EventsCards> {

  void _shareEvent(BuildContext context, String eventName) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        'Check out this event on Velvors: $eventName',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  Widget _buildShareIcon(BuildContext parentContext, String eventName) {
    return Builder(
      builder: (BuildContext iconContext) {
        return InkWell(
          onTap: () {
            debugPrint("Share clicked for $eventName");
            _shareEvent(iconContext, eventName);
          },
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.ios_share,
              color: Color(0xFFE85A7A),
              size: 22,
            ),
          ),
        );
      },
    );
  }

  bool _matches(EventsState state, {required List<int> categories, required List<int> filters, required String searchData}) {
    if (state.selectedCategoryIndex != 0 && !categories.contains(state.selectedCategoryIndex)) {
      return false;
    }
    if (!filters.contains(state.selectedFilterIndex)) {
      return false;
    }
    if (state.searchQuery.isNotEmpty) {
      if (!searchData.toLowerCase().contains(state.searchQuery.toLowerCase())) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          final showCard1 = _matches(state, categories: [1, 3], filters: [0, 1, 3], searchData: "sunset soiree singles signature mixer");
          final showCard2 = _matches(state, categories: [1, 2, 4], filters: [0, 1, 3], searchData: "artisanal spirits stories speed dating");
          final showCard3 = _matches(state, categories: [1, 3, 4], filters: [1, 3], searchData: "vintage vibes vineyards wine tasting");
          final showCard4 = _matches(state, categories: [5, 6], filters: [0, 1, 3], searchData: "sandakphu ridge trek trekking");

          return Column(
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
                child: Column(
                  children: [
                    if (showCard1) ...[
                      _buildStandardCard(),
                      const SizedBox(height: 24),
                    ],
                    if (showCard2) ...[
                      _buildStandardCard2(),
                      const SizedBox(height: 24),
                    ],
                    if (showCard3) ...[
                      _buildStandardCard3(),
                      const SizedBox(height: 24),
                    ],
                    if (showCard4) ...[
                      _buildStandardCard4(),
                      const SizedBox(height: 24),
                    ],
                    if (!showCard1 && !showCard2 && !showCard3 && !showCard4)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          "No events found for the selected filters.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPromotedCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: 'Rooftop Singles Night',
              date: 'This weekend',
              location: 'Mumbai',
              imageUrl: 'assets/concert.jpeg',
              status: 'PROMOTED',
              price: '₹1,250',
            ),
          ),
        );
      },
      child: Container(
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
    ),
    );
  }
  Widget _buildFeaturedCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: 'Speed Dating · 25–32',
              date: 'Sat, Oct 19',
              location: 'Bandra',
              imageUrl: 'assets/speed.jpeg',
              status: 'FEATURED',
              price: '₹999',
            ),
          ),
        );
      },
      child: Container(
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
    ),
    );
  }
  Widget _buildStandardCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: 'Sunset Soirée for Singles',
              date: 'Sat, Oct 12',
              location: 'The Rooftop Lounge, Bandra',
              imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
              status: 'SIGNATURE MIXER',
              price: '₹1,250',
            ),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
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
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SIGNATURE MIXER',
                        style: const TextStyle(
                          color: Color(0xFFE43A6A),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const PriceBadge(price: '₹1,250'),
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
                _buildShareIcon(context, 'Sunset Soirée for Singles'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(14),
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
                const SizedBox(height: 12),



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
                  ],
                ),
                const SizedBox(height: 10),

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
                const SizedBox(height: 4),

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
    ),
    );
  }
  Widget _buildStandardCard2() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: 'Artisanal Spirits & Stories',
              date: 'Thu, Oct 17',
              location: 'The Velvet Room, Lower Parel',
              imageUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=800&q=80',
              status: 'SPEED DATING',
              price: '₹950',
            ),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
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
                  'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=800&q=80',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SPEED DATING',
                        style: const TextStyle(
                          color: Color(0xFFE43A6A),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const PriceBadge(price: '₹950'),
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
                  '41',
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
                  '45',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                _buildShareIcon(context, 'Speed Dating: Creative Professionals'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 8 SPOTS LEFT & Interested
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F8E6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, color: Color(0xFF2E8B57), size: 12),
                          SizedBox(width: 4),
                          Text(
                            '8 SPOTS LEFT',
                            style: TextStyle(
                              color: Color(0xFF2E8B57),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
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
                            text: '41+ ',
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
                const SizedBox(height: 12),



                // Title & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Artisanal Spirits & Stories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Date
                Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Thu, Oct 17 · 6:30 PM – 9:00 PM',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'The Velvet Room, Lower Parel',
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
    ),
    );
  }
  Widget _buildStandardCard3() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: 'Vintage Vibes & Vineyards',
              date: 'Tue, Oct 22',
              location: 'Reserve Bar, Juhu',
              imageUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?auto=format&fit=crop&w=800&q=80',
              status: 'WINE TASTING',
              price: 'Sold Out',
            ),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
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
                  'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?auto=format&fit=crop&w=800&q=80', // Wine tasting image
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'WINE TASTING',
                        style: const TextStyle(
                          color: Color(0xFFE43A6A),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const PriceBadge(price: 'Sold Out'),
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
                  '94',
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
                  '28',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                _buildShareIcon(context, 'Wine Tasting & Networking'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interested Text
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '128+ ',
                        style: TextStyle(
                          color: Color(0xFFE85A7A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'interested · almost full',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),



                // Title & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Vintage Vibes & Vineyards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Date
                Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Tue, Oct 22 · 7:30 PM',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Reserve Bar, Juhu',
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
    ),
    );
  }
  Widget _buildStandardCard4() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: 'Sandakphu Ridge Trek',
              date: 'Nov 14–17',
              location: 'Darjeeling, WB',
              imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=800&q=80',
              status: '🥾 TREKKING',
              price: '₹8,900',
            ),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
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
                  'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=800&q=80', // Trekking image
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🥾 TREKKING',
                        style: const TextStyle(
                          color: Color(0xFFE43A6A),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const PriceBadge(price: '₹8,900'),
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
                  '210',
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
                  '85',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                _buildShareIcon(context, 'Himalayan Adventure Trek'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Text
                Text(
                  '4-day guided trek · small group',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),



                // Title & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Sandakphu Ridge Trek',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Date
                Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Nov 14–17 · 4 days',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Darjeeling, WB',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                

              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class PriceBadge extends StatelessWidget {
  final String price;
  const PriceBadge({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            width: 85,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
