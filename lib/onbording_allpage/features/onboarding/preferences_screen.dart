import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';

class PreferencesScreen extends StatefulWidget {
  final VoidCallback onNext;
  const PreferencesScreen({super.key, required this.onNext});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> with AutomaticKeepAliveClientMixin  {
  String? _selectedPreference;
  final Set<String> _selectedSubPreferences = {};
  bool _isLoading = false;

  final List<Map<String, String>> _orientationOptions = [
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

  bool get _isFormValid => _selectedPreference != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchOnboardingDetails('INTERESTED_IN');
    if (data != null && mounted) {
      setState(() {
        if (data['interestedIn'] != null) {
          _selectedPreference = data['interestedIn'];
          userData.interestedIn = data['interestedIn'];
        }
      });
    }
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? expandedContent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pinkSoft.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.pinkDeep : AppColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.body.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.pinkDeep
                                : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppText.sub.copyWith(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? AppColors.pinkDeep : AppColors.line,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (isSelected && expandedContent != null) expandedContent,
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationCard(Map<String, String> option) {
    final isSelected = _selectedSubPreferences.contains(option['title']!);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSubPreferences.remove(option['title']!);
          } else {
            _selectedSubPreferences.add(option['title']!);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE9EE) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.pinkDeep : AppColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title']!,
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.pinkDeep : AppColors.ink,
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
            if (isSelected) const Icon(Icons.check, color: AppColors.pinkDeep),
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationOptions({required String helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.pinkDeep.withOpacity(0.2), height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Sexual orientation',
                    style: AppText.sub.copyWith(
                      color: AppColors.pinkDeep,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orientationOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildOrientationCard(_orientationOptions[index]);
                },
              ),
              const SizedBox(height: 16),
              Text(
                helperText,
                style: AppText.sub.copyWith(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
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
                  'PREFERENCES',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Who are you interested\nin seeing for a date?',
                  style: AppText.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 32),

                _buildCard(
                  title: 'Women',
                  subtitle: 'Show me women',
                  icon: Icons.female,
                  iconColor: AppColors.pinkDeep,
                  iconBg: AppColors.pinkSoft,
                  isSelected: _selectedPreference == 'Women',
                  onTap: () {
                    setState(() {
                      if (_selectedPreference == 'Women') {
                        _selectedPreference = null;
                      } else {
                        _selectedPreference = 'Women';
                        _selectedSubPreferences.clear();
                      }
                    });
                  },
                  expandedContent: _buildOrientationOptions(
                    helperText: 'Leave blank to see all women.',
                  ),
                ),

                _buildCard(
                  title: 'Man',
                  subtitle: 'Show me men',
                  icon: Icons.male,
                  iconColor: AppColors.blue,
                  iconBg: AppColors.blue.withOpacity(0.15),
                  isSelected: _selectedPreference == 'Man',
                  onTap: () {
                    setState(() {
                      if (_selectedPreference == 'Man') {
                        _selectedPreference = null;
                      } else {
                        _selectedPreference = 'Man';
                        _selectedSubPreferences.clear();
                      }
                    });
                  },
                  expandedContent: _buildOrientationOptions(
                    helperText: 'Leave blank to see all men.',
                  ),
                ),

                _buildCard(
                  title: 'Everyone',
                  subtitle: 'Show me everyone',
                  icon: Icons.transgender,
                  iconColor: AppColors.gold,
                  iconBg: AppColors.gold.withOpacity(0.15),
                  isSelected: _selectedPreference == 'Everyone',
                  onTap: () {
                    setState(() {
                      if (_selectedPreference == 'Everyone') {
                        _selectedPreference = null;
                      } else {
                        _selectedPreference = 'Everyone';
                        _selectedSubPreferences.clear();
                      }
                    });
                  },
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
            20,
          ),
          child: PrimaryButton(
            _isLoading ? 'Saving...' : 'Continue',
            onTap: (_isFormValid && !_isLoading)
                ? () async {
                    setState(() => _isLoading = true);

                    userData.interestedIn = _selectedPreference ?? 'Everyone';

                    // Backend Prisma schema expects the Gender enum, usually uppercase like 'WOMEN', 'MEN', 'EVERYONE'
                    String interestedInValue = 'EVERYONE';
                    if (_selectedPreference == 'Man') interestedInValue = 'MEN';
                    if (_selectedPreference == 'Women')
                      interestedInValue = 'WOMEN';

                    String sexualOrientationValue = 'NOT_LISTED';
                    if (_selectedSubPreferences.isNotEmpty) {
                      final orientation = _selectedSubPreferences.first;
                      switch (orientation) {
                        case 'Straight':
                          sexualOrientationValue = 'STRAIGHT';
                          break;
                        case 'Gay':
                          sexualOrientationValue = 'GAY';
                          break;
                        case 'Lesbian':
                          sexualOrientationValue = 'LESBIAN';
                          break;
                        case 'Aromantic':
                          sexualOrientationValue = 'AROMATIC';
                          break;
                        case 'Asexual':
                          sexualOrientationValue = 'ASEXUAL';
                          break;
                        case 'Bisexual':
                          sexualOrientationValue = 'BISEXUAL';
                          break;
                        case 'Demisexual':
                          sexualOrientationValue = 'DEMISEXUAL';
                          break;
                        case 'Pansexual':
                          sexualOrientationValue = 'PANSEXUAL';
                          break;
                        case 'Queer':
                          sexualOrientationValue = 'QUEER';
                          break;
                        case 'Questioning':
                          sexualOrientationValue = 'NOT_LISTED';
                          break;
                      }
                    }

                    final errorMsg = await ApiService.submitInterestedIn(
                      interestedInValue,
                      sexualOrientationValue,
                    );
                    setState(() => _isLoading = false);

                    if (errorMsg == null) {
                      widget.onNext();
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            duration: const Duration(seconds: 4),
                          ),
                        );
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
