import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import 'user_data.dart';
import '../../services/api_service.dart';

class BasicsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const BasicsScreen({super.key, required this.onNext});

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> with AutomaticKeepAliveClientMixin  {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final FocusNode _dobFocus = FocusNode();
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();

  DateTime? _selectedDateOfBirth;
  String? _selectedHeight;
  String? _selectedGender;
  String? _selectedOrientation;

  final List<Map<String, String>> _orientationOptions = [
    {'title': 'Prefer not to say', 'subtitle': 'You can add this later'},
    {
      'title': 'Straight',
      'subtitle': 'Attracted to people of the opposite gender',
    },
    {'title': 'Gay', 'subtitle': 'Attracted to people of the same gender'},
    {'title': 'Lesbian', 'subtitle': 'A woman attracted to other women'},
    {'title': 'Bisexual', 'subtitle': 'Attracted to more than one gender'},
    {
      'title': 'Pansexual',
      'subtitle': 'Attracted to people regardless of gender',
    },
    {
      'title': 'Asexual',
      'subtitle':
          'Little or no sexual attraction — may still feel romantic attraction',
    },
    {
      'title': 'Aromantic',
      'subtitle':
          'Little or no romantic attraction — may still feel other connections',
    },
    {'title': 'Queer', 'subtitle': 'A broad, self-defined orientation'},
    {'title': 'Questioning', 'subtitle': 'Still exploring what feels right'},
  ];

  bool _isFormValid = false;
  bool _isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateForm() {
    bool isEmailValid = isValidEmail(_emailController.text);

    bool valid =
        _nameController.text.trim().isNotEmpty &&
        isEmailValid &&
        _selectedDateOfBirth != null &&
        _selectedHeight != null &&
        _selectedGender != null;

    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  int? get _age {
    if (_selectedDateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - _selectedDateOfBirth!.year;
    if (now.month < _selectedDateOfBirth!.month ||
        (now.month == _selectedDateOfBirth!.month &&
            now.day < _selectedDateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchOnboardingDetails('BASIC_INFO');
    if (data != null && mounted) {
      setState(() {
        if (data['fullName'] != null) {
          _nameController.text = data['fullName'];
          userData.name = data['fullName'];
        }
        if (data['email'] != null) {
          _emailController.text = data['email'];
          userData.email = data['email'];
        }
        if (data['dateOfBirth'] != null) {
          try {
            _selectedDateOfBirth = DateTime.parse(data['dateOfBirth']);
            _dobController.text = "${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}";
          } catch (_) {}
        }
        if (data['height'] != null) {
          _selectedHeight = "${data['height']} cm";
        }
        if (data['gender'] != null) {
          _selectedGender = data['gender'] == 'WOMEN' ? 'Woman' : (data['gender'] == 'MEN' ? 'Man' : data['gender']);
          userData.gender = _selectedGender!;
        }
        if (data['genderOption'] != null) {
          _selectedOrientation = data['genderOption']; // Assuming STRAIGHT is returned
          userData.sexualOrientation = data['genderOption'];
        }
        _validateForm();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _dobFocus.dispose();
    _heightFocus.dispose();
    _genderFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    _dobFocus.requestFocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pinkDeep,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pinkDeep, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
      _validateForm();
    }
    _dobFocus.unfocus();
  }

  List<String> get _heightOptions {
    List<String> options = [];
    for (int cm = 90; cm <= 240; cm++) {
      options.add('$cm cm');
    }
    return options;
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.sub.copyWith(
            color: AppColors.ink.withOpacity(0.8),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          cursorColor: AppColors.pinkDeep,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: AppText.body.copyWith(
              color: AppColors.muted,
              fontSize: 16,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.rInput),
              borderSide: const BorderSide(color: AppColors.line, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.rInput),
              borderSide: const BorderSide(
                color: AppColors.pinkDeep,
                width: 1.5,
              ),
            ),
          ),
          style: AppText.body.copyWith(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    String? value,
    List<String> options,
    Function(String?) onChanged, {
    bool optional = false,
    String? helperText,
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppText.sub.copyWith(
                color: AppColors.ink.withOpacity(0.8),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (optional)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OPTIONAL',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, child) {
            return Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: focusNode.hasFocus
                      ? AppColors.pinkDeep
                      : AppColors.line,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppDimens.rInput),
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
                focusColor: Colors.transparent,
                hint: Text(
                  hint,
                  style: AppText.body.copyWith(
                    color: AppColors.muted,
                    fontSize: 16,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.ink.withOpacity(0.5),
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                menuMaxHeight: 300,
                items: options.map((String option) {
                  final isSelected = option == value;
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: AppText.body.copyWith(
                        color: AppColors.ink,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              helperText,
              style: AppText.body.copyWith(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomSheetField(
    String label,
    String hint,
    String? value,
    VoidCallback onTap, {
    bool optional = false,
    String? helperText,
    bool isPrivate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppText.sub.copyWith(
                color: AppColors.ink.withOpacity(0.8),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (optional)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OPTIONAL',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.line, width: 1.5),
              borderRadius: BorderRadius.circular(AppDimens.rInput),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: AppText.body.copyWith(
                    color: value == null ? AppColors.muted : AppColors.ink,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.ink.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPrivate) ...[
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    helperText,
                    style: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildComplexDropdownField(
    String label,
    String hint,
    String? value,
    List<Map<String, String>> options, {
    bool optional = false,
    String? helperText,
  }) {
    return _buildBottomSheetField(
      label,
      hint,
      value,
      () {
        FocusScope.of(context).unfocus();
        _showOrientationSheet();
      },
      optional: optional,
      helperText: helperText,
      isPrivate: true,
    );
  }

  void _showOrientationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sexual orientation',
                          style: AppText.h2.copyWith(fontSize: 20),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.ink,
                            size: 16,
                          ),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF4EFE7),
                            minimumSize: const Size(32, 32),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EFE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: AppColors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Private — never shown on your profile to other people.',
                              style: AppText.sub.copyWith(
                                fontSize: 12,
                                color: AppColors.ink.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 8,
                        bottom: 48,
                      ),
                      itemCount: _orientationOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = _orientationOptions[index];
                        final isSelected =
                            _selectedOrientation == option['title'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOrientation = option['title'];
                            });
                            setSheetState(() {});
                            _validateForm();
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFCE9EE)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.pinkDeep
                                    : AppColors.line,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['title']!,
                                        style: AppText.body.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.pinkDeep
                                              : AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option['subtitle']!,
                                        style: AppText.sub.copyWith(
                                          fontSize: 12,
                                          color: isSelected
                                              ? AppColors.pinkDeep
                                              : AppColors.ink.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: AppColors.pinkDeep,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ABOUT YOU',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s set up your profile.',
                  style: AppText.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'A few basics to get you started — you can\nrefine all of this later.',
                  style: AppText.body.copyWith(
                    color: AppColors.ink60,
                    height: 1.5,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                _buildTextField('Full name', 'Sallu Ansari', _nameController),
                const SizedBox(height: 24),

                _buildTextField(
                  'Email ID',
                  'sallu@email.com',
                  _emailController,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                Text(
                  'Date of birth',
                  style: AppText.sub.copyWith(
                    color: AppColors.ink.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDateOfBirth,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dobController,
                      focusNode: _dobFocus,
                      style: AppText.body.copyWith(fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'DD / MM / YYYY',
                        hintStyle: AppText.body.copyWith(
                          color: AppColors.muted,
                          fontSize: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColors.pinkDeep.withOpacity(0.9),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.rInput),
                          borderSide: const BorderSide(
                            color: AppColors.line,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.rInput),
                          borderSide: const BorderSide(
                            color: AppColors.pinkDeep,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedDateOfBirth != null && _age != null && _age! < 18)
                  Text(
                    'You must be at least 18 years old.',
                    style: AppText.body.copyWith(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (_age != null)
                  RichText(
                    text: TextSpan(
                      style: AppText.sub.copyWith(
                        color: AppColors.ink.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(text: 'You’ll appear as '),
                        TextSpan(
                          text: '$_age',
                          style: const TextStyle(
                            color: AppColors.pinkDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' on your profile.'),
                      ],
                    ),
                  )
                else
                  Text(
                    'We only show your age — never the full date.',
                    style: TextStyle(
                      color: AppColors.ink.withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 24),
                _buildDropdownField(
                  'HEIGHT',
                  'Select height',
                  _selectedHeight,
                  _heightOptions,
                  (val) {
                    setState(() => _selectedHeight = val);
                    _validateForm();
                  },
                  focusNode: _heightFocus,
                ),
                const SizedBox(height: 24),

                _buildDropdownField(
                  'GENDER',
                  'Select gender',
                  _selectedGender,
                  ['Man', 'Woman', 'Non-binary', 'Other'],
                  (val) {
                    setState(() => _selectedGender = val);
                    _validateForm();
                  },
                  focusNode: _genderFocus,
                ),
                const SizedBox(height: 24),

                _buildComplexDropdownField(
                  'SEXUAL ORIENTATION',
                  'Select orientation',
                  _selectedOrientation,
                  _orientationOptions,
                  optional: true,
                  helperText: 'We use this to show you relevant matches.',
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            16,
            AppDimens.pad,
            20,
          ),
          child: PrimaryButton(
            'Continue',
            isLoading: _isLoading,
            onTap: _isFormValid && !_isLoading
                ? () async {
                    // Dismiss keyboard
                    FocusScope.of(context).unfocus();

                    if (_age != null && _age! < 18) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You must be at least 18 to use Welvors.',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    userData.name = _nameController.text.trim();
                    userData.email = _emailController.text.trim();
                    userData.age = _age ?? 18;
                    userData.gender = _selectedGender ?? 'Man';
                    userData.sexualOrientation =
                        _selectedOrientation ?? 'Not specified';

                    // Map gender to backend enum
                    String mappedGender = 'PREFER_NOT_TO_SAY';
                    if (_selectedGender == 'Man') mappedGender = 'MEN';
                    if (_selectedGender == 'Woman') mappedGender = 'WOMEN';
                    if (_selectedGender == 'Non-binary')
                      mappedGender = 'NON_BINARY';

                    // Convert height (e.g. 5'9") to cm (number)
                    int heightCm = 170; // default
                    if (_selectedHeight != null) {
                      try {
                        final parts = _selectedHeight!.split('\'');
                        final feet = int.parse(parts[0]);
                        final inches = int.parse(parts[1].replaceAll('"', ''));
                        final totalInches = (feet * 12) + inches;
                        heightCm = (totalInches * 2.54).round();
                      } catch (e) {
                        debugPrint('Height parse error: $e');
                      }
                    }

                    // Map sexual orientation to backend gender_option enum
                    String mappedOrientation = 'NOT_LISTED';
                    if (_selectedOrientation != null) {
                      switch (_selectedOrientation) {
                        case 'Straight':
                          mappedOrientation = 'STRAIGHT';
                          break;
                        case 'Gay':
                          mappedOrientation = 'GAY';
                          break;
                        case 'Lesbian':
                          mappedOrientation = 'LESBIAN';
                          break;
                        case 'Bisexual':
                          mappedOrientation = 'BISEXUAL';
                          break;
                        case 'Pansexual':
                          mappedOrientation = 'PANSEXUAL';
                          break;
                        case 'Asexual':
                          mappedOrientation = 'ASEXUAL';
                          break;
                        case 'Aromantic':
                          mappedOrientation = 'AROMATIC';
                          break;
                        case 'Queer':
                          mappedOrientation = 'QUEER';
                          break;
                        case 'Questioning':
                          mappedOrientation = 'NOT_LISTED';
                          break;
                        case 'Prefer not to say':
                          mappedOrientation = 'NOT_LISTED';
                          break;
                      }
                    }

                    final data = {
                      'fullName': userData.name,
                      'email': userData.email,
                      'gender': mappedGender,
                      'gender_option': mappedOrientation,
                      'height': heightCm,
                      if (_selectedDateOfBirth != null)
                        'birth_date':
                            '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}',
                    };

                    final error = await ApiService.submitBasicInfo(data);

                    if (mounted) {
                      setState(() => _isLoading = false);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        widget.onNext();
                      }
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
