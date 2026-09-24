import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String label;
  final String address;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.address,
  });
}

class LocationMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String label;
  final bool pickMode;

  const LocationMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label = 'Location',
    this.pickMode = false,
  });

  static Future<LocationPickerResult?> pick({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String label = 'Current Location',
  }) {
    return Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationMapScreen(
          latitude: latitude,
          longitude: longitude,
          label: label,
          pickMode: true,
        ),
      ),
    );
  }

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late LatLng _selected;

  GoogleMapController? _controller;

  String _selectedLabel = '';
  String _selectedAddress = '';

  bool _loadingCurrentLocation = false;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();

    _selected = LatLng(widget.latitude, widget.longitude);

    _selectedLabel = widget.label.trim().isEmpty ? 'Location' : widget.label;

    // Get address for initial location
    if (widget.pickMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getAddress(_selected);
      });
    }
  }

  // ==========================================================
  // GET ADDRESS FROM LATITUDE / LONGITUDE
  // ==========================================================

  Future<void> _getAddress(LatLng location) async {
    if (!mounted) return;

    setState(() {
      _loadingAddress = true;
    });

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final List<String> parts = [];

        // Building / place name
        if ((place.name ?? '').trim().isNotEmpty) {
          parts.add(place.name!.trim());
        }

        // Street
        if ((place.street ?? '').trim().isNotEmpty &&
            place.street!.trim() != place.name?.trim()) {
          parts.add(place.street!.trim());
        }

        // Area
        if ((place.subLocality ?? '').trim().isNotEmpty) {
          parts.add(place.subLocality!.trim());
        }

        // City
        if ((place.locality ?? '').trim().isNotEmpty) {
          parts.add(place.locality!.trim());
        }

        // State
        if ((place.administrativeArea ?? '').trim().isNotEmpty) {
          parts.add(place.administrativeArea!.trim());
        }

        // Postal code
        if ((place.postalCode ?? '').trim().isNotEmpty) {
          parts.add(place.postalCode!.trim());
        }

        // Country
        if ((place.country ?? '').trim().isNotEmpty) {
          parts.add(place.country!.trim());
        }

        if (mounted) {
          setState(() {
            _selectedAddress = parts.join(', ');
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedAddress = 'Address not available';
          });
        }
      }
    } catch (e) {
      AppLogger.e('LocationMapScreen', '❌ Reverse geocoding error: $e');

      if (mounted) {
        setState(() {
          _selectedAddress = 'Address not available';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingAddress = false;
        });
      }
    }
  }

  // ==========================================================
  // USE CURRENT LOCATION
  // ==========================================================

  Future<void> _useCurrentLocation() async {
    if (_loadingCurrentLocation) return;

    setState(() {
      _loadingCurrentLocation = true;
    });

    try {
      // Check location service
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services.')),
          );
        }

        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permission denied
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }

        return;
      }

      // Permanently denied
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission permanently denied. Please enable it from Settings.',
              ),
            ),
          );
        }

        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _selected = currentLocation;
        _selectedLabel = 'Current Location';
        _selectedAddress = '';
      });

      // Move map
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 16),
        ),
      );

      // Get address
      await _getAddress(currentLocation);
    } catch (e) {
      AppLogger.e('LocationMapScreen', '❌ Current location error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to get current location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingCurrentLocation = false;
        });
      }
    }
  }

  // ==========================================================
  // MARKERS
  // ==========================================================

  Set<Marker> get _markers {
    return {
      Marker(
        markerId: const MarkerId('chat_location'),

        position: _selected,

        // User can drag marker in pick mode
        draggable: widget.pickMode,

        onDragEnd: widget.pickMode
            ? (LatLng value) async {
                setState(() {
                  _selected = value;
                  _selectedLabel = 'Selected Location';
                  _selectedAddress = '';
                });

                // Fetch new address
                await _getAddress(value);
              }
            : null,

        infoWindow: InfoWindow(
          title: _selectedLabel,
          snippet: _selectedAddress,
        ),
      ),
    };
  }

  // ==========================================================
  // RECENTER
  // ==========================================================

  void _recenter() {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _selected, zoom: 16),
      ),
    );
  }

  // ==========================================================
  // SELECT LOCATION FROM MAP
  // ==========================================================

  Future<void> _selectMapLocation(LatLng value) async {
    setState(() {
      _selected = value;
      _selectedLabel = 'Selected Location';
      _selectedAddress = '';
    });

    // Get address
    await _getAddress(value);
  }

  // ==========================================================
  // SEND LOCATION
  // ==========================================================

  void _sendLocation() {
    if (_loadingAddress) {
      return;
    }

    Navigator.pop(
      context,
      LocationPickerResult(
        latitude: _selected.latitude,
        longitude: _selected.longitude,
        label: _selectedLabel,
        address: _selectedAddress,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: Text(
          widget.pickMode ? 'Choose Location' : 'Location',

          style: AppText.h2,
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: Stack(
        children: [
          // ====================================================
          // GOOGLE MAP
          // ====================================================
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 16),

            // Blue current-location dot
            myLocationEnabled: widget.pickMode,

            // We use our own location button
            myLocationButtonEnabled: false,

            zoomControlsEnabled: false,

            compassEnabled: true,

            mapToolbarEnabled: false,

            markers: _markers,

            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },

            // Tap anywhere on map
            onTap: widget.pickMode ? _selectMapLocation : null,
          ),

          // ====================================================
          // CURRENT LOCATION BUTTON
          // ====================================================
          Positioned(
            right: 16,
            top: 16,

            child: Material(
              color: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),

              child: InkWell(
                customBorder: const CircleBorder(),

                onTap: _useCurrentLocation,

                child: SizedBox(
                  width: 48,
                  height: 48,

                  child: _loadingCurrentLocation
                      ? const Padding(
                          padding: EdgeInsets.all(14),

                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded),
                ),
              ),
            ),
          ),

          // ====================================================
          // SEND LOCATION CARD
          // ====================================================
          if (widget.pickMode)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,

              child: SafeArea(
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // --------------------------------------
                        // TITLE
                        // --------------------------------------
                        Text(
                          'Send this location?',

                          style: AppText.h2.copyWith(fontSize: 18),
                        ),

                        const SizedBox(height: 6),

                        // --------------------------------------
                        // LABEL
                        // --------------------------------------
                        Text(
                          _selectedLabel,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: AppText.sub.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // --------------------------------------
                        // ADDRESS
                        // --------------------------------------
                        if (_loadingAddress)
                          Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,

                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Text(
                                'Getting address...',

                                style: AppText.sub.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          )
                        else if (_selectedAddress.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),

                                child: Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),

                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  _selectedAddress,

                                  maxLines: 3,

                                  overflow: TextOverflow.ellipsis,

                                  style: AppText.sub.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 14),

                        // --------------------------------------
                        // SEND BUTTON
                        // --------------------------------------
                        SizedBox(
                          width: double.infinity,
                          height: 48,

                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,

                              foregroundColor: Colors.white,

                              disabledBackgroundColor: AppColors.primary
                                  .withOpacity(0.5),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            onPressed: _loadingAddress ? null : _sendLocation,

                            icon: const Icon(Icons.send_rounded, size: 19),

                            label: Text(
                              _loadingAddress
                                  ? 'Getting Address...'
                                  : 'Send Location',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
