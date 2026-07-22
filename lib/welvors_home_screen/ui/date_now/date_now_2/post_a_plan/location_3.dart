import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'map_selection_dialog.dart';

class Location3View extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Location3View({
    Key? key,
    required this.onContinue,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Location3View> createState() => _Location3ViewState();
}

class _Location3ViewState extends State<Location3View> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualController = TextEditingController();
  String _selectedWhen = 'Today';
  TimeOfDay? _selectedTime;
  String? _selectedHowLong;
  String? _selectedWhoPays;
  String? _selectedHowMany;
  String? _selectedWhoCanJoin;
  String _selectedVisibility = 'Premium 👑';
  bool _isLocationSelected = false;
  String _selectedPlaceSubtext = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isContinueActive = _isLocationSelected &&
        _selectedTime != null &&
        _selectedHowLong != null &&
        _selectedWhoPays != null &&
        _selectedHowMany != null &&
        _selectedWhoCanJoin != null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const Text(
                "Where & when",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Search for any place — cafe, park, restaurant or landmark. Your exact location stays private.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Location & venue
              const Text(
                '📍 Location & venue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Search Field or Selected Card
              if (_isLocationSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE43A6A).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE43A6A), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('☕', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _searchController.text,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              _selectedPlaceSubtext.isEmpty ? 'Mumbai' : _selectedPlaceSubtext,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLocationSelected = false;
                            _searchController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search cafe, park, restaurant...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.black54),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE43A6A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSuggestionItem('☕', 'Starbucks Reserve', 'Lower Parel, Mumbai'),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem('🍸', 'AER Rooftop Bar', 'Worli, Mumbai'),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem('🍺', 'Toit Taproom', 'Bandra, Mumbai'),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem('🌅', 'Carter Road Promenade', 'Bandra, Mumbai'),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem('🌳', 'Joggers Park', 'Bandra, Mumbai'),
                          ],
                        ),
                      ),
                  ],
                ),

              if (!_isLocationSelected) ...[
                const SizedBox(height: 16),
                // Locate on map button
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapSelectionDialog(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _searchController.text = result;
                        _selectedPlaceSubtext = 'Selected from Map';
                        _isLocationSelected = true;
                      });
                    }
                  },
                  child: DottedBorder(
                    color: const Color(0xFFE43A6A),
                    strokeWidth: 1.2,
                    dashPattern: const [6, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE43A6A).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '🗺️ Locate on map',
                          style: TextStyle(
                            color: Color(0xFFE43A6A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              if (_isLocationSelected) ...[
                const SizedBox(height: 24),
                // Landmark
                const Text(
                  '🏛️ Landmark (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'e.g. Near the fountain, 2nd floor...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE43A6A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔒 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          'Only the place name is shown — your exact spot stays private.',
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // When
              const Text(
                'When',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildWhenChip('Today'),
                  const SizedBox(width: 8),
                  _buildWhenChip('Tomorrow'),
                  const SizedBox(width: 8),
                  _buildWhenChip('This weekend'),
                ],
              ),
              const SizedBox(height: 24),

              // Time
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // Time placeholder
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFE43A6A),
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                            surface: Colors.white,
                          ),
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: Colors.white,
                            dialBackgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select time',
                        style: TextStyle(
                          color: _selectedTime != null
                              ? Colors.black87
                              : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.access_time,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // How long
              const Text(
                'How long',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: ['30 min', '1 hour', '2 hours', 'Flexible']
                    .map(
                      (option) =>
                          _buildGenericChip(option, _selectedHowLong, (val) {
                            setState(() => _selectedHowLong = val);
                          }),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Who pays the bill?
              const Text(
                'Who pays the bill?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children:
                    [
                          '🙋 I’ll pay',
                          '🤝 Split (TTMM)',
                          '💁 You pay',
                          '🤷 Decide there',
                        ]
                        .map(
                          (option) => _buildGenericChip(
                            option,
                            _selectedWhoPays,
                            (val) {
                              setState(() => _selectedWhoPays = val);
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),

              // How many can join?
              const Text(
                'How many can join?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: ['Just 1', '2 people', 'Small group']
                    .map(
                      (option) =>
                          _buildGenericChip(option, _selectedHowMany, (val) {
                            setState(() => _selectedHowMany = val);
                          }),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Who can request to join?
              const Text(
                'Who can request to join?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: ['🌈 Anyone.', '👩 Women', '👨 Men', '⚧ Other']
                    .map(
                      (option) =>
                          _buildGenericChip(option, _selectedWhoCanJoin, (val) {
                            setState(() => _selectedWhoCanJoin = val);
                          }),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),

              // Visibility section
              const Row(
                children: [
                  Text('👁️ ', style: TextStyle(fontSize: 14)),
                  Text(
                    'Who can see this plan?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Limit visibility to specific membership tiers',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _buildVisibilityOption(
                title: 'Premium 👑',
                subtitle: 'Only Premium members see this',
                icon: '💎',
                isLocked: false,
              ),
              const SizedBox(height: 12),
              _buildVisibilityOption(
                title: 'VIP & above',
                subtitle: 'VIP and VIP Elite users only',
                icon: '⭐',
                isLocked: true,
              ),
              const SizedBox(height: 12),
              _buildVisibilityOption(
                title: 'VIP Elite',
                subtitle: 'Only VIP Elite members see this',
                icon: '👑',
                isLocked: true,
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),

        // Bottom Buttons
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 8,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                GestureDetector(
                  onTap: isContinueActive ? widget.onContinue : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isContinueActive
                          ? const Color(0xFFE43A6A)
                          : const Color(0xFFF2EFEA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: isContinueActive
                                ? Colors.white
                                : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: isContinueActive ? Colors.white : Colors.grey,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhenChip(String label) {
    bool isSelected = _selectedWhen == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWhen = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE43A6A).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildGenericChip(
    String label,
    String? currentSelection,
    Function(String) onSelect,
  ) {
    bool isSelected = currentSelection == label;
    return GestureDetector(
      onTap: () {
        onSelect(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE43A6A).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isLocked,
  }) {
    bool isSelected = _selectedVisibility == title;
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                _selectedVisibility = title;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFF9F7F4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected && !isLocked
                ? const Color(0xFFE43A6A)
                : Colors.grey.shade200,
            width: isSelected && !isLocked ? 1.5 : 1.0,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.black45 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Colors.black38 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock, size: 18, color: Colors.black26)
            else if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFFE43A6A),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String emoji, String title, String subtitle) {
    return InkWell(
      onTap: () {
        setState(() {
          _searchController.text = title;
          _selectedPlaceSubtext = subtitle;
          _isLocationSelected = true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
