import 'package:flutter/material.dart';

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
  final Set<String> _selectedLookingFor = {'New friends'};

  void _toggleLookingFor(String label) {
    setState(() {
      if (_selectedLookingFor.contains(label)) {
        _selectedLookingFor.remove(label);
      } else {
        _selectedLookingFor.add(label);
      }
    });
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
              onTap: () {},
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildPreferenceRow('Age', '19 – 32'),
                _buildDivider(),
                _buildPreferenceRow('Distance', '25 km'),
                _buildDivider(),
                _buildPreferenceRow('Show me', 'Women'),
                _buildDivider(),
                _buildOnlineNowRow(),
                _buildDivider(),
                _buildPreferenceRow('Religion & community', 'Any'),
                _buildDivider(),
                _buildPreferenceRow('Profession', 'Any'),
                _buildDivider(),
                _buildPreferenceRow('Zodiac', 'Any'),
                _buildDivider(),
                _buildPreferenceRow('Trust score', '0 – 20'),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildBrowsePoolFreePremium(),
                const SizedBox(height: 24),
                
                _buildLockedPremiumBox(
                  Opacity(
                    opacity: (_selectedTier == 'VIP' || _selectedTier == 'Elite') ? 1.0 : 0.4,
                    child: Column(
                      children: [
                        _buildLockHeader('VIP Filters', Colors.amber.shade700, 'VIP'),
                        _buildPreferenceRow('Income range', 'Any'),
                        _buildDivider(),
                        _buildPreferenceRow('Networking intent', 'Any'),
                        _buildDivider(),
                        _buildPreferenceRow('Ambition', 'Any'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildLockedPremiumBox(
                  Opacity(
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
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          'Members-only gatherings',
                          'Open to private Elite events',
                          _membersOnly,
                          (val) {
                            setState(() => _membersOnly = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildBrowsePoolVipWorld(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTierSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildTierCard(
            title: 'Premium+',
            subtitle: _selectedTier == 'Premium+' ? '✓ Active' : '○ Other world',
            subtitleColor: _selectedTier == 'Premium+' ? const Color(0xFF00C853) : Colors.grey.shade400,
            borderColor: _selectedTier == 'Premium+' ? const Color(0xFFE43A6A) : Colors.grey.shade200,
            backgroundColor: _selectedTier == 'Premium+' ? const Color(0xFFFCEEED) : Colors.white,
            onTap: () => setState(() => _selectedTier = 'Premium+'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTierCard(
            title: 'VIP',
            subtitle: _selectedTier == 'VIP' ? '✓ Active' : '⊘ Other world',
            subtitleColor: _selectedTier == 'VIP' ? const Color(0xFF00C853) : Colors.grey.shade400,
            borderColor: _selectedTier == 'VIP' ? const Color(0xFF9C27B0) : Colors.grey.shade200,
            backgroundColor: _selectedTier == 'VIP' ? Colors.purple.shade50 : Colors.white,
            onTap: () => setState(() => _selectedTier = 'VIP'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTierCard(
            title: 'Elite',
            subtitle: _selectedTier == 'Elite' ? '✓ Active' : '⊘ Other world',
            subtitleColor: _selectedTier == 'Elite' ? const Color(0xFF00C853) : Colors.grey.shade400,
            borderColor: _selectedTier == 'Elite' ? Colors.black : Colors.grey.shade200,
            backgroundColor: _selectedTier == 'Elite' ? Colors.grey.shade100 : Colors.white,
            onTap: () => setState(() => _selectedTier = 'Elite'),
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required Color borderColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: backgroundColor == Colors.white ? 1 : 1.5,
        ),
        boxShadow: backgroundColor == Colors.white
            ? []
            : [
                BoxShadow(
                  color: borderColor.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: backgroundColor == Colors.white
                  ? Colors.black87
                  : borderColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'The two worlds run separately — members of one never see the other.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                  _buildSelectableWrapChip('Any'),
                  _buildSelectableWrapChip('Long-term relationship'),
                  _buildSelectableWrapChip('Marriage'),
                  _buildSelectableWrapChip('Open-minded'),
                  _buildSelectableWrapChip('New friends'),
                ],
              ),
            ],
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
            color: Colors.grey.shade500,
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
            opacity: _selectedTier != 'Premium+' ? 1.0 : 0.4, // Unfaded if VIP or Elite
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
                    _buildSelectableWrapChip('Any', disabled: _selectedTier == 'Premium+'),
                    _buildSelectableWrapChip(
                      'Long-term relationship',
                      disabled: _selectedTier == 'Premium+',
                    ),
                    _buildSelectableWrapChip('Marriage', disabled: _selectedTier == 'Premium+'),
                    _buildSelectableWrapChip(
                      'Exclusive companionship',
                      disabled: _selectedTier == 'Premium+',
                    ),
                    _buildSelectableWrapChip(
                      'Travel companion',
                      disabled: _selectedTier == 'Premium+',
                    ),
                    _buildSelectableWrapChip('Networking', disabled: _selectedTier == 'Premium+'),
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
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE43A6A)
                : (disabled ? Colors.grey.shade100 : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFE43A6A)
                : (disabled ? Colors.grey.shade300 : Colors.grey.shade700),
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

  Widget _buildPreferenceRow(String title, String value) {
    return Padding(
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
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFE43A6A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildOnlineNowRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Online now',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Active in the last 15 min',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: _isOnlineNow,
            onChanged: (val) {
              setState(() {
                _isOnlineNow = val;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFE43A6A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFE43A6A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
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
