import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
// import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/booking_confirm.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/splash_screen_book.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/service_event/event_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String eventId;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final double basePrice;

  const CheckoutScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.basePrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _eventTitle = '';
  String _eventDate = '';
  String _eventLocation = '';

  Map<String, dynamic>? _bookingPreview;
  bool _isProcessingPayment = false;
  String? _currentBookingId;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _eventTitle = widget.title;
    _eventDate = widget.date;
    _eventLocation = widget.location;
    _fetchCheckoutDetails();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.i('CheckoutScreen', 
      'Razorpay Success: Payment ID: ${response.paymentId}, Order ID: ${response.orderId}, Signature: ${response.signature}',
    );
    
    if (mounted) {
      setState(() {
        _isProcessingPayment = true; // Keep loading spinner while verifying
      });
      
      final verifyResponse = await EventApiService.verifyPayment(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );

      if (mounted) {
        if (verifyResponse != null && verifyResponse['success'] == true) {
          setState(() {
            _isProcessingPayment = false;
          });
          
          final vEventBooking = verifyResponse['eventBooking'];
          final vData = verifyResponse['data'];
          
          if (vEventBooking != null && vEventBooking['id'] != null) {
            _currentBookingId = vEventBooking['id'];
          } else if (vData != null) {
            _currentBookingId = vData['id'] ?? vData['bookingId'] ?? vData['booking']?['id'] ?? vData['eventBooking']?['id'] ?? _currentBookingId;
          }
          
          if (_currentBookingId == null || _currentBookingId!.isEmpty) {
            _currentBookingId = verifyResponse.toString(); // Just pass it directly so it might show up in UI, but we'll see it in console now
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreenBook(
                totalPayable: _totalPayable,
                title: widget.title,
                date: widget.date,
                location: widget.location,
                bookingId: _currentBookingId ?? '',
              ),
            ),
          );
        } else {
          setState(() {
            _isProcessingPayment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Verification Failed! Please contact support.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.e('CheckoutScreen', 
      'Razorpay Error: Code: ${response.code}, Message: ${response.message}',
    );
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message ?? "Cancelled"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.d('CheckoutScreen', 'Razorpay External Wallet: ${response.walletName}');
    // Optional
  }

  Future<void> _fetchCheckoutDetails() async {
    final userGender = context
        .read<ProfileEditCubit>()
        .state
        .gender
        .toLowerCase();
    final String ticketType = (userGender == 'man' || userGender == 'men')
        ? 'MEN'
        : 'WOMEN';

    final response = await EventApiService.getCheckoutDetails(
      eventId: widget.eventId,
      ticketType: ticketType,
      ticketCount: 1,
    );

    if (response != null && response['data'] != null) {
      final data = response['data'];
      if (mounted) {
        setState(() {
          final event = data['event'];
          if (event != null) {
            _eventTitle = event['title'] ?? _eventTitle;
            _eventLocation = event['fullAddress'] ?? _eventLocation;

            if (event['eventDate'] != null) {
              try {
                final DateTime parsedDate = DateTime.parse(
                  event['eventDate'],
                ).toLocal();
                String formattedDate = DateFormat(
                  'EEE, MMM d, yyyy',
                ).format(parsedDate);
                if (event['startTime'] != null) {
                  formattedDate += ' · ${event['startTime']}';
                }
                _eventDate = formattedDate;
              } catch (e) {
                _eventDate = event['eventDate'];
              }
            } else if (event['startTime'] != null) {
              _eventDate = event['startTime'];
            }
          }

          if (data['ticketOptions'] != null) {
            for (var option in data['ticketOptions']) {
              if (option['ticketType'] == 'MEN') {
                _manPrice =
                    double.tryParse(option['discountedPrice'].toString()) ??
                    _manPrice;
              } else if (option['ticketType'] == 'WOMEN') {
                _womanPrice =
                    double.tryParse(option['discountedPrice'].toString()) ??
                    _womanPrice;
              }
            }
          }

          _bookingPreview = data['bookingPreview'];
        });
      }
    }
  }

  Future<void> _updateCheckoutCalculation() async {
    final userGender = context
        .read<ProfileEditCubit>()
        .state
        .gender
        .toLowerCase();
    final bool isUserMan = userGender == 'man' || userGender == 'men';

    int menCount = isUserMan ? 1 : 0;
    int womenCount = !isUserMan ? 1 : 0;

    for (var p in _partners) {
      if (p.isMan == true)
        menCount++;
      else if (p.isMan == false)
        womenCount++;
    }

    List<Map<String, dynamic>> tickets = [];
    if (womenCount > 0)
      tickets.add({'ticketType': 'WOMEN', 'quantity': womenCount});
    if (menCount > 0) tickets.add({'ticketType': 'MEN', 'quantity': menCount});

    final response = await EventApiService.calculateCheckout(
      eventId: widget.eventId,
      tickets: tickets,
    );

    if (response != null && response['success'] == true) {
      if (mounted) {
        setState(() {
          _bookingPreview =
              response['data']?['bookingPreview'] ?? response['data'];
        });
      }
    }
  }

  // Partner Tickets State
  List<PartnerTicket> _partners = [];
  double _womanPrice = 1250.0;
  double _manPrice = 1800.0;

  double get _baseTotal {
    if (_bookingPreview != null && _bookingPreview!['ticketAmount'] != null) {
      return double.tryParse(_bookingPreview!['ticketAmount'].toString()) ??
          0.0;
    }
    return 0.0;
  }

  double get _gst {
    if (_bookingPreview != null && _bookingPreview!['gstAmount'] != null) {
      return double.tryParse(_bookingPreview!['gstAmount'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  double get _platformFee {
    if (_bookingPreview != null && _bookingPreview!['platformFee'] != null) {
      return double.tryParse(_bookingPreview!['platformFee'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  double get _discountAmount {
    if (_bookingPreview != null && _bookingPreview!['discountAmount'] != null) {
      return double.tryParse(_bookingPreview!['discountAmount'].toString()) ??
          0.0;
    }
    return 0.0;
  }

  double get _couponDiscount {
    if (_bookingPreview != null && _bookingPreview!['couponDiscount'] != null) {
      return double.tryParse(_bookingPreview!['couponDiscount'].toString()) ??
          0.0;
    }
    return 0.0;
  }

  String get _couponCode {
    if (_bookingPreview != null && _bookingPreview!['couponCode'] != null) {
      return _bookingPreview!['couponCode'].toString();
    }
    return '';
  }

  double get _totalPayable {
    if (_bookingPreview != null && _bookingPreview!['totalAmount'] != null) {
      return double.tryParse(_bookingPreview!['totalAmount'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
          'Checkout',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Section
                  Text(
                    'ORDER SUMMARY',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFF0F5), // Very light soft pink
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE43A6A).withOpacity(0.15),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE43A6A).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Event Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: widget.imageUrl.startsWith('http')
                                  ? Image.network(
                                      widget.imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 48,
                                                height: 48,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 24,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    )
                                  : Image.asset(
                                      widget.imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 48,
                                                height: 48,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 24,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _eventTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_eventDate · $_eventLocation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                        ),

                        // Price Breakdown
                        Builder(
                          builder: (context) {
                            final userGender = context
                                .read<ProfileEditCubit>()
                                .state
                                .gender
                                .toLowerCase();
                            final bool isUserMan =
                                userGender == 'man' || userGender == 'men';
                            return _buildPriceRow(
                              'Ticket × 1',
                              _currencyFormat.format(
                                isUserMan ? _manPrice : _womanPrice,
                              ),
                              subtitle: isUserMan ? "(Man)" : "(Woman)",
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ..._partners.asMap().entries.map((entry) {
                          int idx = entry.key;
                          PartnerTicket p = entry.value;
                          if (p.isMan == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPriceRow(
                              'Partner ${idx + 1}',
                              _currencyFormat.format(
                                p.isMan == true ? _manPrice : _womanPrice,
                              ),
                              subtitle: p.isMan == true ? "(Man)" : "(Woman)",
                            ),
                          );
                        }).toList(),
                        _buildPriceRow(
                          'Platform fee',
                          _currencyFormat.format(_platformFee),
                        ),
                        const SizedBox(height: 10),
                        _buildPriceRow(
                          'GST (18%)',
                          _currencyFormat.format(_gst),
                        ),
                        if (_couponDiscount > 0 ||
                            _couponCode.isNotEmpty ||
                            true) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                        233,
                                        247,
                                        240,
                                        1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.local_activity,
                                      size: 10,
                                      color: Color.fromRGBO(44, 175, 107, 1),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _couponCode.isNotEmpty
                                        ? '$_couponCode applied'
                                        : 'WELVORS100 applied',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromRGBO(44, 175, 107, 1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '-${_currencyFormat.format(_couponDiscount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(44, 175, 107, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_couponDiscount > 0) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                        233,
                                        247,
                                        240,
                                        1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.local_activity,
                                      size: 10,
                                      color: Color.fromRGBO(44, 175, 107, 1),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_couponCode} applied',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromRGBO(44, 175, 107, 1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '-${_currencyFormat.format(_couponDiscount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(44, 175, 107, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Dashed Divider Alternative
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: List.generate(
                              30,
                              (index) => Expanded(
                                child: Container(
                                  color: index % 2 == 0
                                      ? Colors.transparent
                                      : const Color(
                                          0xFFE43A6A,
                                        ).withOpacity(0.2),
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total payable',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _currencyFormat.format(_totalPayable),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE43A6A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bring a Partner Section
                  const Text(
                    'BRING A PARTNER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBringAPartnerSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Fixed Bottom Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isProcessingPayment
                            ? null
                            : () async {
                                setState(() {
                                  _isProcessingPayment = true;
                                });

                                int menTicketCount = 0;
                                int womenTicketCount = 0;

                                final userGender = context
                                    .read<ProfileEditCubit>()
                                    .state
                                    .gender
                                    .toLowerCase();
                                final isUserMan =
                                    (userGender == 'man' ||
                                    userGender == 'men');
                                if (isUserMan)
                                  menTicketCount++;
                                else
                                  womenTicketCount++;

                                for (var p in _partners) {
                                  if (p.isMan == true)
                                    menTicketCount++;
                                  else if (p.isMan == false)
                                    womenTicketCount++;
                                }

                                final response =
                                    await EventApiService.createEventOrder(
                                      eventId: widget.eventId,
                                      menTicketCount: menTicketCount,
                                      womenTicketCount: womenTicketCount,
                                    );

                                if (mounted) {
                                      if (response != null &&
                                          response['success'] == true) {
                                        final data = response['data'];
                                        
                                        // Save booking ID to pass to success screen
                                        _currentBookingId = data['eventBooking']?['id'] ?? data['id'] ?? data['bookingId'] ?? data['booking']?['id'];

                                      var options = {
                                        'key':
                                            data['razorpayKeyId'] ??
                                            'rzp_test_TX7SxmIJ0n6rJW',
                                        'amount': (data['amount'] as num).toInt(),
                                      'name': 'Welvors',
                                      'description': 'Event Booking',
                                      'order_id': data['razorpayOrderId'],
                                      'prefill': {
                                        'contact': '9999999999', // Kept dummy because ProfileEditCubit doesn't have mobile
                                        'email': context.read<ProfileEditCubit>().state.email.isNotEmpty 
                                            ? context.read<ProfileEditCubit>().state.email 
                                            : 'user@welvors.com',
                                      },
                                      'retry': {
                                        'enabled': true,
                                        'max_count': 1,
                                      },
                                      'send_sms_hash': true,
                                      'theme': {'color': '#E43A6A'},
                                      'external': {
                                        // TODO: Remove 'external' block before going LIVE, otherwise native UPI will get stuck on loading!
                                        'wallets': [
                                          'upi',
                                          'paytm',
                                          'phonepe',
                                          'gpay',
                                        ],
                                        'upi': true,
                                      },
                                    };

                                    try {
                                      _razorpay.open(options);
                                    } catch (e) {
                                      AppLogger.e('CheckoutScreen', 'Error opening Razorpay: $e');
                                      setState(() {
                                        _isProcessingPayment = false;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _isProcessingPayment = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response?['message'] ??
                                              'Failed to create order',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE43A6A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isProcessingPayment
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pay ${_currencyFormat.format(_totalPayable)} securely',
                                    style: const TextStyle(
                                      fontSize: 16,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String title,
    String amount, {
    String? subtitle,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? const Color.fromRGBO(44, 175, 107, 1)
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBringAPartnerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket price differs by gender — a partner\'s ticket is charged at their rate.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._partners.asMap().entries.map((entry) {
                  int idx = entry.key;
                  PartnerTicket p = entry.value;
                  return _buildPartnerForm(idx, p);
                }).toList(),
                // Add button
                InkWell(
                  onTap: () {
                    setState(() {
                      _partners.add(PartnerTicket());
                    });
                    _updateCheckoutCalculation();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: DashedBorderPainter(
                      color: const Color(0xFFE43A6A).withOpacity(0.5),
                      strokeWidth: 1.5,
                      gap: 6.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFE43A6A).withOpacity(0.05),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Color(0xFFE43A6A), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Add partner ticket',
                            style: TextStyle(
                              color: Color(0xFFE43A6A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerForm(int index, PartnerTicket partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Partner ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Text(
                    _currencyFormat.format(
                      partner.isMan == null
                          ? 0.0
                          : (partner.isMan == true ? _manPrice : _womanPrice),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE43A6A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _partners.removeAt(index);
                        });
                        _updateCheckoutCalculation();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE43A6A).withOpacity(0.08),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFFE43A6A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Full name',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE43A6A),
                  width: 1.5,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (val) => partner.fullName = val,
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              counterText: "",
              hintText: 'Mobile number',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE43A6A),
                  width: 1.5,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (val) => partner.mobile = val,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      partner.isMan = false;
                    });
                    _updateCheckoutCalculation();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: partner.isMan == false
                          ? const Color(0xFFE43A6A).withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: partner.isMan == false
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Woman - ${_currencyFormat.format(_womanPrice)}',
                        style: TextStyle(
                          color: partner.isMan == false
                              ? const Color(0xFFE43A6A)
                              : Colors.black87,
                          fontWeight: partner.isMan == false
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      partner.isMan = true;
                    });
                    _updateCheckoutCalculation();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: partner.isMan == true
                          ? const Color(0xFFE43A6A).withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: partner.isMan == true
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Man - ${_currencyFormat.format(_manPrice)}',
                        style: TextStyle(
                          color: partner.isMan == true
                              ? const Color(0xFFE43A6A)
                              : Colors.black87,
                          fontWeight: partner.isMan == true
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PartnerTicket {
  String fullName = '';
  String mobile = '';
  bool? isMan;
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2.0;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
