import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';

class CareerScreen extends StatefulWidget {
  final VoidCallback onNext;
  const CareerScreen({super.key, required this.onNext});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _gradYearController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  final FocusNode _eduFocus = FocusNode();
  final FocusNode _profFocus = FocusNode();
  final FocusNode _expFocus = FocusNode();
  final FocusNode _salaryFocus = FocusNode();

  String? _educationLevel;
  String? _profession;
  String? _experience;
  String? _employmentType;
  String? _salaryRange;
  String? _ambitionLevel;
  final TextEditingController _dreamsController = TextEditingController();

  List<String> _professionOptions = [];
  Map<String, int> _professionsMap = {};
  bool _isProfessionsLoading = true;

  List<String> _experienceOptions = [];
  Map<String, int> _experiencesMap = {};
  bool _isExperiencesLoading = true;

  List<String> _employmentTypeOptions = [];
  Map<String, int> _employmentTypesMap = {};
  bool _isEmploymentTypesLoading = true;

  List<String> _salaryRangeOptions = [];
  Map<String, int> _salaryRangesMap = {};
  bool _isSalaryRangesLoading = true;

  List<String> _ambitionOptions = [];
  Map<String, int> _ambitionsMap = {};
  bool _isAmbitionsLoading = true;

  bool _isSubmitting = false;

  bool get _isFormValid => _educationLevel != null && _profession != null;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final professionsFuture = ApiService.fetchProfessions();
    final experiencesFuture = ApiService.fetchExperiences();
    final employmentTypesFuture = ApiService.fetchEmploymentTypes();
    final salaryRangesFuture = ApiService.fetchSalaryRanges();
    final ambitionsFuture = ApiService.fetchAmbitions();

    final results = await Future.wait([
      professionsFuture,
      experiencesFuture,
      employmentTypesFuture,
      salaryRangesFuture,
      ambitionsFuture,
    ]);

    final professions = results[0] as Map<String, int>;
    final experiences = results[1] as Map<String, int>;
    final employmentTypes = results[2] as Map<String, int>;
    final salaryRanges = results[3] as Map<String, int>;
    final ambitions = results[4] as Map<String, int>;

