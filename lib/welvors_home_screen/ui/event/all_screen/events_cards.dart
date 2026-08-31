import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../events_bloc/events_bloc.dart';
import '../events_bloc/events_state.dart';
// import '../events_bloc/events_event.dart';
import 'view_details/event_details.dart';
import 'service_event/event_api_service.dart';
import 'package:intl/intl.dart';
import '../../drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';

class EventsCards extends StatefulWidget {
  final String? eventType;
  final String? categoryName;
  final String? cityName;
  
  const EventsCards({
    super.key, 
    this.eventType, 
    this.categoryName, 
    this.cityName,
  });

  @override
  State<EventsCards> createState() => _EventsCardsState();
}

class _EventsCardsState extends State<EventsCards> {
  List<dynamic> _apiEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<EventsBloc>().state;
    _fetchWithState(state);
  }

  void _fetchWithState(EventsState state) {
    String? dateFilter;
    bool? freeOnly;

    if (state.selectedFilterIndex == 0) {
      dateFilter = 'TODAY';
    } else if (state.selectedFilterIndex == 1) {
      dateFilter = 'THIS_WEEKEND';
    } else if (state.selectedFilterIndex == 2) {
      dateFilter = 'THIS_MONTH';
    } else if (state.selectedFilterIndex == 3) {
      freeOnly = true;
    }

    _fetchEvents(dateFilter: dateFilter, freeOnly: freeOnly);
  }

  Future<void> _fetchEvents({String? dateFilter, bool? freeOnly}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final response = await EventApiService.getEvents(
        eventType: widget.eventType,
        dateFilter: dateFilter,
        freeOnly: freeOnly,
      );
      if (response != null && response['success'] == true) {
        if (mounted) {
          setState(() {
            _apiEvents = response['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            child: Icon(Icons.ios_share, color: Color(0xFFE85A7A), size: 22),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: BlocConsumer<EventsBloc, EventsState>(
        listenWhen: (previous, current) => 
            previous.selectedFilterIndex != current.selectedFilterIndex,
        listener: (context, state) {
          _fetchWithState(state);
        },
        builder: (context, state) {
          // Separate events based on tag
          final promotedTags = ['BRAND', 'PROMOTED', 'FEATURED'];
          final promotedEvents = _apiEvents.where((e) {
            final tag = (e['eventTag'] ?? '').toString().toUpperCase();
            return promotedTags.contains(tag);
          }).toList();

          final regularEvents = _apiEvents.where((e) {
            final tag = (e['eventTag'] ?? '').toString().toUpperCase();
            return !promotedTags.contains(tag);
          }).toList();

          return Column(
            children: [
              // Highlighted / Promoted Events (Horizontal Scroll)
              if (promotedEvents.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: promotedEvents.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _buildHorizontalApiEventCard(
                        promotedEvents[index],
                        state,
                      );
                    },
                  ),
                ),
              if (promotedEvents.isNotEmpty)
                const SizedBox(height: 24),

              // Standard Events (Vertical)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Render API events
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      )
                    else ...[
                      for (var event in regularEvents) ...[
                        _buildApiEventCard(event, state),
                        const SizedBox(height: 24),
                      ],
                    ],

                    if (_apiEvents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        child: Text(
                          "No ${widget.categoryName?.replaceAll('\n', ' ') ?? 'Events'} in ${widget.cityName ?? 'Mumbai'} right now. We add new ones every week — try another city or category.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            height: 1.4,
                          ),
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

  String _formatApiDate(String? isoDate, String? startTime) {
    if (isoDate == null) return 'Upcoming';
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
      return isoDate; // fallback
    }
  }

  Widget _buildHorizontalApiEventCard(dynamic event, EventsState state) {
    final title = event['title'] ?? 'Event Title';
    final locationTitle =
        event['fullAddress']?.split(',').first ?? 'Location TBA';

    final heroImageRaw = event['heroImage'];
    final imageUrl =
        (heroImageRaw != null && heroImageRaw.toString().isNotEmpty)
        ? heroImageRaw
        : 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80';

    final tagRaw = event['eventTag'] ?? 'PROMOTED';
    final tagLabel = tagRaw.toString().toUpperCase();
    final isBrand = tagLabel == 'BRAND';
    final isFeatured = tagLabel == 'FEATURED';
    final isPromoted = tagLabel == 'PROMOTED';

    final dateStr = _formatApiDate(event['eventDate'], event['startTime']);
    final eventId = event['id'] ?? '';
    final capacity = event['totalCapacity'] ?? event['capacity'] ?? 'Limited';
    final eventType = (event['eventType'] ?? 'Event')
        .toString()
        .replaceAll('_', ' ')
        .toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventId: eventId,
              title: title,
              date: dateStr,
              location: locationTitle,
              imageUrl: imageUrl,
              status: tagLabel,
              price: _getEventPrice(context, event),
              featureTags: event['featureTags'],
            ),
          ),
        );
      },
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              // Event tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isBrand
                      ? const Color(0xFFE85A7A).withOpacity(0.95)
                      : (isFeatured || isPromoted)
                      ? null
                      : const Color(
                          0xFF424242,
                        ).withOpacity(0.95), // Fallback dark grey
                  gradient: isFeatured
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFED86A), // rgba(254, 216, 106)
                            Color(0xFFE9A73F), // rgba(233, 167, 63)
                          ],
                        )
                      : isPromoted
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00C6FF), // Bright Cyan
                            Color(0xFF0072FF), // Deep Blue
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFeatured)
                      const Text(
                        '✦',
                        style: TextStyle(color: Colors.black87, fontSize: 10),
                      )
                    else if (isBrand)
                      const Icon(Icons.star, size: 10, color: Colors.white)
                    else if (isPromoted)
                      const Icon(
                        Icons.rocket_launch,
                        size: 10,
                        color: Colors.white,
                      )
                    else
                      const Icon(
                        Icons.auto_awesome,
                        size: 10,
                        color: Colors.white,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      tagLabel,
                      style: TextStyle(
                        color: isFeatured ? Colors.black87 : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '$dateStr · $locationTitle',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$capacity singles · $eventType',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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

  Widget _buildApiEventCard(dynamic event, EventsState state) {
    final title = event['title'] ?? 'Event Title';
    final location = event['fullAddress'] ?? 'Location TBA';

    // Check for null heroImage and provide a fallback
    final heroImageRaw = event['heroImage'];
    final imageUrl =
        (heroImageRaw != null && heroImageRaw.toString().isNotEmpty)
        ? heroImageRaw
        : 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80';

    final status = (event['eventType'] ?? 'UPCOMING')
        .toString()
        .replaceAll('_', ' ')
        .toUpperCase();
    final price = _getEventPrice(context, event);
    final interestedCount = event['interested'] ?? 0;
    final dateStr = _formatApiDate(event['eventDate'], event['startTime']);

    final eventId = event['id'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventId: eventId,
              title: title,
              date: dateStr,
              location: location,
              imageUrl: imageUrl,
              status: status.toString().toUpperCase(),
              price: price,
              featureTags: event['featureTags'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE85A7A).withOpacity(0.06),
              blurRadius: 24,
              spreadRadius: 4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE85A7A).withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
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
                PriceBadge(price: price),
              ],
            ),

            // Action Icons Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Text(
                    '$interestedCount interested',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  _buildShareIcon(context, title),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Colors.grey.shade100),
            ),

            // Content Details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
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
                  const SizedBox(height: 5),

                  // Date
                  Row(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Color(0xFFE43A6A), // Highlighted date/time
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
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
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
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
