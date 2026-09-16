import 'package:flutter/material.dart';

import '../../service_account_Setting.dart';

class WhoMessageScreen extends StatefulWidget {
  final String initialOption;
  const WhoMessageScreen({super.key, this.initialOption = 'paid'});

  @override
  State<WhoMessageScreen> createState() => _WhoMessageScreenState();
}

class _WhoMessageScreenState extends State<WhoMessageScreen> {
  late String selectedOption;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialOption;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Clean white background for premium feel
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Who can message me',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildPremiumOptionCard(
              id: 'matches',
              emoji: '💞',
              iconBgColor: const Color(0xFFFCE8EE),
              title: 'Matches only',
              subtitle: 'Only people you\'ve both liked can start a chat',
            ),
            const SizedBox(height: 16),
            _buildPremiumOptionCard(
              id: 'verified',
              emoji: '🛡️',
              iconBgColor: const Color(0xFFE8F1FC),
              title: 'Verified only',
              subtitle: 'Anyone with a verified Trust Score can reach you',
            ),
            const SizedBox(height: 16),
            _buildPremiumOptionCard(
              id: 'paid',
              emoji: '💎',
              iconBgColor: const Color(0xFFFBF4E4),
              title: 'Paid only',
              subtitle: 'Only Premium, VIP and Elite members can message first',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anyone you haven\'t allowed can still send a like — you just won\'t get their messages until you match.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumOptionCard({
    required String id,
    required String emoji,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = selectedOption == id;

    return GestureDetector(
      onTap: _isLoading ? null : () async {
        setState(() {
          selectedOption = id;
          _isLoading = true;
        });

        String apiValue;
        if (id == 'matches') apiValue = 'MATCHES_ONLY';
        else if (id == 'verified') apiValue = 'VERIFIED_ONLY';
        else apiValue = 'PAID_ONLY';

        final success = await AccountSettingService.updatePrivacyControls({
          "messagePermission": apiValue
        });

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message permission updated')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update')),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF5F7) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFE43A6A).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.black87 : Colors.grey.shade500,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Custom Animated Radio Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFE43A6A) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? const Color(0xFFE43A6A).withOpacity(0.4) : Colors.transparent,
                    blurRadius: isSelected ? 8 : 0,
                    offset: isSelected ? const Offset(0, 2) : Offset.zero,
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
