import 'package:flutter/material.dart';
import '../post_a_plan/activity_1.dart';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'manage_plan.dart';
import '../../date_api_service/date_now_api_service.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  static List<Map<String, dynamic>> myHostedPlans = [
    {
      'day': 'Today',
      'category': '☕ Coffee',
      'imageUrl':
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'title': 'Morning Coffee Date',
      'subtitle': 'Today · Central Perk',
      'tags': ['👥 Limit 2', '☕ Coffee'],
      'isLive': true,
      'requests': [
        {
          'id': 'req1',
          'name': 'Sarah',
          'age': 24,
          'match': '92%',
          'message': '"This sounds perfect, I\'m in!"',
          'avatar':
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
          'status': 'new',
        },
        {
          'id': 'req2',
          'name': 'Jessica',
          'age': 25,
          'match': '88%',
          'message': '"Would love to grab a coffee!"',
          'avatar':
              'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
          'status': 'new',
        },
      ],
    },
    {
      'day': 'Tomorrow',
      'category': '🍽️ Dinner',
      'imageUrl':
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'title': 'Sushi Night',
      'subtitle': 'Tomorrow · Nobu',
      'tags': ['👥 Limit 2', '🍽️ Dinner'],
      'isLive': false,
      'requests': [
        {
          'id': 'req3',
          'name': 'Emma',
          'age': 26,
          'match': '85%',
          'message': '"I love sushi!"',
          'avatar':
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
          'status': 'approved',
        },
      ],
    },
  ];

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  String _selectedDayFilter = 'Today';
  String? _selectedCategoryFilter;
  final List<String> _myPlansFilters = [
    'Today',
    'Tomorrow',
    'Weekend',
    '|',
    '☕ Coffee',
    '🍽️ Dinner',
    '🍸 Drinks',
    '🚶 Walk',
    '🥞 Brunch',
    '🍿 Movie',
  ];

  List<Map<String, dynamic>> _apiPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
    });

    String? rawActivity;
    if (_selectedCategoryFilter != null) {
      rawActivity = _selectedCategoryFilter!.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
    }

    final res = await DateNowApiService.getMyPlans(period: _selectedDayFilter, activity: rawActivity);
    if (res != null && res['success'] == true) {
      final data = res['data'] as List<dynamic>? ?? [];
      
      setState(() {
        _apiPlans = data.map((plan) {
          final activity = plan['activity'] ?? {};
          final event = plan['event'] ?? {};
          final venue = plan['venue'] ?? {};
          
          String title = plan['title']?.toString() ?? 
                         (plan['quickTitle'] != null ? plan['quickTitle']['label']?.toString() : null) ?? 
                         'Date Plan';
          
          String category = activity['label']?.toString() ?? 'General';
          String imageUrl = plan['photoUrl']?.toString() ?? activity['icon']?.toString() ?? 'https://images.unsplash.com/photo-1511920170033-f8396924c348?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
          String subtitle = '$_selectedDayFilter · ${venue['name']?.toString() ?? 'Custom location'}';
          final int partLimit = int.tryParse(plan['participantLimit']?.toString() ?? '1') ?? 1;
          String limitTag = partLimit > 2 ? '👥 Small group' : '👥 Limit $partLimit';

          return {
            'id': plan['id']?.toString() ?? '',
            'day': _selectedDayFilter, // Fallback since it's filtered by day
            'category': category,
            'imageUrl': imageUrl,
            'title': title,
            'subtitle': subtitle,
            'tags': [limitTag, category],
            'isLive': event['isLiveNow'] == true,
            'requests': (plan['requestsList'] as List<dynamic>? ?? []).map((req) {
              final requester = req['requester'] ?? {};
              return {
                'id': req['id']?.toString() ?? '',
                'name': requester['name']?.toString() ?? 'Unknown',
                'age': requester['age'] ?? 20,
                'match': requester['matchPercentage'] != null ? '${requester['matchPercentage']}%' : '92%',
                'message': req['message']?.toString() ?? '"No message attached."',
                'avatar': requester['photo']?.toString() ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                'status': req['status']?.toString().toLowerCase() == 'pending' ? 'new' : req['status']?.toString().toLowerCase(),
                'rawRequest': req,
              };
            }).toList(),
            'requestsMeta': plan['requests'] ?? {}, // total, pending
            'rawPlan': plan,
          };
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _apiPlans = [];
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return _buildMyPlansTab();
  }

  Widget _buildMyPlansTab() {
    List<Map<String, dynamic>> filteredPlans = _apiPlans.where((plan) {
      bool matchesDay = plan['day'] == _selectedDayFilter;
      bool matchesCategory = true;
      if (_selectedCategoryFilter != null) {
        // Strip emojis and get the raw text (e.g. 'Coffee')
        String filterText = _selectedCategoryFilter!.replaceAll(RegExp(r'[^\w\s]+'), '').trim().toLowerCase();
        
        String planCategory = (plan['category'] ?? '').toString().toLowerCase();
        String planTitle = (plan['title'] ?? '').toString().toLowerCase();
        
        // Match if the category name OR the title contains the filter text
        matchesCategory = planCategory.contains(filterText) || planTitle.contains(filterText);
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
                  child: _buildMyPlansFilterChip(_myPlansFilters[index], index),
                );
              }),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A)))
              : filteredPlans.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 40),
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
              );
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
    List<Map<String, dynamic>> requests = List<Map<String, dynamic>>.from(plan['requests'] ?? []);

    return Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
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
                  _buildBoostSection(),
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

  Widget _buildMyPlansFilterChip(String label, int index) {
    if (label == '|') {
      return Container(
        height: 24,
        width: 1,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
    }
    bool isDayFilter =
        label == 'Today' || label == 'Tomorrow' || label == 'Weekend';
    bool isSelected = isDayFilter
        ? _selectedDayFilter == label
        : _selectedCategoryFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isDayFilter) {
            if (_selectedDayFilter != label) {
              _selectedDayFilter = label;
              _fetchPlans(); // Fetch new plans for the selected day
            }
          } else {
            if (_selectedCategoryFilter == label) {
              _selectedCategoryFilter = null;
            } else {
              _selectedCategoryFilter = label;
            }
            _fetchPlans(); // Fetch new plans for the selected activity
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
              children: (plan['tags'] as List<dynamic>?)?.map((tag) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildSmallTag(tag.toString()),
                );
              }).toList() ?? [],
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

  Widget _buildBoostSection() {
    return DottedBorder(
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
              final result = await _showRequesterProfileBottomSheet(
                context,
                request,
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
                      final success = await DateNowApiService.declineRequest(requestId);
                      if (success) {
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
                      final success = await DateNowApiService.approveRequest(requestId);
                      if (success) {
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

Future<String?> _showRequesterProfileBottomSheet(
  BuildContext context,
  Map<String, dynamic> request,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section with Name
                Stack(
                  children: [
                    Container(
                      height: 340,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            request['avatar'].toString().replaceAll(
                              'w=200',
                              'w=800',
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay for text readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 24,
                      child: Row(
                        children: [
                          Text(
                            '${request['name']}, ${request['age']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Profile details
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check, color: Colors.blue, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFA6A85).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${request['match'] ?? '92%'} match',
                              style: const TextStyle(
                                color: Color(0xFFDE2957),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Nearby',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4EF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '“${request['message']}”',
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Coffee lover', 'Deep talker', 'Bookworm']
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      SafeArea(
                        child: request['status'] == 'approved'
                            ? GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFA6A85),
                                        Color(0xFFDE2957),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Message ${request['name']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        final requestId = request['id'] ?? 'DUMMY_ID';
                                        final success = await DateNowApiService.declineRequest(requestId);
                                        if (success) {
                                          Navigator.pop(context); // Close bottom sheet
                                          _showFeedbackSavedSnackBar(
                                            context,
                                            'Request from ${request['name']} declined',
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Decline',
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        final requestId = request['id'] ?? 'DUMMY_ID';
                                        final success = await DateNowApiService.approveRequest(requestId);
                                        if (success) {
                                          setModalState(() {
                                            request['status'] = 'approved';
                                          });
                                          if (context.mounted) {
                                            _showFeedbackSavedSnackBar(
                                              context,
                                              '${request['name']} approved. Date details sent to chat',
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFA6A85),
                                              Color(0xFFDE2957),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Approve to chat',
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
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
