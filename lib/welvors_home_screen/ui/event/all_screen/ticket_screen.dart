import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'service_event/event_api_service.dart';
import 'share_ticket_card.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class TicketScreen extends StatefulWidget {
  final String title;
  final String date;
  final String location;
  final String status;
  final String bookingId;

  const TicketScreen({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.status,
    required this.bookingId,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  bool _isLoading = true;
  List<dynamic> _tickets = [];
  Map<String, dynamic>? _eventDetails;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    if (widget.bookingId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await EventApiService.getBookingPaymentSuccess(
      widget.bookingId,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null && response['success'] == true) {
          final data = response['data'];
          if (data != null && data['booking'] != null) {
            _tickets = data['booking']['tickets'] ?? [];
            _eventDetails = data['booking']['event'];
          } else if (data != null && data['eventBooking'] != null) {
            _tickets = data['eventBooking']['tickets'] ?? [];
            _eventDetails = data['eventBooking']['event'];
          }
        }
      });
    }
  }

  Future<void> _openMap() async {
    double? lat;
    double? lng;

    // Use event coordinates if available
    if (_eventDetails != null) {
      if (_eventDetails!['latitude'] != null) {
        lat = (_eventDetails!['latitude'] is String)
            ? double.tryParse(_eventDetails!['latitude'].toString()) ?? lat
            : (_eventDetails!['latitude'] as num).toDouble();
      }
      if (_eventDetails!['longitude'] != null) {
        lng = (_eventDetails!['longitude'] is String)
            ? double.tryParse(_eventDetails!['longitude'].toString()) ?? lng
            : (_eventDetails!['longitude'] as num).toDouble();
      }
    }

    String query;
    if (lat != null && lng != null) {
      query = '$lat,$lng';
    } else if (widget.location.isNotEmpty) {
      query = Uri.encodeComponent(widget.location);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not available')),
        );
      }
      return;
    }

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map app')));
      }
    }
  }

  void _showShareModal() {
    if (_tickets.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ShareModalContent(
          tickets: _tickets,
          title: widget.title,
          date: widget.date,
          location: widget.location,
          status: widget.status,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
        title: const Text(
          'Your Ticket',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                  )
                : _tickets.isEmpty
                ? const Center(
                    child: Text('No tickets found for this booking.'),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: _tickets
                          .map((ticket) => _buildPremiumTicketCard(ticket))
                          .toList(),
                    ),
                  ),
          ),

          // --- FIXED BOTTOM BUTTONS ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Share Ticket Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _showShareModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Share Ticket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTicketCard(Map<String, dynamic> ticket) {
    final ticketIdStr = ticket['ticketId'] ?? ticket['id'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE43A6A).withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- TOP HALF ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Confirmed Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1CAF5E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1CAF5E).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1CAF5E),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.status.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1CAF5E),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Date
                Text(
                  widget.date,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE43A6A),
                  ),
                ),
                const SizedBox(height: 20),

                // Premium QR Code Visual
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE43A6A).withOpacity(0.15),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: QrImageView(
                        data: ticketIdStr,
                        version: QrVersions.auto,
                        size: 130.0,
                        errorStateBuilder: (cxt, err) {
                          return Icon(
                            Icons.qr_code_2,
                            size: 110,
                            color: Colors.black87.withOpacity(0.85),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ticket ID
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: $ticketIdStr',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- TICKET DIVIDER (Dashed Line & Cutouts) ---
          SizedBox(
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Dashed Line
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (constraints.constrainWidth() / 12).floor(),
                          (index) => Container(
                            width: 6,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Left Cutout (Hole effect)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(250, 241, 244, 1.0),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // Right Cutout (Hole effect)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(250, 241, 244, 1.0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- BOTTOM HALF ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Location Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pin Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE43A6A).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFE43A6A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.location.split(',').first,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.location.split(',').skip(1).join(',').trim(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Get Directions Button
                    GestureDetector(
                      onTap: _openMap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.directions,
                              color: Color(0xFFE43A6A),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Directions',
                              style: TextStyle(
                                color: Color(0xFFE43A6A),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Important Info Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF4F6), Color(0xFFFFF8F9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE43A6A).withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFE43A6A),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'IMPORTANT INFO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE43A6A),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Please arrive 15 mins early'),
                      const SizedBox(height: 4),
                      _buildInfoRow('Carry a valid photo ID'),
                      const SizedBox(height: 4),
                      _buildInfoRow('Dress Code: Smart Casual'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class ShareModalContent extends StatefulWidget {
  final List<dynamic> tickets;
  final String title;
  final String date;
  final String location;
  final String status;

  const ShareModalContent({
    Key? key,
    required this.tickets,
    required this.title,
    required this.date,
    required this.location,
    required this.status,
  }) : super(key: key);

  @override
  State<ShareModalContent> createState() => ShareModalContentState();
}

class ShareModalContentState extends State<ShareModalContent> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _currentIndex = 0;
  bool _isSharing = false;
  bool _selectAll = false;

  Future<void> _shareTicket() async {
    if (widget.tickets.isEmpty) return;
    setState(() => _isSharing = true);

    try {
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            InheritedTheme.captureAll(
              context,
              Material(
                color: Colors.transparent,
                child: Center(
                  child: ShareTicketCard(
                    ticket: widget.tickets[_currentIndex],
                    title: widget.title,
                    date: widget.date,
                    location: widget.location,
                    status: widget.status,
                  ),
                ),
              ),
            ),
            delay: const Duration(milliseconds: 100),
          );

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Here is my ticket for ${widget.title}!',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      AppLogger.e('TicketScreen', 'Error sharing: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share ticket: $e')));
      }
    }

    if (mounted) setState(() => _isSharing = false);
  }

  Future<void> _shareAllTickets() async {
    if (widget.tickets.isEmpty) return;
    setState(() => _isSharing = true);

    try {
      List<XFile> imageFiles = [];
      final directory = await getTemporaryDirectory();

      for (int i = 0; i < widget.tickets.length; i++) {
        final Uint8List imageBytes = await _screenshotController
            .captureFromWidget(
              InheritedTheme.captureAll(
                context,
                Material(
                  color: Colors.transparent,
                  child: Center(
                    child: ShareTicketCard(
                      ticket: widget.tickets[i],
                      title: widget.title,
                      date: widget.date,
                      location: widget.location,
                      status: widget.status,
                    ),
                  ),
                ),
              ),
              delay: const Duration(milliseconds: 100),
            );

        final imagePath = await File(
          '${directory.path}/ticket_${DateTime.now().millisecondsSinceEpoch}_$i.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);
        imageFiles.add(XFile(imagePath.path));
      }

      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.shareXFiles(
        imageFiles,
        text: 'Here are my tickets for ${widget.title}!',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      AppLogger.e('TicketScreen', 'Error sharing all: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share all tickets: $e')),
        );
      }
    }

    if (mounted) setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Share Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.tickets.length > 1)
                Positioned(
                  right: 24,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectAll = !_selectAll;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _selectAll
                            ? const Color(0xFFE43A6A)
                            : Colors.transparent,
                        border: Border.all(
                          color: _selectAll
                              ? const Color(0xFFE43A6A)
                              : Colors.white54,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Select All',
                        style: TextStyle(
                          color: _selectAll ? Colors.white : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.tickets.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Swipe to select a ticket',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                _BlinkingArrow(),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: widget.tickets.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: ShareTicketCard(
                      ticket: widget.tickets[index],
                      title: widget.title,
                      date: widget.date,
                      location: widget.location,
                      status: widget.status,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Share Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFFE43A6A).withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSharing
                    ? null
                    : () {
                        if (_selectAll && widget.tickets.length > 1) {
                          _shareAllTickets();
                        } else {
                          _shareTicket();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE43A6A),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSharing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _selectAll && widget.tickets.length > 1
                            ? 'Share All Tickets'
                            : 'Share This Ticket',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Close Button
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingArrow extends StatefulWidget {
  @override
  _BlinkingArrowState createState() => _BlinkingArrowState();
}

class _BlinkingArrowState extends State<_BlinkingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text(
        ' >>>>>',
        style: TextStyle(
          color: Color(0xFFFA6A85),
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}