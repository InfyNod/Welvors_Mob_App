import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart'; // For GenericListPickerScreen

class WhoYouAreSeeingSection extends StatelessWidget {
  const WhoYouAreSeeingSection({super.key});

  final List<String> _interestedInOptions = const [
    'Men',
    'Women',
    'Non binary',
  ];

  final List<String> _sexualOrientationOptions = const [
    'Straight',
    'Gay',
    'Lesbian',
    'Aromantic',
    'Asexual',
    'Bisexual',
    'Demisexual',
    'Pansexual',
    'Queer',
    'Not listed',
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
                Icon(Icons.search, color: Color(0xFFE43A6A), size: 16),
                SizedBox(width: 8),
                Text(
                  "WHO YOU'RE SEEING",
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
                children: [
                  _buildListItem(
                    context: context,
                    label: 'INTERESTED IN',
                    value: state.interestedIn,
                    options: _interestedInOptions,
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateInterestedIn(val);
                    },
                  ),
                  if (state.interestedIn != 'Everyone') ...[
                    _buildDivider(),
                    _buildListItem(
                      context: context,
                      label: 'SEXUAL ORIENTATION',
                      value: state.sexualOrientation,
                      options: _sexualOrientationOptions,
                      onSelect: (val) {
                        context.read<ProfileEditCubit>().updateSexualOrientation(val);
                      },
                    ),
                  ],
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
        if (result != null) {
          onSelect(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Add $label' : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }
}
