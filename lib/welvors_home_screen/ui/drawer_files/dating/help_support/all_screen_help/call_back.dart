import 'package:flutter/material.dart';

class CallBackScreen extends StatefulWidget {
  const CallBackScreen({super.key});

  @override
  State<CallBackScreen> createState() => _CallBackScreenState();
}

class _CallBackScreenState extends State<CallBackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDay = 'Today';
  String _selectedTime = '12-2 PM';
  String _selectedTopic = 'Payment or refund';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _days = ['Today', 'Tomorrow', '📅 Pick a date'];
  final List<String> _times = [
    '10-12 PM',
    '12-2 PM',
    '2-4 PM',
    '4-6 PM',
    '6-7 PM',
  ];
  final List<String> _topics = [
    'Payment or refund',
    'Account or login',
    'Verification',
    'Safety concern',
    'Something else',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          'Callbacks',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFFE85A7A),
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFFE85A7A), width: 2),
              ),
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.only(right: 24),
              tabs: [
                const Tab(text: 'Request a call'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('History'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? const Color(0xFFFBE4E7)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '4',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _tabController.index == 1
                                ? const Color(0xFFE85A7A)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRequestTab(), _buildHistoryTab()],
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When should we call?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              children: const [
                TextSpan(
                  text:
                      'Pick a day and a time window that suits you. We call from ',
                ),
                TextSpan(
                  text: '+91 97653 03735',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(text: ' — usually within your chosen slot.'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('DAY'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _days.map((day) {
              return _buildChip(
                label: day,
                isSelected: _selectedDay == day,
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('TIME WINDOW'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _times.map((time) {
              return _buildChip(
                label: time,
                isSelected: _selectedTime == time,
                onTap: () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('WHAT\'S IT ABOUT? Optional'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _topics.map((topic) {
              return _buildChip(
                label: topic,
                isSelected: _selectedTopic == topic,
                onTap: () {
                  setState(() {
                    _selectedTopic = topic;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEAE7), // slightly darker than bg
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Calls are made Mon–Sat, 10am–7pm IST. If we miss you, we\'ll try once more and then email you.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 100), // padding for bottom button
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Past callbacks',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Every call we\'ve made to you, and how it ended.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          _buildHistoryCard(
            title: 'Payment or refund',
            statusText: 'RESOLVED',
            isResolved: true,
            subtitle: 'Yesterday · 4-6 PM · Priya S. · 6 min',
            description:
                'Refund of ₹499 approved — credited in 3–5 working days.',
            referenceId: 'CB-884120',
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            title: 'Verification',
            statusText: 'RESOLVED',
            isResolved: true,
            subtitle: 'Thu, 28 Aug · 12-2 PM · Rohan M. · 11 min',
            description:
                'Re-uploaded ID accepted. Trust level moved to Identity Verified.',
            referenceId: 'CB-871905',
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            title: 'Safety concern',
            statusText: 'MISSED',
            isResolved: false,
            subtitle: 'Mon, 25 Aug · 10-12 PM',
            description:
                'We called twice, no answer — details emailed to you instead.',
            referenceId: 'CB-863477',
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            title: 'Account or login',
            statusText: 'RESOLVED',
            isResolved: true,
            subtitle: 'Fri, 22 Aug · 6-7 PM · Sana P. · 4 min',
            description:
                'Login issue was a stale session. Resolved on the call.',
            referenceId: 'CB-857001',
          ),

          const SizedBox(height: 100), // padding for bottom button
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String statusText,
    required bool isResolved,
    required String subtitle,
    required String description,
    required String referenceId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isResolved ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isResolved
                        ? Colors.green.shade600
                        : Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            referenceId,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white, // Match body background
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            if (_tabController.index == 0) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Callback requested successfully!'),
                  backgroundColor: Colors.black87,
                ),
              );
            } else {
              _tabController.animateTo(0);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE85A7A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _tabController.index == 0
                ? 'Confirm · $_selectedDay, $_selectedTime'
                : 'Request a new call',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE4E7) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE85A7A) : Colors.grey.shade400,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE85A7A) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
