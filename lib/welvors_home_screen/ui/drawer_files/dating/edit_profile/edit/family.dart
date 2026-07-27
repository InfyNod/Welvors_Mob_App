import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';

class FamilySection extends StatefulWidget {
  const FamilySection({super.key});

  @override
  State<FamilySection> createState() => _FamilySectionState();
}

class _FamilySectionState extends State<FamilySection> {
  static const List<String> _familyTypeOptions = [
    'Nuclear · Close-knit',
    'Nuclear',
    'Joint family',
    'Close-knit',
    'Living independently',
    'Prefer not to say',
  ];

  static const List<String> _fatherOptions = [
    'Retired banker',
    'Business / Self-employed',
    'Government service',
    'Private service',
    'Doctor',
    'Engineer',
    'Lawyer',
    'Teacher / Professor',
    'Farmer',
    'Retired',
  ];

  static const List<String> _motherOptions = [
    'Homemaker',
    'Former school teacher',
    'Business / Self-employed',
    'Government service',
    'Private service',
    'Doctor',
    'Engineer',
    'Lawyer',
    'Retired',
    'No longer living',
  ];

  static const List<String> _cityOptions = [
    'Pune',
    'Mumbai',
    'Nashik',
    'Nagpur',
    'Kolhapur',
    'Bengaluru',
    'Delhi',
    'Hyderabad',
    'Satara',
    'Sangli',
    'Other',
  ];

  static const List<String> _incomeOptions = [
    'Prefer not to say',
    'Up to ₹10 L / year',
    '₹10–25 L / year',
    '₹25–40 L / year',
    '₹40–75 L / year',
    '₹75 L–1 Cr / year',
    '₹1 Cr+ / year',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: Color(0xFFE43A6A),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  "FAMILY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFFE43A6A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    context: context,
                    label: 'FAMILY TYPE',
                    value: state.familyType,
                    options: _familyTypeOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateFamilyType(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'FATHER',
                    value: state.father,
                    options: _fatherOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateFather(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'MOTHER',
                    value: state.mother,
                    options: _motherOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateMother(val),
                  ),
                  _buildDivider(),
                  // Custom UI for Sisters & Brothers as requested, for now we just show a static card
                  // that can't be edited easily until we know the complex steps from the user.
                  _buildComingSoonItem(
                    label: 'SISTERS',
                    value: state.sisters,
                  ),
                  _buildDivider(),
                  _buildComingSoonItem(
                    label: 'BROTHERS',
                    value: state.brothers,
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'FAMILY HOME',
                    value: state.familyHome,
                    options: _cityOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateFamilyHome(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'NATIVE PLACE',
                    value: state.nativePlace,
                    options: _cityOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateNativePlace(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'FAMILY INCOME',
                    value: state.familyIncome,
                    options: _incomeOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateFamilyIncome(val),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => GenericListPickerScreen(
              title: 'Select ${label.toLowerCase()}',
              headerText: label,
              subHeaderText: 'Please select one from the list',
              options: options,
              currentValue: value,
            ),
          ),
        );
        if (result != null && result.isNotEmpty) {
          onSelect(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'Select',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonItem({
    required String label,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        // Will implement complex steps here later
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complex multi-step flow coming soon!')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'Select',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
    );
  }
}
