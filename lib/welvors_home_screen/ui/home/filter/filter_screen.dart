import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'all_screen/age.dart';
import 'all_screen/distance.dart';
import 'all_screen/show_me.dart';
import 'all_screen/looking_for.dart';
import 'all_screen/height.dart';
import 'all_screen/education.dart';
import 'all_screen/languages.dart';
import 'all_screen/lifestyle.dart';
import 'all_screen/religion_community.dart';
import 'all_screen/profession.dart';
import 'all_screen/zodiac.dart';
import 'all_screen/trust_score.dart';
import 'filter_bloc/filter_bloc.dart';
import 'filter_bloc/filter_event.dart';
import 'filter_bloc/filter_state.dart';

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
                  _selectedTier = 'Premium+';
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      'Show me', 
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
                _buildOnlineNowRow(),
                _buildDivider(),
                _buildPreferenceRow(
                  'Looking for', 
                  state.lookingFor.isEmpty ? 'Any' : state.lookingFor.join(', '),
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
                  state.education.isEmpty ? 'Any' : state.education.join(', '),
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
                  state.languages.isEmpty ? 'Any' : state.languages.join(', '),
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
                  state.lifestyle.isEmpty ? 'Any' : state.lifestyle.map((e) => e.split(':').last).join(', '),
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
                  state.religion.isEmpty ? 'Any' : state.religion.join(', '),
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
                  state.profession.isEmpty ? 'Any' : state.profession.join(', '),
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
                  state.zodiac,
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
                const SizedBox(height: 24),
                _buildBrowsePoolFreePremium(),
                const SizedBox(height: 24),

                _buildLockedPremiumBox(
                  IgnorePointer(
                    ignoring:
                        _selectedTier != 'VIP' && _selectedTier != 'Elite',
                    child: Opacity(
                      opacity:
                          (_selectedTier == 'VIP' || _selectedTier == 'Elite')
                          ? 1.0
                          : 0.4,
                      child: Column(
                        children: [
                          _buildLockHeader(
                            'VIP Filters',
                            Colors.amber.shade700,
                            'VIP',
                          ),
                          _buildPreferenceRow('Income range', 'Any'),
                          _buildDivider(),
                          _buildPreferenceRow('Networking intent', 'Any'),
                          _buildDivider(),
                          _buildPreferenceRow('Ambition', 'Any'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _buildLockedPremiumBox(
                  IgnorePointer(
                    ignoring: _selectedTier != 'Elite',
                    child: Opacity(
                      opacity: _selectedTier == 'Elite' ? 1.0 : 0.4,
                      child: Column(
                        children: [
                          _buildLockHeader(
                            'Elite Filters',
                            Colors.purple.shade300,
                            'Elite',
                          ),
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
                const SizedBox(height: 40),
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
    final tiers = ['Premium+', 'VIP', 'Elite'];
    int selectedIndex = tiers.indexOf(_selectedTier);
    if (selectedIndex == -1) selectedIndex = 0;

    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 3;

          Color activeBorderColor = Colors.transparent;
          if (_selectedTier == 'Premium+') {
            activeBorderColor = const Color(0xFFE43A6A).withOpacity(0.3);
          } else if (_selectedTier == 'VIP') {
            activeBorderColor = const Color(0xFF9C27B0).withOpacity(0.3);
          } else if (_selectedTier == 'Elite') {
            activeBorderColor = Colors.black.withOpacity(0.2);
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: activeBorderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                  Color subtitleColor = Colors.grey.shade400;
                  Color titleColor = Colors.grey.shade700;

                  if (title == 'Premium+') {
                    subtitle = isSelected ? '✓ Active' : '○ Other world';
                    subtitleColor = isSelected
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade400;
                    titleColor = isSelected
                        ? const Color(0xFFE43A6A)
                        : Colors.grey.shade700;
                  } else if (title == 'VIP') {
                    subtitle = isSelected ? '✓ Active' : '⊘ Other world';
                    subtitleColor = isSelected
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade400;
                    titleColor = isSelected
                        ? const Color(0xFF9C27B0)
                        : Colors.grey.shade700;
                  } else if (title == 'Elite') {
                    subtitle = isSelected ? '✓ Active' : '⊘ Other world';
                    subtitleColor = isSelected
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade400;
                    titleColor = isSelected
                        ? Colors.black87
                        : Colors.grey.shade700;
                  }

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selectedTier = title),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                  const SizedBox(height: 16),
                  Text(
                    'LOOKING FOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildSelectableWrapChip(
                        'Any',
                        disabled: _selectedTier != 'Premium+',
                      ),
                      _buildSelectableWrapChip(
                        'Long-term relationship',
                        disabled: _selectedTier != 'Premium+',
                      ),
                      _buildSelectableWrapChip(
                        'Marriage',
                        disabled: _selectedTier != 'Premium+',
                      ),
                      _buildSelectableWrapChip(
                        'Open-minded',
                        disabled: _selectedTier != 'Premium+',
                      ),
                      _buildSelectableWrapChip(
                        'New friends',
                        disabled: _selectedTier != 'Premium+',
                      ),
                    ],
                  ),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50.withOpacity(0.5),
                    border: Border.all(color: Colors.purple.shade100, width: 1),
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
                ),
                const SizedBox(height: 16),
                Text(
                  'LOOKING FOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildSelectableWrapChip(
                      'Any',
                      disabled: _selectedTier == 'Premium+',
                      isElite: true,
                    ),
                    _buildSelectableWrapChip(
                      'Long-term relationship',
                      disabled: _selectedTier == 'Premium+',
                      isElite: true,
                    ),
                    _buildSelectableWrapChip(
                      'Marriage',
                      disabled: _selectedTier == 'Premium+',
                      isElite: true,
                    ),
                    _buildSelectableWrapChip(
                      'Exclusive companionship',
                      disabled: _selectedTier == 'Premium+',
                      isElite: true,
                    ),
                    _buildSelectableWrapChip(
                      'Travel companion',
                      disabled: _selectedTier == 'Premium+',
                      isElite: true,
                    ),
                    _buildSelectableWrapChip(
                      'Networking',
                      disabled: _selectedTier == 'Premium+',
                      isElite: true,
                    ),
                  ],
                ),
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

  Widget _buildSelectableWrapChip(
    String label, {
    bool? isSelectedParam,
    bool disabled = false,
    bool isElite = false,
  }) {
    final isSelected =
        isSelectedParam ?? (!disabled && _selectedLookingFor.contains(label));
    return GestureDetector(
      onTap: disabled ? null : () => _toggleLookingFor(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isElite ? null : Colors.white,
          gradient: isElite
              ? LinearGradient(
                  colors: isSelected
                      ? [const Color(0xFFAB47BC), const Color(0xFF2C2C2C)] // Richer purple to dark charcoal grey for better text contrast
                      : [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isElite
                ? (isSelected
                    ? Colors.transparent
                    : (disabled ? Colors.grey.shade100 : Colors.grey.shade300))
                : (isSelected
                    ? const Color(0xFFE43A6A)
                    : (disabled ? Colors.grey.shade100 : Colors.grey.shade300)),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: (isSelected && isElite)
                ? Colors.white
                : (isSelected
                    ? const Color(0xFFE43A6A)
                    : (disabled ? Colors.grey.shade300 : Colors.grey.shade700)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Inter', // Assuming standard font
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

  Widget _buildLockHeader(String title, Color badgeColor, String badgeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.lock, size: 14, color: badgeColor),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
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
          Text(
            'Other world • upgrade to unlock',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String title, String value, {VoidCallback? onTap}) {
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
                      style: const TextStyle(
                        color: Color(0xFFE43A6A),
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
                                const Color.fromARGB(255, 209, 114, 223),
                                const Color(0xFF1A1A1A),
                              ]
                            : [Colors.grey.shade300, Colors.grey.shade300],
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
              'Show 248 profiles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
