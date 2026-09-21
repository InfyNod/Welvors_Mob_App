import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/services/edit_profile_api_service.dart';

import 'package:velvors/config/env_config.dart';

class FamilySection extends StatefulWidget {
  const FamilySection({super.key});

  @override
  State<FamilySection> createState() => _FamilySectionState();
}

class _FamilySectionState extends State<FamilySection> {
  List<Map<String, dynamic>> _familyTypeOptionsMap = [];
  List<Map<String, dynamic>> _fatherOccupationOptionsMap = [];
  List<Map<String, dynamic>> _fatherOrganizationOptionsMap = [];
  List<Map<String, dynamic>> _motherOptionsMap = [];
  List<Map<String, dynamic>> _organizationOptionsMap = [];
  List<Map<String, dynamic>> _familyHomeOptionsMap = [];
  List<Map<String, dynamic>> _nativePlaceOptionsMap = [];
  List<Map<String, dynamic>> _familyIncomeOptionsMap = [];

  int? _familyTypeId;
  int? _fatherOccupationId;
  int? _fatherOrganisationId;
  int? _motherOccupationId;
  int? _motherOrganisationId;
  int? _familyHomeId;
  int? _nativePlaceId;
  int? _familyIncomeId;
  
  Map<String, dynamic> _brothersData = {'count': 0, 'details': []};
  Map<String, dynamic> _sistersData = {'count': 0, 'details': []};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<List<Map<String, dynamic>>> _fetchOptionsWithId(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final url = Uri.parse('${EnvConfig.apiBaseUrl}/admin/family/options?type=$type');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List dataList = decoded['data'] ?? (decoded is List ? decoded : []);
        return dataList.map((e) {
          if (e is Map) {
            final id = e['id'] ?? e['_id'];
            final value = e['value'] ?? e['name'];
            return {'id': id, 'value': value?.toString() ?? ''};
          }
          return {'id': null, 'value': e.toString()};
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching $type: $e');
    }
    return [];
  }

  Future<void> _patchFamilyData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.patch(
        Uri.parse('${EnvConfig.apiBaseUrl}/user/profile/family'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Failed to patch family data: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error patching family data: $e');
    }
  }

  int? _getIdFor(String value, List<Map<String, dynamic>> mapList) {
    for (var map in mapList) {
      if (map['value'] == value) return map['id'];
    }
    return null;
  }

  Future<void> _fetchOptions() async {
    final familyTypeOptions = await _fetchOptionsWithId('familyType');
    final fatherOcc = await _fetchOptionsWithId('fatherOccupation');
    final fatherOrg = await _fetchOptionsWithId('fatherOrganisation');
    final motherOcc = await _fetchOptionsWithId('motherOccupation');
    final motherOrg = await _fetchOptionsWithId('motherOrganisation');
    final familyHome = await _fetchOptionsWithId('familyHome');
    final nativePlace = await _fetchOptionsWithId('nativePlace');
    final familyIncome = await _fetchOptionsWithId('familyIncome');

    if (mounted) {
      setState(() {
        _familyTypeOptionsMap = familyTypeOptions;
        _fatherOccupationOptionsMap = fatherOcc;
        _fatherOrganizationOptionsMap = fatherOrg;
        _motherOptionsMap = motherOcc;
        _organizationOptionsMap = motherOrg;
        _familyHomeOptionsMap = familyHome;
        _nativePlaceOptionsMap = nativePlace;
        _familyIncomeOptionsMap = familyIncome;
        
        final state = context.read<ProfileEditCubit>().state;
        _familyTypeId = _getIdFor(state.familyType, _familyTypeOptionsMap);
        _fatherOccupationId = _getIdFor(state.father, _fatherOccupationOptionsMap);
        // Father organisation is normally embedded in state.father if formatted, but let's just rely on state if it's there.
        // For simple fields:
        _familyHomeId = _getIdFor(state.familyHome, _familyHomeOptionsMap);
        _nativePlaceId = _getIdFor(state.nativePlace, _nativePlaceOptionsMap);
        _familyIncomeId = _getIdFor(state.familyIncome, _familyIncomeOptionsMap);
        
        _brothersData = state.brothersData ?? {};
        _sistersData = state.sistersData ?? {};

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
      );
    }
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
                  _buildListItem(
                    context: context,
                    label: 'FAMILY TYPE',
                    value: state.familyType,
                    options: _familyTypeOptionsMap.isNotEmpty ? _familyTypeOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateFamilyType(val);
                      final id = _getIdFor(val, _familyTypeOptionsMap);
                      if (id != null) _patchFamilyData({'familyTypeId': id});
                    },
                  ),
                  _buildDivider(),
                  _buildParentItem(
                    context: context,
                    label: 'FATHER',
                    value: state.father,
                    occupationOptions: _fatherOccupationOptionsMap.isNotEmpty ? _fatherOccupationOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    organizationOptions: _fatherOrganizationOptionsMap.isNotEmpty ? _fatherOrganizationOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateFather(val);
                      if (val.contains('·')) {
                        final parts = val.split('·').map((e) => e.trim()).toList();
                        final occId = _getIdFor(parts[0], _fatherOccupationOptionsMap);
                        final orgId = parts.length > 1 ? _getIdFor(parts[1], _fatherOrganizationOptionsMap) : null;
                        if (occId != null) {
                          final data = <String, dynamic>{'fatherOccupationId': occId};
                          if (orgId != null) data['fatherOrganisationId'] = orgId;
                          _patchFamilyData(data);
                        }
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildParentItem(
                    context: context,
                    label: 'MOTHER',
                    value: state.mother,
                    occupationOptions: _motherOptionsMap.isNotEmpty ? _motherOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    organizationOptions: _organizationOptionsMap.isNotEmpty ? _organizationOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateMother(val);
                      if (val.contains('·')) {
                        final parts = val.split('·').map((e) => e.trim()).toList();
                        final occId = _getIdFor(parts[0], _motherOptionsMap);
                        final orgId = parts.length > 1 ? _getIdFor(parts[1], _organizationOptionsMap) : null;
                        if (occId != null) {
                          final data = <String, dynamic>{'motherOccupationId': occId};
                          if (orgId != null) data['motherOrganisationId'] = orgId;
                          _patchFamilyData(data);
                        }
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildSiblingItem(
                    context: context,
                    label: 'SISTERS',
                    value: state.sisters,
                    onSelect: (val, data) {
                      context.read<ProfileEditCubit>().updateSisters(val);
                      if (data != null) {
                        _sistersData = data;
                        
                        final List<Map<String, dynamic>> siblingsArray = [];
                        final brothersDetails = _brothersData['details'] as List<dynamic>? ?? [];
                        for (var d in brothersDetails) {
                          siblingsArray.add({
                            'siblingTypeId': 55, // 55 for Brother
                            'occupationId': d['occupationId'],
                            'maritalId': d['maritalId'],
                          });
                        }
                        final sistersDetails = _sistersData['details'] as List<dynamic>? ?? [];
                        for (var d in sistersDetails) {
                          siblingsArray.add({
                            'siblingTypeId': 56, // 56 for Sister
                            'occupationId': d['occupationId'],
                            'maritalId': d['maritalId'],
                          });
                        }

                        _patchFamilyData({'siblings': siblingsArray});
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildSiblingItem(
                    context: context,
                    label: 'BROTHERS',
                    value: state.brothers,
                    onSelect: (val, data) {
                      context.read<ProfileEditCubit>().updateBrothers(val);
                      if (data != null) {
                        _brothersData = data;
                        
                        final List<Map<String, dynamic>> siblingsArray = [];
                        final brothersDetails = _brothersData['details'] as List<dynamic>? ?? [];
                        for (var d in brothersDetails) {
                          siblingsArray.add({
                            'siblingTypeId': 55, // 55 for Brother
                            'occupationId': d['occupationId'],
                            'maritalId': d['maritalId'],
                          });
                        }
                        final sistersDetails = _sistersData['details'] as List<dynamic>? ?? [];
                        for (var d in sistersDetails) {
                          siblingsArray.add({
                            'siblingTypeId': 56, // 56 for Sister
                            'occupationId': d['occupationId'],
                            'maritalId': d['maritalId'],
                          });
                        }

                        _patchFamilyData({'siblings': siblingsArray});
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'FAMILY HOME',
                    value: state.familyHome,
                    options: _familyHomeOptionsMap.isNotEmpty ? _familyHomeOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateFamilyHome(val);
                      final id = _getIdFor(val, _familyHomeOptionsMap);
                      if (id != null) _patchFamilyData({'familyHomeId': id});
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'NATIVE PLACE',
                    value: state.nativePlace,
                    options: _nativePlaceOptionsMap.isNotEmpty ? _nativePlaceOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateNativePlace(val);
                      final id = _getIdFor(val, _nativePlaceOptionsMap);
                      if (id != null) _patchFamilyData({'nativePlaceId': id});
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    context: context,
                    label: 'FAMILY INCOME',
                    value: state.familyIncome,
                    options: _familyIncomeOptionsMap.isNotEmpty ? _familyIncomeOptionsMap.map((e) => e['value'].toString()).toList() : [],
                    onSelect: (val) {
                      context.read<ProfileEditCubit>().updateFamilyIncome(val);
                      final id = _getIdFor(val, _familyIncomeOptionsMap);
                      if (id != null) _patchFamilyData({'familyIncomeId': id});
                    },
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

  Widget _buildParentItem({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> occupationOptions,
    required List<String> organizationOptions,
    required Function(String) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepParentPickerScreen(
              title: label,
              occupationOptions: occupationOptions,
              organizationOptions: organizationOptions,
              currentOccupation: value.split(' · ').first,
              currentOrganization: value.split(' · ').length > 1 ? value.split(' · ')[1] : '',
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
    required Function(String, Map<String, dynamic>?) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => SiblingFlowScreen(
              title: label == 'SISTERS' ? 'Sisters' : 'Brothers',
              currentValue: value,
            ),
          ),
        );
        if (result != null) {
          onSelect(result['formatted'] as String, result['data'] as Map<String, dynamic>);
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
      Navigator.pop(context, {
        'formatted': '${widget.title} · None',
        'data': {'count': 0, 'details': []},
      });
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
    List<Map<String, dynamic>> detailsList = [];
    for (int i = 0; i < _siblingCount!; i++) {
      formattedResult += '\n${i + 1}: ${_siblingDetails[i].maritalStatus}, ${_siblingDetails[i].occupation}';
      detailsList.add({
        'occupationId': _siblingDetails[i].occupationId,
        'maritalId': _siblingDetails[i].maritalId,
      });
    }

    if (mounted) {
      Navigator.pop(context, {
        'formatted': formattedResult,
        'data': {
          'count': _siblingCount,
          'details': detailsList,
        },
      });
    }
  }
}

class SiblingDetail {
  String maritalStatus = '';
  String occupation = '';
  int? maritalId;
  int? occupationId;
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
  
  List<Map<String, dynamic>> _maritalOptionsMap = [];
  List<Map<String, dynamic>> _occupationOptionsMap = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<List<Map<String, dynamic>>> _fetchOptionsWithId(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final url = Uri.parse('${EnvConfig.apiBaseUrl}/admin/family/options?type=$type');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List dataList = decoded['data'] ?? (decoded is List ? decoded : []);
        return dataList.map((e) {
          if (e is Map) {
            final id = e['id'] ?? e['_id'];
            final value = e['value'] ?? e['name'];
            return {'id': id, 'value': value?.toString() ?? ''};
          }
          return {'id': null, 'value': e.toString()};
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching $type: $e');
    }
    return [];
  }

  Future<void> _fetchOptions() async {
    try {
      final marital = await _fetchOptionsWithId('siblingMarital');
      final occupation = await _fetchOptionsWithId('siblingOccupation');
      
      if (mounted) {
        setState(() {
          _maritalOptionsMap = marital;
          _occupationOptionsMap = occupation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int? _getIdFor(String value, List<Map<String, dynamic>> mapList) {
    for (var map in mapList) {
      if (map['value'] == value) return map['id'];
    }
    return null;
  }

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
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE43A6A)))
                          : ListView.separated(
                              itemCount: _currentStep == 1 ? _maritalOptionsMap.length : _occupationOptionsMap.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final text = _currentStep == 1 ? _maritalOptionsMap[index]['value'].toString() : _occupationOptionsMap[index]['value'].toString();
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
                                  ..occupation = text
                                  ..maritalId = _getIdFor(_maritalStatus, _maritalOptionsMap)
                                  ..occupationId = _getIdFor(text, _occupationOptionsMap);
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

class MultiStepParentPickerScreen extends StatefulWidget {
  final String title;
  final List<String> occupationOptions;
  final List<String> organizationOptions;
  final String currentOccupation;
  final String currentOrganization;

  const MultiStepParentPickerScreen({
    Key? key,
    required this.title,
    required this.occupationOptions,
    required this.organizationOptions,
    required this.currentOccupation,
    required this.currentOrganization,
  }) : super(key: key);

  @override
  State<MultiStepParentPickerScreen> createState() => _MultiStepParentPickerScreenState();
}

class _MultiStepParentPickerScreenState extends State<MultiStepParentPickerScreen> {
  int _step = 0; // 0 for Occupation, 1 for Organization
  late String _selectedOccupation;
  late String _selectedOrganization;

  @override
  void initState() {
    super.initState();
    _selectedOccupation = widget.currentOccupation;
    _selectedOrganization = widget.currentOrganization;
  }

  Future<bool> _onWillPop() async {
    if (_step == 1) {
      setState(() {
        _step = 0;
      });
      return false; // Prevent pop, just go back to step 0
    }

    final hasChanges = _selectedOccupation != widget.currentOccupation || _selectedOrganization != widget.currentOrganization;
    if (!hasChanges) return true;

    final result = await showUnsavedChangesDialog(context);
    if (result == true) {
      if (mounted) Navigator.pop(context, null);
      return false;
    }
    return result == false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOccupationStep = _step == 0;
    final List<String> currentOptions = isOccupationStep ? widget.occupationOptions : widget.organizationOptions;
    final String currentSelected = isOccupationStep ? _selectedOccupation : _selectedOrganization;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: buildCustomAppBar(context, widget.title, _onWillPop),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smooth Progress Bar
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0.5,
                  end: isOccupationStep ? 0.5 : 1.0,
                ),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFFE43A6A),
                    minHeight: 4,
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOccupationStep ? 'Occupation' : 'Organization',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOccupationStep ? 'Please select an occupation' : 'Please select an organization',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: ListView.separated(
                          itemCount: currentOptions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final option = currentOptions[index];
                            final isSelected = currentSelected == option;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isOccupationStep) {
                                    _selectedOccupation = option;
                                  } else {
                                    _selectedOrganization = option;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE43A6A).withOpacity(0.05) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
                                        ),
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
                          onPressed: currentSelected.isEmpty ? null : () {
                            if (isOccupationStep) {
                              setState(() {
                                _step = 1;
                              });
                            } else {
                              // Both steps completed, save and pop
                              Navigator.pop(context, '$_selectedOccupation · $_selectedOrganization');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE43A6A),
                            disabledBackgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isOccupationStep ? 'Continue' : 'Save Changes',
                            style: const TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }
}
