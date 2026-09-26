import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../edit_profile/bloc/profile_edit_cubit.dart';
import '../../edit_profile/services/edit_profile_api_service.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';
// import '../../edit_profile/bloc/profile_edit_state.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch initial values from Bloc state (as fallback)
    final state = context.read<ProfileEditCubit>().state;
    _nameController = TextEditingController(text: state.fullName);
    _emailController = TextEditingController(text: state.email);
    _phoneController = TextEditingController();
    _dobController = TextEditingController(text: state.dob);
    
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final response = await EditProfileApiService.getProfileDetails();
    if (response['error'] == null && response['data'] != null) {
      final data = response['data'];
      final basicDetails = data['basicDetails'] ?? {};
      
      String rawPhone = basicDetails['phoneNumber']?.toString() ?? data['phoneNumber']?.toString() ?? basicDetails['phone']?.toString() ?? '';
      
      // Remove any non-digit characters (like +, -, spaces)
      String phone = rawPhone.replaceAll(RegExp(r'\D'), '');
      // If the number includes a country code (e.g. 918806655218), take the last 10 digits
      if (phone.length > 10) {
        phone = phone.substring(phone.length - 10);
      }

      setState(() {
        if (basicDetails['fullName'] != null && basicDetails['fullName'].toString().isNotEmpty) {
          _nameController.text = basicDetails['fullName'];
        }
        if (basicDetails['email'] != null && basicDetails['email'].toString().isNotEmpty) {
          _emailController.text = basicDetails['email'];
        }
        if (phone.isNotEmpty) {
          _phoneController.text = phone;
        }
        
        String dob = basicDetails['birthDate']?.toString() ?? '';
        if (dob.isNotEmpty) {
          // Format dob if it's in ISO format
          if (dob.contains('T')) dob = dob.split('T').first;
          final parts = dob.split('-');
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              _dobController.text = '${parts[2]} / ${parts[1]} / ${parts[0]}';
            } else {
              _dobController.text = '${parts[0]} / ${parts[1]} / ${parts[2]}';
            }
          } else {
            _dobController.text = dob;
          }
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  int _calculateAge(String dobString) {
    try {
      final parts = dobString
          .split(RegExp(r'[\/\-]'))
          .map((e) => e.trim())
          .toList();
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        final selectedDate = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - selectedDate.year;
        if (now.month < selectedDate.month ||
            (now.month == selectedDate.month && now.day < selectedDate.day)) {
          age--;
        }
        return age;
      }
    } catch (e) {
      AppLogger.w('PersonalInfoScreen', 'Failed to calculate age from DOB: $e');
    }
    return 27; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE43A6A),
                ),
              )
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        label: 'Full name',
                        controller: _nameController,
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        label: 'Email',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        label: 'Phone',
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        label: 'Date of birth',
                        controller: _dobController,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your age (${_calculateAge(_dobController.text)}) is shown on your profile — never your full date of birth.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            enableInteractiveSelection: false, // Prevents text selection/copying if desired, makes it fully read-only feeling
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE43A6A),
                  width: 1.5,
                ),
              ),
              errorStyle: const TextStyle(color: Colors.red),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
