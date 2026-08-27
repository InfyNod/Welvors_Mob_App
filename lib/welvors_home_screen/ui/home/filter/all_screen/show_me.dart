import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';
import '../../../../../onbording_allpage/theme/app_colors.dart';
import '../../../../../onbording_allpage/theme/app_text.dart';

class ShowMeScreen extends StatefulWidget {
  const ShowMeScreen({super.key});

  @override
  State<ShowMeScreen> createState() => _ShowMeScreenState();
}

class _ShowMeScreenState extends State<ShowMeScreen> {
  String _selectedShowMe = 'WOMEN';
  final Set<String> _selectedPreferences = {};

  // Display map for UI (Backend Key : Display Name)
  final Map<String, String> _orientationDisplayNames = {
    'STRAIGHT': 'Straight',
    'GAY': 'Gay',
    'LESBIAN': 'Lesbian',
    'AROMATIC': 'Aromantic',
    'ASEXUAL': 'Asexual',
    'BISEXUAL': 'Bisexual',
    'DEMISEXUAL': 'Demisexual',
    'PANSEXUAL': 'Pansexual',
    'QUEER': 'Queer',
    'NOT_LISTED': 'Not listed',
  };

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _selectedShowMe = ['WOMEN', 'MEN', 'EVERYONE'].contains(currentState.showMe)
        ? currentState.showMe
        : 'WOMEN';
        
    if (currentState.showMePreference.isNotEmpty) {
      _selectedPreferences.add(currentState.showMePreference);
    }
  }

  void _onDone() {
    context.read<FilterBloc>().add(
      UpdateShowMe(
        _selectedShowMe, 
        _selectedPreferences.isNotEmpty ? _selectedPreferences.first : ''
      )
    );
    Navigator.pop(context);
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
          color: isSelected ? AppColors.pinkSoft.withOpacity(0.5) : Colors.white,
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
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
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
                            color: isSelected ? AppColors.pinkDeep : AppColors.ink,
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
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isSelected && expandedContent != null
                  ? expandedContent
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade200, height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Sexual orientation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPTIONAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _orientationDisplayNames.keys.map((pref) {
                  final isSelected = _selectedPreferences.contains(pref);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedPreferences.remove(pref);
                        } else {
                          _selectedPreferences.clear();
                          _selectedPreferences.add(pref);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE43A6A) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFFE43A6A).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Text(
                        _orientationDisplayNames[pref]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Show me',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                title: 'Women',
                subtitle: 'Show me women',
                icon: Icons.female,
                iconColor: AppColors.pinkDeep,
                iconBg: AppColors.pinkSoft,
                isSelected: _selectedShowMe == 'WOMEN',
                onTap: () {
                  setState(() {
                    _selectedShowMe = 'WOMEN';
                    _selectedPreferences.clear();
                  });
                },
                expandedContent: _buildExpandedPreferences(),
              ),
              _buildCard(
                title: 'Men',
                subtitle: 'Show me men',
                icon: Icons.male,
                iconColor: AppColors.blue,
                iconBg: AppColors.blue.withOpacity(0.15),
                isSelected: _selectedShowMe == 'MEN',
                onTap: () {
                  setState(() {
                    _selectedShowMe = 'MEN';
                    _selectedPreferences.clear();
                  });
                },
                expandedContent: _buildExpandedPreferences(),
              ),
              _buildCard(
                title: 'Everyone',
                subtitle: 'Show me everyone',
                icon: Icons.transgender,
                iconColor: AppColors.gold,
                iconBg: AppColors.gold.withOpacity(0.15),
                isSelected: _selectedShowMe == 'EVERYONE',
                onTap: () {
                  setState(() {
                    _selectedShowMe = 'EVERYONE';
                    _selectedPreferences.clear();
                  });
                },
                // No expanded content for 'Everyone' as requested
              ),
            ],
          ),
        ),
      ),
    );
  }
}
