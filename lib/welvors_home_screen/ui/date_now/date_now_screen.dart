import 'package:cached_network_image/cached_network_image.dart';
import '../../services/token_helper.dart';
import 'package:flutter/material.dart';
import 'send_request_drawer.dart';
import 'date_now_2/requests_sent/requests_sent_screen.dart';
import 'date_now_2/my_plans/my_plan_screen.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';
import 'date_now_2/post_a_plan/activity_1.dart';
import 'package:intl/intl.dart';
import 'profile/profile_detail.dart';

String _formatEventTime(String? timeStr) {
  if (timeStr == null || timeStr.isEmpty) return '';
  try {
    if (timeStr.startsWith('T')) {
      final utcTime = DateTime.parse('1970-01-01$timeStr');
      final localTime = utcTime.toLocal();
      return '🕔 ${DateFormat('hh:mm a').format(localTime)}';
    } else {
      final utcTime = DateTime.parse(timeStr);
      final localTime = utcTime.toLocal();
      return '🕔 ${DateFormat('hh:mm a').format(localTime)}';
    }
  } catch (e) {
    return '🕔 $timeStr';
  }
}

class DateNowScreen extends StatefulWidget {
  const DateNowScreen({super.key});

  @override
  State<DateNowScreen> createState() => _DateNowScreenState();
}

