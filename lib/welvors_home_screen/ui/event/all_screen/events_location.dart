import 'package:flutter/material.dart';

class EventsLocationSheet extends StatefulWidget {
  final String initialCity;
  final Function(String) onCitySelected;

  const EventsLocationSheet({
    super.key,
    required this.initialCity,
    required this.onCitySelected,
  });

  @override
  State<EventsLocationSheet> createState() => _EventsLocationSheetState();
}

class _EventsLocationSheetState extends State<EventsLocationSheet> {
  late String _selectedCity;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allCities = [
    {'name': 'Mumbai', 'events': '42 events this week'},
    {'name': 'Pune', 'events': '28 events this week'},
    {'name': 'Delhi NCR', 'events': '36 events this week'},
    {'name': 'Bengaluru', 'events': '31 events this week'},
    {'name': 'Hyderabad', 'events': '19 events this week'},
    {'name': 'Chennai', 'events': '14 events this week'},
    {'name': 'Kolkata', 'events': '11 events this week'},
    {'name': 'Ahmedabad', 'events': '9 events this week'},
    {'name': 'Jaipur', 'events': '7 events this week'},
    {'name': 'Chandigarh', 'events': '6 events this week'},
    {'name': 'Goa', 'events': '12 events this week'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCities = _allCities
        .where((city) =>
            city['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose your city',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Events are shown for the city you pick.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFFE85A7A).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cities List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 40),
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final isSelected = city['name'] == _selectedCity;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCity = city['name'];
                    });
                    widget.onCitySelected(city['name']);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFEEF2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFFFEEF2), // Light pink circle for all unselected icons too, per design? Wait, screenshot shows light pink for unselected too. Let's make it fixed light pink for the icon bg.
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFFE85A7A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                city['events'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Color(0xFFE85A7A),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
