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
                  _buildSiblingItem(
                    context: context,
                    label: 'SISTERS',
                    value: state.sisters,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateSisters(val),
                  ),
                  _buildDivider(),
                  _buildSiblingItem(
                    context: context,
                    label: 'BROTHERS',
                    value: state.brothers,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateBrothers(val),
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
                  _buildDivider(),
                  _buildTextFieldItem(
                    context: context,
                    label: 'FAMILY DYNAMIC',
                    value: state.familyDynamic,
                    isMultiline: true,
                    maxLength: 300,
                    onSelect: (val) => context.read<ProfileEditCubit>().updateFamilyDynamic(val),
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

  Widget _buildSiblingItem({
    required BuildContext context,
    required String label,
    required String value,
    required Function(String) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => SiblingFlowScreen(
              title: label == 'SISTERS' ? 'Sisters' : 'Brothers',
              currentValue: value,
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
                    value.isNotEmpty ? value : 'Add',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: isMultiline ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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

class SiblingFlowScreen extends StatefulWidget {
  final String title; // 'Sisters' or 'Brothers'
  final String currentValue;

  const SiblingFlowScreen({
    super.key,
    required this.title,
    required this.currentValue,
  });

  @override
  State<SiblingFlowScreen> createState() => _SiblingFlowScreenState();
}

class _SiblingFlowScreenState extends State<SiblingFlowScreen> {
  int? _siblingCount;
  List<SiblingDetail> _siblingDetails = [];

  final List<int> _countOptions = [0, 1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(
          context,
          widget.title,
          () async => true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How many ${widget.title.toLowerCase()} do you have?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select the number below.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: _countOptions.map((count) {
                    final isNone = count == 0;
                    final text = count == 5 ? '5+' : count.toString();
                    return InkWell(
                      borderRadius: BorderRadius.circular(isNone ? 24 : 24),
                      onTap: () {
                        setState(() {
                          _siblingCount = count;
                          _siblingDetails = List.generate(count, (_) => SiblingDetail());
                        });
                        _startDetailsFlow();
                      },
                      child: Container(
                        width: isNone ? 100 : 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: isNone ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: isNone ? BorderRadius.circular(24) : null,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isNone ? 'None' : text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDetailsFlow() async {
    if (_siblingCount == null || _siblingCount == 0) {
      Navigator.pop(context, '${widget.title} · None');
      return;
    }

    // Process each sibling
    for (int i = 0; i < _siblingCount!; i++) {
      final result = await Navigator.push<SiblingDetail>(
        context,
        MaterialPageRoute(
          builder: (context) => SiblingDetailScreen(
            title: widget.title,
            siblingIndex: i + 1,
            totalSiblings: _siblingCount!,
          ),
        ),
      );

      if (result == null) {
        // User cancelled the flow, we should reset or stop
        return;
      }
      _siblingDetails[i] = result;
    }

    // Once all siblings are processed, compile the result and pop
    String formattedResult = '$_siblingCount';
    for (int i = 0; i < _siblingCount!; i++) {
      formattedResult += '\n${i + 1}: ${_siblingDetails[i].maritalStatus}, ${_siblingDetails[i].occupation}';
    }

    if (mounted) {
      Navigator.pop(context, formattedResult);
    }
  }
}

class SiblingDetail {
  String maritalStatus = '';
  String occupation = '';
}

class SiblingDetailScreen extends StatefulWidget {
  final String title;
  final int siblingIndex;
  final int totalSiblings;

  const SiblingDetailScreen({
    super.key,
    required this.title,
    required this.siblingIndex,
    required this.totalSiblings,
  });

  @override
  State<SiblingDetailScreen> createState() => _SiblingDetailScreenState();
}

class _SiblingDetailScreenState extends State<SiblingDetailScreen> {
  int _currentStep = 1; // 1: Marital Status, 2: Occupation
  String _maritalStatus = '';
  
  final List<String> _maritalOptions = ['Unmarried', 'Married', 'Engaged'];
  final List<String> _occupationOptions = [
    'Studying',
    'Working',
    'Business',
    'Homemaker',
    'Not working'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(
          context,
          widget.title,
          () async => true,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _currentStep / 2,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE43A6A)),
              minHeight: 4,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE43A6A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.title.substring(0, widget.title.length - 1)} ${widget.siblingIndex}',
                            style: const TextStyle(
                              color: Color(0xFFE43A6A),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          'Step $_currentStep/2',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _currentStep == 1 ? 'Marital status' : 'What do they do?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    if (_currentStep == 2) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$_maritalStatus · now pick occupation',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _currentStep == 1 ? _maritalOptions.length : _occupationOptions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final text = _currentStep == 1 ? _maritalOptions[index] : _occupationOptions[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (_currentStep == 1) {
                                setState(() {
                                  _maritalStatus = text;
                                  _currentStep = 2; // Move to next step
                                });
                              } else {
                                // Complete
                                final detail = SiblingDetail()
                                  ..maritalStatus = _maritalStatus
                                  ..occupation = text;
                                Navigator.pop(context, detail);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
