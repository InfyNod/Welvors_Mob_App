import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';

class LocationScreen extends StatefulWidget {
  final VoidCallback onNext;
  const LocationScreen({super.key, required this.onNext});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _useCurrentLocation = false;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(19.0760, 72.8777); // Default Mumbai
  
  double? _lat;
  double? _lng;
  String? _city;
  String? _state;
  String? _country;

  @override
  void initState() {
    super.initState();
    // Initially try to get location if toggled on, but we default to false to not spam permissions immediately.
  }

  @override
  void dispose() {
    _cityController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _cityController.text = 'Fetching...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      } 

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final latLng = LatLng(position.latitude, position.longitude);
      
      // Update Map
      _mapCenter = latLng;
      _mapController.move(latLng, 13.0);

      // Reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Unknown City';
        String state = place.administrativeArea ?? 'Unknown State';
        String country = place.country ?? 'Unknown Country';
        
        setState(() {
          _cityController.text = '$city, $country';
          _lat = position.latitude;
          _lng = position.longitude;
          _city = city;
          _state = state;
          _country = country;
        });
      } else {
        setState(() {
          _cityController.text = 'Location found';
          _lat = position.latitude;
          _lng = position.longitude;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _cityController.text = '';
        _useCurrentLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Widget _buildRealMap() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.velvors',
                ),
              ],
            ),
            
            // Map Pin Overlay
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pinkDeep.withOpacity(0.2),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.pinkDeep,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Badge Overlay
            Positioned(
              bottom: 16,
              left: 16,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.line.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.pinkDeep,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '240+ verified people near you',
                        style: AppText.body.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEARBY',
                            style: AppText.eyebrow.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Where are you based?',
                            style: AppText.display.copyWith(fontSize: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We use this to show you people in your city.\nOnly your city is ever shown — never your\nexact location.',
                            style: AppText.sub.copyWith(
                              color: AppColors.ink60,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'City',
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cityController,
                            cursorColor: AppColors.pinkDeep,
                            style: AppText.body.copyWith(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Your city',
                              hintStyle: AppText.body.copyWith(
                                color: AppColors.muted,
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.pinkDeep),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildRealMap(),
                          
                          const SizedBox(height: 24),
                          
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Use my current location',
                                        style: AppText.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Keep your city up to date automatically',
                                        style: AppText.body.copyWith(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _isLoadingLocation
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pinkDeep),
                                        ),
                                      )
                                    : CupertinoSwitch(
                                        value: _useCurrentLocation,
                                        activeColor: CupertinoColors.activeGreen,
                                        onChanged: (val) {
                                          setState(() {
                                            _useCurrentLocation = val;
                                          });
                                          if (val) {
                                            _fetchLocation();
                                          } else {
                                            _cityController.clear();
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.pad, 16, AppDimens.pad, 20),
                    child: PrimaryButton(
                      'Continue',
                      isLoading: _isSubmitting,
                      onTap: ((_cityController.text.trim().isEmpty && !_useCurrentLocation) || _isSubmitting)
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();

                              setState(() => _isSubmitting = true);

                              if (!_useCurrentLocation && _cityController.text.isNotEmpty) {
                                try {
                                  List<Location> locations = await locationFromAddress(_cityController.text);
                                  if (locations.isNotEmpty) {
                                    _lat = locations[0].latitude;
                                    _lng = locations[0].longitude;
                                    List<Placemark> placemarks = await placemarkFromCoordinates(_lat!, _lng!);
                                    if (placemarks.isNotEmpty) {
                                      Placemark p = placemarks[0];
                                      _city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? _cityController.text;
                                      _state = p.administrativeArea ?? 'Unknown';
                                      _country = p.country ?? 'Unknown';
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('Manual geocode failed: $e');
                                }
                              }
                              
                              if (_lat == null || _lng == null) {
                                setState(() => _isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a valid location.')),
                                );
                                return;
                              }

                              userData.location = '$_city, $_state';
                              userData.locationAuto = _useCurrentLocation ? 'Auto' : 'Manual';

                              // Simulate API delay
                              await Future.delayed(const Duration(seconds: 1));

                              if (mounted) {
                                setState(() => _isSubmitting = false);
                                widget.onNext();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}