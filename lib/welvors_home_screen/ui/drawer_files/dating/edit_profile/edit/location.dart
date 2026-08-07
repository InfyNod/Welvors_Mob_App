import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/services/edit_profile_api_service.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFE43A6A),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'LOCATION',
                  style: TextStyle(
                    color: Color(0xFFE43A6A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField(context, 'AREA / NEIGHBOURHOOD', state.area, (val) {
                    context.read<ProfileEditCubit>().updateArea(val);
                  }),
                  _buildDivider(),
                  _buildEditableField(context, 'CITY', state.city, (val) {
                    context.read<ProfileEditCubit>().updateCity(val);
                  }),
                  _buildDivider(),
                  _buildEditableField(context, 'STATE', state.stateLocation, (val) {
                    context.read<ProfileEditCubit>().updateStateLocation(val);
                  }),
                  _buildDivider(),
                  _buildCurrentLocationButton(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField(
      BuildContext context, String label, String value, Function(String) onSave) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => EditTextInputScreen(
              title: label == 'AREA / NEIGHBOURHOOD' ? 'Area' : label == 'CITY' ? 'City' : 'State',
              label: label,
              headerText: 'What\'s your ${label.toLowerCase()}?',
              subHeaderText: 'Please enter your ${label.toLowerCase()} for better matches.',
              currentValue: value,
            ),
          ),
        );
        if (result != null && context.mounted) {
          onSave(result);
        }
      },
      child: Container(
        color: Colors.transparent, // to make the whole row tappable
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Text(
                    value.isEmpty ? 'Add $label' : value,
                    style: TextStyle(
                      color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade300,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fetching current location...'),
            duration: Duration(seconds: 2),
          ),
        );
        
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
          
          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.isNotEmpty && context.mounted) {
            Placemark place = placemarks[0];
            String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Unknown City';
            String state = place.administrativeArea ?? 'Unknown State';
            String area = place.subLocality ?? place.thoroughfare ?? place.name ?? 'Unknown Area';
            String country = place.country ?? 'India';
            
            context.read<ProfileEditCubit>().updateArea(area);
            context.read<ProfileEditCubit>().updateCity(city);
            context.read<ProfileEditCubit>().updateStateLocation(state);
            
            // Send updated location to backend
            await EditProfileApiService.updateLocation(
              country: country,
              state: state,
              city: city,
              area: area,
              latitude: position.latitude,
              longitude: position.longitude,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location updated successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not fetch location: $e')),
            );
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
        child: const Row(
          children: [
            Icon(
              Icons.my_location,
              color: Color(0xFFE43A6A),
              size: 18,
            ),
            SizedBox(width: 12),
            Text(
              'USE MY CURRENT LOCATION',
              style: TextStyle(
                color: Color(0xFFE43A6A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }
}
