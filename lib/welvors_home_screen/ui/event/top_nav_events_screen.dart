import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'events_bloc/events_bloc.dart';
import 'events_bloc/events_event.dart';
import 'events_bloc/events_state.dart';
import 'all_screen/events_cards.dart';
import 'all_screen/events_location.dart';
import 'all_screen/my_ticket.dart';
import 'filter_events.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EventsScreenView();
  }
}

class _EventsScreenView extends StatefulWidget {
  const _EventsScreenView();

  @override
  State<_EventsScreenView> createState() => _EventsScreenViewState();
}

class _EventsScreenViewState extends State<_EventsScreenView> {
  final List<Map<String, String>> _categories = const [
    {
      'name': 'All events',
      'image': 'assets/photo_event/all_events.jpeg',
      'color': '0xFFFFEFF4',
    },
    {
      'name': 'Singles\nMixer',
      'image': 'assets/photo_event/singles_mixer.jpeg',
      'color': '0xFFFFF5E6',
    },
    {
      'name': 'Speed\nDates',
      'image': 'assets/photo_event/speed_dates.jpeg',
      'color': '0xFFE6F3FF',
    },
    {
      'name': 'Singles\nNight',
      'image': 'assets/photo_event/singles_night.jpeg',
      'color': '0xFFF0FFF0',
    },
    {
      'name': 'Dinner\nDates',
      'image': 'assets/photo_event/dinner_date.jpeg',
      'color': '0xFFFFF0F5',
    },
    {
      'name': 'Activity\nDate',
      'image': 'assets/photo_event/activity_date.jpeg',
      'color': '0xFFFDF5E6',
    },
    {
      'name': 'Play &\nMatch',
      'image': 'assets/photo_event/play_match.jpeg',
      'color': '0xFFF5FFFA',
    },
    {
      'name': 'Travel\nDating',
      'image': 'assets/photo_event/travel_date.jpeg',
      'color': '0xFFF8F8FF',
    },
    {
      'name': 'Trek\nDates',
      'image':
          'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=500&q=80',
      'color': '0xFFFFF5EE',
    },
    {
      'name': 'The\nReserve',
      'image':
          'https://images.unsplash.com/photo-1560624052-449f5ddf0c31?auto=format&fit=crop&w=500&q=80',
      'color': '0xFFF0F8FF',
    },
    {
      'name': 'Professionals\nMeet',
      'image':
          'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=500&q=80',
      'color': '0xFFE0FFFF',
    },
    {
      'name': 'Matched\nfor You',
      'image':
          'https://cdn0.hitched.co.uk/article/6290/3_2/1280/jpg/100926-signs-youve-found-the-one.jpeg',
      'color': '0xFFFFF8DC',
    },
  ];

  final List<String> _filters = const [
    'Today',
    'This Weekend',
    'This Month',
    'Free events',
  ];
  late final List<GlobalKey> _filterKeys;
  String _currentCity = 'Mumbai';

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    super.dispose();
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
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EventsLocationSheet(
                            initialCity: _currentCity,
                            onCitySelected: (city) {
                              setState(() {
                                _currentCity = city;
                              });
                            },
                          ),
                        );
                      },
                      child: Container(
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
                            Text(
                              _currentCity,
                              style: const TextStyle(
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
                              onChanged: (value) {
                                context.read<EventsBloc>().add(
                                  SearchQueryEvent(value),
                                );
                              },
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

                    // Categories (New 2-Row Horizontal Scroll Grid)
                    SliverToBoxAdapter(
                      child: BlocBuilder<EventsBloc, EventsState>(
                        buildWhen: (previous, current) =>
                            previous.selectedCategoryIndex !=
                            current.selectedCategoryIndex,
                        builder: (context, state) {
                          return SizedBox(
                            height: 160,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    mainAxisExtent: 160,
                                  ),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final isSelected =
                                    state.selectedCategoryIndex == index;
                                final category = _categories[index];
                                return GestureDetector(
                                  onTap: () {
                                    if (index == 0) {
                                      context.read<EventsBloc>().add(
                                        SelectCategoryEvent(index),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FilterEventsScreen(
                                                category: category,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(
                                        int.parse(category['color']!),
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? Border.all(
                                              color: const Color(0xFFE85A7A),
                                              width: 1.5,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12,
                                              right: 4,
                                            ),
                                            child: Text(
                                              category['name']!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? const Color(0xFFE85A7A)
                                                    : Colors.black87,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(
                                                    14.5,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    14.5,
                                                  ),
                                                ),
                                            child:
                                                category['image']!.startsWith(
                                                  'http',
                                                )
                                                ? Image.network(
                                                    category['image']!,
                                                    fit: BoxFit.cover,
                                                    height: double.infinity,
                                                  )
                                                : Image.asset(
                                                    category['image']!,
                                                    fit: BoxFit.cover,
                                                    height: double.infinity,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 15)),

                    // Filters
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TopNavStickyFiltersDelegate(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(top: 0, bottom: 8),
                          child: SizedBox(
                            height: 34,
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
                                          vertical: 6,
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
                        ),
                      ),
                    ),

                    // Event Cards
                    const SliverToBoxAdapter(child: EventsCards()),
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

class _TopNavStickyFiltersDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TopNavStickyFiltersDelegate({required this.child});

  @override
  double get minExtent => 42.0;

  @override
  double get maxExtent => 42.0;

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
