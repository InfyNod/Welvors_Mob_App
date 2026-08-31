import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/events_cards.dart';
import 'package:velvors/welvors_home_screen/ui/event/all_screen/my_ticket.dart';

class FilterEventsScreen extends StatefulWidget {
  final Map<String, String> category;

  const FilterEventsScreen({super.key, required this.category});

  @override
  State<FilterEventsScreen> createState() => _FilterEventsScreenState();
}

class _FilterEventsScreenState extends State<FilterEventsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'Today',
    'This Weekend',
    'This Month',
    'Free events',
  ];

  late final ScrollController _filterScrollController;
  late final List<GlobalKey> _filterKeys;

  @override
  void initState() {
    super.initState();
    _filterScrollController = ScrollController();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(int index) {
    if (!_filterScrollController.hasClients) return;

    final context = _filterKeys[index].currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final itemCenter = box.localToGlobal(box.size.center(Offset.zero)).dx;

      final screenWidth = MediaQuery.of(this.context).size.width;
      final currentScroll = _filterScrollController.offset;

      final targetOffset = currentScroll + (itemCenter - (screenWidth / 2));

      _filterScrollController.animateTo(
        targetOffset.clamp(
          0.0,
          _filterScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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

                  // My Ticket Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTicketScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.confirmation_num_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'My Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Hero Banner
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (widget.category['image'] ?? '').startsWith('http')
                              ? NetworkImage(widget.category['image'] ?? '') as ImageProvider
                              : AssetImage(widget.category['image'] ?? '') as ImageProvider,
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
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.9),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category['name']?.replaceAll('\n', ' ') ??
                                  'Events',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.category['subtitle'] ??
                                  'Music, dancing and late nights in Mumbai',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Spacing below the image
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Sticky Filters
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyFiltersDelegate(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 34,
                          child: ListView.builder(
                            controller: _filterScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedFilterIndex == index;
                              return GestureDetector(
                                key: _filterKeys[index],
                                onTap: () {
                                  setState(() {
                                    _selectedFilterIndex = index;
                                  });
                                  _scrollToCenter(index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE85A7A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE85A7A)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _filters[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Event Cards (List of events)
                  const SliverToBoxAdapter(child: EventsCards()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyFiltersDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFiltersDelegate({required this.child});

  @override
  double get minExtent => 50.0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
