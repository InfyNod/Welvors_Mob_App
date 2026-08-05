import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/onbording_allpage/services/api_service.dart';

class EducationCareerSection extends StatefulWidget {
  const EducationCareerSection({super.key});

  @override
  State<EducationCareerSection> createState() => _EducationCareerSectionState();
}

class _EducationCareerSectionState extends State<EducationCareerSection> {
  static const List<String> _highestEducationOptions = [
    'High School',
    'Higher Secondary',
    'Diploma',
    'ITI',
    'Bachelor',
    'Master',
    'MBA',
    'CA',
    'CS',
    'Doctor',
    'Engineer',
    'Law',
    'PhD',
    'Post Doctorate',
    'Other',
  ];

  List<String> _professionOptions = [];
  Map<String, int> _professionsMap = {};

  List<String> _experienceOptions = [];
  Map<String, int> _experiencesMap = {};

  List<String> _employmentTypeOptions = [];
  Map<String, int> _employmentTypesMap = {};

  List<String> _salaryRangeOptions = [];
  Map<String, int> _salaryRangesMap = {};

  List<String> _ambitionLevelOptions = [];
  Map<String, int> _ambitionsMap = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final results = await Future.wait([
      ApiService.fetchProfessions(),
      ApiService.fetchExperiences(),
      ApiService.fetchEmploymentTypes(),
      ApiService.fetchSalaryRanges(),
      ApiService.fetchAmbitions(),
    ]);

    if (mounted) {
      setState(() {
        _professionsMap = results[0] as Map<String, int>;
        _professionOptions = _professionsMap.keys.toList();

        _experiencesMap = results[1] as Map<String, int>;
        _experienceOptions = _experiencesMap.keys.toList();

        _employmentTypesMap = results[2] as Map<String, int>;
        _employmentTypeOptions = _employmentTypesMap.keys.toList();

        _salaryRangesMap = results[3] as Map<String, int>;
        _salaryRangeOptions = _salaryRangesMap.keys.toList();

        _ambitionsMap = results[4] as Map<String, int>;
        _ambitionLevelOptions = _ambitionsMap.keys.toList();

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        if (_isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.work_outline, color: Color(0xFFE43A6A), size: 16),
                SizedBox(width: 8),
                Text(
                  "CAREER & AMBITION",
                  style: TextStyle(
                    fontSize: 11,
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
                    label: 'WORK AS',
                    value: state.profession,
                    options: _professionOptions,
                    onSelect: (val) {
                      final id = _professionsMap[val];
                      context.read<ProfileEditCubit>().updateProfession(
                        val,
                        id,
                      );
                    },
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
                    onSelect: (val) {
                      final id = _experiencesMap[val];
                      context.read<ProfileEditCubit>().updateExperience(
                        val,
                        id,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'EMPLOYMENT TYPE',
                    value: state.employmentType,
                    options: _employmentTypeOptions,
                    onSelect: (val) {
                      final id = _employmentTypesMap[val];
                      context.read<ProfileEditCubit>().updateEmploymentType(
                        val,
                        id,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'INCOME',
                    value: state.salaryRange,
                    options: _salaryRangeOptions,
                    onSelect: (val) {
                      final id = _salaryRangesMap[val];
                      context.read<ProfileEditCubit>().updateSalaryRange(
                        val,
                        id,
                      );
                    },
                  ),

                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'AMBITION LEVEL',
                    value: state.ambitionLevel,
                    options: _ambitionLevelOptions,
                    onSelect: (val) {
                      final id = _ambitionsMap[val];
                      context.read<ProfileEditCubit>().updateAmbitionLevel(
                        val,
                        id,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildTextFieldItem(
                    context: context,
                    label: 'BIG DREAMS',
                    value: state.bigDreams,
                    isMultiline: true,
                    maxLength: 300,
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
