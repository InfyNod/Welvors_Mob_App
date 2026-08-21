import 'package:flutter/material.dart';
import 'send_request_drawer.dart';
import 'date_now_2/requests_sent/requests_sent_screen.dart';
import 'date_now_2/my_plans/my_plan_screen.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

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

  bool _isLoading = true;
  List<Map<String, dynamic>> _fetchedPlans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
    });

    String filter = 'today';
    if (_selectedTabIndex == 1) {
      filter = 'tomorrow';
    } else if (_selectedTabIndex == 2) {
      filter = 'weekend'; // Adjust if backend uses a different term for weekend
    }

    final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhMTM0OGNlNC0zMTgzLTRkNzgtYWI4Ni00ODZhMjg4NzcyMjQiLCJpYXQiOjE3ODY3MDI5OTgsImV4cCI6MTc4OTI5NDk5OH0.acSy-NV8wDq8p4793J2rYatcnAsxvc49Oq2KM3AZA2A';

    final plans = await DateNowApiService.getDiscoverPlans(filter, overrideToken: token);
    
    if (mounted) {
      setState(() {
        _fetchedPlans = [];
        if (plans != null) {
          for (var p in plans) {
            String activity = p['activity'] ?? 'Unknown';
            
            // Determine default image based on activity type if photoUrl is null
            String defaultImage = 'https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'; // Default walk/nature
            final activityLower = activity.toLowerCase();
            if (activityLower.contains('dinner')) {
              defaultImage = 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            } else if (activityLower.contains('coffee')) {
              defaultImage = 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            } else if (activityLower.contains('brunch')) {
              defaultImage = 'https://images.unsplash.com/photo-1543807535-eceef0bc6599?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            } else if (activityLower.contains('drink') || activityLower.contains('bar')) {
              defaultImage = 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            } else if (activityLower.contains('trek') || activityLower.contains('hike')) {
              defaultImage = 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            }

            _fetchedPlans.add({
              'id': p['id'],
              'imageUrl': p['photoUrl'] ?? defaultImage,
              'location': 'Live · ${p['venueName'] ?? 'Unknown'}',
              'distance': p['distanceKm'] != null ? '${p['distanceKm']} km away' : 'Near you',
              'match': p['matchScore'] != null ? '${p['matchScore']['score']}% match' : '0% match',
              'date': p['eventDate'] != null ? '📅 ${p['eventDate']}' : '📅 TODAY',
              'time': p['eventTime'] != null ? '🕔 ${p['eventTime']}' : '🕔 TBD',
              'type': activity,
              'title': p['title'] ?? 'Date Plan',
              'subtitle': p['note'] ?? '',
              'people': p['duration'] != null ? '⏱️ ${p['duration']} mins' : '👥 2 people',
              'pay': p['whoPays'] ?? '🤝 Split',
              'name': p['host'] != null ? '${p['host']['name']}, ${p['host']['age']}' : 'User',
              'verified': true, // default for now
              'nameSubtitle': 'Host',
              'avatarUrl': p['host'] != null ? p['host']['profilePhoto'] : 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
            });
          }
        }
        _currentPlanIndex = 0;
        _isLoading = false;
      });
    }
  }

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestsSentScreen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      setState(() {}); // Refresh the badge number when returning
                    }
                  });
                },
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
                        child: Text(
                          '${RequestsSentScreen.mySentRequests.length + MyPlanScreen.myHostedPlans.length}',
                          style: const TextStyle(
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
                            _fetchPlans(); // Fetch new plans for the selected tab
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
      );
    }

    List<Map<String, dynamic>> currentList = List.from(_fetchedPlans);

    String selectedFilter = _filters[_selectedFilterIndex];
    if (selectedFilter != 'All plans') {
      final filterText = selectedFilter.split(' ').last; // e.g. 'Coffee' from '☕ Coffee'
      currentList = currentList
          .where((plan) => plan['type'].toString().contains(filterText))
          .toList();
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                        onPressed: () async {
                          final testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhMTM0OGNlNC0zMTgzLTRkNzgtYWI4Ni00ODZhMjg4NzcyMjQiLCJpYXQiOjE3ODY3MDI5OTgsImV4cCI6MTc4OTI5NDk5OH0.acSy-NV8wDq8p4793J2rYatcnAsxvc49Oq2KM3AZA2A';
                          
                          // Optional UI feedback or just remove immediately for perceived speed
                          setState(() {
                            _fetchedPlans.remove(plan);
                          });
                          
                          // Call API in the background
                          await DateNowApiService.skipPlan(plan['id'], overrideToken: testToken);
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
                            onTap: () async {
                              await showRequestDateBottomSheet(context, plan);
                              if (mounted) {
                                setState(() {
                                  _fetchedPlans.remove(plan);
                                });
                              }
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


}
