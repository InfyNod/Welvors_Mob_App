import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Generic unsaved changes popup method
Future<bool> showUnsavedChangesDialog(BuildContext context) async {
  final shouldPop = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE43A6A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE43A6A),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unsaved Changes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You have unsaved changes. Do you want to save them before leaving?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  ); // User wants to save (we handle save outside)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE43A6A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    Navigator.pop(context, false), // User wants to discard
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Discard',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, null), // Cancel dialog
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return shouldPop ?? false; // Returns true for 'Save', false for 'Discard'
}

Widget buildCustomAppBar(
  BuildContext context,
  String title,
  Future<bool> Function() onWillPop,
) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    leading: Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: InkWell(
        onTap: () async {
          if (await onWillPop()) {
            if (context.mounted) Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 16,
          ),
        ),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// ---------------------------------------------------------
// 1. TEXT INPUT SCREEN (For Name, Email)
// ---------------------------------------------------------
class EditTextInputScreen extends StatefulWidget {
  final String title;
  final String label;
  final String headerText;
  final String subHeaderText;
  final String currentValue;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;

  const EditTextInputScreen({
    super.key,
    required this.title,
    required this.label,
    required this.headerText,
    required this.subHeaderText,
    required this.currentValue,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<EditTextInputScreen> createState() => _EditTextInputScreenState();
}

class _EditTextInputScreenState extends State<EditTextInputScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _controller.text.trim() != widget.currentValue;
    if (!hasChanges) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) Navigator.pop(context, _controller.text.trim());
      return false; // Already popped
    }
    return result == false; // Pop without saving
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, widget.title, _onWillPop),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.headerText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subHeaderText,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE43A6A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _controller.text.trim());
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

// ---------------------------------------------------------
// 2. GENERIC LIST PICKER SCREEN (For Gender, Religion, etc.)
// ---------------------------------------------------------
class GenericListPickerScreen extends StatefulWidget {
  final String title;
  final String headerText;
  final String subHeaderText;
  final String currentValue;
  final List<String> options;
  final Map<String, String>? optionSubtitles;

  const GenericListPickerScreen({
    super.key,
    required this.title,
    required this.headerText,
    required this.subHeaderText,
    required this.currentValue,
    required this.options,
    this.optionSubtitles,
  });

  @override
  State<GenericListPickerScreen> createState() =>
      _GenericListPickerScreenState();
}

class _GenericListPickerScreenState extends State<GenericListPickerScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentValue;
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _selected != widget.currentValue;
    if (!hasChanges) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) Navigator.pop(context, _selected);
      return false; // Already popped
    }
    return result == false; // Pop without saving
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, widget.title, _onWillPop),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.headerText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subHeaderText,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.options.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final option = widget.options[index];
                      final isSelected = _selected == option;
                      final subtitle = widget.optionSubtitles?[option];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selected = option;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE43A6A).withOpacity(0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE43A6A)
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFFE43A6A)
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (subtitle != null && subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected ? const Color(0xFFE43A6A).withOpacity(0.8) : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFE43A6A),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selected);
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

// ---------------------------------------------------------
// 3. EDIT DOB SCREEN (For Date of Birth)
// ---------------------------------------------------------
class EditDobScreen extends StatefulWidget {
  final String currentValue; // Expected format: '12 / 08 / 1997'

  const EditDobScreen({super.key, required this.currentValue});

  @override
  State<EditDobScreen> createState() => _EditDobScreenState();
}

class _EditDobScreenState extends State<EditDobScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Parse current value '12 / 08 / 1997' to DateTime
    try {
      final parts = widget.currentValue.split(' / ');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        _selectedDate = DateTime(year, month, day);
      }
    } catch (e) {
      _selectedDate = DateTime(2000, 1, 1);
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.day.toString().padLeft(2, '0')} / ${_selectedDate!.month.toString().padLeft(2, '0')} / ${_selectedDate!.year}';
  }

  int get _age {
    if (_selectedDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    if (now.month < _selectedDate!.month ||
        (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
      age--;
    }
    return age;
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _formattedDate != widget.currentValue;
    if (!hasChanges) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) Navigator.pop(context, _formattedDate);
      return false;
    }
    return result == false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, 'Date of Birth', _onWillPop),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What\'s your date of birth?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You'll appear as $_age — we only show your age.",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFE43A6A),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE43A6A),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formattedDate.isNotEmpty
                              ? _formattedDate
                              : 'DD / MM / YYYY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _formattedDate.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month,
                          color: Color(0xFFE43A6A),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _formattedDate);
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

// ---------------------------------------------------------
// 4. EDIT HEIGHT SCREEN (Custom Wheel Picker)
// ---------------------------------------------------------
class EditHeightScreen extends StatefulWidget {
  final String currentValue; // Expected format: "5'5\" · 165 cm"

  const EditHeightScreen({super.key, required this.currentValue});

  @override
  State<EditHeightScreen> createState() => _EditHeightScreenState();
}

class _EditHeightScreenState extends State<EditHeightScreen> {
  int _selectedCm = 165;