class _DateNowScreenState extends State<DateNowScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedTabIndex = 0;
  int _selectedFilterIndex = 0;

  final List<String> _tabs = ['Today', 'Tomorrow', 'Weekend'];
  List<String> _filters = ['All plans'];
  List<GlobalKey> _filterKeys = [GlobalKey()];
  int _currentPlanIndex = 0;

  bool _isLoading = true;
  List<Map<String, dynamic>> _fetchedPlans = [];
  final Set<String> _removedPlanIds = {};

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    _fetchOptions();
    _fetchPlans();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    final options = await DateNowApiService.getActivityOptions();
    if (options != null && mounted) {
      setState(() {
        _filters = ['All plans'];
        _filterKeys = [GlobalKey()];
        for (var opt in options) {
          String label = '';
          if (opt['emoji'] != null && opt['emoji'].toString().isNotEmpty) {
            label = '${opt['emoji']} ${opt['label']}';
          } else if (opt['icon'] != null &&
              !opt['icon'].toString().startsWith('http')) {
            label = '${opt['icon']} ${opt['label']}';
          } else {
            label = opt['label'] ?? opt['name'] ?? 'Unknown';
          }
          _filters.add(label);
          _filterKeys.add(GlobalKey());
        }
      });
    }
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

    final token = (await TokenHelper.getToken() ?? "");

    final plans = await DateNowApiService.getDiscoverPlans(
      filter,
      overrideToken: token,
    );

    if (mounted) {
      setState(() {
        _fetchedPlans = [];
        _removedPlanIds.clear();
        if (plans != null) {
          for (var p in plans) {
            String activity = p['activity'] ?? 'Unknown';

            _fetchedPlans.add({
              'id': p['id'],
              'imageUrl': p['photoUrl'] ?? p['activityIcon'] ?? '',
              'location': 'Live · ${p['venueName'] ?? 'Unknown'}',
              'distance': p['distanceKm'] != null
                  ? '${p['distanceKm']} km away'
                  : 'Near you',
              'match': p['matchScore'] != null
                  ? '${p['matchScore']['score']}% match'
                  : '0% match',
              'date': p['eventDate'] != null ? '📅 ${p['eventDate']}' : '',
              'time': _formatEventTime(p['eventTime']),
              'type': activity,
              'title': p['title'] ?? p['quickTitle'] ?? 'Date Plan',
              'subtitle': p['note'] ?? '',
              'people':
                  (p['duration'] != null && p['duration'].toString() != '0')
                  ? '⏱️ ${p['duration']} mins'
                  : '⏱️ Flexible',
              'pay': p['whoPays'] ?? '',
              'name': p['host'] != null
                  ? '${p['host']['name'] ?? 'User'}, ${p['host']['age'] ?? ''}'
                  : 'User',
              'userId': p['host'] != null
                  ? (p['host']['id'] ??
                        p['host']['userId'] ??
                        p['host']['_id'] ??
                        p['userId'])
                  : p['userId'],
              'verified': p['host'] != null && p['host']['isVerified'] == true,
              'nameSubtitle': 'Host',
              'avatarUrl': p['host'] != null
                  ? (p['host']['profilePhoto'] ?? '')
                  : '',
            });
          }
        }
        _currentPlanIndex = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tabs.length,
                onPageChanged: (index) {
                  if (_selectedTabIndex != index) {
                    setState(() {
                      _selectedTabIndex = index;
                      _fetchPlans();
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildDateCard(),
                  );
                },
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
                      setState(
                        () {},
                      ); // Refresh the badge number when returning
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
                        if (_selectedTabIndex != index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
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

    List<Map<String, dynamic>> currentList = _fetchedPlans
        .where((plan) => !_removedPlanIds.contains(plan['id'].toString()))
        .toList();

    String selectedFilter = _filters[_selectedFilterIndex];
    if (selectedFilter != 'All plans') {
      final filterText = selectedFilter
          .split(' ')
          .last; // e.g. 'Coffee' from '☕ Coffee'
      currentList = currentList
          .where((plan) => plan['type'].toString().contains(filterText))
          .toList();
    }

    if (currentList.isEmpty) {
      String currentTab = _tabs[_selectedTabIndex];
      String filterLabel = currentTab == 'Weekend'
          ? 'this weekend'
          : currentTab.toLowerCase();
      if (selectedFilter != 'All plans') {
        final filterText = selectedFilter.split(' ').last;
        filterLabel = '$filterLabel for $filterText';
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No plans found $filterLabel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to post a plan and\ninvite others to join you!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
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
                        builder: (context) => const Activity1Screen(),
                      ),
                    ).then((_) {
                      if (mounted) {
                        _fetchPlans();
                      }
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Post a plan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

    int displayIndex = _currentPlanIndex % currentList.length;
    final plan = currentList[displayIndex];

    return Container(
      key: ValueKey(plan['id']),
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
                  child: CachedNetworkImage(
                    imageUrl: plan['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                    ),
                    errorWidget: (context, url, error) => Container(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '💜 ${plan['match']} · 🛡️ 98% trust',
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
                if (plan['subtitle'] != null &&
                    plan['subtitle'].toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  // Subtitle
                  Text(
                    plan['subtitle'],
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
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
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            plan['avatarUrl'] != null &&
                                plan['avatarUrl'].toString().isNotEmpty
                            ? CachedNetworkImageProvider(plan['avatarUrl'])
                            : null,
                        child:
                            plan['avatarUrl'] == null ||
                                plan['avatarUrl'].toString().isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    plan['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
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
                        onPressed: () {
                          if (plan['userId'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileDetailScreen(
                                  userId: plan['userId'].toString(),
                                  profileImageUrl: plan['avatarUrl'],
                                  profileName: plan['name'],
                                  plan: plan,
                                  onPlanAction: () {
                                    setState(() {
                                      _removedPlanIds.add(
                                        plan['id'].toString(),
                                      );
                                    });
                                    final remaining = _fetchedPlans
                                        .where(
                                          (p) => !_removedPlanIds.contains(
                                            p['id'].toString(),
                                          ),
                                        )
                                        .length;
                                    if (remaining == 0) {
                                      _fetchPlans();
                                    }
                                  },
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Host details not available'),
                              ),
                            );
                          }
                        },
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
                          final testToken =
                              (await TokenHelper.getToken() ?? "");

                          // Optional UI feedback or just remove immediately for perceived speed
                          setState(() {
                            _removedPlanIds.add(plan['id'].toString());
                          });

                          // Check if we need to fetch more
                          final remaining = _fetchedPlans
                              .where(
                                (p) => !_removedPlanIds.contains(
                                  p['id'].toString(),
                                ),
                              )
                              .length;
                          if (remaining == 0) {
                            _fetchPlans();
                          }

                          // Call API in the background
                          await DateNowApiService.skipPlan(
                            plan['id'],
                            overrideToken: testToken,
                          );
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
                              debugPrint("plan>>>>>>>${plan}");
                              final requestSent =
                                  await showRequestDateBottomSheet(
                                    context,
                                    plan,
                                  );
                              if (mounted && requestSent == true) {
                                setState(() {
                                  _removedPlanIds.add(plan['id'].toString());
                                });

                                // Check if we need to fetch more
                                final remaining = _fetchedPlans
                                    .where(
                                      (p) => !_removedPlanIds.contains(
                                        p['id'].toString(),
                                      ),
                                    )
                                    .length;
                                if (remaining == 0) {
                                  _fetchPlans();
                                }
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
