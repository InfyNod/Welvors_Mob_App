import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class CityItem {
  final String name;
  final String stateName;
  final bool isPopular;
  final bool isAllCities;

  const CityItem({
    required this.name,
    required this.stateName,
    this.isPopular = false,
    this.isAllCities = false,
  });
}

/// Dynamic city service that loads all Indian cities and states dynamically using country_state_city package.
class DynamicCityService {
  static List<CityItem>? _cachedCities;

  static const Set<String> _popularCityNames = {
    'mumbai',
    'pune',
    'delhi',
    'new delhi',
    'delhi ncr',
    'bengaluru',
    'bangalore',
    'hyderabad',
    'chennai',
    'kolkata',
    'ahmedabad',
    'jaipur',
    'chandigarh',
    'goa',
    'indore',
    'lucknow',
    'kochi',
    'surat',
    'nagpur',
    'bhopal',
    'patna',
    'vadodara',
    'nashik',
  };

  static Future<List<CityItem>> getCities() async {
    if (_cachedCities != null) return _cachedCities!;

    try {
      final states = await csc.getStatesOfCountry('IN');
      final stateMap = {for (var s in states) s.isoCode: s.name};
      final rawCities = await csc.getCountryCities('IN');

      final List<CityItem> list = [
        const CityItem(
          name: 'All Cities',
          stateName: 'Explore events across all cities & states',
          isAllCities: true,
          isPopular: true,
        ),
      ];

      final Set<String> seenNames = {'all cities'};
      for (final c in rawCities) {
        final trimmedName = c.name.trim();
        if (trimmedName.isEmpty) continue;
        final lower = trimmedName.toLowerCase();
        if (seenNames.contains(lower)) continue;
        seenNames.add(lower);

        final stateName = stateMap[c.stateCode] ?? c.stateCode;
        final isPopular = _popularCityNames.contains(lower);

        list.add(
          CityItem(
            name: trimmedName,
            stateName: stateName,
            isPopular: isPopular,
          ),
        );
      }

      // Sort: All Cities first, then popular cities, then alphabetically
      list.sort((a, b) {
        if (a.isAllCities) return -1;
        if (b.isAllCities) return 1;
        if (a.isPopular && !b.isPopular) return -1;
        if (!a.isPopular && b.isPopular) return 1;
        return a.name.compareTo(b.name);
      });

      _cachedCities = list;
      return list;
    } catch (_) {
      return [
        const CityItem(
          name: 'All Cities',
          stateName: 'Explore events across all cities',
          isAllCities: true,
          isPopular: true,
        ),
        const CityItem(
          name: 'Mumbai',
          stateName: 'Maharashtra',
          isPopular: true,
        ),
        const CityItem(
          name: 'Pune',
          stateName: 'Maharashtra',
          isPopular: true,
        ),
      ];
    }
  }
}

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<CityItem> _cities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _loadDynamicCities();
  }

  Future<void> _loadDynamicCities() async {
    final cities = await DynamicCityService.getCities();
    if (mounted) {
      setState(() {
        _cities = cities;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelect(String cityName) {
    setState(() {
      _selectedCity = cityName;
    });
    widget.onCitySelected(cityName);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

    final filteredCities = _cities.where((city) {
      if (query.isEmpty) return true;
      return city.name.toLowerCase().contains(query) ||
          city.stateName.toLowerCase().contains(query);
    }).toList();

    final hasExactMatch = _cities.any((c) => c.name.toLowerCase() == query);
    final showCustomCityOption = query.isNotEmpty && !hasExactMatch;

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
              'Search any city or state across India.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search city or state...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade500,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
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
          const SizedBox(height: 12),

          // Cities List / Loading
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE85A7A),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 4,
                      bottom: 40,
                    ),
                    itemCount: filteredCities.length + (showCustomCityOption ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (showCustomCityOption && index == 0) {
                        return _buildCustomCityCard(_searchQuery.trim());
                      }
                      final cityIndex = showCustomCityOption ? index - 1 : index;
                      final city = filteredCities[cityIndex];
                      return _buildCityItem(city);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCityCard(String customCity) {
    final isSelected = customCity.toLowerCase() == _selectedCity.toLowerCase();
    return GestureDetector(
      onTap: () => _onSelect(customCity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFEEF2) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE85A7A).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEF2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_location_alt_outlined,
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
                    'Select "$customCity"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE85A7A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Use custom city name',
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
  }

  Widget _buildCityItem(CityItem city) {
    final isSelected = city.name.toLowerCase() == _selectedCity.toLowerCase();

    return GestureDetector(
      onTap: () => _onSelect(city.name),
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
                color: city.isAllCities
                    ? const Color(0xFFEDE7F6)
                    : const Color(0xFFFFEEF2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                city.isAllCities
                    ? Icons.public
                    : Icons.location_on_outlined,
                color: city.isAllCities
                    ? const Color(0xFF7E57C2)
                    : const Color(0xFFE85A7A),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          city.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (city.isPopular && !city.isAllCities) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEF2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE85A7A),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    city.stateName,
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
  }
}
