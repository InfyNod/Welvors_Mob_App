import 'package:flutter/material.dart';

class DateNowScreen extends StatefulWidget {
  const DateNowScreen({super.key});

  @override
  State<DateNowScreen> createState() => _DateNowScreenState();
}

class _DateNowScreenState extends State<DateNowScreen> {
  int _selectedTabIndex = 0;
  int _selectedFilterIndex = 0;

  final List<String> _tabs = ['Today', 'Tomorrow', 'Weekend'];
  final List<String> _filters = [
    'All plans',
    '☕ Coffee',
    '🍽️ Dinner',
    '🍸 Drinks',
    '🌅 Walk',
    '🥞 Brunch',
  ];
  int _currentPlanIndex = 0;

  final List<Map<String, dynamic>> _todayPlans = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'location': 'Live · Carter Road Promenade',
      'distance': '800 m away',
      'match': '81% match',
      'date': '📅 TODAY',
      'time': '🕔 5:30 PM',
      'type': '🌅 Walk',
      'title': 'Sunset Beach Walk',
      'subtitle': 'Anyone up for a calm evening? 🌅',
      'people': '👥 2 people',
      'pay': '🤝 Split (TTMM)',
      'name': 'Karan, 27',
      'verified': false,
      'nameSubtitle': 'he/him · Outdoorsy',
      'avatarUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'location': 'Live · Olive Bar, Mahalaxmi',
      'distance': '3.4 km away',
      'match': '88% match',
      'date': '📅 TODAY',
      'time': '🕗 8:30 PM',
      'type': '🥂 Dinner',
      'title': 'Pasta & Honest Chats',
      'subtitle': 'Foodie looking for a dinner buddy 🍝',
      'people': '👥 Just 1',
      'pay': '🤝 I\'ll pay',
      'name': 'Ananya, 25',
      'verified': true,
      'nameSubtitle': 'she/her · Foodie',
      'avatarUrl':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    },
  ];

  final List<Map<String, dynamic>> _tomorrowPlans = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Coffee image
      'location': 'Live · Blue Tokai, Bandra',
      'distance': '1.2 km away',
      'match': '92% match',
      'date': '📅 TOMORROW',
      'time': '🕙 10:00 AM',
      'type': '☕ Coffee',
      'title': 'Morning Brew & Books',
      'subtitle': 'Let\'s talk about our favorite books! 📚',
      'people': '👥 Just 1',
      'pay': '🤝 You pay',
      'name': 'Rahul, 28',
      'verified': true,
      'nameSubtitle': 'he/him · Bookworm',
      'avatarUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1543807535-eceef0bc6599?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Brunch image
      'location': 'Live · The Nutcracker',
      'distance': '5.0 km away',
      'match': '75% match',
      'date': '📅 TOMORROW',
      'time': '🕐 1:00 PM',
      'type': '🥞 Brunch',
      'title': 'Sunday Brunching',
      'subtitle': 'Craving some pancakes 🥞',
      'people': '👥 3 people',
      'pay': '🤝 Split (TTMM)',
      'name': 'Sneha, 24',
      'verified': false,
      'nameSubtitle': 'she/her · Social Butterfly',
      'avatarUrl':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    },
  ];

  final List<Map<String, dynamic>> _weekendPlans = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Bar/Drinks image
      'location': 'Live · Toit, Lower Parel',
      'distance': '8.5 km away',
      'match': '95% match',
      'date': '📅 SATURDAY',
      'time': '🕘 9:00 PM',
      'type': '🍸 Drinks',
      'title': 'Craft Beer & Chill',
      'subtitle': 'Who loves good beer? 🍻',
      'people': '👥 4 people',
      'pay': '🤝 Split (TTMM)',
      'name': 'Vikram, 30',
      'verified': true,
      'nameSubtitle': 'he/him · Extrovert',
      'avatarUrl':
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Hiking/Trekking image
      'location': 'Live · Sanjay Gandhi NP',
      'distance': '12.0 km away',
      'match': '89% match',
      'date': '📅 SUNDAY',
      'time': '🕕 6:00 AM',
      'type': '⛰️ Trek',
      'title': 'Early Morning Trek',
      'subtitle': 'Nature lovers assemble! 🌿',
      'people': '👥 5+ people',
      'pay': '🤝 Split (TTMM)',
      'name': 'Riya, 26',
      'verified': true,
      'nameSubtitle': 'she/her · Fitness Freak',
      'avatarUrl':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    },
  ];

  late final List<GlobalKey> _filterKeys = List.generate(
    _filters.length,
    (index) => GlobalKey(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 4),
            _buildTabs(),
            const SizedBox(height: 6),
            _buildFilters(),
            const SizedBox(height: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildDateCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(
                  text: 'Date ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'Now',
                  style: TextStyle(color: Color(0xFFE43A6A)), // Pink
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDE2957).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'My Plans',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '7',
                          style: TextStyle(
                            color: Color(0xFFDE2957),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double parentWidth = constraints.maxWidth;
          final double itemWidth = parentWidth / 3;

          double indicatorWidth;
          if (_selectedTabIndex == 0) {
            indicatorWidth = 45;
          } else if (_selectedTabIndex == 1) {
            indicatorWidth = 72;
          } else {
            indicatorWidth = 65;
          }

          double indicatorCenter;
          if (_selectedTabIndex == 0) {
            indicatorCenter = itemWidth / 2;
          } else if (_selectedTabIndex == 1) {
            indicatorCenter = parentWidth / 2;
          } else {
            indicatorCenter = parentWidth - (itemWidth / 2);
          }

          return Stack(
            children: [
              Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTabIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedTabIndex != index) {
                            _selectedTabIndex = index;
                            _currentPlanIndex = 0; // Reset index when changing tab
                          }
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFE43A6A)
                                  : Colors.black54,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: 0,
                left: indicatorCenter - (indicatorWidth / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 2,
                  width: indicatorWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE43A6A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.none,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            key: _filterKeys[index],
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
              if (_filterKeys[index].currentContext != null) {
                Scrollable.ensureVisible(
                  _filterKeys[index].currentContext!,
                  alignment: 0.5, // 0.5 means center in the scroll view
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE43A6A) : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateCard() {
    List<Map<String, dynamic>> currentList;
    if (_selectedTabIndex == 0) {
      currentList = _todayPlans;
    } else if (_selectedTabIndex == 1) {
      currentList = _tomorrowPlans;
    } else {
      currentList = _weekendPlans;
    }
    
    String selectedFilter = _filters[_selectedFilterIndex];
    if (selectedFilter != 'All plans') {
      currentList = currentList.where((plan) => plan['type'] == selectedFilter).toList();
    }

    if (currentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No plans found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different filter.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    int displayIndex = _currentPlanIndex % currentList.length;
    final plan = currentList[displayIndex];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    plan['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                // Top Left Tags
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34A853),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              plan['location'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plan['distance'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Top Right Flag
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                // Bottom Right Match %
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // Translucent white
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFFE43A6A), // Pink heart
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan['match'],
                          style: const TextStyle(
                            color: Color(0xFFE43A6A),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Tags
                Row(
                  children: [
                    _buildInfoTag(
                      plan['date'],
                      const Color(0xFFE43A6A),
                      const Color(0xFFFCE4EC),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoTag(
                      plan['time'],
                      const Color(0xFF5D3587),
                      const Color(0xFFF3E5F5),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoTag(
                      plan['type'],
                      const Color(0xFF5D3587),
                      const Color(0xFFF3E5F5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  plan['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  plan['subtitle'],
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),

                // Additional Chips
                Row(
                  children: [
                    _buildChip(plan['people']),
                    const SizedBox(width: 8),
                    _buildChip(plan['pay']),
                  ],
                ),
                const SizedBox(height: 12),

                // Profile Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(plan['avatarUrl']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (plan['verified']) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.black87,
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan['nameSubtitle'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(
                                color: Color(0xFFE43A6A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFFE43A6A),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC), // Light pink
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFE43A6A)),
                        onPressed: () {
                          setState(() {
                            List<Map<String, dynamic>> currentList;
                            if (_selectedTabIndex == 0) {
                              currentList = _todayPlans;
                            } else if (_selectedTabIndex == 1) {
                              currentList = _tomorrowPlans;
                            } else {
                              currentList = _weekendPlans;
                            }
                            
                            String selectedFilter = _filters[_selectedFilterIndex];
                            if (selectedFilter != 'All plans') {
                              currentList = currentList.where((plan) => plan['type'] == selectedFilter).toList();
                            }
                            
                            if (currentList.isNotEmpty) {
                              _currentPlanIndex =
                                  (_currentPlanIndex + 1) % currentList.length;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              _showRequestDateBottomSheet(context, plan);
                            },
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Request Date',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showRequestDateBottomSheet(BuildContext context, Map<String, dynamic> plan) {
    final TextEditingController messageController = TextEditingController();
    int selectedBillIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String firstName = plan['name'].split(',')[0];
        String planDate = plan['date'].replaceAll('📅 ', '');
        String planTime = plan['time']
            .replaceAll('🕔 ', '')
            .replaceAll('🕗 ', '')
            .replaceAll('🕙 ', '')
            .replaceAll('🕐 ', '')
            .replaceAll('🕘 ', '')
            .replaceAll('🕕 ', '');

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                Text(
                  'Request a date with $firstName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Ask to join ${plan['title']} · $planDate · $planTime. If they accept, you can meet right away.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F4EF), // Beige
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(plan['avatarUrl']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan['location'].replaceAll('Live · ', ''),
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Safety Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Light green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield, color: Color(0xFF2E7D32), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Meet in the public venue. Your exact location stays private until they accept.',
                          style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Bill suggestion
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bill suggestion · boosts your chance 💫',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSelectionChip('🙋‍♂️', 'I\'ll pay the bill', selectedBillIndex == 0, () {
                      setModalState(() { selectedBillIndex = 0; });
                    }),
                    _buildSelectionChip('🤝', 'Let\'s do TTMM', selectedBillIndex == 1, () {
                      setModalState(() { selectedBillIndex = 1; });
                    }),
                    _buildSelectionChip('☕', 'I\'ve got the coffee', selectedBillIndex == 2, () {
                      setModalState(() { selectedBillIndex = 2; });
                    }),
                    _buildSelectionChip('🤷‍♂️', 'Decide there', selectedBillIndex == 3, () {
                      setModalState(() { selectedBillIndex = 3; });
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                // Add a message
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add a message',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Hey $firstName! I\'d love to join you for walk...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE43A6A)),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildQuickMessageChip('Hey! I\'m free, let\'s meet ✨', () {
                      messageController.text = 'Hey! I\'m free, let\'s meet ✨';
                    }),
                    _buildQuickMessageChip('Love this plan, count me in!', () {
                      messageController.text = 'Love this plan, count me in!';
                    }),
                    _buildQuickMessageChip('I\'m nearby — see you soon?', () {
                      messageController.text = 'I\'m nearby — see you soon?';
                    }),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Buttons (Fixed at bottom)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        'Send date request 📅',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
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
          },
        );
      },
    );
  }

  Widget _buildSelectionChip(String emoji, String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMessageChip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
