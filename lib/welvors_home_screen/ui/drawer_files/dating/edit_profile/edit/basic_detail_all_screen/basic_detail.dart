import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/bloc/profile_edit_state.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';

class BasicDetailsSection extends StatelessWidget {
  const BasicDetailsSection({super.key});

  int _calculateAge(String dobString) {
    try {
      final parts = dobString.split(' / ');
      if (parts.length == 3) {
        int year = int.parse(parts[2]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[0]);
        final selectedDate = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - selectedDate.year;
        if (now.month < selectedDate.month ||
            (now.month == selectedDate.month && now.day < selectedDate.day)) {
          age--;
        }
        return age;
      }
    } catch (e) {}
    return 28;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE43A6A), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Color(0xFFE43A6A), size: 10),
                ),
                const SizedBox(width: 8),
                const Text(
                  'BASIC DETAILS',
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
                  _buildEditableField('FULL NAME', state.fullName, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTextInputScreen(
                          title: 'Name',
                          label: 'FULL NAME',
                          headerText: 'What\'s your full name?',
                          subHeaderText:
                              'Please enter your valid and full name for better connections.',
                          currentValue: state.fullName,
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateFullName(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('EMAIL ID', state.email, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTextInputScreen(
                          title: 'Email',
                          label: 'EMAIL ID',
                          headerText: 'What\'s your email ID?',
                          subHeaderText: 'We use this to keep your account secure.',
                          currentValue: state.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateEmail(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableDobField(context, state.dob),
                  _buildDivider(),
                  _buildEditableField('HEIGHT', state.height, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHeightScreen(currentValue: state.height),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateHeight(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('GENDER', state.gender, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericListPickerScreen(
                          title: 'Gender',
                          headerText: 'What\'s your gender?',
                          subHeaderText: 'You can select what appears on your profile.',
                          currentValue: state.gender,
                          options: ['Woman', 'Man', 'Non-binary', 'Prefer not to say'],
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateGender(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('GENDER IDENTITY', state.genderIdentity, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericListPickerScreen(
                          title: 'Gender Identity',
                          headerText: 'What\'s your gender identity?',
                          subHeaderText: 'This helps us find the best matches for you.',
                          currentValue: state.genderIdentity,
                          options: ['Cis woman', 'Trans woman', 'Intersex woman', 'Cis man', 'Trans man', 'Intersex man'],
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateGenderIdentity(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('RELIGION & CASTE', state.religionCaste, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditReligionCasteScreen(currentValue: state.religionCaste),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateReligionCaste(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('MOTHER TONGUE', state.motherTongue, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericListPickerScreen(
                          title: 'Mother Tongue',
                          headerText: 'What\'s your mother tongue?',
                          subHeaderText: 'The language you grew up speaking.',
                          currentValue: state.motherTongue,
                          options: ['Marathi', 'Hindi', 'English', 'Gujarati', 'Tamil', 'Telugu'],
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateMotherTongue(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('ZODIAC', state.zodiac, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericListPickerScreen(
                          title: 'Zodiac',
                          headerText: 'What\'s your Zodiac sign?',
                          subHeaderText: 'Let the stars decide your match.',
                          currentValue: state.zodiac,
                          options: ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'],
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateZodiac(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('LOVE LANGUAGE', state.loveLanguage, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericListPickerScreen(
                          title: 'Love Language',
                          headerText: 'What\'s your love language?',
                          subHeaderText: 'How do you prefer to give and receive love?',
                          currentValue: state.loveLanguage,
                          options: ['Words of affirmation', 'Quality time', 'Receiving gifts', 'Acts of service', 'Physical touch'],
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateLoveLanguage(result);
                    }
                  }),
                  _buildDivider(),
                  _buildEditableField('COMMUNICATION', state.communication, () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericListPickerScreen(
                          title: 'Communication',
                          headerText: 'How do you communicate?',
                          subHeaderText: 'Your preferred style of communicating.',
                          currentValue: state.communication,
                          options: ['Phone calls over texts', 'Texts over phone calls', 'In person only', 'Video calls'],
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileEditCubit>().updateCommunication(result);
                    }
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
    );
  }

  Widget _buildEditableDobField(BuildContext context, String dob) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => EditDobScreen(currentValue: dob),
          ),
        );
        if (result != null && context.mounted) {
          context.read<ProfileEditCubit>().updateDob(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DATE OF BIRTH',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dob,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: "You'll appear as ",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                      children: [
                        TextSpan(
                          text: "${_calculateAge(dob)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const TextSpan(text: " — we only show your age."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }
}
