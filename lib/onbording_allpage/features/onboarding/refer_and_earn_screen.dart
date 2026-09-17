import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../services/api_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'share_referral_card.dart';
class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen>
    with SingleTickerProviderStateMixin {
  bool _isCopied = false;
  late AnimationController _gradientController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  final TextEditingController _inviteCodeController = TextEditingController();
  bool _isInviteCodeValid = false;
  bool _isApplyingCode = false;
  String _selectedTab = 'Joined';

  bool _isLoading = true;
  String _referralCode = '';
  String _shareLink = '';
  int _totalEarned = 0;
  int _joinedCount = 0;
  int _rewardedCount = 0;
  int _pendingCount = 0;
  List<Map<String, dynamic>> _allReferrals = [];

  String _signupReward = '';
  String _packageReward = '';
  String _rewardsTitle = '';
  List<String> _rewardsDescriptions = [];

  List<Map<String, dynamic>> get _filteredReferrals {
    if (_selectedTab == 'Rewarded') {
      return _allReferrals.where((r) => r['isRewarded'] == true).toList();
    } else if (_selectedTab == 'Pending') {
      return _allReferrals.where((r) => r['isPending'] == true).toList();
    }
    return _allReferrals;
  }

  Future<void> _fetchData() async {
    final results = await Future.wait([
      ApiService.fetchReferralDashboard(),
      ApiService.fetchReferEarnInfo(),
    ]);

    final data = results[0];
    final infoData = results[1];

    if (mounted) {
      setState(() {
        if (data != null) {
          final stats = data['stats'] ?? {};
          final List history = data['history'] ?? [];

          _referralCode = data['referralCode'] ?? '';
          _shareLink = data['shareLink'] ?? '';
          if (_shareLink.isNotEmpty && !_shareLink.startsWith('http')) {
            _shareLink = 'https://$_shareLink';
          }

          _totalEarned = stats['totalEarned'] ?? 0;
          _joinedCount = stats['joined'] ?? 0;
          _rewardedCount = stats['rewarded'] ?? 0;
          _pendingCount = stats['pending'] ?? 0;

          _allReferrals = history.map<Map<String, dynamic>>((item) {
            final String name = item['name'] ?? 'User';
            final String statusStr = item['status'] ?? '';
            final int totalReward = item['totalReward'] ?? 0;
            final bool isRewarded = totalReward > 0 || statusStr == 'REWARDED';

            String initials = '';
            if (name.isNotEmpty) {
              final parts = name.split(' ');
              if (parts.length > 1 && parts[1].isNotEmpty) {
                initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
              } else {
                initials = name[0].toUpperCase();
              }
            }

            return {
              'name': name,
              'status': isRewarded ? 'Joined · Rewarded' : 'Joined',
              'amount': isRewarded ? '+₹$totalReward' : '',
              'amountSub': isRewarded ? 'credited' : '',
              'amountColor': const Color(0xFF2E7D32),
              'initials': initials,
              'profileImage': item['profileImage'],
              'isRewarded': isRewarded,
              'isPending': !isRewarded,
            };
          }).toList();
        }

        if (infoData != null) {
          _signupReward = infoData['signupReward']?.toString() ?? '100';
          _packageReward = infoData['packageReward']?.toString() ?? '500';
          _rewardsTitle =
              infoData['title']?.toString().toUpperCase() ?? 'HOW REWARDS WORK';

          if (infoData['descriptions'] != null) {
            final List descriptions = infoData['descriptions'];
            _rewardsDescriptions = descriptions
                .map((d) => d['description']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toList();
          }
        }

        _isLoading = false;
      });
    }
  }

  Future<void> _applyReferralCode() async {
    final code = _inviteCodeController.text.trim();
    if (code.length != 8) return;

    setState(() => _isApplyingCode = true);
    FocusScope.of(context).unfocus();

    final result = await ApiService.applyReferralCode(code);

    if (mounted) {
      setState(() => _isApplyingCode = false);

      final bool success = result?['success'] == true;
      final String message =
          result?['message'] ??
          (success
              ? 'Referral code applied successfully!'
              : 'Failed to apply code.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        _inviteCodeController.clear();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _inviteCodeController.addListener(() {
      final isValid = _inviteCodeController.text.trim().length == 8;
      if (_isInviteCodeValid != isValid) {
        setState(() {
          _isInviteCodeValid = isValid;
        });
      }
    });

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFFE94086),
      end: const Color(0xFFFF80AB), // Light Pink
    ).animate(_gradientController);

    _color2 = ColorTween(
      begin: const Color(0xFFC2185B),
      end: const Color.fromARGB(255, 198, 34, 122), // Very Dark Pink
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
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
        title: Text(
          'Refer & Earn',
          style: AppText.h2.copyWith(fontSize: 18, letterSpacing: 0.5),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pinkDeep),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // Animated Gradient Banner
                  AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              _color1.value ?? const Color(0xFFE94086),
                              _color2.value ?? const Color(0xFFC2185B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_color1.value ?? const Color(0xFFE94086))
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Center graphics (gift lottie)
                        Positioned(
                          top: 0,
                          child: Lottie.asset(
                            'assets/giftref.json',
                            width: 170,
                            height: 170,
                            fit: BoxFit.contain,
                            repeat: false,
                          ),
                        ),
                        // Title text
                        Positioned(
                          bottom: 12,
                          child: Text(
                            'Refer & Earn',
                            style: AppText.h2.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // How it works Title
                  Text(
                    'How it works',
                    style: AppText.eyebrow.copyWith(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timeline items
                  _buildTimelineItem(
                    icon: Icons.share,
                    title: 'Share your code',
                    description:
                        'Send your invite link via WhatsApp, Instagram or anywhere.',
                    isFirst: true,
                  ),
                  _buildTimelineSpacing(),
                  _buildTimelineItem(
                    icon: Icons.login,
                    title: 'Friend joins Welvors',
                    description: 'They sign up & log in using your code.',
                    rewardText: '+₹$_signupReward',
                  ),
                  _buildTimelineSpacing(),
                  _buildTimelineItem(
                    icon: Icons.diamond_outlined,
                    title: 'They buy any plan',
                    description: 'Premium+, VIP or Elite — any package counts.',
                    rewardText: '+₹$_packageReward',
                    isLast: true,
                  ),

                  const SizedBox(height: 32),

                  // Your invite code Title
                  Text(
                    'Your invite code',
                    style: AppText.eyebrow.copyWith(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Invite Code Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF0F0F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TAP TO COPY',
                          style: AppText.eyebrow.copyWith(
                            color: AppColors.muted,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(_referralCode),
                          child: Text(
                            _referralCode.isEmpty ? '...' : _referralCode,
                            style: AppText.display.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 28,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _copyToClipboard(_referralCode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _isCopied
                                  ? Colors.green.withOpacity(0.1)
                                  : AppColors.pinkSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCopied ? Icons.check : Icons.copy,
                                  size: 16,
                                  color: _isCopied
                                      ? Colors.green
                                      : AppColors.pinkDeep,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCopied ? 'Copied!' : 'Copy code',
                                  style: AppText.button.copyWith(
                                    color: _isCopied
                                        ? Colors.green
                                        : AppColors.pinkDeep,
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



                  // Invite friends & earn button
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () async {
                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: AppColors.pinkDeep),
                            ),
                          );

                          final screenshotController = ScreenshotController();
                          
                          // Capture the widget
                          final capturedImage = await screenshotController.captureFromWidget(
                            ShareReferralCard(referralCode: _referralCode),
                            delay: const Duration(milliseconds: 200),
                            context: context,
                          );

                          // Hide loading
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          // Save and Share
                          final directory = await getTemporaryDirectory();
                          final imagePath = await File('${directory.path}/referral_share.png').create();
                          await imagePath.writeAsBytes(capturedImage);

                          final box = context.findRenderObject() as RenderBox?;
                          await Share.shareXFiles(
                            [XFile(imagePath.path)],
                            text: 'Join Velvors with my invite code $_referralCode and get rewards! 🚀\n$_shareLink',
                            sharePositionOrigin: box != null
                                ? box.localToGlobal(Offset.zero) & box.size
                                : null,
                          );
                        } catch (e) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          debugPrint('Error sharing referral: $e');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.pinkDeep,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pinkDeep.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Invite friends & earn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Have a friend's code?
                  Text(
                    "Have a friend's code?",
                    style: AppText.h2.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF0F0F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _inviteCodeController,
                                  maxLength: 8,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                    color: AppColors.pinkDeep,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter invite code',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 14,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none,
                                    counterText: '',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 13,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: (_isInviteCodeValid && !_isApplyingCode)
                                  ? _applyReferralCode
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isInviteCodeValid
                                      ? AppColors.pinkDeep
                                      : AppColors.pinkDeep.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _isApplyingCode
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Apply',
                                        style: AppText.button.copyWith(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Enter a friend's code to give them credit when you join — you can add it once.",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Total Earned Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE94086), Color(0xFFC2185B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pinkDeep.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total earned',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹$_totalEarned',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Withdraw to UPI anytime',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Lottie.asset(
                          'assets/moneybag.json',
                          width: 95,
                          height: 95,
                          repeat: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Your Referrals
                  Text(
                    'Your referrals',
                    style: AppText.h2.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildReferralTab(
                          'Joined',
                          '$_joinedCount',
                          _selectedTab == 'Joined',
                        ),
                        const SizedBox(width: 8),
                        _buildReferralTab(
                          'Rewarded',
                          '$_rewardedCount',
                          _selectedTab == 'Rewarded',
                        ),
                        const SizedBox(width: 8),
                        _buildReferralTab(
                          'Pending',
                          '$_pendingCount',
                          _selectedTab == 'Pending',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Referral Item
                        Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF0F0F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _filteredReferrals.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(
                                    'No referrals yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ]
                          : _filteredReferrals.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final Map<String, dynamic> r = entry.value;
                              return Column(
                                children: [
                                  if (index > 0)
                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                  _buildReferralItem(
                                    name: r['name'],
                                    status: r['status'],
                                    amount: r['amount'],
                                    amountSub: r['amountSub'],
                                    initials: r['initials'],
                                    amountColor:
                                        r['amountColor'] ??
                                        const Color(0xFF2E7D32),
                                  ),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // HOW REWARDS WORK
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.pinkSoft.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.pinkDeep.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.pinkDeep,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _rewardsTitle,
                              style: TextStyle(
                                color: AppColors.pinkDeep,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._rewardsDescriptions.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final String desc = entry.value;
                          return Column(
                            children: [
                              _buildRewardRule(desc),
                              if (index < _rewardsDescriptions.length - 1)
                                const SizedBox(height: 12),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSocialButton(
    String label, {
    IconData? icon,
    String? lottiePath,
    double scale = 1.0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottiePath != null)
              Transform.scale(
                scale: scale,
                child: Lottie.asset(
                  lottiePath,
                  width: 32,
                  height: 32,
                  repeat: true,
                ),
              )
            else if (icon != null)
              Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralTab(String label, String count, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pinkSoft.withOpacity(0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.pinkDeep : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.pinkDeep : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pinkDeep : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSpacing() {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 8,
          child: CustomPaint(
            painter: DashedLinePainter(
              color: AppColors.pinkDeep.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    String? rewardText,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator (left side)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(
                  child: isFirst
                      ? const SizedBox()
                      : CustomPaint(
                          painter: DashedLinePainter(
                            color: AppColors.pinkDeep.withOpacity(0.4),
                          ),
                        ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pinkSoft, width: 3),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.pinkDeep),
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : CustomPaint(
                          painter: DashedLinePainter(
                            color: AppColors.pinkDeep.withOpacity(0.4),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card content (right side)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.h2.copyWith(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppText.body.copyWith(
                            fontSize: 13,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (rewardText != null) ...[
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFED8F03).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            rewardText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'to you',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralItem({
    required String name,
    required String status,
    required String amount,
    required String amountSub,
    Color amountColor = const Color(0xFF2E7D32),
    String initials = '',
    String? profileImage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.pinkSoft.withOpacity(0.2),
            backgroundImage: profileImage != null && profileImage.isNotEmpty
                ? NetworkImage(profileImage)
                : null,
            child:
                (profileImage == null || profileImage.isEmpty) &&
                    initials.isNotEmpty
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.pinkDeep,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  )
                : (profileImage == null || profileImage.isEmpty)
                ? const Icon(Icons.person, color: AppColors.pinkDeep)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (amountSub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  amountSub,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRule(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 12),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.pinkDeep,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pinkDeep.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
