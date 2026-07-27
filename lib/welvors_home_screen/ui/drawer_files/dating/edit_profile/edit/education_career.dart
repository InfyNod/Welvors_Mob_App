import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';

class EducationCareerSection extends StatefulWidget {
  const EducationCareerSection({super.key});

  @override
  State<EducationCareerSection> createState() => _EducationCareerSectionState();
}

class _EducationCareerSectionState extends State<EducationCareerSection> {
  static const List<String> _highestEducationOptions = [
    'High School',
    'IIT',
    'Diploma',
    'Undergraduate',
    'Post Graduate',
    'Master',
    'MPhil',
    'PhD',
    'Post-Doctorate',
    'Other',
  ];

  static const List<String> _professionOptions = [
    'Product Manager',
    'Designer',
    'Engineer / Developer',
    'Doctor / Healthcare',
    'Founder / Entrepreneur',
    'Marketing & PR',
    'Finance & Banking',
    'Consultant',
    'Architect',
    'Lawyer',
  ];

  static const List<String> _experienceOptions = [
    'Fresher',
    '<1 yr',
    '1–2 yrs',
    '3–5 yrs',
    '5–10 yrs',
    '10–15 yrs',
    '15+ yrs',
  ];

  static const List<String> _employmentTypeOptions = [
    'Full-time',
    'Freelance',
    'Self-employed',
    'Studying',
    'Between roles',
  ];

  static const List<String> _salaryRangeOptions = [
    'Prefer not to say',
    'Up to 10 LPA',
    '10–20 LPA',
    '20–30 LPA',
    '30–45 LPA',
    '45–75 LPA',
    '75 LPA+',
    '1 Cr+',
  ];

  static const List<String> _ambitionLevelOptions = [
    'Easy-going',
    'Balanced',
    'Driven',
    'Highly driven',
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
                Icon(Icons.work_outline, color: Color(0xFFE43A6A), size: 16),
                SizedBox(width: 8),
                Text(
                  "EDUCATION & CAREER",
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
                  _buildTextFieldItem(
                    context: context,
                    label: 'COLLEGE / INSTITUTION',
                    value: state.college,
                    onSelect: (val) =>
                        context.read<ProfileEditCubit>().updateCollege(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'HIGHEST EDUCATION',
                    value: state.highestEducation,
                    options: _highestEducationOptions,
                    onSelect: (val) => context
                        .read<ProfileEditCubit>()
                        .updateHighestEducation(val),
                  ),
                  _buildDivider(),
                  _buildTextFieldItem(
                    context: context,
                    label: 'DEGREE / COURSE',
                    value: state.degreeCourse,
                    onSelect: (val) => context
                        .read<ProfileEditCubit>()
                        .updateDegreeCourse(val),
                  ),
                  _buildDivider(),
                  _buildGraduationYearItem(context, state.graduationYear),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'PROFESSION',
                    value: state.profession,
                    options: _professionOptions,
                    onSelect: (val) =>
                        context.read<ProfileEditCubit>().updateProfession(val),
                  ),
                  _buildDivider(),
                  _buildTextFieldItem(
                    context: context,
                    label: 'COMPANY / ORGANISATION',
                    value: state.company,
                    onSelect: (val) =>
                        context.read<ProfileEditCubit>().updateCompany(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'EXPERIENCE',
                    value: state.experience,
                    options: _experienceOptions,
                    onSelect: (val) =>
                        context.read<ProfileEditCubit>().updateExperience(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'EMPLOYMENT TYPE',
                    value: state.employmentType,
                    options: _employmentTypeOptions,
                    onSelect: (val) => context
                        .read<ProfileEditCubit>()
                        .updateEmploymentType(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'SALARY RANGE',
                    value: state.salaryRange,
                    options: _salaryRangeOptions,
                    onSelect: (val) =>
                        context.read<ProfileEditCubit>().updateSalaryRange(val),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'AMBITION LEVEL',
                    value: state.ambitionLevel,
                    options: _ambitionLevelOptions,
                    onSelect: (val) => context
                        .read<ProfileEditCubit>()
                        .updateAmbitionLevel(val),
                  ),
                  _buildDivider(),
                  _buildTextFieldItem(
                    context: context,
                    label: 'BIG DREAMS',
                    value: state.bigDreams,
                    isMultiline: true,
                    maxLength: 120,
                    onSelect: (val) =>
                        context.read<ProfileEditCubit>().updateBigDreams(val),
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

  Widget _buildTextFieldItem({
    required BuildContext context,
    required String label,
    required String value,
    required Function(String) onSelect,
    bool isMultiline = false,
    int? maxLength,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => EditTextInputScreen(
              title: label,
              headerText: label,
              subHeaderText: 'Please enter your ${label.toLowerCase()}',
              label: label,
              currentValue: value,
              maxLines: isMultiline ? 5 : 1,
              maxLength: maxLength,
            ),
          ),
        );
        if (result != null) {
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
                    value.isNotEmpty ? value : 'Enter ${label.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: isMultiline ? 2 : 1,
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

  Widget _buildGraduationYearItem(BuildContext context, String value) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => EditGraduationYearScreen(currentValue: value),
          ),
        );
        if (result != null && result.isNotEmpty && context.mounted) {
          context.read<ProfileEditCubit>().updateGraduationYear(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GRADUATION YEAR',
              style: TextStyle(
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
                  ),
                ),
                Icon(
                  Icons.access_time, // Clock icon
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
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }
}

class EditGraduationYearScreen extends StatefulWidget {
  final String currentValue;

  const EditGraduationYearScreen({super.key, required this.currentValue});

  @override
  State<EditGraduationYearScreen> createState() =>
      _EditGraduationYearScreenState();
}

class _EditGraduationYearScreenState extends State<EditGraduationYearScreen> {
  late String _selectedYear;
  late List<String> _years;

  @override
  void initState() {
    super.initState();
    // Generate years from 1950 to 5 years into the future
    final currentYear = DateTime.now().year;
    _years = List.generate(
      currentYear - 1950 + 6,
      (index) => (currentYear + 5 - index).toString(),
    );

    _selectedYear =
        widget.currentValue.isNotEmpty && _years.contains(widget.currentValue)
        ? widget.currentValue
        : currentYear.toString();
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _selectedYear != widget.currentValue;
    if (hasChanges) {
      final result = await showUnsavedChangesDialog(context);
      if (result == true) {
        if (mounted) Navigator.pop(context, _selectedYear);
        return false;
      }
      return result == false; // Pop without saving if false
    }
    return true; // Safe to pop
  }

  @override
  Widget build(BuildContext context) {
    int initialIndex = _years.indexOf(_selectedYear);
    if (initialIndex == -1) initialIndex = 0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, 'Graduation Year', _onWillPop),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Graduation Year',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your year of graduation.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const Spacer(),
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Selection highlight
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: initialIndex,
                        ),
                        itemExtent: 50,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedYear = _years[index];
                          });
                        },
                        selectionOverlay: const SizedBox.shrink(),
                        children: _years.map((year) {
                          final isSelected = year == _selectedYear;
                          return Center(
                            child: Text(
                              year,
                              style: TextStyle(
                                fontSize: isSelected ? 24 : 20,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade400,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedYear);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE43A6A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
          ),
        ),
      ),
    );
  }
}
