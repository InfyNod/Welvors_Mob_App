import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'service_trust.dart';

class TrustScreen extends StatefulWidget {
  final String userId;
  
  const TrustScreen({super.key, required this.userId});

  @override
  State<TrustScreen> createState() => _TrustScreenState();
}

class _TrustScreenState extends State<TrustScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _trustData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final result = await ServiceTrust.fetchTrustScore(widget.userId);
    if (mounted) {
      if (result != null && result['success'] == true && result['data'] != null) {
        setState(() {
          _trustData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load trust score.';
          _isLoading = false;
        });
      }
    }
  }

  String _getEmojiForType(String type) {
    switch (type) {
      case 'MOBILE_EMAIL': return '📱';
      case 'LOCATION': return '📍';
      case 'GOVERNMENT_ID': return '🪪';
      case 'FACE_VERIFICATION': return '🤳';
      case 'VIDEO_VERIFICATION': return '🎥';
      case 'EDUCATION_VERIFICATION': return '🎓';
      case 'PROFESSIONAL_VERIFICATION': return '💼';
      case 'INCOME_VERIFICATION': return '💰';
      case 'CRIMINAL_BACKGROUND_CHECK': return '🔍';
      case 'EMERGENCY_CONTACT': return '📞';
      default: return '✅';
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'MOBILE_EMAIL': return const Color(0xFFE3F2FD);
      case 'LOCATION': return const Color(0xFFFFEBEE);
      case 'GOVERNMENT_ID': return const Color(0xFFFFF3E0);
      case 'FACE_VERIFICATION': return const Color(0xFFF3E5F5);
      case 'VIDEO_VERIFICATION': return const Color(0xFFE0F7FA);
      case 'EDUCATION_VERIFICATION': return const Color(0xFFFFF8E1);
      case 'PROFESSIONAL_VERIFICATION': return const Color(0xFFEFEBE9);
      case 'INCOME_VERIFICATION': return const Color(0xFFE8F5E9);
      case 'CRIMINAL_BACKGROUND_CHECK': return const Color(0xFFE8EAF6);
      case 'EMERGENCY_CONTACT': return const Color(0xFFFCE4EC);
      default: return const Color(0xFFEDF2FA);
    }
  }

  String? _formatDate(String? isoDate) {
    if (isoDate == null) return null;
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return null;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(255, 253, 252, 1.0),
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _trustData == null) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(255, 253, 252, 1.0),
        appBar: _buildAppBar(),
        body: Center(child: Text(_error ?? 'No data')),
      );
    }

    final user = _trustData!['user'];
    final trustScore = _trustData!['trustScore'];
    final privacyNotice = _trustData!['privacyNotice'];
    final sections = _trustData!['sections'] as List;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 253, 252, 1.0),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildMainTrustCard(user, trustScore),
            const SizedBox(height: 16),
            _buildInfoBanner(privacyNotice),
            const SizedBox(height: 32),
            ...sections.map((section) {
              return Column(
                children: [
                  _buildVerificationSection(
                    title: section['title'],
                    pointsText: section['maxPoints'] == 0 
                        ? 'No points · required' 
                        : '${section['maxPoints']} pts',
                    progress: '${section['completed']}/${section['total']}${section['status'] == 'VERIFIED' ? ' ✓' : ''}',
                    isComplete: section['status'] == 'VERIFIED',
                    stepNumber: int.tryParse(section['number'] ?? ''),
                    items: (section['items'] as List).map((item) {
                      String badge = item['required'] == true
                          ? 'Required'
                          : (item['status'] == 'VERIFIED'
                              ? '+${item['points']} pts'
                              : 'Not yet');

                      return _buildVerificationItem(
                        title: item['title'],
                        subtitle: item['description'],
                        badgeText: badge,
                        emoji: _getEmojiForType(item['type']),
                        iconBgColor: _getColorForType(item['type']),
                        isVerified: item['status'] == 'VERIFIED',
                        details: {
                          if (item['details'] != null)
                            for (var detail in item['details'])
                              detail['label']: detail['value']
                        },
                        verifiedDate: _formatDate(item['verifiedAt']),
                        verifiedMethod: item['verifiedBy'],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            }),
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

  Widget _buildMainTrustCard(Map<String, dynamic> user, Map<String, dynamic> trustScore) {
    final double maxScore = (trustScore['maxScore'] as num).toDouble();
    final double currentScore = (trustScore['score'] as num).toDouble();
    final double progress = maxScore > 0 ? currentScore / maxScore : 0.0;

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
                  image: DecorationImage(
                    image: NetworkImage(user['profilePhoto'] ?? ''),
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
                        Text(
                          '${user['name']}, ${user['age']}',
                          style: const TextStyle(
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
                    Text(
                      '${trustScore['verifiedChecks']} of ${trustScore['totalChecks']} checks verified',
                      style: const TextStyle(
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
                    CustomPaint(painter: _GradientArcPainter(progress: progress)),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${trustScore['score']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const Text(
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
          if (trustScore['badge'] != null)
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
                children: [
                  if (trustScore['badge']['key'] == 'PLATINUM')
                    const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: Text('🔥', style: TextStyle(fontSize: 12)),
                    ),
                  Text(
                    trustScore['badge']['title'] ?? '',
                    style: const TextStyle(
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
          Text(
            trustScore['description'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(Map<String, dynamic> privacyNotice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6ED),
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
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF2CB864),
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: privacyNotice['message'] ?? '',
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
    double widthFactor = 0.0;
    if (!isComplete) {
      try {
        final parts = progress.replaceAll(' ✓', '').split('/');
        if (parts.length == 2) {
          final current = double.parse(parts[0]);
          final total = double.parse(parts[1]);
          if (total > 0) {
            widthFactor = current / total;
          }
        }
      } catch (_) {}
    }

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
                      if (!isComplete && widthFactor > 0.0)
                        FractionallySizedBox(
                          widthFactor: widthFactor,
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

    if (progress <= 0.0) return;

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
