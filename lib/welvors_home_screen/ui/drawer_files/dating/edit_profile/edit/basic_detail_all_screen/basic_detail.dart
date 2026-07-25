import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/edit_profile/edit/basic_detail_all_screen/basic_details_screens.dart';

class BasicDetailsSection extends StatefulWidget {
  const BasicDetailsSection({super.key});

  @override
  State<BasicDetailsSection> createState() => _BasicDetailsSectionState();
}

class _BasicDetailsSectionState extends State<BasicDetailsSection> {
  // Mock data for the UI - removed 'final' to allow updates via setState
  String _fullName = "Ananya Deshpande";
  String _email = "ananya.d@email.com";
  String _dob = "12 / 08 / 1997";
  int _age = 28;
  
  String _height = "5'5\" · 165 cm";
  String _gender = "Woman";
  String _genderIdentity = "Cis woman";
  String _religionCaste = "Hindu · Maratha";
  String _motherTongue = "Marathi";
  String _zodiac = "Scorpio";
  String _loveLanguage = "Words of affirmation";
  String _communication = "Phone calls over texts";

  // Helper method to parse age from DOB string 'dd / MM / yyyy'
  void _updateAgeFromDob(String dobString) {
    try {
      final parts = dobString.split(' / ');
      if (parts.length == 3) {
        int year = int.parse(parts[2]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[0]);
        final selectedDate = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - selectedDate.year;
        if (now.month < selectedDate.month || (now.month == selectedDate.month && now.day < selectedDate.day)) {
          age--;
        }
        setState(() {
          _dob = dobString;
          _age = age;
        });
      }
    } catch (e) {
      // fallback
      setState(() { _dob = dobString; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildEditableField('FULL NAME', _fullName, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => EditTextInputScreen(
                    title: 'Name', label: 'FULL NAME', currentValue: _fullName,
                  )),
                );
                if (result != null && mounted) setState(() { _fullName = result; });
              }),
              _buildDivider(),
              _buildEditableField('EMAIL ID', _email, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => EditTextInputScreen(
                    title: 'Email', label: 'EMAIL ID', currentValue: _email, keyboardType: TextInputType.emailAddress,
                  )),
                );
                if (result != null && mounted) setState(() { _email = result; });
              }),
              _buildDivider(),
              _buildEditableDobField(),
              _buildDivider(),
              _buildEditableField('HEIGHT', _height, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => EditHeightScreen(currentValue: _height)),
                );
                if (result != null && mounted) setState(() { _height = result; });
              }),
              _buildDivider(),
              _buildEditableField('GENDER', _gender, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Gender', headerText: 'What\'s your gender?', subHeaderText: 'You can select what appears on your profile.',
                    currentValue: _gender, options: ['Woman', 'Man', 'Non-binary', 'Prefer not to say'],
                  )),
                );
                if (result != null && mounted) setState(() { _gender = result; });
              }),
              _buildDivider(),
              _buildEditableField('GENDER IDENTITY', _genderIdentity, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Gender Identity', headerText: 'What\'s your gender identity?', subHeaderText: 'This helps us find the best matches for you.',
                    currentValue: _genderIdentity, options: ['Cis woman', 'Trans woman', 'Prefer not to say'],
                  )),
                );
                if (result != null && mounted) setState(() { _genderIdentity = result; });
              }),
              _buildDivider(),
              _buildEditableField('RELIGION & CASTE', _religionCaste, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Religion', headerText: 'What\'s your religion?', subHeaderText: 'Add your religion and caste.',
                    currentValue: _religionCaste, options: ['Hindu · Maratha', 'Hindu · Brahmin', 'Muslim', 'Christian', 'Sikh', 'Other'],
                  )),
                );
                if (result != null && mounted) setState(() { _religionCaste = result; });
              }),
              _buildDivider(),
              _buildEditableField('MOTHER TONGUE', _motherTongue, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Mother Tongue', headerText: 'What\'s your mother tongue?', subHeaderText: 'The language you grew up speaking.',
                    currentValue: _motherTongue, options: ['Marathi', 'Hindi', 'English', 'Gujarati', 'Tamil', 'Telugu'],
                  )),
                );
                if (result != null && mounted) setState(() { _motherTongue = result; });
              }),
              _buildDivider(),
              _buildEditableField('ZODIAC', _zodiac, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Zodiac', headerText: 'What\'s your Zodiac sign?', subHeaderText: 'Let the stars decide your match.',
                    currentValue: _zodiac, options: ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'],
                  )),
                );
                if (result != null && mounted) setState(() { _zodiac = result; });
              }),
              _buildDivider(),
              _buildEditableField('LOVE LANGUAGE', _loveLanguage, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Love Language', headerText: 'What\'s your love language?', subHeaderText: 'How do you prefer to give and receive love?',
                    currentValue: _loveLanguage, options: ['Words of affirmation', 'Quality time', 'Receiving gifts', 'Acts of service', 'Physical touch'],
                  )),
                );
                if (result != null && mounted) setState(() { _loveLanguage = result; });
              }),
              _buildDivider(),
              _buildEditableField('COMMUNICATION', _communication, () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => GenericListPickerScreen(
                    title: 'Communication', headerText: 'How do you communicate?', subHeaderText: 'Your preferred style of communicating.',
                    currentValue: _communication, options: ['Phone calls over texts', 'Texts over phone calls', 'In person only', 'Video calls'],
                  )),
                );
                if (result != null && mounted) setState(() { _communication = result; });
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
    );
  }

  Widget _buildEditableDobField() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => EditDobScreen(currentValue: _dob)),
        );
        if (result != null && mounted) {
          _updateAgeFromDob(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  const SizedBox(height: 6),
                  Text(
                    _dob,
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
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      children: [
                        TextSpan(
                          text: "$_age",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  const SizedBox(height: 6),
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
