import '../../../../services/token_helper.dart';
import 'package:flutter/material.dart';
import '../post_a_plan/activity_1.dart';
import '../history/top_history_screen.dart';
import '../my_plans/my_plan_screen.dart';
import '../history/card_history.dart';
import '../../date_api_service/date_now_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestsSentScreen extends StatefulWidget {
  final int initialTabIndex;
  const RequestsSentScreen({super.key, this.initialTabIndex = 0});

  // Global static data for sent requests
  static List<Map<String, dynamic>> mySentRequests = [];

  @override
  State<RequestsSentScreen> createState() => _RequestsSentScreenState();
}

class _RequestsSentScreenState extends State<RequestsSentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  int _selectedFilterIndex = -1;
  bool _isLoading = true;
  int _historyCount = 0;

  // Shared token for API calls in this screen

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _fetchMySentRequests();
  }

  Future<void> _fetchMySentRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://api.welvors.com/api/user/my-date-plan-requests',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          RequestsSentScreen.mySentRequests = items.map<Map<String, dynamic>>((
            item,
          ) {
            final plan = item['plan'] ?? {};
            final host = plan['host'] ?? {};

            // Format status to Title Case if needed (e.g. PENDING -> Pending)
            String rawStatus = (item['status'] ?? 'Pending').toString();
            String displayStatus = rawStatus.isNotEmpty
                ? rawStatus[0].toUpperCase() +
                      rawStatus.substring(1).toLowerCase()
                : 'Pending';

            return {
              'id': item['id'],
              'planId': item['planId'] ?? plan['id'],
              'imageUrl':
                  plan['photoUrl'] ??
                  (plan['activity'] is Map ? plan['activity']['icon'] : null),
              'activityName': plan['activity'] is Map
                  ? (plan['activity']['label'] ??
                        plan['activity']['name'] ??
                        '')
                  : (plan['activity'] ?? ''),
              'title':
                  (plan['quickTitle'] is Map
                      ? plan['quickTitle']['label']
                      : plan['quickTitle']) ??
                  plan['title'] ??
                  'Plan',
              'subtitle':
                  '${_formatDate(plan['eventDateTime'])} · ${plan['venueName'] ?? ''}',
              'hostName': host['name'] ?? 'User',
              'hostAvatar': host['profilePhoto'],
              'status': displayStatus,
              'message': item['message'] ?? 'I would love to join!',
              'billSuggestionLabel':
                  item['billSuggestion'] != null &&
                      item['billSuggestion'] is Map
                  ? item['billSuggestion']['label']
                  : '🤝 Split the bill',
              'statusMessage': item['status'] == 'APPROVED'
                  ? 'Host approved your request!'
                  : 'Waiting for host to approve. You can withdraw anytime.',
              'pay': plan['whoPays'] ?? 'Split',
              'match': '88%',
              'isLive': false,
            };
          }).toList();
        }
      }

      // Fetch history count for the tab
      final historyResponse = await DateNowApiService.getHistoryPlans(
        page: 1,
        limit: 100,
      );
      if (historyResponse != null && historyResponse['success'] == true) {
        final List<dynamic> historyData = historyResponse['data'] ?? [];
        if (mounted) {
          setState(() {
            _historyCount = historyData.length;
          });
        }
      }

      // Fetch dynamic options for filters
      final options = await DateNowApiService.getActivityOptions();
      if (options != null && mounted) {
        setState(() {
          _filters = [];
          _filterKeys = [];
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
    } catch (e) {
      debugPrint('Error fetching requests: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return 'Today · $hour12:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionPopup(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isError ? Colors.red.shade800 : Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isError ? Icons.error : Icons.check_circle,
                        color: isError ? Colors.white : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  List<String> _filters = ['☕ Coffee', '🍽️ Dinner', '🍸 Drinks', '🚶 Walk'];
  late List<GlobalKey> _filterKeys = List.generate(
    _filters.length,
    (index) => GlobalKey(),
  );

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPlans = RequestsSentScreen.mySentRequests
        .where((plan) {
          if (_selectedFilterIndex == -1) return true;
          String filterText = _filters[_selectedFilterIndex]
              .replaceAll(RegExp(r'[^\w\s]'), '')
              .trim()
              .toLowerCase();

          String activityName =
              plan['activityName']?.toString().toLowerCase() ?? '';

          if (activityName.isNotEmpty && activityName.contains(filterText)) {
            return true;
          }
          return false;
        })
        .toList();

    filteredPlans.sort((a, b) {
      final aStatus = a['status']?.toString().toUpperCase() ?? '';
      final bStatus = b['status']?.toString().toUpperCase() ?? '';
      final aIsApproved = aStatus == 'APPROVED' ? 1 : 0;
      final bIsApproved = bStatus == 'APPROVED' ? 1 : 0;
      return bIsApproved.compareTo(aIsApproved);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 55,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: RichText(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Activity1Screen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      _fetchMySentRequests();
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDE2957).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        const Text(
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
            padding: const EdgeInsets.only(left: 4, right: 16),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorColor: const Color(0xFFE43A6A),
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent, // Hides default grey bottom line
            splashFactory: NoSplash
                .splashFactory, // Removes ripple effect for smoother look
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            physics: const BouncingScrollPhysics(),
            tabs: [
              _buildTab(
                'Requests sent',
                RequestsSentScreen.mySentRequests.length,
                0,
              ),
              _buildTab('My plans', MyPlanScreen.myHostedPlans.length, 1),
              _buildTab('History', _historyCount, 2),
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
                            child: _buildFilterChip(
                              _filters[index],
                              index,
                              _filterKeys[index],
                            ),
                          );
                        }),
                      ),
                    ),
                    // List
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFA6A85),
                              ),
                            )
                          : filteredPlans.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (RequestsSentScreen
                                            .mySentRequests
                                            .isNotEmpty &&
                                        _selectedFilterIndex != -1) ...[
                                      Icon(
                                        Icons.event_busy,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No plans found for ${_filters[_selectedFilterIndex]}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFA6A85,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.search_rounded,
                                          size: 40,
                                          color: Color(0xFFFA6A85),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No requests sent',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Find a live plan you like and ask to join. Your requests show up here so you can track or withdraw them.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFA6A85),
                                                Color(0xFFDE2957),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          child: const Text(
                                            'Discover plans',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
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

                // TAB 3: History
                const TopHistoryScreen(),
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
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE43A6A)
                  : (index == 2
                        ? Colors.grey.shade400
                        : const Color(0xFFF2A93B)),
              shape: BoxShape.circle,
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, GlobalKey key) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFilterIndex == index) {
            _selectedFilterIndex = -1;
          } else {
            _selectedFilterIndex = index;
            if (key.currentContext != null) {
              Scrollable.ensureVisible(
                key.currentContext!,
                alignment: 0.5,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      },
      child: Container(
        key: key,
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
                image:
                    plan['imageUrl'] != null &&
                        plan['imageUrl'].toString().isNotEmpty
                    ? NetworkImage(plan['imageUrl']) as ImageProvider
                    : const AssetImage('assets/dummyphoto.jpeg'),
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
                // Profile Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            plan['hostAvatar'] != null &&
                                plan['hostAvatar'].toString().isNotEmpty
                            ? NetworkImage(plan['hostAvatar']) as ImageProvider
                            : const AssetImage('assets/dummyphoto.jpeg'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan['hostName'] +
                                      (plan['pay'] != null ? ' , ' : ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    plan['pay'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(text: 'Host · '),
                                  TextSpan(
                                    text: '💜 88% match',
                                    style: TextStyle(
                                      color: Color(0xFF9C27B0),
                                    ), // Purple color for match
                                  ),
                                  TextSpan(text: ' · 🛡️ 95% trust'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Message Bubble (Vertical pink line style)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFFFA6A85).withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
                  child: Text(
                    plan['message'] ?? '',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 10),

                // Bill Suggestion
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR BILL SUGGESTION',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          plan['billSuggestionLabel'] ?? '🤝 Split the bill',
                          style: const TextStyle(
                            color: Color(0xFFDE2957),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Status Box (Premium Slim Design)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isApproved
                        ? LinearGradient(
                            colors: [
                              const Color(0xFFE8F5E9),
                              const Color(0xFFC8E6C9).withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFFFFF3E0),
                              const Color(0xFFFFE0B2).withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isApproved
                          ? const Color(0xFFA5D6A7).withOpacity(0.5)
                          : const Color(0xFFFFCC80).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isApproved ? '🥳' : '⏳',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan['statusMessage'],
                          style: TextStyle(
                            color: isApproved
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFFE65100),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
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
                            _showActionPopup('Coming soon');
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
                        child: GestureDetector(
                          onTap: () => _showWithdrawBottomSheet(context, plan),
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showViewPlanBottomSheet(context, plan),
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
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 16,
          ),
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
                  child: const Text('💔', style: TextStyle(fontSize: 28)),
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
                      cleanTitle = cleanTitle.substring(
                        cleanTitle.indexOf(' ') + 1,
                      );
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
                        backgroundImage:
                            plan['hostAvatar'] != null &&
                                plan['hostAvatar'].toString().isNotEmpty
                            ? NetworkImage(plan['hostAvatar']) as ImageProvider
                            : const AssetImage('assets/dummyphoto.jpeg'),
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
                  onTap: () async {
                    Navigator.pop(context); // Close bottom sheet

                    // Show a simple snackbar indicating progress
                    // (Removed loading snackbar)

                    final planId = plan['planId'];
                    final url = Uri.parse(
                      'https://api.welvors.com/api/user/date-plans/$planId/cancel-request',
                    );

                    try {
                      final response = await http.patch(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization':
                              'Bearer ${await TokenHelper.getToken() ?? ""}',
                        },
                        body: json.encode(
                          {},
                        ), // Add empty body to prevent backend parsing errors
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        setState(() {
                          RequestsSentScreen.mySentRequests.remove(plan);
                        });
                        if (mounted) {
                          _showActionPopup('Date canceled successfully');
                        }
                      } else {
                        String errorMessage = 'Failed to cancel date';
                        try {
                          final errorBody = json.decode(response.body);
                          if (errorBody['message'] != null) {
                            errorMessage = errorBody['message'];
                          }
                        } catch (_) {}

                        if (mounted) {
                          _showActionPopup(errorMessage, isError: true);
                        }
                        debugPrint(
                          'Failed to cancel: ${response.statusCode} - ${response.body}',
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        _showActionPopup('Error canceling date', isError: true);
                      }
                      debugPrint('Error canceling date: $e');
                    }
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

  void _showWithdrawBottomSheet(
    BuildContext context,
    Map<String, dynamic> plan,
  ) {
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
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 16,
          ),
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
                // Withdraw icon
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFA6A85).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '↩️',
                    style: TextStyle(fontSize: 28, height: 1.2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Withdraw request?',
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
                      cleanTitle = cleanTitle.substring(
                        cleanTitle.indexOf(' ') + 1,
                      );
                    }
                    return RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Your request to join '),
                          TextSpan(
                            text: cleanTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' will be\nremoved and $name won\'t see it anymore.',
                          ),
                        ],
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
                        backgroundImage:
                            plan['hostAvatar'] != null &&
                                plan['hostAvatar'].toString().isNotEmpty
                            ? NetworkImage(plan['hostAvatar']) as ImageProvider
                            : const AssetImage('assets/dummyphoto.jpeg'),
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
                // Withdraw request button
                GestureDetector(
                  onTap: () async {
                    // Start loader or just optimistically remove
                    Navigator.pop(context); // Close bottom sheet

                    final requestId = plan['id'] ?? 'DUMMY_ID';

                    // Show a simple snackbar indicating progress
                    // (Removed loading snackbar)

                    final success = await DateNowApiService.withdrawRequest(
                      requestId,
                      overrideToken: (await TokenHelper.getToken() ?? ""),
                    );

                    if (success) {
                      setState(() {
                        RequestsSentScreen.mySentRequests.remove(plan);
                      });
                      if (context.mounted) {
                        _showActionPopup('Request withdrawn');
                      }
                    } else {
                      if (context.mounted) {
                        _showActionPopup(
                          'Failed to withdraw request',
                          isError: true,
                        );
                      }
                    }
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
                        'Withdraw request',
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

  void _showViewPlanBottomSheet(
    BuildContext context,
    Map<String, dynamic> plan,
  ) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top image with title overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          plan['imageUrl'] != null &&
                              plan['imageUrl'].toString().isNotEmpty
                          ? NetworkImage(plan['imageUrl']) as ImageProvider
                          : const AssetImage('assets/dummyphoto.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      plan['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: '💜 ${plan['match']} match',
                              style: const TextStyle(
                                color: Color(0xFF9C27B0),
                              ), // Purple color for match
                            ),
                            const TextSpan(text: ' · 🛡️ 98% trust'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date/Time
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plan['subtitle'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tags row (Payment, people)
                      Row(
                        children: [
                          Text(
                            plan['pay'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '·',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '👥 2 people',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                              radius: 20,
                              backgroundImage:
                                  plan['hostAvatar'] != null &&
                                      plan['hostAvatar'].toString().isNotEmpty
                                  ? NetworkImage(plan['hostAvatar'])
                                        as ImageProvider
                                  : const AssetImage('assets/dummyphoto.jpeg'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan['hostName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Host of this plan',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Message card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          plan['message'].replaceAll('You: ', 'You said: '),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Close view plan
                                _showWithdrawBottomSheet(
                                  context,
                                  plan,
                                ); // Show withdraw
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Withdraw',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFA6A85),
                                      Color(0xFFDE2957),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
