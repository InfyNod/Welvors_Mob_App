import 'package:flutter/material.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All',
    '✓ Confirmed',
    'Cancelled',
    'Mixers',
    'Speed Dating',
    'This Month',
  ];
  late final List<GlobalKey> _filterKeys;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allTickets = [
    {
      'title': 'Sunset Soirée for Singles',
      'date': 'Sat, Oct 12 · 7:00 PM',
      'location': 'The Rooftop Lounge, Bandra',
      'imageUrl':
          'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
      'status': 'Confirmed',
      'categories': ['Mixers', 'This Month'],
    },
    {
      'title': 'Speed Dating: Creative Professionals',
      'date': 'Sat, Oct 28 · 6:30 PM',
      'location': 'Artisan Loft, Lower Parel',
      'imageUrl':
          'https://images.unsplash.com/photo-1519340333755-56e9c1d04579?auto=format&fit=crop&w=800&q=80',
      'status': 'Confirmed',
      'categories': ['Speed Dating', 'This Month'],
    },
    {
      'title': 'Acoustic Night & Cocktails',
      'date': 'Fri, Nov 3 · 8:00 PM',
      'location': 'The Velvet Room, Juhu',
      'imageUrl':
          'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80',
      'status': 'Cancelled',
      'categories': ['Mixers'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filterKeys = List.generate(_filters.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Slightly off-white background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
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
        ),
        title: _isSearching
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              )
            : const Text(
                'My Ticket',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 40,
                height: 40,
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
                child: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    key: _filterKeys[index],
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                      final itemContext = _filterKeys[index].currentContext;
                      if (itemContext != null) {
                        Scrollable.ensureVisible(
                          itemContext,
                          alignment: 0.5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                              ? const Color(0xFFE85A7A)
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
            const SizedBox(height: 20),

            // Tickets List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ..._allTickets
                      .where((ticket) {
                        // Search Filter
                        if (_searchQuery.isNotEmpty &&
                            !ticket['title'].toString().toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            )) {
                          return false;
                        }

                        // Category Filter
                        final selectedFilter = _filters[_selectedFilterIndex];
                        if (selectedFilter == 'All') return true;
                        if (selectedFilter == '✓ Confirmed')
                          return ticket['status'] == 'Confirmed';
                        if (selectedFilter == 'Cancelled')
                          return ticket['status'] == 'Cancelled';

                        final categories = ticket['categories'] as List<String>;
                        return categories.contains(selectedFilter);
                      })
                      .map((ticket) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTicketCard(
                            title: ticket['title'] as String,
                            date: ticket['date'] as String,
                            location: ticket['location'] as String,
                            imageUrl: ticket['imageUrl'] as String,
                            status: ticket['status'] as String,
                          ),
                        );
                      }),
                  // Show empty message if nothing matches
                  if (_allTickets.where((ticket) {
                    if (_searchQuery.isNotEmpty &&
                        !ticket['title'].toString().toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ))
                      return false;
                    final selectedFilter = _filters[_selectedFilterIndex];
                    if (selectedFilter == 'All') return true;
                    if (selectedFilter == '✓ Confirmed')
                      return ticket['status'] == 'Confirmed';
                    if (selectedFilter == 'Cancelled')
                      return ticket['status'] == 'Cancelled';
                    return (ticket['categories'] as List<String>).contains(
                      selectedFilter,
                    );
                  }).isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        "No tickets found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom Text
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  children: [
                    TextSpan(text: 'Looking for more events? Check '),
                    TextSpan(
                      text: 'Upcoming.',
                      style: TextStyle(
                        color: Color(0xFFE85A7A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String title,
    required String date,
    required String location,
    required String imageUrl,
    required String status,
  }) {
    final bool isCancelled = status == 'Cancelled';

    return Opacity(
      opacity: isCancelled ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (status == 'Confirmed')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 44, 175, 107),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CONFIRMED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (status == 'Cancelled')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CANCELLED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        // View Details Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isCancelled ? Colors.grey.shade400 : const Color(0xFFE85A7A),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              color: isCancelled ? Colors.grey.shade500 : const Color(0xFFE85A7A),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Ticket Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isCancelled
                                ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                                : const LinearGradient(
                                    colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (isCancelled ? Colors.grey : const Color(0xFFE85A7A)).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.confirmation_num,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Ticket',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
