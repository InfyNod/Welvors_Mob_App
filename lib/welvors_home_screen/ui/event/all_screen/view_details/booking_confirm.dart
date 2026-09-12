import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../my_ticket.dart';

import 'dart:convert';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/service_event/event_api_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String title;
  final String date;
  final String location;
  final double totalPayable;
  final String bookingId;

  const BookingConfirmationScreen({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.bookingId,
    this.totalPayable = 1424,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  Map<String, dynamic>? _bookingDetails;
  bool _isLoading = true;

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
    
    final response = await EventApiService.getBookingPaymentSuccess(widget.bookingId);
    if (mounted) {
      setState(() {
        if (response != null && response['success'] == true) {
          _bookingDetails = response['data'];
        }
        _isLoading = false;
      });
    }
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          'Booking Confirmation',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Success Lottie Animation
                  Align(
                    alignment: Alignment.center,
                    heightFactor:
                        0.65, // This cuts off the empty space above and below the animation
                    child: SizedBox(
                      width: 220,
                      height:
                          220, // Increased size slightly to make the checkmark clearer
                      child: Lottie.asset(
                        'assets/succeess.json',
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Success Text
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Your spot is confirmed for the '),
                        TextSpan(
                          text: '${widget.title}.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(233, 247, 240, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${_bookingDetails != null ? (_bookingDetails!['payment']?['amount']?.toString() ?? widget.totalPayable.toStringAsFixed(0)) : widget.totalPayable.toStringAsFixed(0)} paid - ${_bookingDetails?['payment']?['paidVia'] ?? 'Razorpay'}',
                      style: const TextStyle(
                        color: Color.fromRGBO(44, 175, 107, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // QR Code Cards
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_bookingDetails?['booking']?['tickets'] != null)
                    ...(_bookingDetails!['booking']['tickets'] as List).map((ticket) {
                      final qrDataUrl = ticket['qrCodeUrl'] as String?;
                      final base64String = qrDataUrl?.split(',').last;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 22),
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: QrImageView(
                                data: '${ticket['ticketId'] ?? ticket['id'] ?? 'Unknown'}',
                                version: QrVersions.auto,
                                size: 150.0,
                                errorStateBuilder: (cxt, err) {
                                  return const Icon(
                                    Icons.qr_code_2,
                                    size: 120,
                                    color: Colors.black87,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'TICKET ID: ${ticket['ticketId'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Show this QR at the entrance',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load QR code. Booking ID: "${widget.bookingId}" is empty or API failed.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Payment Receipt Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PAYMENT RECEIPT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Receipt Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow('Transaction ID', _bookingDetails?['payment']?['transactionId'] ?? 'N/A'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFF5F5F5), height: 1),
                        ),
                        _buildReceiptRow('Order ID', _bookingDetails?['payment']?['orderId'] ?? 'N/A'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFF5F5F5), height: 1),
                        ),
                        _buildReceiptRow('Paid via', _bookingDetails?['payment']?['paidVia'] ?? 'Razorpay'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFF5F5F5), height: 1),
                        ),
                        _buildReceiptRow('Paid on', _bookingDetails != null ? (_bookingDetails!['payment']?['paidAt']?.toString().split('T').first ?? 'Just now') : 'Just now'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFF5F5F5), height: 1),
                        ),
                        _buildReceiptRow(
                          'Amount',
                          '₹${_bookingDetails != null ? (_bookingDetails!['payment']?['amount']?.toString() ?? widget.totalPayable.toStringAsFixed(0)) : widget.totalPayable.toStringAsFixed(0)}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFF5F5F5), height: 1),
                        ),
                        _buildReceiptRow(
                          'Status',
                          _bookingDetails != null 
                              ? (_bookingDetails!['payment']?['status'] == 'COMPLETED' ? '✓ Captured' : _bookingDetails!['payment']?['status'] ?? '✓ Captured') 
                              : '✓ Captured',
                          valueColor: const Color.fromRGBO(44, 175, 107, 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Event Details Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'EVENT DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: Calendar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFFE43A6A),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Color(0xFFF5F5F5)),
                        ),

                        // Row 2: Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFFE43A6A),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.location.split(',').first,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.location
                                            .split(',')
                                            .skip(1)
                                            .join(',')
                                            .trim()
                                            .isEmpty
                                        ? widget.location
                                        : widget.location
                                              .split(',')
                                              .skip(1)
                                              .join(',')
                                              .trim(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      height: 1.4,
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
                ],
              ),
            ),
          ),

          // --- FIXED BOTTOM BUTTONS ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 5),
            decoration: BoxDecoration(
              color: Colors.white, // Matches Scaffold background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Share Button
                  Container(
                    width: double.infinity,
                    height: 54,
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
                      onPressed: () {},
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
                          Icon(Icons.link, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Share Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // View Bookings Button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF0F5), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.pink.shade50,
                        width: 1.5,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyTicketScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'View My Bookings',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
