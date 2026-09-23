import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/logger_service.dart';
import 'all_screen/age.dart';
import 'all_screen/distance.dart';
import 'all_screen/show_me.dart';
import 'all_screen/looking_for.dart';
import 'all_screen/height.dart';
import 'all_screen/education.dart';
import 'all_screen/income_range.dart';
import 'all_screen/languages.dart';
import 'all_screen/lifestyle.dart';
import 'all_screen/religion_community.dart';
import 'all_screen/profession.dart';
import 'all_screen/networking_intent.dart';
import 'all_screen/ambition.dart';
import 'all_screen/zodiac.dart';
import 'all_screen/trust_score.dart';
import 'filter_bloc/filter_bloc.dart';
import 'filter_bloc/filter_event.dart';
import 'filter_bloc/filter_state.dart';
import '../../../home_bloc/home_bloc.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _isOnlineNow = false;
  bool _showWhoLikedMe = false;
  bool _membersOnly = false;

  String _selectedTier = 'Premium+';

  String _activeBrowsePool = 'Premium+ only';
  String _activeVipBrowsePool = 'Both';
  final Set<String> _selectedLookingFor = {'Any'};

  void _toggleLookingFor(String label) {
    setState(() {
      if (_selectedLookingFor.contains(label)) {
        _selectedLookingFor.remove(label);
      } else {
        _selectedLookingFor.add(label);
      }
    });
  }

  String _formatHeight(double cm) {
    int totalInches = (cm / 2.54).round();
    int feet = totalInches ~/ 12;
    int inches = totalInches % 12;
    return "$feet'$inches\"";
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
                  color: Colors.black87,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Preferences',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: GestureDetector(
              onTap: () {
                context.read<FilterBloc>().add(ResetFilter());
                setState(() {
                  _isOnlineNow = false;
                  _showWhoLikedMe = false;
                  _membersOnly = false;
                  _selectedLookingFor.clear();
                  _selectedLookingFor.add('Any');
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildTierSelection(),
          ),
          Expanded(
            child: BlocBuilder<FilterBloc, FilterState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    _buildPreferenceRow(
                      'Age',
                      '${state.minAge.round()} – ${state.maxAge.round()}',
                      onTap: () {
                        // Pass the existing FilterBloc instance to the new route
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const AgeScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Distance',
                      '${state.distance.round()} km',
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const DistanceScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Interested in',
                      {
                            'MEN': 'Men',
                            'WOMEN': 'Women',
                            'NON_BINARY': 'Non-binary',
                            'ANY': 'Any',
                          }[state.showMe] ??
                          state.showMe,
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const ShowMeScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Looking for',
                      state.lookingFor.isEmpty
                          ? 'Any'
                          : state.lookingFor
                                .map((e) => e.split('|').last)
                                .join(', '),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const LookingForScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Height',
                      state.minHeight == null || state.maxHeight == null
                          ? 'Any'
                          : '${_formatHeight(state.minHeight!)} - ${_formatHeight(state.maxHeight!)}',
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const HeightScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Education',
                      state.education.isEmpty
                          ? 'Any'
                          : state.education
                                .map((e) => e.split('|').last)
                                .join(', '),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const EducationScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Languages',
                      state.languages.isEmpty
                          ? 'Any'
                          : state.languages
                                .map((e) => e.split('|').last)
                                .join(', '),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const LanguagesScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Lifestyle',
                      state.lifestyle.isEmpty
                          ? 'Any'
                          : state.lifestyle
                                .map((e) => e.split('|').last)
                                .join(', '),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const LifestyleScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Religion & community',
                      state.religion.isEmpty
                          ? 'Any'
                          : state.religion
                                .map((e) => e.split('|').last)
                                .join(', '),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const ReligionCommunityScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Profession',
                      state.profession.isEmpty
                          ? 'Any'
                          : state.profession
                                .map((e) => e.split('|').last)
                                .join(', '),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const ProfessionScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Zodiac',
                      state.zodiac == 'Any'
                          ? 'Any'
                          : state.zodiac.substring(0, 1) +
                                state.zodiac.substring(1).toLowerCase(),
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const ZodiacScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceRow(
                      'Trust score',
                      '${state.minTrustScore.round()} – ${state.maxTrustScore.round()}',
                      onTap: () {
                        final filterBloc = context.read<FilterBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: filterBloc,
                              child: const TrustScoreScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildOnlineNowRow(),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildBrowsePoolFreePremium(),
                    const SizedBox(height: 24),

                    _buildLockedPremiumBox(
                      IgnorePointer(
                        ignoring: _selectedTier != 'VIP & Elite',
                        child: Opacity(
                          opacity: _selectedTier == 'VIP & Elite' ? 1.0 : 0.4,
                          child: Column(
                            children: [
                              _buildLockHeader(
                                'Filters',
                                Colors.purple,
                                '',
                                isUnlocked: _selectedTier == 'VIP & Elite',
                                customBadge: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.purple.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.purple.withOpacity(0.05),
                                  ),
                                  child: RichText(
                                    text: const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'VIP ',
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        TextSpan(
                                          text: '& ',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Elite',
                                          style: TextStyle(
                                            color: Color(0xFFB8860B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _buildPreferenceRow(
                                'Income range',
                                (state.minIncome == 5.0 &&
                                        state.maxIncome == 200.0)
                                    ? 'Any'
                                    : '${state.minIncome >= 100 ? '${(state.minIncome / 100).toStringAsFixed(state.minIncome % 100 == 0 ? 0 : 1)} Cr' : '${state.minIncome.toInt()} L'} - ${state.maxIncome >= 100 ? (state.maxIncome == 200 ? '2 Cr+' : '${(state.maxIncome / 100).toStringAsFixed(state.maxIncome % 100 == 0 ? 0 : 1)} Cr') : '${state.maxIncome.toInt()} L'}',
                                valueColor: Colors.purple,
                                onTap: () {
                                  final filterBloc = context.read<FilterBloc>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: filterBloc,
                                        child: const IncomeRangeScreen(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildPreferenceRow(
                                'Networking intent',
                                state.networkingIntent.isEmpty
                                    ? 'Any'
                                    : state.networkingIntent.join(', '),
                                valueColor: Colors.purple,
                                onTap: () {
                                  final filterBloc = context.read<FilterBloc>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: filterBloc,
                                        child: const NetworkingIntentScreen(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildPreferenceRow(
                                'Ambition',
                                state.ambition.isEmpty
                                    ? 'Any'
                                    : state.ambition.join(', '),
                                valueColor: Colors.purple,
                                onTap: () {
                                  final filterBloc = context.read<FilterBloc>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: filterBloc,
                                        child: const AmbitionScreen(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildToggleRow(
                                'Show who liked me first',
                                'Elite priority ordering',
                                _showWhoLikedMe,
                                (val) {
                                  setState(() => _showWhoLikedMe = val);
                                },
                                isElite: true,
                              ),
                              _buildDivider(),
                              _buildToggleRow(
                                'Members-only gatherings',
                                'Open to private Elite events',
                                _membersOnly,
                                (val) {
                                  setState(() => _membersOnly = val);
                                },
                                isElite: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBrowsePoolVipWorld(),
                    const SizedBox(height: 10),
                  ],
                ); // Closes ListView
              }, // Closes builder
            ), // Closes BlocBuilder
          ), // Closes Expanded
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTierSelection() {
    final tiers = ['Premium+', 'VIP & Elite'];
    int selectedIndex = tiers.indexOf(_selectedTier);
    if (selectedIndex == -1) selectedIndex = 0;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 243, 243),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 2;

          Color activeBorderColor = Colors.transparent;
          if (_selectedTier == 'Premium+') {
            activeBorderColor = const Color(0xFFE43A6A).withOpacity(0.3);
          } else if (_selectedTier == 'VIP & Elite') {
            activeBorderColor = const Color(0xFF9C27B0).withOpacity(0.3);
          }

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: _selectedTier == 'Premium+'
                        ? const LinearGradient(
                            colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFFB8860B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedTier == 'Premium+'
                            ? const Color(0xFFDE2957).withOpacity(0.4)
                            : const Color(0xFF9C27B0).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(tiers.length, (index) {
                  final title = tiers[index];
                  final isSelected = _selectedTier == title;

                  String subtitle = '';
                  Color subtitleColor = Colors.grey.shade500;
                  Color titleColor = Colors.grey.shade700;

                  if (title == 'Premium+') {
                    subtitle = isSelected ? '✓ Active' : '○ Other world';
                    subtitleColor = isSelected
                        ? const Color(0xFF00E676) // Bright green
                        : Colors.grey.shade500;
                    titleColor = isSelected
                        ? Colors.white
                        : Colors.grey.shade700;
                  } else if (title == 'VIP & Elite') {
                    subtitle = isSelected ? '✓ Active' : '○ Other world';
                    subtitleColor = isSelected
                        ? const Color(0xFF00E676) // Bright green
                        : Colors.grey.shade500;
                    titleColor = isSelected
                        ? Colors.white
                        : Colors.grey.shade700;
                  }

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selectedTier = title),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (title == 'VIP & Elite')
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'VIP ',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  TextSpan(
                                    text: '& ',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Elite',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                              child: Text(title),
                            ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            child: Text(subtitle),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrowsePoolFreePremium() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BROWSE POOL - FREE & PREMIUM',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _selectedTier == 'Premium+'
                ? Colors.black87
                : Colors.grey.shade400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'The two worlds run separately — members of one never see the other.',
          style: TextStyle(
            fontSize: 12,
            color: _selectedTier == 'Premium+'
                ? Colors.grey.shade700
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFE43A6A,
                ).withOpacity(0.04), // subtle pinkish glow
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: IgnorePointer(
            ignoring: _selectedTier != 'Premium+',
            child: Opacity(
              opacity: _selectedTier == 'Premium+' ? 1.0 : 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSmallBadge('Free', Colors.pinkAccent),
                      const SizedBox(width: 8),
                      _buildSmallBadge('Premium+', Colors.orangeAccent),
                      const Spacer(),
                      const Text(
                        '• Your world',
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Free & Premium',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Free and Premium+ members share one pool.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 12),
                  _buildSlidingSegmentedControl(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrowsePoolVipWorld() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BROWSE POOL - VIP WORLD',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _selectedTier != 'Premium+'
                ? Colors.black87
                : Colors.grey.shade400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF9C27B0,
                ).withOpacity(0.04), // subtle purple glow
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Opacity(
            opacity: _selectedTier != 'Premium+'
                ? 1.0
                : 0.4, // Unfaded if VIP or Elite
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50.withOpacity(0.5),
                        border: Border.all(color: Colors.purple.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'VIP',
                        style: TextStyle(
                          color: Colors.purple.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A4A4A), Color(0xFF1A1A1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'VIP Elite',
                        style: TextStyle(
                          color: Color(0xFFFFD700), // Premium Gold text
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'VIP & VIP Elite',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'VIP and VIP Elite members share one private pool.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                if (_selectedTier == 'Premium+')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50.withOpacity(0.5),
                      border: Border.all(
                        color: Colors.purple.shade100,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.purple.shade300,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Upgrade to VIP to enter',
                          style: TextStyle(
                            color: Colors.purple.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _buildVipSlidingSegmentedControl(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBadge(
    String text,
    Color color, {
    Color textColor = Colors.black87,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor == Colors.white ? Colors.grey.shade400 : color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSlidingSegmentedControl() {
    final options = ['Free only', 'Premium+\nonly', 'Both'];
    int selectedIndex = options.indexOf(_activeBrowsePool);
    if (selectedIndex == -1) selectedIndex = 0;

    return Container(
      height: 44, // 36 for inner pill + 8 padding
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 3;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(options.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _activeBrowsePool = options[index]),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFE43A6A)
                                : Colors.black87,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          child: Text(options[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVipSlidingSegmentedControl() {
    final options = ['VIP only', 'VIP Elite only', 'Both'];
    int selectedIndex = options.indexOf(_activeVipBrowsePool);
    if (selectedIndex == -1) selectedIndex = 2; // Default to 'Both'

    return Container(
      height: 44, // 36 for inner pill + 8 padding
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 3;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTier == 'Elite' ? null : Colors.white,
                    gradient: _selectedTier == 'Elite'
                        ? const LinearGradient(
                            colors: [Color(0xFF4A4A4A), Color(0xFF1A1A1A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(options.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _activeVipBrowsePool = options[index]),
                      child: Center(
                        child: isSelected && options[index] == 'Both'
                            ? ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Colors.purple,
                                        Color(0xFFB8860B),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: Text(
                                  options[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? (options[index] == 'VIP Elite only'
                                            ? const Color(0xFFB8860B)
                                            : Colors.purple)
                                      : Colors.black87,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                                child: Text(options[index]),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectableWrapChip(
    String label, {
    bool? isSelectedParam,
    bool disabled = false,
    String? premiumStyle,
  }) {
    final isSelected =
        isSelectedParam ?? (!disabled && _selectedLookingFor.contains(label));
    final isVip = premiumStyle == 'VIP';
    final isElite = premiumStyle == 'Elite';
    final isPremium = isVip || isElite;

    return GestureDetector(
      onTap: disabled ? null : () => _toggleLookingFor(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isPremium ? null : Colors.white,
          gradient: isPremium
              ? LinearGradient(
                  colors: isSelected
                      ? (isElite
                            ? [
                                const Color(0xFF4A4A4A),
                                const Color(0xFF1A1A1A),
                              ] // Light Black to Dark Black Gradient
                            : [
                                const Color(0xFFAB47BC),
                                const Color(0xFF2C2C2C),
                              ]) // Purple/Charcoal
                      : [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isPremium
                ? (isSelected
                      ? (isElite
                            ? const Color(0xFFFFE066).withOpacity(0.7)
                            : Colors.transparent)
                      : (disabled
                            ? Colors.grey.shade100
                            : Colors.grey.shade300))
                : (isSelected
                      ? const Color(0xFFE43A6A)
                      : (disabled
                            ? Colors.grey.shade100
                            : Colors.grey.shade300)),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: (isSelected && isPremium)
                ? (isElite
                      ? const Color(0xFFFFE066)
                      : Colors.white) // Gold text for Elite, White for Purple
                : (isSelected
                      ? const Color(0xFFE43A6A)
                      : (disabled
                            ? Colors.grey.shade300
                            : Colors.grey.shade700)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Inter',
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildLockedPremiumBox(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }

  Widget _buildLockHeader(
    String title,
    Color badgeColor,
    String badgeText, {
    bool isUnlocked = false,
    bool isElite = false,
    Widget? customBadge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (!isUnlocked)
            Icon(
              Icons.lock,
              size: 14,
              color: isElite ? Colors.black87 : badgeColor,
            )
          else
            const Text(
              '✓',
              style: TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          const SizedBox(width: 8),
          customBadge ??
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isElite ? null : badgeColor.withOpacity(0.15),
                  gradient: isElite
                      ? const LinearGradient(
                          colors: [Color(0xFF4A4A4A), Color(0xFF1A1A1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: isElite
                      ? Border.all(color: badgeColor.withOpacity(0.5))
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Spacer(),
          if (isUnlocked)
            const Text(
              '• Your world',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF00C853),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(
    String title,
    String value, {
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: valueColor ?? const Color(0xFFE43A6A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade300,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineNowRow() {
    return _buildToggleRow(
      'Online now',
      'Active in the last 15 min',
      _isOnlineNow,
      (val) {
        setState(() {
          _isOnlineNow = val;
        });
      },
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isElite = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 50,
              height: 30,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: isElite
                    ? LinearGradient(
                        colors: value
                            ? [
                                const Color.fromARGB(255, 23, 23, 23),
                                const Color.fromARGB(255, 250, 218, 93),
                              ]
                            : [Colors.grey.shade500, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isElite
                    ? null
                    : (value ? const Color(0xFFE43A6A) : Colors.grey.shade300),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }

  Widget _buildBottomButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 16,
            top: 16,
          ),
          child: ElevatedButton(
            onPressed: () {
              final filterState = context.read<FilterBloc>().state;
              final payload = filterState.hasActiveFilters
                  ? filterState.toJson()
                  : null;
              AppLogger.i('FilterScreen', 'Dispatching event with filters: $payload');
              context.read<HomeBloc>().add(
                LoadHomeDataEvent(isRefresh: true, filters: payload),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE43A6A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Show profiles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
