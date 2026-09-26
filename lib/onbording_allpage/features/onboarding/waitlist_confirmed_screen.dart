import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'refer_and_earn_screen.dart';
import 'package:lottie/lottie.dart';
import 'user_data.dart';
import '../../services/api_service.dart';

class WaitlistConfirmedScreen extends StatefulWidget {
  const WaitlistConfirmedScreen({super.key});

  @override
  State<WaitlistConfirmedScreen> createState() =>
      _WaitlistConfirmedScreenState();
}

class _WaitlistConfirmedScreenState extends State<WaitlistConfirmedScreen> {
  Timer? _timer;
  Duration _timeLeft = const Duration(days: 0);
  bool _isCopied = false;
  bool _isLoading = true;
  String _originalPrice = '1000';
  String _totalBenefitsValue = '2400';
  DateTime? _launchDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.fetchWaitlistOffer();
    if (data != null && mounted) {
      setState(() {
        _originalPrice = data['originalPrice']?.toString() ?? '1000';
        _totalBenefitsValue = data['totalBenefitsValue']?.toString() ?? '2400';
        if (data['launchDate'] != null) {
          _launchDate = DateTime.tryParse(data['launchDate']);
        }
        _updateTimeLeft();
        _startTimer();
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _updateTimeLeft();
        _startTimer();
        _isLoading = false;
      });
    }
  }

  void _updateTimeLeft() {
    if (_launchDate != null) {
      final now = DateTime.now();
      if (_launchDate!.isAfter(now)) {
        _timeLeft = _launchDate!.difference(now);
      } else {
        _timeLeft = Duration.zero;
      }
    } else {
      _timeLeft = const Duration(days: 89, hours: 23, minutes: 51, seconds: 25);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTimeLeft();
          if (_timeLeft.inSeconds <= 0) {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: CircularProgressIndicator(color: AppColors.pinkDeep)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Waitlist Confirmed Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 12, color: Color(0xFFD94A4A)),
                    const SizedBox(width: 4),
                    Text(
                      'WAITLIST CONFIRMED',
                      style: AppText.body.copyWith(
                        color: AppColors.pink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                "You're in, ${userData.name.isNotEmpty ? userData.name.split(' ').first : 'there'}!",
                style: AppText.display.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppText.body.copyWith(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: 'Spot '),
                    TextSpan(
                      text: '#976',
                      style: AppText.body.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(text: ' reserved.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Countdown Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.pinkSoft.withValues(alpha: 0.5),
                      AppColors.pinkSoft,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pink.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🚀', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            'LAUNCHING IN',
                            style: AppText.body.copyWith(
                              color: AppColors.pinkDeep,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeBox(
                            _timeLeft.inDays.toString().padLeft(2, '0'),
                            'DAYS',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTimeBox(
                            (_timeLeft.inHours % 24).toString().padLeft(2, '0'),
                            'HRS',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTimeBox(
                            (_timeLeft.inMinutes % 60).toString().padLeft(
                              2,
                              '0',
                            ),
                            'MIN',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTimeBox(
                            (_timeLeft.inSeconds % 60).toString().padLeft(
                              2,
                              '0',
                            ),
                            'SEC',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: AppColors.pinkDeep.withValues(alpha: 0.15),
                      height: 1,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppText.body.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'When this hits zero, Welvors goes live. As a founding member you\'re ',
                          ),
                          TextSpan(
                            text: 'first through the door',
                            style: AppText.body.copyWith(
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                          const TextSpan(
                            text: ' — we\'ll notify you the moment it opens.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Your details Card
              _buildInfoCard(
                icon: Icons.person,
                iconColor: AppColors.blue,
                title: 'Your details',
                children: [
                  _buildDetailRow('Name', '${userData.name}, ${userData.age}'),
                  _buildDetailRow(
                    'Phone',
                    userData.phone.isEmpty ? 'Not specified' : userData.phone,
                  ),
                  _buildDetailRow(
                    'Email',
                    userData.email.isEmpty ? 'Not specified' : userData.email,
                  ),
                  _buildDetailRow(
                    'City',
                    userData.location.isEmpty
                        ? 'Not specified'
                        : userData.location,
                  ),
                  _buildDetailRow(
                    'Welvors ID',
                    userData.welvorsId.isEmpty
                        ? 'Not specified'
                        : userData.welvorsId,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment details Card
              _buildInfoCard(
                icon: Icons.receipt_long,
                iconColor: AppColors.muted,
                title: 'Payment details',
                children: [
                  _buildDetailRow(
                    'Amount paid',
                    '₹299',
                    valueColor: AppColors.green,
                  ),
                  _buildDetailRow('Plan', 'Founding · 1 mo Premium'),
                  _buildDetailRow('Transaction ID', 'TXN0982561XN'),
                  _buildDetailRow('Date & time', '10 Jul 2026, 12:58 PM'),
                  _buildStatusRow('Status', 'Success'),
                ],
              ),
              const SizedBox(height: 16),

              // Invite Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF0F3), // soft premium pink
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pinkDeep.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Center(
                        child: Lottie.asset(
                          'assets/Referral.json',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Text(
                        'Invite friends, share the perks',
                        style: AppText.display.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: AppColors.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 0),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppText.body.copyWith(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Refer a friend and they lock the ',
                          ),
                          TextSpan(
                            text: 'exact same founding benefits',
                            style: TextStyle(
                              color: AppColors.pinkDeep,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: ' you just did — plus '),
                          TextSpan(
                            text: 'you both get ₹100',
                            style: TextStyle(
                              color: AppColors.pinkDeep,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: ' in Welvors Coins at launch.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Inner Perks Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.pinkDeep.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR FRIEND ALSO GETS',
                            style: AppText.body.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 18,
                                color: Color(0xFFD94A4A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '1 month Premium free at launch',
                                  style: AppText.body.copyWith(
                                    fontSize: 14,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Text(
                                '₹$_originalPrice',
                                style: AppText.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 18,
                                color: Color(0xFFD94A4A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Early access — first pick of matches',
                                  style: AppText.body.copyWith(
                                    fontSize: 14,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Text(
                                'FREE',
                                style: AppText.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Divider(
                            color: AppColors.line.withValues(alpha: 0.5),
                            height: 1,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text('💎', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                'Total first-month value',
                                style: AppText.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹$_totalBenefitsValue+',
                                style: AppText.body.copyWith(
                                  fontSize: 15,
                                  color: AppColors.pinkDeep,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '+ 100 Welcome Coins',
                                style: AppText.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                'one-time',
                                style: AppText.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.pinkDeep,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Code Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.pink,
                          width: 1.5,
                        ), // Ideally dashed
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DEEE156',
                            style: AppText.display.copyWith(
                              fontSize: 22,
                              letterSpacing: 2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                const ClipboardData(text: 'DEEE156'),
                              );
                              setState(() => _isCopied = true);
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) setState(() => _isCopied = false);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _isCopied
                                    ? Colors.green
                                    : AppColors.pinkDeep,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isCopied ? 'Copied!' : 'Copy',
                                style: AppText.body.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Share Link Button
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          final box = context.findRenderObject() as RenderBox?;
                          Share.share(
                            'Join Velvors with my invite code TANISHKA250 and get rewards! 🚀\nhttps://velvors.com',
                            sharePositionOrigin: box != null
                                ? box.localToGlobal(Offset.zero) & box.size
                                : null,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.pinkDeep,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.link, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Share invite link',
                                style: AppText.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // View referral history Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReferAndEarnScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.pinkSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.pinkDeep),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bar_chart,
                              size: 16,
                              color: Color(0xFFD94A4A),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'View referral history',
                              style: AppText.button.copyWith(
                                color: AppColors.pinkDeep,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.pinkDeep.withValues(alpha: 0.5),
                  ),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            '📧 We\'ll email & SMS you the second Welvors launches. ',
                      ),
                      TextSpan(
                        text: 'Nothing more to do for now — sit tight!',
                        style: AppText.body.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppText.display.copyWith(
                color: AppColors.pinkDeep,
                fontSize: 28,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppText.body.copyWith(
              color: AppColors.pink.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) ...[
              const SizedBox(height: 16),
              Divider(color: AppColors.line.withValues(alpha: 0.3), height: 1),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.body.copyWith(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppText.body.copyWith(
              color: valueColor ?? AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.body.copyWith(color: AppColors.muted, fontSize: 13),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF28A76F),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: AppText.body.copyWith(
                color: AppColors.green,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
