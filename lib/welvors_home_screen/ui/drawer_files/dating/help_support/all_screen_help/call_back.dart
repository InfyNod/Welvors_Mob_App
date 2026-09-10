import 'package:flutter/material.dart';

class CallBackScreen extends StatefulWidget {
  const CallBackScreen({super.key});

  @override
  State<CallBackScreen> createState() => _CallBackScreenState();
}

class _CallBackScreenState extends State<CallBackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDay;
  String? _selectedTime;
  String? _selectedTopic;

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
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
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
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
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
                    _selectedDay = _selectedDay == day ? null : day;
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
                    _selectedTime = _selectedTime == time ? null : time;
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
                    _selectedTopic = _selectedTopic == topic ? null : topic;
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
    bool isTab0 = _tabController.index == 0;
    bool allSelected =
        _selectedDay != null && _selectedTime != null && _selectedTopic != null;

    bool isButtonEnabled = !isTab0 || allSelected;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 38),
      decoration: const BoxDecoration(
        color: Colors.white, // Match body background
      ),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isButtonEnabled
              ? const LinearGradient(
                  colors: [
                    Color.fromRGBO(248, 104, 131, 1),
                    Color.fromRGBO(223, 43, 88, 1),
                  ],
                )
              : null,
          color: isButtonEnabled
              ? null
              : const Color.fromRGBO(242, 239, 234, 1),
        ),
        child: ElevatedButton(
          onPressed: isButtonEnabled
              ? () {
                  if (isTab0) {
                    _showSuccessDialog();
                  } else {
                    _tabController.animateTo(0);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isTab0 ? 'Confirm' : 'Request a new call',
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.7],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromARGB(255, 132, 126, 127),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD1DC).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal header similar to match_dialog
                const Text(
                  'WELVORS',
                  style: TextStyle(
                    color: Color(0xFFC73A5E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Call booked',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC73A5E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'We’ll ring you on +91 98765 43210.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Details Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      230,
                      230,
                      230,
                    ).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(255, 250, 218, 218),
                      width: 2,
                    ),
                  ),
                  child: Wrap(
                    spacing: 32, // Horizontal spacing between items
                    runSpacing:
                        16, // Vertical spacing when items wrap to next line
                    children: [
                      _buildDialogRow('Day', _selectedDay ?? ''),
                      _buildDialogRow('Time window', _selectedTime ?? ''),
                      _buildDialogRow('Topic', _selectedTopic ?? ''),
                      _buildDialogRow('Reference', 'CB-646453'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _tabController.animateTo(1);
                          setState(() {
                            _selectedDay = null;
                            _selectedTime = null;
                            _selectedTopic = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE85A7A),
                          side: const BorderSide(color: Color(0xFFE85A7A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'History',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85A7A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Help',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
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
