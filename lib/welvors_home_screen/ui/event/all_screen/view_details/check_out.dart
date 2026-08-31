import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/booking_confirm.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/view_details/splash_screen_book.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final double basePrice;

  const CheckoutScreen({
    super.key,
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
  int _selectedPaymentMethod =
      0; // 0 = UPI, 1 = Card, 2 = Wallet, 3 = Netbanking

  final double _platformFee = 49.0;
  final double _discount = 100.0;
  
  // Partner Tickets State
  List<PartnerTicket> _partners = [];
  final double _womanPrice = 1250.0;
  final double _manPrice = 1800.0;

  double get _baseTotal {
    double total = widget.basePrice;
    for (var p in _partners) {
      total += p.isMan ? _manPrice : _womanPrice;
    }
    return total;
  }

  double get _gst => _baseTotal * 0.18;
  double get _totalPayable =>
      _baseTotal + _platformFee + _gst - _discount;

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
                                      errorBuilder: (context, error, stackTrace) =>
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
                                      errorBuilder: (context, error, stackTrace) =>
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
                                    widget.title,
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
                                    '${widget.date} · ${widget.location}',
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
                        _buildPriceRow(
                          'Ticket × 1',
                          _currencyFormat.format(widget.basePrice),
                          subtitle: "(Woman's entry)",
                        ),
                        const SizedBox(height: 10),
                        ..._partners.asMap().entries.map((entry) {
                          int idx = entry.key;
                          PartnerTicket p = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPriceRow(
                              'Partner ${idx + 1}',
                              _currencyFormat.format(p.isMan ? _manPrice : _womanPrice),
                              subtitle: p.isMan ? "(Man)" : "(Woman)",
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
                                const Text(
                                  'WELVORS100 applied',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color.fromRGBO(44, 175, 107, 1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '-${_currencyFormat.format(_discount)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(44, 175, 107, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

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

                  // Payment Method Section
                  const Text(
                    'PAYMENT METHOD',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  _buildPaymentMethodTile(
                    index: 0,
                    icon: '₹',
                    iconBgColor: const Color(0xFFFFF0F3),
                    title: 'UPI',
                    subtitle: 'GPay · PhonePe · Paytm',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentMethodTile(
                    index: 1,
                    icon: '💳',
                    iconBgColor: const Color(0xFFE8F4FD),
                    title: 'Card',
                    subtitle: 'Visa, Mastercard, RuPay',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentMethodTile(
                    index: 2,
                    icon: '🪙',
                    iconBgColor: const Color(0xFFF3E8FF),
                    title: 'Welvors Wallet',
                    subtitle: 'Balance ₹420 · partial',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentMethodTile(
                    index: 3,
                    icon: '🏦',
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: 'Net banking',
                    subtitle: 'All major banks',
                  ),
                  const SizedBox(height: 16),
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
                        onPressed: () {
                          // Navigate to splash screen first
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreenBook(
                                totalPayable: _totalPayable,
                                title: widget.title,
                                date: widget.date,
                                location: widget.location,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE43A6A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
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

  Widget _buildPriceRow(String title, String amount, {String? subtitle}) {
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required int index,
    required String icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE43A6A)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
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
                    _currencyFormat.format(partner.isMan ? _manPrice : _womanPrice),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                borderSide: const BorderSide(color: Color(0xFFE43A6A), width: 1.5),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (val) => partner.fullName = val,
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Mobile number',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                borderSide: const BorderSide(color: Color(0xFFE43A6A), width: 1.5),
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
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !partner.isMan
                          ? const Color(0xFFE43A6A).withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: !partner.isMan
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '♀ Woman - ₹1,250',
                        style: TextStyle(
                          color: !partner.isMan ? const Color(0xFFE43A6A) : Colors.black87,
                          fontWeight: !partner.isMan ? FontWeight.bold : FontWeight.normal,
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
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: partner.isMan
                          ? const Color(0xFFE43A6A).withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: partner.isMan
                            ? const Color(0xFFE43A6A)
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '♂ Man - ₹1,800',
                        style: TextStyle(
                          color: partner.isMan ? const Color(0xFFE43A6A) : Colors.black87,
                          fontWeight: partner.isMan ? FontWeight.bold : FontWeight.normal,
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
  bool isMan = true;
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
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12)));

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
