import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../events_bloc/events_bloc.dart';
import '../../events_bloc/events_state.dart';
import '../../events_bloc/events_event.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/eventphoto_why_come.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/your_pass_amenities.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/event_itinerary_location.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/abouthost_frequently.dart';

class EventDetailsScreen extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String status;
  final List<String>? categories;
  final String price;
  final int spotsLeft;

  const EventDetailsScreen({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.price,
    this.spotsLeft = 8,
    this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    final isBooked = state.bookedEvents.contains(title);
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isBooked ? null : () {
                              context.read<EventsBloc>().add(BookEventEvent(title));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booked $title successfully!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBooked ? Colors.grey : const Color(0xFFE43A6A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isBooked
                                  ? '✅ Booked'
                                  : '🎟️ Book Now · $price — $spotsLeft spots left',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final box = context.findRenderObject() as RenderBox?;
                await Share.share(
                  'Check out this event on Velvors: $title',
                  sharePositionOrigin: box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null,
                );
              } catch (e) {
                debugPrint('Error sharing: $e');
              }
            },
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.black87,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image Section
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: imageUrl.startsWith('http')
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Image.asset(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE43A6A),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFE43A6A), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'OFFICIAL BRAND EVENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Main Content Area
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flat Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Host
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE43A6A,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '🥂',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Hosted by Spark Official Events • ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.check,
                                        color: Color(0xFFE43A6A),
                                        size: 12,
                                      ),
                                      const Text(
                                        ' Verified',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFE43A6A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildTag('Verified profiles only'),
                            _buildTag('Age 25-32'),
                            _buildTag('Solo welcome'),
                            _buildTag('Smart casual'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats Grid
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                Icons.calendar_today,
                                'DATE',
                                date.split('·').first.trim(),
                              ),
                              _buildVerticalDivider(),
                              _buildStatItem(
                                Icons.access_time,
                                'TIME',
                                '7-10 PM',
                              ),
                              _buildVerticalDivider(),
                              _buildStatItem(
                                Icons.confirmation_num_outlined,
                                'ENTRY',
                                '₹1,250',
                              ),
                              _buildVerticalDivider(),
                              _buildStatItem(
                                Icons.people_outline,
                                'CROWD',
                                '60 singles',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filling Fast Section
                  const _FillingFastCard(),
                  const SizedBox(height: 24),

                  // Who's Coming Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Who's Coming",
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balanced gender ratio',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '60 verified guests',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Ratio Bar
                        Row(
                          children: [
                            Expanded(
                              flex: 52,
                              child: Container(
                                height: 12,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFA9EB5),
                                      Color(0xFFE43A6A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    bottomLeft: Radius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 48,
                              child: Container(
                                height: 12,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6BB5F6),
                                      Color(0xFF2C74C9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Color(0xFFFA6A85),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Women 52%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFA6A85),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Men 48%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                                SizedBox(width: 6),
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Color(0xFF4A90E2),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '25–32',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Age range',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            const Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '100%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ID verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            const Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '7',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your matches',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const EventMoreDetailsSection(),
                  const SizedBox(height: 20),
                  YourPassAndAmenitiesSection(price: price),
                  const SizedBox(height: 20),
                  const EventItineraryAndLocationSection(),
                  const SizedBox(height: 20),
                  const AboutHostAndFAQSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1CAF5E).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Color(0xFF1CAF5E), size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1CAF5E),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF0F3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFE43A6A), size: 14),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildAvatar(double leftPos, String imgUrl) {
    return Positioned(
      left: leftPos,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFF0F3), width: 2),
        ),
        child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(imgUrl)),
      ),
    );
  }
}

class _FillingFastCard extends StatefulWidget {
  const _FillingFastCard();

  @override
  State<_FillingFastCard> createState() => _FillingFastCardState();
}

class _FillingFastCardState extends State<_FillingFastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE43A6A).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🔥', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Filling fast',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDE2957),
                    ),
                  ),
                ],
              ),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE43A6A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Only 8 spots left',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE43A6A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: maxWidth * (52 / 60)),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Container(
                        height: 8,
                        width: value,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE43A6A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Avatars
              SizedBox(
                width: 60,
                height: 24,
                child: Stack(
                  children: [
                    _buildAvatar(
                      0,
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
                    ),
                    _buildAvatar(
                      15,
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80',
                    ),
                    _buildAvatar(
                      30,
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFDE2957),
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: '52 of 60 spots booked · '),
                      TextSpan(
                        text: '12 people booked in the last 24 hours',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double leftPos, String imgUrl) {
    return Positioned(
      left: leftPos,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFF0F3), width: 2),
        ),
        child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(imgUrl)),
      ),
    );
  }
}
