import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';

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
                  _buildDivider(),
                  _buildShowDistanceToggle(context, state.showDistance),
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
        // Show loading snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fetching current location...'),
            duration: Duration(milliseconds: 800),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (context.mounted) {
          context.read<ProfileEditCubit>().updateArea('Bandra West');
          context.read<ProfileEditCubit>().updateCity('Mumbai');
          context.read<ProfileEditCubit>().updateStateLocation('Maharashtra');
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

  Widget _buildShowDistanceToggle(BuildContext context, bool showDistance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Show distance to matches',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: showDistance,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFE43A6A),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
            onChanged: (val) {
              context.read<ProfileEditCubit>().updateShowDistance(val);
            },
          ),
        ],
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
