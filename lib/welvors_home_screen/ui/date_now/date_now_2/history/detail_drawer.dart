import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../date_api_service/date_now_api_service.dart';

void showHistoryDetailDrawer(BuildContext context, Map<String, dynamic> plan) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: HistoryDetailDrawer(plan: plan),
    ),
  );
}

class HistoryDetailDrawer extends StatefulWidget {
  final Map<String, dynamic> plan;

  const HistoryDetailDrawer({super.key, required this.plan});

  @override
  State<HistoryDetailDrawer> createState() => _HistoryDetailDrawerState();
}

class _HistoryDetailDrawerState extends State<HistoryDetailDrawer> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final planId = widget.plan['id'];
    if (planId != null) {
      final response = await DateNowApiService.getHistoryPlanDetails(planId.toString());
      if (mounted) {
        setState(() {
          _detailData = response;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final status = _detailData?['statusLabel']?.toString().toUpperCase() ?? 
                   _detailData?['status']?.toString().toUpperCase() ?? 
                   plan['status'] as String? ?? 'EXPIRED';
    final hasPartnerInfo =
        plan.containsKey('partnerName') && plan['partnerName'] != null;

    // Status color mapping for the badge text
    Color statusColor;
    switch (status) {
      case 'MET':
        statusColor = const Color(0xFF1EA95B); // Green
        break;
      case 'NO-SHOW':
        statusColor = const Color(0xFFE53935); // Red
        break;
      case 'CANCELLED':
        statusColor = const Color(0xFFE53935); // Red
        break;
      case 'EXPIRED':
        statusColor = Colors.grey.shade600; // Grey
        break;
      default:
        statusColor = Colors.black;
    }

    int parseStat(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      if (val is Map) {
        if (val.containsKey('total')) return parseStat(val['total']);
        if (val.containsKey('count')) return parseStat(val['count']);
      }
      return 0;
    }

    String parseString(dynamic val, String defaultVal) {
      if (val == null) return defaultVal;
      if (val is String) return val;
      if (val is Map) {
        if (val.containsKey('label')) return parseString(val['label'], defaultVal);
        if (val.containsKey('name')) return parseString(val['name'], defaultVal);
        if (val.containsKey('value')) return parseString(val['value'], defaultVal);
      }
      return val.toString();
    }

    // Default calculations for stats if not present
    final views = parseStat(_detailData?['views'] ?? plan['views']);
    final requests = parseStat(_detailData?['requests'] ?? plan['requests']);
    final approved = parseStat(_detailData?['approved']) > 0 
        ? parseStat(_detailData?['approved']) 
        : (hasPartnerInfo ? 1 : 0);
    final split = parseString(_detailData?['whoPays'] ?? _detailData?['split'] ?? plan['split'], 'Split (TTMM)');
    final groupSize = parseString(_detailData?['groupSize'] ?? plan['groupSize'], 'Just 1');
    final boost = parseString(_detailData?['boost'] ?? plan['boost'], 'No');
    final planCost = parseString(_detailData?['planCost'] ?? plan['planCost'], '₹100');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          _isLoading 
          ? const Flexible(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
              ),
            )
          : Flexible(
              child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: plan['image'] ?? '',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey.shade300,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Center(
                    child: Text(
                      plan['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dates
                  if (plan['createdDate'] != null && plan['createdDate'].isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.edit_calendar, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          'Created on ${plan['createdDate']}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  if (plan['eventDate'] != null && plan['eventDate'].isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          'Event starts ${plan['eventDate']}',
                          style: TextStyle(
                            fontSize: 13, 
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          plan['location'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Note container
                  if (plan['note'] != null && plan['note'].toString().trim().isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F4EF), // Light beige
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        plan['note'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // WHO CAME Section
                  if (hasPartnerInfo &&
                      (status == 'MET' || status == 'NO-SHOW')) ...[
                    _buildSectionTitle('WHO CAME'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF4ED),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: plan['partnerAvatar'] != null &&
                                    plan['partnerAvatar'].toString().isNotEmpty
                                ? CachedNetworkImageProvider(
                                    plan['partnerAvatar'],
                                  )
                                : null,
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan['partnerName'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  status == 'MET'
                                      ? 'You rated ${plan['rating']}★ · they rated you 5★'
                                      : 'Didn\'t show up',
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
                    ),
                    const SizedBox(height: 24),
                  ],

                  // HOW IT PERFORMED Section
                  _buildSectionTitle('HOW IT PERFORMED'),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    label: 'Views',
                    subtext: null,
                    value: views,
                    maxVal: views > 0 ? views : 1,
                    progress: 1.0,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    label: 'Requests',
                    subtext: views > 0
                        ? '${((requests / views) * 100).toInt()}% of views'
                        : '0% of views',
                    value: requests,
                    maxVal: views > 0 ? views : 1,
                    progress: views > 0 ? (requests / views) : 0,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    label: 'Approved',
                    subtext: requests > 0
                        ? '${((approved / requests) * 100).toInt()}% of requests'
                        : '0% of requests',
                    value: approved,
                    maxVal: views > 0 ? views : 1,
                    progress: views > 0 ? (approved / views) : 0,
                  ),
                  const SizedBox(height: 24),

                  // INFO GRID
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'BILL',
                          split,
                          Icons.receipt_long_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'GROUP',
                          groupSize,
                          Icons.group_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('BOOST', boost, Icons.rocket_launch_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'PLAN COST',
                          planCost,
                          Icons.payments_rounded,
                        ),
                      ),
                    ],
                  ),

                  // Bottom spacing inside scroll view
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Sticky MESSAGE BUTTON at bottom
          if (!_isLoading && status == 'MET' && hasPartnerInfo)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle message action
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE43A6A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Message ${plan['partnerName']?.split(',')[0] ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFE43A6A).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.insights_rounded,
            size: 16,
            color: Color(0xFFE43A6A),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required String label,
    required String? subtext,
    required int value,
    required int maxVal,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label Column
          SizedBox(
            width: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (subtext != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtext,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),

          // Progress Bar
          Expanded(
            child: Container(
              height: 8,
              alignment: Alignment.centerLeft, // Fixes the center alignment issue
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE43A6A), Color(0xFFFF5E8B)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Value
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
