import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'events_bloc/events_bloc.dart';
import 'events_bloc/events_event.dart';
import 'events_bloc/events_state.dart';
import 'all_screen/events_cards.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventsBloc(),
      child: const _EventsScreenView(),
    );
  }
}

class _EventsScreenView extends StatefulWidget {
  const _EventsScreenView();

  @override
  State<_EventsScreenView> createState() => _EventsScreenViewState();
}

class _EventsScreenViewState extends State<_EventsScreenView> {
  final List<Map<String, String>> _categories = const [
    {'icon': '✨', 'name': 'All'},
    {'icon': '🍸', 'name': 'Mixers'},
    {'icon': '💘', 'name': 'Speed\nDating'},
    {'icon': '🎶', 'name': 'Parties'},
    {'icon': '🍽', 'name': 'Dining'},
    {'icon': '🎳', 'name': 'Activities'},
    {'icon': '🥾', 'name': 'Trekking'},
  ];

  final List<String> _filters = const [
    'Today',
    'This Weekend',
    'Free events',
    'This Month',
  ];

  final ScrollController _categoryScrollController = ScrollController();
  late final List<GlobalKey> _filterKeys;

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(int index) {
    if (!_categoryScrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    // item width is 72 + 8 margin = 80. ListView padding is 12.
    final itemCenter = 12.0 + (index * 80.0) + 40.0;
    final targetOffset = itemCenter - (screenWidth / 2);

    _categoryScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _categoryScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToFilterCenter(int index) {
    final context = _filterKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header: Location & My Ticket
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFFE85A7A),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Mumbai',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                    // My Ticket Button
                    Container(
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search comedy, mixers, parties...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE85A7A,
                                    ).withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Title
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "What's hot in Mumbai",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // Categories
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyCategoriesDelegate(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 80,
                                child: BlocBuilder<EventsBloc, EventsState>(
                                  buildWhen: (previous, current) =>
                                      previous.selectedCategoryIndex !=
                                      current.selectedCategoryIndex,
                                  builder: (context, state) {
                                    return ListView.builder(
                                      controller: _categoryScrollController,
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      itemCount: _categories.length,
                                      itemBuilder: (context, index) {
                                        final isSelected =
                                            state.selectedCategoryIndex ==
                                            index;
                                        final category = _categories[index];
                                        return GestureDetector(
                                          onTap: () {
                                            context.read<EventsBloc>().add(
                                              SelectCategoryEvent(index),
                                            );
                                            _scrollToCenter(index);
                                          },
                                          child: Container(
                                            width: 64,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                    border: isSelected
                                                        ? Border.all(
                                                            color: const Color(
                                                              0xFFE85A7A,
                                                            ),
                                                            width: 1.5,
                                                          )
                                                        : Border.all(
                                                            color: Colors
                                                                .grey
                                                                .shade300,
                                                            width: 1,
                                                          ),
                                                    boxShadow: [
                                                      if (isSelected)
                                                        BoxShadow(
                                                          color: const Color(
                                                            0xFFE85A7A,
                                                          ).withOpacity(0.25),
                                                          blurRadius: 10,
                                                          spreadRadius: 1,
                                                          offset: const Offset(0, 4),
                                                        )
                                                      else
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.04),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                    ],
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    category['icon']!,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  category['name']!,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w600,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFFE85A7A,
                                                          )
                                                        : Colors.grey.shade800,
                                                    height: 1.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Filters
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 36,
                            child: BlocBuilder<EventsBloc, EventsState>(
                              buildWhen: (previous, current) =>
                                  previous.selectedFilterIndex !=
                                  current.selectedFilterIndex,
                              builder: (context, state) {
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: _filters.length,
                                  itemBuilder: (context, index) {
                                    final isSelected =
                                        state.selectedFilterIndex == index;
                                    return GestureDetector(
                                      key: _filterKeys[index],
                                      onTap: () {
                                        context.read<EventsBloc>().add(
                                          SelectFilterEvent(index),
                                        );
                                        _scrollToFilterCenter(index);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFE85A7A)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Event Cards
                          const EventsCards(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyCategoriesDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyCategoriesDelegate({required this.child});

  @override
  double get minExtent => 92.0;

  @override
  double get maxExtent => 92.0;

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
