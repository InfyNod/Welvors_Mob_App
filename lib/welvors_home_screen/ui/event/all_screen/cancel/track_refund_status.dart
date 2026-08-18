import 'package:flutter/material.dart';

class TrackRefundScreen extends StatelessWidget {
  const TrackRefundScreen({super.key});

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
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        title: const Text(
          'Refund Status',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPolicyNotice(),
                  const SizedBox(height: 16),
                  _buildStatusApproved(),
                  const SizedBox(height: 24),
                  _buildTotalRefundCard(),
                  const SizedBox(height: 32),
                  _buildTimeline(),
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomChatButton(),
        ],
      ),
    );
  }

  Widget _buildPolicyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Refund Policy: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB98000),
                    ),
                  ),
                  TextSpan(
                    text:
                        'Full refunds are only processed for cancellations made ',
                  ),
                  TextSpan(
                    text: '3 or more days ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: 'before the event date.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusApproved() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(227, 243, 234, 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Color.fromRGBO(25, 110, 66, 1.0), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'REFUND STATUS: Approved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(25, 110, 66, 1.0),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cancelled 4 days before event (Policy: >3 days)',
                  style: TextStyle(fontSize: 12, color: Color.fromRGBO(25, 110, 66, 1.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRefundCard() {
    return Container(
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.shade50, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE43A6A).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative faded icon in the background
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 80,
              color: const Color(0xFFE43A6A).withOpacity(0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE43A6A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      size: 14,
                      color: Color(0xFFE43A6A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TOTAL REFUND',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Reduced
              const Text(
                '₹1,250',
                style: TextStyle(
                  fontSize: 34, // Reduced from 38
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE43A6A),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6), // Reduced
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.shade200,
                      Colors.pink.shade50.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16), // Reduced
              _buildInfoRow('Refund ID', 'RFD-9928341', isBold: true),
              const SizedBox(height: 8), // Reduced
              _buildInfoRow('Event', 'Sunset Soirée for Singles', isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRACKING HISTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            isFirst: true,
            isLast: false,
            isActive: false,
            isCompleted: true,
            title: 'Refund Initiated',
            subtitle:
                'Oct 24 · 10:30 AM\nThe refund process was successfully started from our end.',
          ),
          _buildTimelineItem(
            isFirst: false,
            isLast: false,
            isActive: true,
            isCompleted: false,
            title: 'Processing by Bank',
            subtitle:
                'Ongoing\nYour bank is verifying the transaction. This typically takes 5-7 business days.',
            titleColor: const Color(0xFFE43A6A),
          ),
          _buildTimelineItem(
            isFirst: false,
            isLast: true,
            isActive: false,
            isCompleted: false,
            title: 'Refund Completed',
            subtitle: 'Funds will be credited back to your original source.',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isFirst,
    required bool isLast,
    required bool isActive,
    required bool isCompleted,
    required String title,
    required String subtitle,
    Color? titleColor,
  }) {
    // Top line
    Color topLineColor = isFirst
        ? Colors.transparent
        : (isActive || isCompleted
              ? const Color(0xFFE43A6A)
              : Colors.grey.shade300);
    double topLineWidth = (isActive || isCompleted) ? 3.0 : 2.0;

    // Bottom line
    Color bottomLineColor = isLast
        ? Colors.transparent
        : (isCompleted ? const Color(0xFFE43A6A) : Colors.grey.shade300);
    double bottomLineWidth = isCompleted ? 3.0 : 2.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Top line (Fixed height for alignment)
                Container(
                  width: topLineWidth,
                  height: 6,
                  decoration: BoxDecoration(color: topLineColor),
                ),
                // Premium Node icon
                _buildNodeIcon(isActive: isActive, isCompleted: isCompleted),
                // Bottom line (Dashed for pending, Solid for completed)
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : (isCompleted
                            ? Container(
                                width: bottomLineWidth,
                                decoration: BoxDecoration(
                                  color: bottomLineColor,
                                ),
                              )
                            : _buildDashedLine(bottomLineColor)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 24.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          titleColor ??
                          (isCompleted || isActive
                              ? Colors.black87
                              : Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.grey.shade600 : Colors.grey,
                      height: 1.4,
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

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.credit_card,
            title: 'HDFC Credit Card',
            subtitle: 'Ending in •••• 1234',
          ),
          Divider(color: Colors.grey.shade100, height: 1, indent: 64),
          _buildDetailRow(
            icon: Icons.access_time_filled,
            title: 'Est. Completion',
            subtitle: 'Nov 01, 2026',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE43A6A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE43A6A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Back to black
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey, // Back to grey
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine(Color color) {
    return SizedBox(
      width: 2,
      child: CustomPaint(painter: _DashedLinePainter(color: color)),
    );
  }

  Widget _buildBottomChatButton() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0F5), Colors.white], // Pink to light pink
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.pink.shade50,
              width: 1,
            ), // added slight border to define the button
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💬', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Chat with Support',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNodeIcon({required bool isActive, required bool isCompleted}) {
    Widget node = Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? const Color(0xFFE43A6A) : Colors.white,
        border: Border.all(
          color: isCompleted
              ? Colors.transparent
              : (isActive ? const Color(0xFFE43A6A) : Colors.grey.shade300),
          width: isCompleted ? 0 : 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFE43A6A).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : (isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : []),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 12, color: Colors.white)
            : (isActive
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE43A6A),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null),
      ),
    );

    if (isActive) {
      return _BlinkingNode(child: node);
    }
    return node;
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double dashHeight = 4, dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BlinkingNode extends StatefulWidget {
  final Widget child;
  const _BlinkingNode({required this.child});

  @override
  State<_BlinkingNode> createState() => _BlinkingNodeState();
}

class _BlinkingNodeState extends State<_BlinkingNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
