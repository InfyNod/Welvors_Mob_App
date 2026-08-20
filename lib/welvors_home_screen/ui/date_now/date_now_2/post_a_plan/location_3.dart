import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'map_selection_dialog.dart';
import 'bloc/post_plan_bloc.dart';
import 'bloc/post_plan_event.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

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
  String _selectedVisibility = 'Premium';
  bool _isLocationSelected = false;
  String _selectedPlaceSubtext = '';

  final FocusNode _locationFocusNode = FocusNode();
  List<dynamic> _whoPaysOptions = [];
  List<dynamic> _whoCanJoinOptions = [];
  List<dynamic> _visibilityOptions = [];
  bool _isLoading = true;
  bool _isPatching = false;

  Future<void> _submitStep3() async {
    final state = context.read<PostPlanBloc>().state;
    final planId = state.planId;
    if (planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan ID is missing. Please restart.')));
      return;
    }

    setState(() { _isPatching = true; });

    try {
      // Find IDs
      String? whoPaysId;
      for (var o in _whoPaysOptions) {
        if (o['label'] == _selectedWhoPays) {
          whoPaysId = o['id']; break;
        }
      }
      String? joinRequestGenderId;
      for (var o in _whoCanJoinOptions) {
        if (o['label'] == _selectedWhoCanJoin) {
          joinRequestGenderId = o['id']; break;
        }
      }
      String? visibilityId;
      for (var o in _visibilityOptions) {
        final label = o['label'] as String;
        final parts = label.split(' ');
        final title = parts.length > 1 ? parts.skip(1).join(' ') : label;
        if (title == _selectedVisibility) {
          visibilityId = o['id']; break;
        }
      }

      // Duration parsing
      int? duration;
      if (_selectedHowLong == '30 min') duration = 30;
      else if (_selectedHowLong == '1 hour') duration = 60;
      else if (_selectedHowLong == '2 hours') duration = 120;
      else if (_selectedHowLong == 'Flexible') duration = 0;

      // Participant limit parsing
      int participantLimit = 1;
      if (_selectedHowMany != null && _selectedHowMany!.isNotEmpty) {
        final match = RegExp(r'\d+').firstMatch(_selectedHowMany!);
        if (match != null) {
          participantLimit = int.tryParse(match.group(0)!) ?? 1;
        }
      }

      // DateTime logic
      DateTime now = DateTime.now();
      DateTime eventDate = now;
      if (_selectedWhen == 'Tomorrow') {
        eventDate = now.add(const Duration(days: 1));
      } else if (_selectedWhen == 'This weekend') {
        int daysUntilSaturday = DateTime.saturday - now.weekday;
        if (daysUntilSaturday <= 0) daysUntilSaturday += 7;
        eventDate = now.add(Duration(days: daysUntilSaturday));
      }

      String? eventDateTimeIso;
      String? expiresAtIso;
      if (_selectedTime != null) {
        final dt = DateTime(eventDate.year, eventDate.month, eventDate.day, _selectedTime!.hour, _selectedTime!.minute);
        eventDateTimeIso = dt.toUtc().toIso8601String();
        expiresAtIso = dt.subtract(const Duration(hours: 1)).toUtc().toIso8601String();
      }

      Map<String, dynamic> data = {
        "venueName": _searchController.text.trim(),
        "venueAddress": _selectedPlaceSubtext,
        "status": "DRAFT",
      };

      if (duration != null) data["duration"] = duration;
      if (whoPaysId != null) data["whoPaysId"] = whoPaysId;
      if (participantLimit > 0) data["participantLimit"] = participantLimit;
      if (joinRequestGenderId != null) data["joinRequestGenderId"] = joinRequestGenderId;
      if (visibilityId != null) data["visibilityId"] = visibilityId;
      if (eventDateTimeIso != null) data["eventDateTime"] = eventDateTimeIso;
      if (expiresAtIso != null) data["expiresAt"] = expiresAtIso;

      final response = await DateNowApiService.patchPlan(planId, data);
      
      if (response != null && response['success'] == true) {
        if (mounted) {
          context.read<PostPlanBloc>().add(
            UpdateStep3Event(
              locationName: _searchController.text,
              locationSubtitle: _selectedPlaceSubtext,
              landmark: '',
              whenDate: _selectedWhen == 'This weekend' ? 'Weekend' : _selectedWhen,
              time: _selectedTime,
              howLong: _selectedHowLong,
              whoPays: _selectedWhoPays,
              groupSize: _selectedHowMany,
              whoCanRequest: _selectedWhoCanJoin,
              visibility: _selectedVisibility,
            ),
          );
          widget.onContinue();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update plan. Please try again.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred. Please try again.')));
      }
    } finally {
      if (mounted) {
        setState(() { _isPatching = false; });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();

    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus &&
          _searchController.text.trim().isNotEmpty &&
          !_isLocationSelected) {
        setState(() {
          _isLocationSelected = true;
          _selectedPlaceSubtext = 'Custom location';
          _searchController.text = _searchController.text.trim();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PostPlanBloc>().state;
      if (state.locationName.isNotEmpty) {
        setState(() {
          _isLocationSelected = true;
          _searchController.text = state.locationName;
          _selectedPlaceSubtext = state.locationSubtitle;
          _selectedTime = state.time;
          _selectedHowLong = state.howLong;
          _selectedWhoPays = state.whoPays;
          _selectedHowMany = state.groupSize;
          _selectedWhoCanJoin = state.whoCanRequest;
          _selectedVisibility = state.visibility;
        });
      }
    });
  }

  Future<void> _fetchOptions() async {
    final pays = await DateNowApiService.getOptions('WHO_PAYS');
    final gender = await DateNowApiService.getOptions('JOIN_REQUEST_GENDER');
    final visibility = await DateNowApiService.getOptions('PLAN_VISIBILITY');
    if (mounted) {
      setState(() {
        _whoPaysOptions = pays ?? [];
        _whoCanJoinOptions = gender ?? [];
        _visibilityOptions = visibility ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _locationFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isContinueActive =
        _isLocationSelected &&
        _selectedTime != null &&
        _selectedHowLong != null &&
        _selectedWhoPays != null &&
        _selectedHowMany != null &&
        _selectedWhoCanJoin != null;

    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE43A6A).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE43A6A),
                            width: 1.5,
                          ),
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
                                child: Text(
                                  '☕',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _searchController.text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _selectedPlaceSubtext.isEmpty
                                        ? 'Mumbai'
                                        : _selectedPlaceSubtext,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
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
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.black54,
                                ),
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
                            focusNode: _locationFocusNode,
                            onChanged: (val) => setState(() {}),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                setState(() {
                                  _searchController.text = val.trim();
                                  _selectedPlaceSubtext = 'Custom location';
                                  _isLocationSelected = true;
                                });
                              }
                            },
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Search cafe, park, restaurant...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black54,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                          /*
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
                            _buildSuggestionItem(
                              '☕',
                              'Starbucks Reserve',
                              'Lower Parel, Mumbai',
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem(
                              '🍸',
                              'AER Rooftop Bar',
                              'Worli, Mumbai',
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem(
                              '🍺',
                              'Toit Taproom',
                              'Bandra, Mumbai',
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem(
                              '🌅',
                              'Carter Road Promenade',
                              'Bandra, Mumbai',
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildSuggestionItem(
                              '🌳',
                              'Joggers Park',
                              'Bandra, Mumbai',
                            ),
                          ],
                        ),
                      ),
                    */
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
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
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
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFE43A6A), // Pink header and selected dial color
                                  onPrimary: Colors.white, // Text color on primary
                                  onSurface: Colors.black87, // Text color on dial
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFE43A6A), // Pink OK/Cancel buttons
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
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
                          color: _selectedTime != null
                              ? const Color(0xFFE43A6A).withOpacity(0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedTime != null
                                ? const Color(0xFFE43A6A)
                                : Colors.grey.shade300,
                            width: _selectedTime != null ? 1.5 : 1.0,
                          ),
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
                                    ? const Color(0xFFE43A6A)
                                    : Colors.black54,
                                fontWeight: _selectedTime != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              color: _selectedTime != null
                                  ? const Color(0xFFE43A6A)
                                  : Colors.black54,
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
                            (option) => _buildGenericChip(
                              option,
                              _selectedHowLong,
                              (val) {
                                setState(() => _selectedHowLong = val);
                              },
                            ),
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
                      children: _whoPaysOptions.map((optionObj) {
                        final option = optionObj['label'] as String;
                        return _buildGenericChip(option, _selectedWhoPays, (
                          val,
                        ) {
                          setState(() => _selectedWhoPays = val);
                        });
                      }).toList(),
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
                      children: ['1 person', '2 people', 'Small group']
                          .map(
                            (option) => _buildGenericChip(
                              option,
                              _selectedHowMany,
                              (val) {
                                setState(() => _selectedHowMany = val);
                              },
                            ),
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
                      children: _whoCanJoinOptions.map((optionObj) {
                        final option = optionObj['label'] as String;
                        return _buildGenericChip(option, _selectedWhoCanJoin, (
                          val,
                        ) {
                          setState(() => _selectedWhoCanJoin = val);
                        });
                      }).toList(),
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
                    ..._visibilityOptions.map((optionObj) {
                      final label = optionObj['label'] as String;
                      final value = optionObj['value'] as String;
                      final parts = label.split(' ');
                      final icon = parts.isNotEmpty ? parts.first : '';
                      final title = parts.length > 1
                          ? parts.skip(1).join(' ')
                          : label;
                      final isLocked = value != 'premium';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildVisibilityOption(
                          title: title,
                          subtitle: 'Visible to $title members',
                          icon: icon,
                          isLocked: isLocked,
                        ),
                      );
                    }).toList(),
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
                  onTap: (isContinueActive && !_isPatching)
                      ? () {
                          _submitStep3();
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isContinueActive
                          ? const Color(0xFFE43A6A)
                          : const Color.fromARGB(255, 224, 222, 220),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isPatching
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Row(
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
      child: Container(
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
      child: Container(
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
      child: Container(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
