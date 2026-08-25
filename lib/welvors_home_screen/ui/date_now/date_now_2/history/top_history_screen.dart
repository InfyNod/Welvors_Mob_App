import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../date_api_service/date_now_api_service.dart';
import 'card_history.dart';

class TopHistoryScreen extends StatefulWidget {
  const TopHistoryScreen({super.key});

  @override
  State<TopHistoryScreen> createState() => _TopHistoryScreenState();
}

class _TopHistoryScreenState extends State<TopHistoryScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  int _selectedFilterIndex = 0;

  List<Map<String, dynamic>> _thisWeekPlans = [];
  List<Map<String, dynamic>> _earlierPlans = [];
  bool _isLoading = true;
  int _totalViews = 0;
  int _totalRequests = 0;
  int _totalMet = 0;

  List<String> get _filters {
    final allPlans = [
      ..._thisWeekPlans,
      ..._earlierPlans,
    ];
    final metCount = allPlans.where((p) => p['status'] == 'MET').length;
    final expiredCount = allPlans.where((p) => p['status'] == 'EXPIRED').length;
    final noShowCount = allPlans.where((p) => p['status'] == 'NO-SHOW').length;
    final cancelledCount = allPlans.where((p) => p['status'] == 'CANCELLED').length;
    final activeCount = allPlans.where((p) => p['status'] == 'ACTIVE').length;
    final bookedCount = allPlans.where((p) => p['status'] == 'BOOKED').length;
    
    return [
      'All ${allPlans.length}',
      'Active $activeCount',
      'Booked $bookedCount',
      'Met $metCount',
      'Expired $expiredCount',
      'No-show $noShowCount',
      'Cancelled $cancelledCount',
    ];
  }

  late final List<GlobalKey> _filterKeys;
  late final AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(7, (index) => GlobalKey());
    _fetchHistoryData();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistoryData() async {
    final response = await DateNowApiService.getHistoryPlans(page: 1, limit: 100);
    if (response != null && response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      
      final DateTime now = DateTime.now();
      final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

      List<Map<String, dynamic>> thisWeek = [];
      List<Map<String, dynamic>> earlier = [];
      
      int views = 0;
      int reqs = 0;
      int met = 0;

      for (var item in data) {
        // Parse date
        DateTime eventDate = DateTime.now();
        if (item['eventDateTime'] != null) {
          eventDate = DateTime.parse(item['eventDateTime']);
        }
        
        String formattedDate = DateFormat('EEE, d MMM · h:mm a').format(eventDate);
        
        // Calculate duration end time if needed, though simple format is fine
        final duration = item['duration'] ?? 120;
        final endTime = eventDate.add(Duration(minutes: duration));
        formattedDate += ' – ${DateFormat('h:mm a').format(endTime)}';

        // Extract required fields
        final title = item['quickTitle']?['label'] ?? item['title'] ?? 'Date Plan';
        final location = '${item['venue']?['name'] ?? ''} · ${item['venue']?['address'] ?? ''}';
        final image = item['activity']?['icon'] ?? 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
        final status = item['statusLabel']?.toString().toUpperCase() ?? item['status']?.toString().toUpperCase() ?? 'EXPIRED';
        final note = item['message'] ?? '';
        final requestsCount = item['requests']?['total'] ?? 0;
        final split = item['whoPays']?['label'] ?? 'Split';
        final rating = item['review']?['rating'] ?? 0;
        
        final partnerName = item['participant']?['name'];
        final partnerAvatar = item['participant']?['photoUrl'];

        reqs += requestsCount as int;
        if (status == 'MET') met++;
        
        // We will just mock views as random for now or 0
        final itemViews = (item['views'] ?? 10) as int;
        views += itemViews;

        final mappedItem = {
          'id': item['_id'] ?? item['id'],
          'title': title,
          'date': formattedDate,
          'location': location,
          'image': image,
          'status': status,
          'note': note,
          'requests': requestsCount,
          'split': split,
          'views': itemViews,
          'rating': rating,
        };
        
        if (partnerName != null) {
          mappedItem['partnerName'] = partnerName;
          mappedItem['partnerAvatar'] = partnerAvatar;
          mappedItem['partnerStatus'] = 'Matched';
        }

        if (eventDate.isAfter(sevenDaysAgo)) {
          thisWeek.add(mappedItem);
        } else {
          earlier.add(mappedItem);
        }
      }

      if (mounted) {
        setState(() {
          _thisWeekPlans = thisWeek;
          _earlierPlans = earlier;
          _totalViews = views;
          _totalRequests = reqs;
          _totalMet = met;
          _isLoading = false;
          
          double progress = 0.0;
          int total = thisWeek.length + earlier.length;
          if (total > 0) {
            progress = met / total;
          }
          
          _progressAnimation = Tween<double>(begin: 0.0, end: progress).animate(
            CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
          );
          _progressController.forward(from: 0.0);
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
    super.build(context);
    if (_isLoading) {
      return Container(
        color: const Color(0xFFFAFAFA),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.pink),
        ),
      );
    }
    
    return Container(
      color: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Match the off-white background from image
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCard(),
            const SizedBox(height: 6),
            _buildFilters(),
            const SizedBox(height: 20),
            CardHistory(
              selectedFilter: _filters[_selectedFilterIndex].split(' ')[0],
              plansThisWeek: _thisWeekPlans,
              plansEarlier: _earlierPlans,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF4EDFE), // Left
              Color(0xFFF7EFF5), // Right
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8D4F0), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_thisWeekPlans.length + _earlierPlans.length} plans hosted',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1E24), // Darker text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalMet turned into a real meeting',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Circular Progress
            SizedBox(
              width: 48,
              height: 48,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white,
                        color: const Color(0xFFE43A6A), // Pink
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE43A6A),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;

          // Split the text into word and number
          final parts = _filters[index].split(' ');
          final word = parts[0];
          final number = parts.length > 1 ? parts[1] : '';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });

                // Animate to center
                Scrollable.ensureVisible(
                  _filterKeys[index].currentContext!,
                  alignment: 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                key: _filterKeys[index],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E1E24) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E1E24)
                        : Colors.grey.shade300,
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: word,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E1E24),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (number.isNotEmpty)
                        TextSpan(
                          text: ' $number',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
