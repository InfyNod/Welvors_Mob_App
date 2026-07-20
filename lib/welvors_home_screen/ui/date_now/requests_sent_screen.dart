import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'my_plan_screen.dart';

class RequestsSentScreen extends StatefulWidget {
  const RequestsSentScreen({super.key});

  @override
  State<RequestsSentScreen> createState() => _RequestsSentScreenState();
}

class _RequestsSentScreenState extends State<RequestsSentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  int _selectedFilterIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _filters = [
    '☕ Coffee',
    '🍽️ Dinner',
    '🍸 Drinks',
    '🚶 Walk',
  ];

  // Dummy data for plans
  final List<Map<String, dynamic>> _plans = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'title': '🍝 Pasta & Honest Chats',
      'subtitle': 'Today · 8:30 PM · Olive Bar, Mahalaxmi',
      'hostName': 'Ananya, 25',
      'hostAvatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'pay': '🤝 She\'ll pay',
      'match': '88%',
      'message': 'You: "Hey Ananya! I\'d love to join you for dinner 🍝"',
      'status': 'Approved',
      'statusMessage':
          'Ananya approved — head to Olive Bar, Mahalaxmi to meet. Details are in your chat.',
      'isLive': true,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'title': '🚶 Sunset Beach Walk',
      'subtitle': 'Today · 5:30 PM · Carter Road',
      'hostName': 'Karan, 27',
      'hostAvatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'pay': '🤝 Split (TTMM)',
      'match': '81%',
      'message': 'You: "Up for a calm evening walk? I\'m nearby!"',
      'status': 'Pending',
      'statusMessage':
          'Waiting for Karan to approve. You can withdraw anytime before they do.',
      'isLive': true,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'title': '🍸 Rooftop Cocktails',
      'subtitle': 'Tomorrow · 9:00 PM · AER Worli',
      'hostName': 'Meher, 24',
      'hostAvatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'pay': '🤝 She\'ll pay',
      'match': '91%',
      'message': 'You: "Let\'s skip small talk over a drink 🍸"',
      'status': 'Pending',
      'statusMessage':
          'Waiting for Meher to approve. You can withdraw anytime before they do.',
      'isLive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPlans = _plans.where((plan) {
      if (_selectedFilterIndex == -1) return true;
      String filter = _filters[_selectedFilterIndex].toLowerCase();
      String title = plan['title'].toString().toLowerCase();

      if (filter.contains('coffee') && title.contains('coffee')) return true;
      if (filter.contains('dinner') &&
          (title.contains('dinner') || title.contains('pasta')))
        return true;
      if (filter.contains('drinks') &&
          (title.contains('drinks') || title.contains('cocktails'))) {
        return true;
      }
      if (filter.contains('walk') && title.contains('walk')) return true;

      return false;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 24,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Date ',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'Now',
                style: TextStyle(
                  color: Color(0xFFE43A6A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Post a plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelPadding: const EdgeInsets.only(right: 24),
            indicatorColor: const Color(0xFFE43A6A),
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent, // Hides default grey bottom line
            splashFactory: NoSplash
                .splashFactory, // Removes ripple effect for smoother look
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              _buildTab('Requests sent', 3, 0),
              _buildTab('My plans', 4, 1),
            ],
          ),
          const Divider(height: 1, color: Colors.black12),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Requests sent
                Column(
                  children: [
                    // Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(_filters[index], index),
                          );
                        }),
                      ),
                    ),
                    // List
                    Expanded(
                      child: filteredPlans.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No plans found for ${_filters[_selectedFilterIndex].substring(2).trim()}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredPlans.length,
                              itemBuilder: (context, index) {
                                return _buildPlanCard(filteredPlans[index]);
                              },
                            ),
                    ),
                  ],
                ),
                // TAB 2: My plans
                const MyPlanScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int count, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE43A6A) : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE43A6A)
                  : const Color(0xFFF2A93B), // Yellow-orange for unselected
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFilterIndex == index) {
            _selectedFilterIndex = -1;
          } else {
            _selectedFilterIndex = index;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    bool isApproved = plan['status'] == 'Approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image header
          Container(
            height: 100, // image height
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(plan['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Tags and info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Live Now Tag
                          if (plan['isLive'] ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF45B16D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE NOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(),
                          // Status Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? const Color(0xFF45B16D)
                                  : const Color(0xFFF2A93B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (isApproved)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                if (!isApproved)
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  isApproved ? 'Approved' : 'Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan['subtitle'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(plan['hostAvatar']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['hostName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Host · ${plan['pay']}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plan['match'],
                        style: const TextStyle(
                          color: Color(0xFFE43A6A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Message Bubble
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F4EF), // Beige
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plan['message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Status Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isApproved ? '🎉' : '⏳',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan['statusMessage'],
                          style: TextStyle(
                            color: isApproved
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isApproved) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCancelBottomSheet(context, plan),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFFA6A85).withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel date',
                                style: TextStyle(
                                  color: Color(0xFFDE2957),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon')),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                '💬 Message',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFFA6A85).withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Withdraw',
                              style: TextStyle(
                                color: Color(0xFFDE2957),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'View plan',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelBottomSheet(BuildContext context, Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Broken heart icon
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFA6A85).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '💔',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 16),
              const Text(
                'Cancel this date?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final name = plan['hostName'].split(',')[0].trim();
                  String cleanTitle = plan['title'];
                  if (cleanTitle.contains(' ')) {
                    cleanTitle = cleanTitle.substring(cleanTitle.indexOf(' ') + 1);
                  }

                  return Text(
                    "$name approved you for $cleanTitle.\nThey'll be notified that you can no longer make it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Host details card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F4EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(plan['hostAvatar']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['hostName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan['subtitle'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Cancel Date button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _plans.remove(plan);
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCB3A31),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel date',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Keep it button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Keep it',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}
