import 'package:flutter/material.dart';
import '../post_a_plan/activity_1.dart';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'manage_plan.dart';
import '../../date_api_service/date_now_api_service.dart';
import 'profile.dart';
import 'boost.dart';
import 'dart:async';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  static List<Map<String, dynamic>> myHostedPlans = [];

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String _selectedDayFilter = 'Today';
  String? _selectedCategoryFilter;
  List<String> _myPlansFilters = ['Today', 'Tomorrow', 'Weekend', '|'];
  late List<GlobalKey> _myPlansFilterKeys = List.generate(
    _myPlansFilters.length,
    (index) => GlobalKey(),
  );

  List<Map<String, dynamic>> _apiPlans = [];
  bool _isLoading = true;

  bool _isBoosted = false;
  DateTime? _boostEndTime;
  Timer? _timer;

  int _fakeViews = 2;
  int _fakeRequests = 1;
  int _fakeApproved = 0;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (DateTime.now().second % 7 == 0) _fakeViews++;
          if (DateTime.now().second % 13 == 0) _fakeRequests++;
          if (DateTime.now().second % 29 == 0) _fakeApproved++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();
    _fetchPlans();
  }

  Future<void> _fetchOptions() async {
    final options = await DateNowApiService.getActivityOptions();
    if (options != null && mounted) {
      setState(() {
        _myPlansFilters = ['Today', 'Tomorrow', 'Weekend', '|'];
        _myPlansFilterKeys = List.generate(
          _myPlansFilters.length,
          (index) => GlobalKey(),
        );
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
          _myPlansFilters.add(label);
          _myPlansFilterKeys.add(GlobalKey());
        }
      });
    }
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
    });

    String? rawActivity;
    if (_selectedCategoryFilter != null) {
      rawActivity = _selectedCategoryFilter!
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .trim();
    }

    final res = await DateNowApiService.getMyPlans(
      period: _selectedDayFilter,
      activity: rawActivity,
    );

    if (!mounted) return;

    if (res != null && res['success'] == true) {
      final data = res['data'] as List<dynamic>? ?? [];

      setState(() {
        _apiPlans = data.map((plan) {
          final activity = plan['activity'] ?? {};
          final event = plan['event'] ?? {};
          final venue = plan['venue'] ?? {};

          String title =
              plan['title']?.toString() ??
              (plan['quickTitle'] != null
                  ? plan['quickTitle']['label']?.toString()
                  : null) ??
              'Date Plan';

          String category = activity['label']?.toString() ?? 'General';
          String imageUrl =
              plan['photoUrl']?.toString() ??
              activity['icon']?.toString() ??
              'https://images.unsplash.com/photo-1511920170033-f8396924c348?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
          String subtitle =
              '$_selectedDayFilter · ${venue['name']?.toString() ?? 'Custom location'}';
          final int partLimit =
              int.tryParse(plan['participantLimit']?.toString() ?? '1') ?? 1;
          String limitTag = partLimit > 2
              ? '👥 Small group'
              : '👥 Limit $partLimit';

          return {
            'id': plan['id']?.toString() ?? '',
            'day': _selectedDayFilter, // Fallback since it's filtered by day
            'category': category,
            'imageUrl': imageUrl,
            'title': title,
            'subtitle': subtitle,
            'tags': [limitTag, category],
            'isLive': event['isLiveNow'] == true,
            'requests': (plan['requestsList'] as List<dynamic>? ?? []).map((
              req,
            ) {
              final requester = req['requester'] ?? {};
              return {
                'id': req['id']?.toString() ?? '',
                'userId':
                    requester['_id']?.toString() ??
                    requester['id']?.toString() ??
                    '',
                'name': requester['name']?.toString() ?? 'Unknown',
                'age': requester['age'] ?? 20,
                'match': requester['matchPercentage'] != null
                    ? '${requester['matchPercentage']}%'
                    : '92%',
                'message':
                    req['message']?.toString() ?? '"No message attached."',
                'avatar':
                    requester['photo']?.toString() ??
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                'status': req['status']?.toString().toLowerCase() == 'pending'
                    ? 'new'
                    : req['status']?.toString().toLowerCase(),
                'rawRequest': req,
              };
            }).toList(),
            'requestsMeta': plan['requests'] ?? {}, // total, pending
            'rawPlan': plan,
          };
        }).toList();
        MyPlanScreen.myHostedPlans = List.from(_apiPlans);
        _isLoading = false;
      });
    } else {
      setState(() {
        _apiPlans = [];
        MyPlanScreen.myHostedPlans = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMyPlansTab();
  }

  Widget _buildMyPlansTab() {
    List<Map<String, dynamic>> filteredPlans = _apiPlans.where((plan) {
      bool matchesDay = plan['day'] == _selectedDayFilter;
      bool matchesCategory = true;
      if (_selectedCategoryFilter != null) {
        // Strip emojis and get the raw text (e.g. 'Coffee')
        String filterText = _selectedCategoryFilter!
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .trim()
            .toLowerCase();

        String planCategory = (plan['category'] ?? '').toString().toLowerCase();
        String planTitle = (plan['title'] ?? '').toString().toLowerCase();

        // Match if the category name OR the title contains the filter text
        matchesCategory =
            planCategory.contains(filterText) || planTitle.contains(filterText);
      }
      return matchesDay && matchesCategory;
    }).toList();

    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          // My Plans Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(_myPlansFilters.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildMyPlansFilterChip(
                    _myPlansFilters[index],
                    index,
                    _myPlansFilterKeys[index],
                  ),
                );
              }),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                  )
                : filteredPlans.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 40,
                    ),
                    itemCount: filteredPlans.length,
                    itemBuilder: (context, index) {
                      return _buildContent(filteredPlans[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFA6A85).withOpacity(0.1),
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
            'No plans here',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No active plans match this filter. Try another day or category — or post a new one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 32),
          GestureDetector(
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE43A6A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE43A6A).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '+ Post a plan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> plan) {
    List<Map<String, dynamic>> requests = List<Map<String, dynamic>>.from(
      plan['requests'] ?? [],
    );

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHostedPlanCard(plan),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoostSection(plan),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE43A6A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${requests.length} new requests',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(requests.length, (index) {
                  return _buildRequestCard(requests[index], requests);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPlansFilterChip(String label, int index, GlobalKey key) {
    if (label == '|') {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('|', style: TextStyle(color: Colors.black26, fontSize: 18)),
      );
    }
    bool isSelected = false;
    if (index < 3) {
      isSelected = _selectedDayFilter == label;
    } else {
      isSelected = _selectedCategoryFilter == label;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (index < 3) {
            _selectedDayFilter = label;
          } else {
            if (_selectedCategoryFilter == label) {
              _selectedCategoryFilter = null;
            } else {
              _selectedCategoryFilter = label;
            }
          }
          if (key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              alignment: 0.5,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
        _fetchPlans(); // re-fetch with new filters
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

  Widget _buildHostedPlanCard(Map<String, dynamic> plan) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  plan['imageUrl'],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
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
              if (plan['isLive'] == true)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF45B16D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
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
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => showManageBottomSheet(context, plan, () {
                    setState(() {
                      MyPlanScreen.myHostedPlans.remove(plan);
                      _apiPlans.remove(plan);
                    });
                  }),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Manage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan['subtitle'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
                  (plan['tags'] as List<dynamic>?)?.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildSmallTag(tag.toString()),
                    );
                  }).toList() ??
                  [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getRemainingTime() {
    if (_boostEndTime == null) return '0h 0m 0s';
    final diff = _boostEndTime!.difference(DateTime.now());
    if (diff.isNegative) return '0h 0m 0s';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  Widget _buildStatChip(String icon, String label, {bool isGreen = false}) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
       decoration: BoxDecoration(
         color: isGreen ? const Color(0xFFEFFFF4) : Colors.white,
         border: Border.all(color: isGreen ? Colors.green.shade300 : Colors.grey.shade300, width: 0.5),
         borderRadius: BorderRadius.circular(12),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Text(icon, style: const TextStyle(fontSize: 11)),
           const SizedBox(width: 4),
           Text(
             label,
             style: TextStyle(
               fontSize: 11,
               fontWeight: FontWeight.w600,
               color: isGreen ? Colors.green.shade700 : Colors.black87,
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildActiveBoostSection() {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: const Color(0xFFFFF7F2),
         border: Border.all(color: const Color.fromRGBO(241, 182, 114, 1), width: 1.5),
         borderRadius: BorderRadius.circular(16),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Container(
                 width: 8,
                 height: 8,
                 decoration: const BoxDecoration(
                   color: Colors.orange,
                   shape: BoxShape.circle,
                 ),
               ),
               const SizedBox(width: 6),
               const Text(
                 '🚀 Pinned to top of feed',
                 style: TextStyle(
                   color: Color.fromRGBO(138, 90, 0, 1),
                   fontWeight: FontWeight.bold,
                   fontSize: 13,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),
           Wrap(
             spacing: 8,
             runSpacing: 8,
             children: [
               _buildStatChip('⏱️', _getRemainingTime()),
               _buildStatChip('👁️', '$_fakeViews views'),
               _buildStatChip('✉️', '$_fakeRequests requests'),
               _buildStatChip('✔️', '$_fakeApproved approved', isGreen: true),
             ],
           ),
         ],
       ),
     );
  }

  Widget _buildBoostSection(Map<String, dynamic> plan) {
    if (_isBoosted) {
      return _buildActiveBoostSection();
    }
    
    return GestureDetector(
      onTap: () async {
        final duration = await showBoostBottomSheet(context, plan);
        if (duration != null && mounted) {
          setState(() {
            _isBoosted = true;
            _boostEndTime = DateTime.now().add(Duration(hours: duration));
            _startTimer();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Boosted · pinned to top for $duration hrs',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1E1E1E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        color: const Color.fromRGBO(241, 182, 114, 1),
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 246, 237, 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '🚀 Boost to top · up to 5x more requests',
                style: TextStyle(
                  color: Color.fromRGBO(138, 90, 0, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(252, 168, 85, 1),
                    Color.fromRGBO(242, 127, 66, 1),
                  ],
                ),
              ),
              child: const Text(
                'Boost',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
    List<Map<String, dynamic>> planRequests,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyPlanRequesterProfileScreen(request: request),
                ),
              );
              if (result == 'decline') {
                setState(() => planRequests.remove(request));
              } else {
                setState(() {});
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(request['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${request['name']}, ${request['age']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFA6A85).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              request['match'] ?? '92%',
                              style: const TextStyle(
                                color: Color(0xFFDE2957),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['message'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (request['status'] == 'approved') ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Request Approved',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                      ),
                      borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final requestId = request['id'] ?? 'DUMMY_ID';
                      final success = await DateNowApiService.declineRequest(
                        requestId,
                      );
                      if (success) {
                        if (!mounted) return;
                        setState(() {
                          planRequests.remove(request);
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request declined')),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.black54,
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
                  flex: 2,
                  child: GestureDetector(
                    onTap: () async {
                      final requestId = request['id'] ?? 'DUMMY_ID';
                      final success = await DateNowApiService.approveRequest(
                        requestId,
                      );
                      if (success) {
                        if (!mounted) return;
                        setState(() {
                          request['status'] = 'approved';
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request approved')),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '✓ Approve',
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
          ],
        ],
      ),
    );
  }
}

void _showFeedbackSavedSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 60, // Top of the screen
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💌 ', style: TextStyle(fontSize: 16)),
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}
