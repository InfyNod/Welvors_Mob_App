import 'package:flutter/material.dart';
import 'ticket_screen.dart';
import 'view_details/event_details.dart';
import 'cancel/cancel_drawer.dart';
import 'service_event/event_api_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All',
    'Confirmed',
    'Pending',
    'Cancelled',
    'Attended',
    'Expired',
  ];
  late final List<GlobalKey> _filterKeys;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _tickets = [];
  bool _isLoading = true;
  bool _isInitialLoad = true;
  final Map<String, List<dynamic>> _cachedTickets = {};

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    String selectedFilter = _filters[_selectedFilterIndex];
    String? apiStatus;
    if (selectedFilter != 'All') {
      apiStatus = selectedFilter.toUpperCase().replaceAll(' ', '_');
    }

    final cacheKey = apiStatus ?? 'ALL';

    if (_cachedTickets.containsKey(cacheKey)) {
      setState(() {
        _tickets = _cachedTickets[cacheKey]!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    final response = await EventApiService.getMyTickets(status: apiStatus);

    if (mounted) {
      setState(() {
        if (response != null && response['success'] == true) {
          _tickets = response['data']['bookings'] ?? [];

          // TODO: Remove this dummy data after testing
          if (cacheKey == 'CANCELLED' && _tickets.isEmpty) {
            _tickets.add({
              "id": "dummy-cancel-123",
              "paidAmount": "1079.1",
              "status": "CANCELLED",
              "event": {
                "id": "ebb361c7-519a-4ae9-810d-5c507efec7f8",
                "title": "Cancelled Trek Adventure",
                "eventType": "TREK_DATES",
                "eventDate": "2026-10-04T00:00:00.000Z",
                "startTime": "06:00",
                "endTime": "13:00",
                "venueName": "Sinhagad Fort Trek Base",
                "fullAddress":
                    "Sinhagad Ghat Road, Thoptewadi, Pune, Maharashtra 411025",
                "heroImage":
                    "https://ik.imagekit.io/hzyuadmua/events/hero/1788065429214-undefined_IsiQ4H_hq",
              },
            });
          }

          _cachedTickets[cacheKey] = _tickets;
        } else if (!_cachedTickets.containsKey(cacheKey)) {
          _tickets = [];
        }
        _isLoading = false;
        _isInitialLoad = false;
      });
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return timeStr;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Slightly off-white background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
        title: _isSearching
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              )
            : const Text(
                'My Ticket',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 40,
                height: 40,
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
                child: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    key: _filterKeys[index],
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                      _fetchTickets();
                      final itemContext = _filterKeys[index].currentContext;
                      if (itemContext != null) {
                        Scrollable.ensureVisible(
                          itemContext,
                          alignment: 0.5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE85A7A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE85A7A)
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Tickets List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: (_isInitialLoad && _isLoading)
                  ? Column(
                      children: List.generate(
                        2,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 240,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 150,
                                          height: 14,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isLoading ? 0.4 : 1.0,
                      child: Column(
                        children: [
                          ..._tickets
                              .where((ticket) {
                                // Search Filter
                                if (_searchQuery.isNotEmpty) {
                                  final title =
                                      ticket['event']?['title']
                                          ?.toString()
                                          .toLowerCase() ??
                                      '';
                                  if (!title.contains(
                                    _searchQuery.toLowerCase(),
                                  )) {
                                    return false;
                                  }
                                }
                                return true;
                              })
                              .map((ticket) {
                                final event = ticket['event'] ?? {};
                                final dateStr = event['eventDate'] != null
                                    ? DateFormat('EEE, MMM dd').format(
                                        DateTime.parse(event['eventDate']),
                                      )
                                    : '';
                                final timeStr = event['startTime'] != null
                                    ? _formatTime(event['startTime'])
                                    : '';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildTicketCard(
                                    eventId: event['id'] ?? 'dummy_id',
                                    title: event['title'] ?? 'Unknown Event',
                                    date: '$dateStr · $timeStr',
                                    location: event['venueName'] ?? '',
                                    imageUrl: event['heroImage'] ?? '',
                                    status: ticket['status'] ?? 'Unknown',
                                  ),
                                );
                              }),
                          // Show empty message if nothing matches
                          if (_tickets.where((ticket) {
                            if (_searchQuery.isNotEmpty) {
                              final title =
                                  ticket['event']?['title']
                                      ?.toString()
                                      .toLowerCase() ??
                                  '';
                              if (!title.contains(_searchQuery.toLowerCase())) {
                                return false;
                              }
                            }
                            return true;
                          }).isEmpty)
                            Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No tickets found",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                'Looking for more events? Check ',
                                          ),
                                          TextSpan(
                                            text: 'Upcoming.',
                                            style: TextStyle(
                                              color: Color(0xFFE85A7A),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            // Only show at bottom if there ARE tickets
            if (_tickets.where((ticket) {
                  if (_searchQuery.isNotEmpty) {
                    final title =
                        ticket['event']?['title']?.toString().toLowerCase() ??
                        '';
                    if (!title.contains(_searchQuery.toLowerCase())) {
                      return false;
                    }
                  }
                  return true;
                }).isNotEmpty &&
                !_isLoading) ...[
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(text: 'Looking for more events? Check '),
                      TextSpan(
                        text: 'Upcoming.',
                        style: TextStyle(
                          color: Color(0xFFE85A7A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ] else ...[
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  bool _isRefundEligible(String dateStr) {
    try {
      // Expected format: "Sat, Oct 12 · 7:00 PM"
      final parts = dateStr.split('·');
      if (parts.length != 2) return true;
      final datePart = parts[0].trim();
      final timePart = parts[1].trim();

      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };

      final dateWords = datePart.split(RegExp(r'\s+'));
      if (dateWords.length < 3) return true;
      final monthStr = dateWords[1];
      final dayStr = dateWords[2];

      final month = months[monthStr] ?? DateTime.now().month;
      final day = int.tryParse(dayStr) ?? DateTime.now().day;

      int hour = 0;
      int minute = 0;
      if (timePart.contains(':')) {
        final timeWords = timePart.split(' ');
        final hm = timeWords[0].split(':');
        hour = int.tryParse(hm[0]) ?? 0;
        minute = int.tryParse(hm[1]) ?? 0;
        if (timeWords.length > 1 &&
            timeWords[1].toUpperCase() == 'PM' &&
            hour < 12) {
          hour += 12;
        } else if (timeWords.length > 1 &&
            timeWords[1].toUpperCase() == 'AM' &&
            hour == 12) {
          hour = 0;
        }
      }

      final now = DateTime.now();
      // Assume event is in the current year, or next year if month already passed
      int year = now.year;
      if (month < now.month) {
        year++;
      }
      final eventDate = DateTime(year, month, day, hour, minute);

      final difference = eventDate.difference(now);
      return difference.inHours >= 72;
    } catch (e) {
      return true; // Fallback
    }
  }

  Widget _buildTicketCard({
    required String eventId,
    required String title,
    required String date,
    required String location,
    required String imageUrl,
    required String status,
  }) {
    final bool isCancelled = status.toUpperCase() == 'CANCELLED';

    const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: isCancelled
                    ? ColorFiltered(
                        colorFilter: greyscaleFilter,
                        child: Opacity(
                          opacity: 0.8,
                          child: Image.network(
                            imageUrl,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              if (status.toUpperCase() == 'CONFIRMED')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 44, 175, 107),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CONFIRMED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (status.toUpperCase() == 'CANCELLED')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CANCELLED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCancelled)
                      GestureDetector(
                        onTap: () {
                          // TODO: Add tracking logic later
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE85A7A),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE85A7A).withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.track_changes_outlined,
                                size: 12,
                                color: Color(0xFFE85A7A),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Refund Status',
                                style: TextStyle(
                                  color: Color(0xFFE85A7A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    if (isCancelled)
                      const ColorFiltered(
                        colorFilter: greyscaleFilter,
                        child: Text('📅', style: TextStyle(fontSize: 14)),
                      )
                    else
                      const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    if (isCancelled)
                      const ColorFiltered(
                        colorFilter: greyscaleFilter,
                        child: Text('📍', style: TextStyle(fontSize: 14)),
                      )
                    else
                      const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                if (!isCancelled) ...[
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showCancelDrawer(
                            context,
                            isRefundEligible: _isRefundEligible(date),
                          );
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // View Details Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                    eventId: eventId,
                                    title: title,
                                    date: date,
                                    location: location,
                                    imageUrl: imageUrl,
                                    status: status,
                                    price: '₹1,250',
                                    categories: null,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isCancelled
                                      ? Colors.grey.shade400
                                      : const Color(0xFFE85A7A),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                  color: isCancelled
                                      ? Colors.grey.shade500
                                      : const Color(0xFFE85A7A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Ticket Button
                          GestureDetector(
                            onTap: () {
                              if (!isCancelled) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TicketScreen(
                                      title: title,
                                      date: date,
                                      location: location,
                                      status: status,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: isCancelled
                                    ? LinearGradient(
                                        colors: [
                                          Colors.grey.shade400,
                                          Colors.grey.shade500,
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFFFA6A85),
                                          Color(0xFFDE2957),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isCancelled
                                                ? Colors.grey
                                                : const Color(0xFFE85A7A))
                                            .withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_num,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ticket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
