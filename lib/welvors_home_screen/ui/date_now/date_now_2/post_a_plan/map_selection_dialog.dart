import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSelectionDialog extends StatefulWidget {
  const MapSelectionDialog({Key? key}) : super(key: key);

  @override
  State<MapSelectionDialog> createState() => _MapSelectionDialogState();
}

class _MapSelectionDialogState extends State<MapSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  LatLng _center = const LatLng(19.0760, 72.8777); // Default to Mumbai
  Marker? _selectedMarker;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final String _googleApiKey = 'AIzaSyCsnBSbLX4l6lf63J6lPNe2gisuw2CeQy0';

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() {
      _isSearching = true;
    });
    try {
      final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey,
        },
        body: json.encode({'input': query, 'includedRegionCodes': ['IN']}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['suggestions'] != null) {
          setState(() {
            _searchResults = data['suggestions'];
          });
        } else {
          setState(() => _searchResults = []);
        }
      } else {
        setState(() => _searchResults = []);
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    // Keep OSM Nominatim for reverse geocoding to save Google API costs/billing requirements
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json');
      final response = await http.get(url, headers: {'User-Agent': 'com.velvors.app'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null && mounted) {
          setState(() {
            _searchController.text = data['display_name'].toString().split(',').first;
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _selectLocation(Map<String, dynamic> location) async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    
    final placeId = location['placePrediction']?['placeId'];
    if (placeId == null) return;
    
    try {
      final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId?fields=location,displayName');
      final response = await http.get(url, headers: {'X-Goog-Api-Key': _googleApiKey});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['location'] != null) {
          final lat = data['location']['latitude'];
          final lon = data['location']['longitude'];
          final pos = LatLng(lat, lon);
          
          if (mounted) {
            setState(() {
              _center = pos;
              _searchController.text = data['displayName']?['text'] ?? 'Selected Location';
              _searchResults = [];
              _selectedMarker = Marker(
                point: pos,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Color(0xFFE43A6A), size: 40),
              );
            });
            _mapController.move(pos, 15.0);
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }

  List<Marker> _buildMarkers() {
    if (_selectedMarker != null) return [_selectedMarker!];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '📍 Pick on map',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // to balance the back button
                ],
              ),
            ),
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                  // Only search if user typed more than 2 chars
                  if (val.length > 2) {
                    _searchLocation(val);
                  } else {
                    setState(() => _searchResults = []);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search location on map...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE43A6A),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center, 
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                      onTap: (tapPosition, point) {
                        setState(() {
                          _searchResults = [];
                          _searchController.text = 'Loading...';
                          _selectedMarker = Marker(
                            point: point,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Color(0xFFE43A6A), size: 40),
                          );
                        });
                        _reverseGeocode(point);
                      },
                    ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.velvors.app',
                  ),
                  MarkerLayer(markers: _buildMarkers()),
                ],
              ),
              if (_isSearching)
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                      ),
                    ),
                  if (_searchResults.isNotEmpty)
                    Positioned(
                      top: 0,
                      left: 16,
                      right: 16,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              return InkWell(
                                onTap: () {
                                  try {
                                    _selectLocation(item);
                                  } catch (e) {
                                    print("Error selecting location: $e");
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['placePrediction']?['text']?['text']?.toString() ?? 'Unknown',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: 'zoomIn',
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(_mapController.camera.center, currentZoom + 1);
                          },
                          child: const Icon(Icons.add, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'zoomOut',
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(_mapController.camera.center, currentZoom - 1);
                          },
                          child: const Icon(Icons.remove, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Action
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 20,
              ),
              color: Colors.white,
              child: GestureDetector(
                onTap: _searchController.text.isNotEmpty
                    ? () {
                        Navigator.pop(context, _searchController.text);
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _searchController.text.isNotEmpty
                        ? const Color(0xFFE43A6A)
                        : const Color(0xFFF2EFEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Confirm Location',
                      style: TextStyle(
                        color: _searchController.text.isNotEmpty
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
