import 'package:flutter/material.dart';
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
          ? const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
              ),
            )
          : Expanded(
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
                        child: Image.network(
                          plan['image'],
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
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

                  // Date and Location
                  Text(
                    plan['date'],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
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
                          color: Colors.orange.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              plan['partnerAvatar'],
                            ),
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'GROUP',
                          groupSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('BOOST', boost),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'PLAN COST',
                          planCost,
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
                      color: Colors.black.withOpacity(0.05),
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String? subtext,
    required int value,
    required int maxVal,
    required double progress,
  }) {
    return Row(
      children: [
        // Label Column
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                ),
              ],
            ],
          ),
        ),

        // Progress Bar
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F4EF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE43A6A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        // Value
        const SizedBox(width: 16),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
