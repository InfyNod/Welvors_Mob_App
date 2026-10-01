import 'package:flutter/material.dart';

class TrustScreen extends StatelessWidget {
  const TrustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 253, 252, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 253, 252, 1.0),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF242424),
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Trust Score',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildMainTrustCard(),
            const SizedBox(height: 16),
            _buildInfoBanner(),
            const SizedBox(height: 32),
            _buildVerificationSection(
              title: 'Basic verification',
              pointsText: 'No points · required',
              progress: '2/2 ✓',
              items: [
                _buildVerificationItem(
                  title: 'Mobile & Email',
                  subtitle: 'Confirmed real contact details',
                  badgeText: 'Required',
                  emoji: '📱',
                  iconBgColor: const Color(0xFFE3F2FD), // Light blue
                  isVerified: true,
                  details: {
                    'Mobile': '+91 ••••• ••210',
                    'Email': 'aa•••@gmail.com',
                    'Status': 'Both active',
                  },
                  verifiedDate: '12 Jan 2026',
                  verifiedMethod: 'OTP + email link',
                ),
                _buildVerificationItem(
                  title: 'Location check',
                  subtitle: 'City-level authenticity confirmed',
                  badgeText: 'Required',
                  emoji: '📍',
                  iconBgColor: const Color(0xFFFFEBEE), // Light red
                  isVerified: true,
                  details: {
                    'City': 'Pune, Maharashtra',
                    'Area': 'Koregaon Park',
                    'Matches profile': 'Yes',
                  },
                  verifiedDate: '12 Jan 2026',
                  verifiedMethod: 'Device GPS',
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildVerificationSection(
              title: 'Identity verification',
              pointsText: '44 pts',
              progress: '3/3 ✓',
              items: [
                _buildVerificationItem(
                  title: 'Government ID',
                  subtitle: 'A real person, matched to official ID',
                  badgeText: '+20 pts',
                  emoji: '🪪',
                  iconBgColor: const Color(0xFFFFF3E0), // Light orange
                  isVerified: true,
                  details: {
                    'Document': 'Aadhaar card',
                    'Name on ID': 'Aanya Sharma',
                    'Age on ID': '24 years',
                    'Gender': 'Female',
                  },
                  verifiedDate: '14 Jan 2026',
                  verifiedMethod: 'DigiLocker API',
                ),
                _buildVerificationItem(
                  title: 'Face match (selfie)',
                  subtitle: 'Selfie matched the ID photo',
                  badgeText: '+12 pts',
                  emoji: '🤳',
                  iconBgColor: const Color(0xFFF3E5F5), // Light purple
                  isVerified: true,
                  details: {
                    'Match with ID': '99% match',
                    'Profile photos': 'Same person',
                  },
                  verifiedDate: '14 Jan 2026',
                  verifiedMethod: 'AI face match',
                ),
                _buildVerificationItem(
                  title: 'Video liveness',
                  subtitle: 'Live video confirmed a present person',
                  badgeText: '+12 pts',
                  emoji: '🎥',
                  iconBgColor: const Color(0xFFE0F7FA), // Light cyan
                  isVerified: true,
                  details: {
                    'Liveness': 'Real person, live',
                    'Gestures': 'All 3 completed',
                  },
                  verifiedDate: '14 Jan 2026',
                  verifiedMethod: 'Live video check',
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildVerificationSection(
              title: 'High-trust verification',
              pointsText: '38 pts',
              progress: '3/3 ✓',
              items: [
                _buildVerificationItem(
                  title: 'Education',
                  subtitle: 'College & qualification verified',
                  badgeText: '+12 pts',
                  emoji: '🎓',
                  iconBgColor: const Color(0xFFFFF8E1), // Light amber
                  isVerified: true,
                  details: {
                    'Degree': 'MBA',
                    'College': 'IIM Ahmedabad',
                    'Passing year': '2024',
                  },
                  verifiedDate: '20 Jan 2026',
                  verifiedMethod: 'Reviewed by Welvors team',
                ),
                _buildVerificationItem(
                  title: 'Profession',
                  subtitle: 'Job & company verified',
                  badgeText: '+14 pts',
                  emoji: '💼',
                  iconBgColor: const Color(0xFFEFEBE9), // Light brown
                  isVerified: true,
                  details: {
                    'Company': 'Razorpay',
                    'Designation': 'Senior Product Manager',
                    'Joining date': 'Jun 2024',
                    'Currently working': 'Yes',
                  },
                  verifiedDate: '21 Jan 2026',
                  verifiedMethod: 'Work email + offer letter',
                ),
                _buildVerificationItem(
                  title: 'Income',
                  subtitle: 'Declared income bracket confirmed',
                  badgeText: '+12 pts',
                  emoji: '💰',
                  iconBgColor: const Color(0xFFE8F5E9), // Light green
                  isVerified: true,
                  details: {
                    'Income bracket': '₹25–35 L / year',
                    'Matches declared': 'Yes',
                    'Sources verified': '3 sources',
                  },
                  incomeSources: [
                    {
                      'emoji': '💼',
                      'title': 'Salary',
                      'subtitle': 'Razorpay · monthly',
                      'amount': '₹24 L/yr',
                    },
                    {
                      'emoji': '🏠',
                      'title': 'Rental income',
                      'subtitle': '1 flat · Pune',
                      'amount': '₹3.6 L/yr',
                    },
                    {
                      'emoji': '💻',
                      'title': 'Freelance',
                      'subtitle': 'Product consulting',
                      'amount': '₹2.4 L/yr',
                    },
                  ],
                  verifiedDate: '22 Jan 2026',
                  verifiedMethod: 'Bank statement (3 months)',
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildVerificationSection(
              title: 'Platinum verification',
              pointsText: '18 pts',
              progress: '1/2',
              isComplete: false,
              stepNumber: 4,
              items: [
                _buildVerificationItem(
                  title: 'Criminal background',
                  subtitle: 'Court & police records — clean history',
                  badgeText: '+18 pts',
                  emoji: '🔍',
                  iconBgColor: const Color(0xFFE8EAF6), // Light indigo
                  isVerified: true,
                  details: {
                    'Court records': 'None found',
                    'Police records': 'None found',
                    'Result': 'Clean history',
                  },
                  verifiedDate: '02 Feb 2026',
                  verifiedMethod: 'Background-check partner',
                ),
                _buildVerificationItem(
                  title: 'Emergency contact',
                  subtitle: 'A trusted person registered for safety',
                  badgeText: 'Not yet',
                  emoji: '📞',
                  iconBgColor: const Color(0xFFFCE4EC), // Light pink
                  isVerified: false,
                  details: {},
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trust Score is built from independent identity, safety and intent checks. Basic checks and emergency contact are required but carry no points. The other 7 checks add up to 100.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTrustCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF33203C), Color(0xFF1B1527)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Aanya, 24',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF2979FF),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '9 of 10 checks verified',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress
              SizedBox(
                width: 65,
                height: 65,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: _GradientArcPainter(progress: 1.0)),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '100',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'TRUST',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Platinum verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF2BC57), Color(0xFFE59C39)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🔥', style: TextStyle(fontSize: 12)),
                SizedBox(width: 6),
                Text(
                  'Platinum verified',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Description
          const Text(
            'A high Trust Score means more of Aanya\'s identity has been independently checked — you can message with confidence.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6ED), // Light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1E8D8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF2CB864), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFF2CB864),
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text:
                        'You only see the verified result — never the documents. They stay private and encrypted.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection({
    required String title,
    required String pointsText,
    required String progress,
    required List<Widget> items,
    bool isComplete = true,
    int? stepNumber,
  }) {
    List<Widget> separatedItems = [];
    for (int i = 0; i < items.length; i++) {
      separatedItems.add(items[i]);
      if (i < items.length - 1) {
        separatedItems.add(const Divider(height: 1, color: Color(0xFFF0F0F0)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isComplete
                    ? const Color(0xFF2CB864)
                    : const Color(0xFFE85A7A),
                shape: BoxShape.circle,
              ),
              child: isComplete
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : Center(
                      child: Text(
                        stepNumber != null ? '$stepNumber' : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 6,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          pointsText,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isComplete
                              ? const Color(0xFF2CB864)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      if (!isComplete)
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2BC57),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isComplete
                    ? const Color(0xFFE8F6ED)
                    : const Color(0xFFFFF7EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                progress,
                style: TextStyle(
                  color: isComplete
                      ? const Color(0xFF2CB864)
                      : const Color(0xFFF29B38),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: separatedItems),
        ),
      ],
    );
  }

  Widget _buildVerificationItem({
    required String title,
    required String subtitle,
    required String badgeText,
    required String emoji,
    required bool isVerified,
    required Map<String, String> details,
    Color? iconBgColor,
    String? verifiedDate,
    String? verifiedMethod,
    List<Map<String, String>>? incomeSources,
  }) {
    return Column(
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor ?? const Color(0xFFEDF2FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isVerified
                          ? const Color(0xFF2CB864)
                          : const Color(0xFFF6F6F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVerified ? Icons.check : Icons.close,
                      color: isVerified ? Colors.white : Colors.grey.shade400,
                      size: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? const Color(0xFFE8F6ED)
                          : const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: isVerified
                            ? const Color(0xFF2CB864)
                            : Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Inner Details Box (Light Green Border)
        if (details.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF9),
                border: Border.all(color: const Color(0xFFD1E8D8)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Column(
                      children: details.entries.toList().asMap().entries.map((
                        entry,
                      ) {
                        int idx = entry.key;
                        var e = entry.value;
                        return Column(
                          children: [
                            if (idx > 0)
                              const Divider(
                                height: 1,
                                color: Color(0xFFE8F0EA),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        e.value,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2CB864),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  if (incomeSources != null && incomeSources.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: Color(0xFFE8F0EA)),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            'INCOME SOURCES',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8F0EA),
                              ),
                            ),
                            child: Column(
                              children: incomeSources.asMap().entries.map((
                                entry,
                              ) {
                                int idx = entry.key;
                                var source = entry.value;
                                return Column(
                                  children: [
                                    if (idx > 0)
                                      const Divider(
                                        height: 1,
                                        color: Color(0xFFE8F0EA),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 10.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFF6F8F6,
                                              ), // slightly different background for inner emoji
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              source['emoji']!,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  source['title']!,
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  source['subtitle']!,
                                                  style: const TextStyle(
                                                    color: Color(0xFF888888),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                source['amount']!,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF2CB864),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                  if (verifiedDate != null && verifiedMethod != null) ...[
                    // Footer is now a darker green
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(231, 245, 237, 1.0),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: Color(0xFF2CB864),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Verified $verifiedDate',
                                style: const TextStyle(
                                  color: Color(0xFF2CB864),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            verifiedMethod,
                            style: const TextStyle(
                              color: Color.fromRGBO(80, 123, 100, 1.0),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double progress;

  _GradientArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    // Draw background track
    final rect = Offset.zero & size;
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(6.5 / 2),
      0,
      2 * 3.1415926535897932,
      false,
      trackPaint,
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE85A7A), Color(0xFFFF9B70)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(6.5 / 2),
      -1.5707963267948966, // -pi/2 (starts at top center)
      progress * 2 * 3.1415926535897932,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