    if (mounted) {
      setState(() {
        if (professions.isNotEmpty) {
          _professionsMap = professions;
          _professionOptions = professions.keys.toList();
        } else {
          _professionOptions = ['Failed to load'];
        }
        _isProfessionsLoading = false;

        if (experiences.isNotEmpty) {
          _experiencesMap = experiences;
          _experienceOptions = experiences.keys.toList();
        } else {
          _experienceOptions = ['Failed to load'];
        }
        _isExperiencesLoading = false;

        if (employmentTypes.isNotEmpty) {
          _employmentTypesMap = employmentTypes;
          _employmentTypeOptions = employmentTypes.keys.toList();
        } else {
          _employmentTypeOptions = ['Failed to load'];
        }
        _isEmploymentTypesLoading = false;

        if (salaryRanges.isNotEmpty) {
          _salaryRangesMap = salaryRanges;
          _salaryRangeOptions = salaryRanges.keys.toList();
        } else {
          _salaryRangeOptions = ['Failed to load'];
        }
        _isSalaryRangesLoading = false;

        if (ambitions.isNotEmpty) {
          _ambitionsMap = ambitions;
          _ambitionOptions = ambitions.keys.toList();
        } else {
          _ambitionOptions = ['Failed to load'];
        }
        _isAmbitionsLoading = false;
      });
      _loadData(); // Load the saved data after the options are fetched
    }
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchOnboardingDetails('CAREER_AMBITION');
    if (data != null && mounted) {
      setState(() {
        if (data['highestEducation'] != null) {
          String eduCode = data['highestEducation'].toString();
          String? matchingEdu;
          for (var opt in [
            'High School',
            'ITI',
            'Diploma',
            'Undergraduate',
            'Bachelor',
            'Postgraduate',
            'Master',
            'MPhil',
            'PhD',
            'Post-Doctorate',
          ]) {
            if (opt.toUpperCase().replaceAll(' ', '_').replaceAll('-', '_') ==
                eduCode) {
              matchingEdu = opt;
              break;
            }
          }
          if (matchingEdu != null) {
            _educationLevel = matchingEdu;
            userData.education = matchingEdu;
          }
        }

        if (data['degree'] != null) {
          _degreeController.text = data['degree'];
          userData.degree = data['degree'];
        }
        if (data['collegeName'] != null) {
          _collegeController.text = data['collegeName'];
          userData.college = data['collegeName'];
        }
        if (data['graduationYear'] != null) {
          _gradYearController.text = data['graduationYear'].toString();
          userData.gradYear = data['graduationYear'].toString();
        }

        if (data['profession'] != null && data['profession']['name'] != null) {
          _profession = data['profession']['name'];
          userData.profession = _profession!;
        }
        if (data['companyName'] != null) {
          _companyController.text = data['companyName'];
          userData.company = data['companyName'];
        }
        if (data['employmentType'] != null &&
            data['employmentType']['name'] != null) {
          _employmentType = data['employmentType']['name'];
          userData.employmentType = _employmentType!;
        }
        if (data['experience'] != null && data['experience']['title'] != null) {
          _experience = data['experience']['title'];
          userData.experience = _experience!;
        }

        if (data['ambition'] != null && data['ambition']['title'] != null) {
          _ambitionLevel = data['ambition']['title'];
          userData.ambitionLevel = _ambitionLevel!;
        }
        if (data['salaryRange'] != null &&
            data['salaryRange']['title'] != null) {
          _salaryRange = data['salaryRange']['title'];
          userData.salaryRange = _salaryRange!;
        }
        if (data['bigDreams'] != null) {
          _dreamsController.text = data['bigDreams'];
          userData.dreams = data['bigDreams'];
        }
      });
    }
  }

  @override
  void dispose() {
    _collegeController.dispose();
    _degreeController.dispose();
    _gradYearController.dispose();
    _companyController.dispose();
    _dreamsController.dispose();
    _eduFocus.dispose();
    _profFocus.dispose();
    _expFocus.dispose();
    _salaryFocus.dispose();
    super.dispose();
  }

  Widget _buildChipSelection({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.body.copyWith(
            color: AppColors.ink60,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(isSelected ? null : option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pinkDeep : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.pinkDeep : AppColors.line,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.pinkDeep.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  option,
                  style: AppText.body.copyWith(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.ink60,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppText.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        cursorColor: AppColors.pinkDeep,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: AppText.body.copyWith(
            color: AppColors.muted,
            fontSize: 15,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.pinkDeep, width: 1.5),
          ),
        ),
        style: AppText.body.copyWith(fontSize: 15),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
    required FocusNode focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, child) {
          return Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: focusNode.hasFocus ? AppColors.pinkDeep : AppColors.line,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          );
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              focusNode: focusNode,
              isExpanded: true,
              value: value,
              elevation: 8,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              menuMaxHeight: 300,
              hint: Text(
                hint,
                style: AppText.body.copyWith(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.ink.withOpacity(0.5),
              ),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: AppText.body.copyWith(
                      color: AppColors.ink,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAREER & AMBITION',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Education & ambition.',
                  style: AppText.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'What you’ve studied, what you do, and\nwhere you’re headed — it helps us match\nyou with people on a similar path.',
                  style: AppText.sub.copyWith(
                    color: AppColors.ink60,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader('🎓', 'Education'),
                _buildTextField(
                  controller: _collegeController,
                  hint: 'College / institution name',
                ),
                _buildDropdownField(
                  hint: 'Highest education',
                  value: _educationLevel,
                  options: [
                    'High School',
                    'ITI',
                    'Diploma',
                    'Undergraduate',
                    'Bachelor',
                    'Postgraduate',
                    'Master',
                    'MPhil',
                    'PhD',
                    'Post-Doctorate',
                  ],
                  onChanged: (val) => setState(() => _educationLevel = val),
                  focusNode: _eduFocus,
                ),
                _buildTextField(
                  controller: _degreeController,
                  hint: 'Degree / course · e.g. B.Tech Computer',
                ),
                _buildTextField(
                  controller: _gradYearController,
                  hint: '2026',
                  readOnly: true,
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.pinkDeep.withOpacity(0.9),
                    size: 20,
                  ),
                  onTap: () {
                    final int currentYear = DateTime.now().year;
                    int selectedYear = _gradYearController.text.isNotEmpty
                        ? int.tryParse(_gradYearController.text) ?? currentYear
                        : currentYear;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Container(
                            height: 340,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Select Year',
                                  style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController:
                                        FixedExtentScrollController(
                                          initialItem: selectedYear - 1950,
                                        ),
                                    itemExtent: 44,
                                    selectionOverlay: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppColors.pinkSoft.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                    onSelectedItemChanged: (int index) {
                                      selectedYear = 1950 + index;
                                    },
                                    children: List<Widget>.generate(
                                      (currentYear + 10) - 1950 + 1,
                                      (int index) {
                                        return Center(
                                          child: Text(
                                            (1950 + index).toString(),
                                            style: AppText.body.copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  'Done',
                                  onTap: () {
                                    setState(() {
                                      _gradYearController.text = selectedYear
                                          .toString();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                _buildSectionHeader('💼', 'Work'),
                _buildDropdownField(
                  hint: _isProfessionsLoading
                      ? 'Loading professions...'
                      : 'Profession · select',
                  value: _profession,
                  options: _professionOptions.isEmpty
                      ? ['Loading...']
                      : _professionOptions,
                  onChanged: (val) => setState(() => _profession = val),
                  focusNode: _profFocus,
                ),
                _buildTextField(
                  controller: _companyController,
                  hint: 'Company / organisation · e.g. Google',
                ),
                _buildDropdownField(
                  hint: _isExperiencesLoading
                      ? 'Loading experiences...'
                      : 'Experience · select',
                  value: _experience,
                  options: _experienceOptions.isEmpty
                      ? ['Loading...']
                      : _experienceOptions,
                  onChanged: (val) => setState(() => _experience = val),
                  focusNode: _expFocus,
                ),

                _buildChipSelection(
                  label: _isEmploymentTypesLoading
                      ? 'Loading employment types...'
                      : 'Employment type',
                  options: _employmentTypeOptions.isEmpty
                      ? ['Loading...']
                      : _employmentTypeOptions,
                  selectedValue: _employmentType,
                  onChanged: (val) => setState(() => _employmentType = val),
                ),

                _buildDropdownField(
                  hint: _isSalaryRangesLoading
                      ? 'Loading salary ranges...'
                      : 'Salary range · optional',
                  value: _salaryRange,
                  options: _salaryRangeOptions.isEmpty
                      ? ['Loading...']
                      : _salaryRangeOptions,
                  onChanged: (val) => setState(() => _salaryRange = val),
                  focusNode: _salaryFocus,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('🚀', 'Ambition'),
                _buildChipSelection(
                  label: _isAmbitionsLoading
                      ? 'Loading ambitions...'
                      : 'Ambition level',
                  options: _ambitionOptions.isEmpty
                      ? ['Loading...']
                      : _ambitionOptions,
                  selectedValue: _ambitionLevel,
                  onChanged: (val) => setState(() => _ambitionLevel = val),
                ),

                TextField(
                  controller: _dreamsController,
                  maxLines: 4,
                  maxLength: 100,
                  cursorColor: AppColors.pinkDeep,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText:
                        'Big dreams · e.g. Travel the world, build a home, start something of my own...',
                    hintStyle: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.line,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.pinkDeep,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: AppText.body.copyWith(fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            16,
            AppDimens.pad,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                _isSubmitting ? 'Saving...' : 'Continue',
                onTap: (_isFormValid && !_isSubmitting)
                    ? () async {
                        setState(() => _isSubmitting = true);

                        // Map Education Level to Prisma Enum (uppercase, spaces and hyphens to underscores)
                        String formattedEdu = (_educationLevel ?? 'High School')
                            .toUpperCase()
                            .replaceAll(' ', '_')
                            .replaceAll('-', '_');

                        int gradYear = 2024;
                        if (_gradYearController.text.isNotEmpty) {
                          gradYear =
                              int.tryParse(_gradYearController.text) ?? 2024;
                        }

                        // Call Education API
                        final eduError = await ApiService.submitEducation({
                          "highestEdu": formattedEdu,
                          "collegeName": _collegeController.text.isNotEmpty
                              ? _collegeController.text
                              : "Not specified",
                          "degree": _degreeController.text.isNotEmpty
                              ? _degreeController.text
                              : "Not specified",
                          "graduationYear": gradYear,
                        });

                        if (eduError != null) {
                          setState(() => _isSubmitting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Education Error: $eduError'),
                              ),
                            );
                          }
                          return;
                        }

                        // Map Work IDs (send null if not selected, rather than a fake ID like 1)
                        final profId = _professionsMap[_profession];
                        final expId = _experiencesMap[_experience];
                        final empTypeId = _employmentTypesMap[_employmentType];
                        final salId = _salaryRangesMap[_salaryRange];
                        final ambId = _ambitionsMap[_ambitionLevel];

                        // Call Work API
                        final workError = await ApiService.submitWork({
                          "professionId": profId,
                          "companyName": _companyController.text.isNotEmpty
                              ? _companyController.text
                              : "Not specified",
                          "employmentTypeId": empTypeId,
                          "experienceId": expId,
                          "ambitionId": ambId,
                          "salaryRangeId": salId,
                          "bigDreams": _dreamsController.text.isNotEmpty
                              ? _dreamsController.text
                              : "Not specified",
                        });

                        setState(() => _isSubmitting = false);

                        if (workError != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Work Error: $workError')),
                            );
                          }
                          return;
                        }

                        // Local Data Backup (For legacy app screens)
                        userData.education = _educationLevel ?? 'Other';
                        userData.college = _collegeController.text;
                        userData.degree = _degreeController.text;
                        userData.gradYear = _gradYearController.text;

                        userData.company = _companyController.text;
                        userData.profession = _profession ?? 'Other';
                        userData.career = _profession ?? 'Other';
                        userData.experience = _experience ?? 'Other';
                        userData.employmentType = _employmentType ?? 'Other';
                        userData.salaryRange = _salaryRange ?? 'Other';
                        userData.ambitionLevel = _ambitionLevel ?? 'Other';
                        userData.dreams = _dreamsController.text;

                        widget.onNext();
                      }
                    : null,
              ),
              const SizedBox(height: 0),
              TextButton(
                onPressed: () {
                  userData.education = 'Other';
                  userData.career = 'Other';
                  widget.onNext();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink60,
                  minimumSize: const Size(double.infinity, 36),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  'Skip for now',
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
