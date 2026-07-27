import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart'; // For GenericListPickerScreen

class LifestyleSection extends StatelessWidget {
  const LifestyleSection({super.key});

  static const List<String> _drinkingOptions = [
    'Not for me',
    'Newly teetotal',
    'Sober curious',
    'On special occasions',
    'Socially, at the weekend',
    'Most nights'
  ];

  static const List<String> _smokingOptions = [
    'Non-smoker',
    'Social smoker',
    'Smoker with drinking',
    'Smoker',
    'Trying to quit'
  ];

  static const List<String> _workoutOptions = [
    'Every day',
    'Often',
    'Sometimes',
    'Never'
  ];

  static const List<String> _dietOptions = [
    'Vegetarian',
    'Non-vegetarian',
    'Eggetarian',
    'Vegan'
  ];

  static const List<String> _travelOptions = [
    'Rarely',
    '1–2 trips/year',
    '4–5 trips/year',
    'Frequent traveller',
    'Digital nomad'
  ];

  static const List<String> _sleepOptions = [
    'Early bird',
    'Night owl',
    'Flexible',
    'Depends on the day'
  ];

  // Some default pet options
  static const List<String> _petOptions = [
    'Dog',
    'Cat',
    'Reptile',
    'Amphibian',
    'Bird',
    'Fish',
    'Don\'t have, but love',
    'Other'
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
                Icon(Icons.wine_bar, color: Color(0xFFE43A6A), size: 16), // Using wine_bar as a lifestyle icon
                SizedBox(width: 8),
                Text(
                  "LIFESTYLE",
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
                  _buildListItem(
                    context: context,
                    label: 'DRINKING',
                    value: state.drinking,
                    options: _drinkingOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateDrinking(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'SMOKING',
                    value: state.smoking,
                    options: _smokingOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateSmoking(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'WORKOUT',
                    value: state.workout,
                    options: _workoutOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateWorkout(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'DIET',
                    value: state.diet,
                    options: _dietOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateDiet(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'TRAVEL',
                    value: state.travel,
                    options: _travelOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateTravel(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'SLEEP',
                    value: state.sleep,
                    options: _sleepOptions,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateSleep(val),
                  ),
                  _buildDivider(),
                  _buildPetsSection(context, state.pets),
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

  Widget _buildPetsSection(BuildContext context, List<String> selectedPets) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PETS',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...selectedPets.map((pet) {
                return GestureDetector(
                  onTap: () {
                    context.read<ProfileEditCubit>().togglePet(pet);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE43A6A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pet,
                          style: const TextStyle(
                            color: Color(0xFFE43A6A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.close, color: Color(0xFFE43A6A), size: 14),
                      ],
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () {
                  final cubit = context.read<ProfileEditCubit>();
                  List<String> tempSelectedPets = List.from(selectedPets);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (sheetContext) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                              left: 24,
                              right: 24,
                              top: 12,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag handle
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Select Pets',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'What pets do you have? Select up to 3.',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 12,
                                  children: _petOptions.map((pet) {
                                    final isSelected = tempSelectedPets.contains(pet);
                                    return GestureDetector(
                                      onTap: () {
                                        if (!isSelected && tempSelectedPets.length >= 3) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('You can only select up to 3 pets.'),
                                              duration: Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        setState(() {
                                          if (isSelected) {
                                            tempSelectedPets.remove(pet);
                                          } else {
                                            tempSelectedPets.add(pet);
                                          }
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFE43A6A).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          pet,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // First clear all existing pets
                                      for (final pet in selectedPets) {
                                        if (!tempSelectedPets.contains(pet)) {
                                          cubit.togglePet(pet);
                                        }
                                      }
                                      // Then add new ones
                                      for (final pet in tempSelectedPets) {
                                        if (!selectedPets.contains(pet)) {
                                          cubit.togglePet(pet);
                                        }
                                      }
                                      Navigator.pop(sheetContext);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE43A6A),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      );
                    }
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // Dotted border is hard without package, solid for now
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.black54, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
