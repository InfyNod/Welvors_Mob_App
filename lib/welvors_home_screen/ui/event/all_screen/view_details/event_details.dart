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
import 'booking_confirm.dart';
import '../service_event/event_api_service.dart';
import 'package:intl/intl.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String status;
  final List<String>? categories;
  final String price;
  final int spotsLeft;
  final List<dynamic>? featureTags;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.price,
    this.spotsLeft = 8,
    this.categories,
    this.featureTags,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _eventData;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final data = await EventApiService.getEventDetails(widget.eventId);
    if (mounted) {
      setState(() {
        if (data != null && data['success'] == true) {
          _eventData = data['data'];
        }
        _isLoading = false;
      });
    }
  }

  String _formatApiDate(String? isoDate, String? startTime) {
    if (isoDate == null) return widget.date;
    try {
      final date = DateTime.parse(isoDate).toLocal();
      String formattedDate = DateFormat('EEE, MMM d').format(date);
      if (startTime != null && startTime.contains(':')) {
        final timeParts = startTime.split(':');
        final timeObj = DateTime(
          2020,
          1,
          1,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        final formattedTime = DateFormat('h:mm a').format(timeObj);
        return '$formattedDate · $formattedTime';
      }
      return formattedDate;
    } catch (e) {
      return widget.date; // fallback
    }
  }

  String _getEventPrice(BuildContext context, Map<String, dynamic> event) {
    if (event['entryPrice'] != null &&
        event['entryPrice'].toString().isNotEmpty &&
        event['entryPrice'].toString() != 'null') {
      return '₹${event['entryPrice']}';
    }

    final userGender = context
        .read<ProfileEditCubit>()
        .state
        .gender; // "Man", "Woman", "Non-binary", etc.
    String priceStr = '0';

    if (userGender.toLowerCase() == 'woman') {
      priceStr = event['womenEntryPrice']?.toString() ?? '0';
    } else if (userGender.toLowerCase() == 'man') {
      priceStr = event['menEntryPrice']?.toString() ?? '0';
    } else {
      priceStr = event['otherEntryPrice']?.toString() ?? '0';
    }

    int price = int.tryParse(priceStr) ?? 0;
    return price > 0 ? '₹$price' : 'Free';
  }

  @override
  Widget build(BuildContext context) {
    // Determine which data to show (Fallback to widget fields if API data is null)
    final title = _eventData?['title'] ?? widget.title;
    final date = _eventData != null
        ? _formatApiDate(_eventData!['eventDate'], _eventData!['startTime'])
        : widget.date;
    final location = _eventData?['fullAddress'] ?? widget.location;
    final heroImageRaw = _eventData?['heroImage'];
    final imageUrl =
        (heroImageRaw != null && heroImageRaw.toString().isNotEmpty)
        ? heroImageRaw
        : widget.imageUrl;
    final status = _eventData != null
        ? (_eventData!['eventType'] ?? 'UPCOMING')
              .toString()
              .replaceAll('_', ' ')
              .toUpperCase()
        : widget.status;
    final price = _eventData != null
        ? _getEventPrice(context, _eventData!)
        : widget.price;
    final spotsLeft = _eventData?['leftSpot'] ?? widget.spotsLeft;
    final capacity = _eventData?['totalCapacity'] ?? _eventData?['capacity'] ?? 60;
    final interested = _eventData?['interested'] ?? 0;
    final isOfficial = _eventData?['officialPartner'] == true;
    final hostName =
        _eventData?['eventPartner']?['businessName'] ?? 'Spark Official Events';

    String timeStr = date.contains('·') ? date.split('·').last.trim() : 'TBA';
    if (_eventData != null &&
        _eventData!['startTime'] != null &&
        _eventData!['endTime'] != null) {
      try {
        final st = _eventData!['startTime'].split(':');
        final et = _eventData!['endTime'].split(':');
        final stD = DateTime(2020, 1, 1, int.parse(st[0]), int.parse(st[1]));
        final etD = DateTime(2020, 1, 1, int.parse(et[0]), int.parse(et[1]));

        final stFmt = DateFormat('h:mm a').format(stD).replaceAll(':00', '');
        final etFmt = DateFormat('h:mm a').format(etD).replaceAll(':00', '');

        if (stFmt.endsWith('AM') == etFmt.endsWith('AM') &&
            stFmt.endsWith('PM') == etFmt.endsWith('PM')) {
          timeStr = '${stFmt.substring(0, stFmt.length - 3)}–$etFmt';
        } else {
          timeStr = '$stFmt–$etFmt';
        }
      } catch (_) {}
    }

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
                            onPressed: isBooked
                                ? null
                                : () {
                                    context.read<EventsBloc>().add(
                                      BookEventEvent(title),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookingConfirmationScreen(
                                              title: title,
                                              date: date,
                                              location: location,
                                            ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBooked
                                  ? Colors.grey
                                  : const Color(0xFFE43A6A),
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
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFE43A6A),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(
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
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 24,
                    ),
                    child: Row(
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
                                        'Hosted by $hostName • ',
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
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  if ((_eventData?['featureTags'] != null && (_eventData!['featureTags'] as List).isNotEmpty) || 
                      (widget.featureTags != null && widget.featureTags!.isNotEmpty)) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: (_eventData?['featureTags'] as List? ?? widget.featureTags!)
                            .map((feature) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: _buildTag(feature['label']?.toString() ?? ''),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Stats Grid
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    child: Container(
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
                                date.contains('·')
                                    ? date.split('·').first.trim()
                                    : date,
                              ),
                              _buildVerticalDivider(),
                              _buildStatItem(
                                Icons.access_time,
                                'TIME',
                                timeStr,
                              ),
                              _buildVerticalDivider(),
                              _buildStatItem(
                                Icons.confirmation_num_outlined,
                                'ENTRY',
                                price,
                              ),
                              _buildVerticalDivider(),
                              _buildStatItem(
                                Icons.people_outline,
                                'CROWD',
                                '$capacity singles',
                              ),
                            ],
                          ),
                        ),
                  ),

                  // Filling Fast Section
                  if (_eventData?['bookingStats'] != null)
                    _FillingFastCard(bookingStats: _eventData!['bookingStats']),
                  if (_eventData?['bookingStats'] != null)
                    const SizedBox(height: 24),

                  EventMoreDetailsSection(
                    isTrekkingEvent: title.toLowerCase().contains('trek'),
                    aboutEvent: _eventData?['aboutEvent'],
                    galleryImages: _eventData?['galleryImages'] as List?,
                    whyShouldCome: _eventData?['whyShouldCome'] as List?,
                  ),
                  const SizedBox(height: 20),
                  YourPassAndAmenitiesSection(
                    price: price,
                    safetyFeatures: _eventData?['safetyFeatures'] as List?,
                    amenities: _eventData?['amenities'] as List?,
                  ),
                  const SizedBox(height: 20),
                  EventItineraryAndLocationSection(
                    itinerary: _eventData?['itinerary'] as List?,
                    locationTitle:
                        _eventData?['fullAddress']?.split(',').first ??
                        'Location',
                    fullAddress:
                        _eventData?['fullAddress'] ??
                        'Venue details will be shared',
                  ),
                  const SizedBox(height: 20),
                  AboutHostAndFAQSection(
                    termsConditions: _eventData?['termsConditions'] as String?,
                  ),
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
  final Map<String, dynamic> bookingStats;
  const _FillingFastCard({super.key, required this.bookingStats});

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
    final stats = widget.bookingStats;
    final bool fillingFast = stats['fillingFast'] == true;
    final String fillingFastText = stats['fillingFastText'] ?? 'Filling fast';
    final int spotsLeft = stats['spotsLeft'] ?? 0;
    final double bookingPercentage = (stats['bookingPercentage'] ?? 0).toDouble();
    final String bookingSummary = stats['bookingSummary'] ?? '';
    final String last24HoursText = stats['last24HoursText'] ?? '';

    final Color mainColor = const Color(0xFFE43A6A);
    final Color bgColor = const Color(0xFFFFF0F3);
    final Color borderColor = const Color(0xFFE43A6A).withOpacity(0.15);
    final Color textColor = const Color(0xFFDE2957);
    int menCapacity = stats['menCapacity'] ?? 0;
    int womenCapacity = stats['womenCapacity'] ?? 0;
    int otherCapacity = stats['otherCapacity'] ?? 0;

    if (menCapacity == 0 && womenCapacity == 0 && otherCapacity == 0) {
      // Fallback dummy values to keep UI visible if API hasn't populated data yet
      menCapacity = 50;
      womenCapacity = 40;
      otherCapacity = 10;
    }

    final int totalGenderCapacity = menCapacity + womenCapacity + otherCapacity;
    final int menFlex = totalGenderCapacity > 0 ? (menCapacity * 100 / totalGenderCapacity).round() : 0;
    final int womenFlex = totalGenderCapacity > 0 ? (womenCapacity * 100 / totalGenderCapacity).round() : 0;
    final int otherFlex = totalGenderCapacity > 0 ? (otherCapacity * 100 / totalGenderCapacity).round() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  fillingFast
                      ? const Text('🔥', style: TextStyle(fontSize: 18))
                      : Icon(Icons.confirmation_num_outlined, color: mainColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    fillingFast ? fillingFastText : 'Booking Open',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              if (fillingFast)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Only $spotsLeft spots left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    '$spotsLeft spots available',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: maxWidth * (bookingPercentage / 100)),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Container(
                        height: 6,
                        width: value,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: mainColor.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
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
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: bookingSummary + (last24HoursText.isNotEmpty ? ' · ' : '')),
                      if (last24HoursText.isNotEmpty)
                        TextSpan(
                          text: last24HoursText,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Balanced gender ratio
          if (totalGenderCapacity > 0) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balanced gender ratio',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDE2957),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Ratio Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  if (womenCapacity > 0)
                    Expanded(
                      flex: womenCapacity,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFA9EB5), Color(0xFFE43A6A)],
                          ),
                        ),
                      ),
                    ),
                  if (menCapacity > 0)
                    Expanded(
                      flex: menCapacity,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6BB5F6), Color(0xFF2C74C9)],
                          ),
                        ),
                      ),
                    ),
                  if (otherCapacity > 0)
                    Expanded(
                      flex: otherCapacity,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFCE93D8), Color(0xFF8E24AA)],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 4,
              children: [
                if (womenCapacity > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(radius: 3, backgroundColor: Color(0xFFFA6A85)),
                      const SizedBox(width: 4),
                      Text(
                        'Women $womenFlex%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFA6A85),
                        ),
                      ),
                    ],
                  ),
                if (menCapacity > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(radius: 3, backgroundColor: Color(0xFF4A90E2)),
                      const SizedBox(width: 4),
                      Text(
                        'Men $menFlex%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ],
                  ),
                if (otherCapacity > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(radius: 3, backgroundColor: Color(0xFF8E24AA)),
                      const SizedBox(width: 4),
                      Text(
                        'Other $otherFlex%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E24AA),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ]
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