  @override
  void initState() {
    super.initState();
    try {
      final parts = widget.currentValue.split('·');
      if (parts.length == 2) {
        String cmStr = parts[1].replaceAll('cm', '').trim();
        _selectedCm = int.parse(cmStr);
      }
    } catch (e) {
      _selectedCm = 165;
    }
  }

  String get _formattedHeight {
    // Convert cm to feet and inches
    double inches = _selectedCm / 2.54;
    int feet = (inches / 12).floor();
    int remainingInches = (inches % 12).round();

    // Handle edge case where rounding inches makes it 12
    if (remainingInches == 12) {
      feet += 1;
      remainingInches = 0;
    }

    return "$feet'$remainingInches\" · $_selectedCm cm";
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _formattedHeight != widget.currentValue;
    if (!hasChanges) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) Navigator.pop(context, _formattedHeight);
      return false;
    }
    return result == false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, 'Height', _onWillPop),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'How tall are you?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  _formattedHeight,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE43A6A),
                  ),
                ),

                const SizedBox(height: 20),

                // Custom Height Scroll Wheel
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 50,
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedCm - 90,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedCm = 90 + index; // Range from 90 cm to 250 cm
                      });
                    },
                    childCount: 250 - 90 + 1,
                    itemBuilder: (context, index) {
                      int cm = 90 + index;
                      double inches = cm / 2.54;
                      int feet = (inches / 12).floor();
                      int remainingInches = (inches % 12).round();
                      if (remainingInches == 12) {
                        feet += 1;
                        remainingInches = 0;
                      }

                      bool isSelected = cm == _selectedCm;

                      return Center(
                        child: Text(
                          "$feet'$remainingInches\"   ·   $cm cm",
                          style: TextStyle(
                            fontSize: isSelected ? 22 : 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _formattedHeight);
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

// ---------------------------------------------------------
// 5. EDIT RELIGION & CASTE SCREEN (Accordion Picker)
// ---------------------------------------------------------
class EditReligionCasteScreen extends StatefulWidget {
  final String currentValue;

  const EditReligionCasteScreen({super.key, required this.currentValue});

  @override
  State<EditReligionCasteScreen> createState() =>
      _EditReligionCasteScreenState();
}

class _EditReligionCasteScreenState extends State<EditReligionCasteScreen> {
  late String _selectedReligion;
  late String _selectedCaste;

  final List<String> _religions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Jain',
    'Buddhist',
    'Parsi',
    'Jewish',
    'Spiritual but not religious',
    'Atheist',
    'Agnostic',
    'Prefer not to say',
  ];

  final Map<String, List<String>> _castes = {
    'Hindu': ['Maratha', 'Brahmin', 'Other'],
    'Muslim': ['Sunni', 'Shia', 'Other'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.currentValue.contains(' · ')) {
      final parts = widget.currentValue.split(' · ');
      _selectedReligion = parts[0].trim();
      _selectedCaste = parts[1].trim();
    } else {
      _selectedReligion = widget.currentValue.trim();
      _selectedCaste = '';
    }
  }

  String get _currentFormattedValue {
    if (_selectedCaste.isNotEmpty && _castes.containsKey(_selectedReligion)) {
      return '$_selectedReligion · $_selectedCaste';
    }
    return _selectedReligion;
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _currentFormattedValue != widget.currentValue;
    if (!hasChanges) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) Navigator.pop(context, _currentFormattedValue);
      return false;
    }
    return result == false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, 'Religion & Caste', _onWillPop),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What\'s your religion?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your religion and caste.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: _religions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final religion = _religions[index];
                      final isSelectedReligion = _selectedReligion == religion;
                      final hasCastes = _castes.containsKey(religion);

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelectedReligion
                              ? const Color(0xFFE43A6A).withOpacity(0.03)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelectedReligion
                                ? const Color(0xFFE43A6A)
                                : Colors.grey.shade200,
                            width: isSelectedReligion ? 2 : 1,
                          ),
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              // Religion Row
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    _selectedReligion = religion;
                                    if (!hasCastes)
                                      _selectedCaste = '';
                                    else if (!(_castes[religion]?.contains(
                                          _selectedCaste,
                                        ) ??
                                        false)) {
                                      _selectedCaste = '';
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          religion,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelectedReligion
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelectedReligion
                                                ? const Color(0xFFE43A6A)
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelectedReligion)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFFE43A6A),
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Accordion / Expanded Caste List
                              if (isSelectedReligion && hasCastes) ...[
                                Divider(
                                  height: 1,
                                  color: const Color(
                                    0xFFE43A6A,
                                  ).withOpacity(0.2),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select caste · $religion',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _castes[religion]!.map((
                                          caste,
                                        ) {
                                          final isSelectedCaste =
                                              _selectedCaste == caste;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedCaste = caste;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelectedCaste
                                                    ? const Color(0xFFE43A6A)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: isSelectedCaste
                                                      ? const Color(0xFFE43A6A)
                                                      : Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                caste,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: isSelectedCaste
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelectedCaste
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _currentFormattedValue);
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
