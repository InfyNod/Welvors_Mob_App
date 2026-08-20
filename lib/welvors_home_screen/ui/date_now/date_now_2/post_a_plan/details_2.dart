import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/post_plan_bloc.dart';
import 'bloc/post_plan_event.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

class Details2View extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Details2View({Key? key, required this.onContinue, required this.onBack})
    : super(key: key);

  @override
  State<Details2View> createState() => _Details2ViewState();
}

class _Details2ViewState extends State<Details2View> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<dynamic> _quickTitles = [];

  String? _selectedVibe;
  List<dynamic> _vibes = [];

  bool _isLoading = true;
  bool _isPatching = false;

  Future<void> _submitStep2() async {
    final state = context.read<PostPlanBloc>().state;
    final planId = state.planId;
    if (planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan ID is missing. Please restart.')));
      return;
    }

    setState(() { _isPatching = true; });

    try {
      String? quickTitleId;
      for (var qt in _quickTitles) {
        if (qt['label'] == _titleController.text.trim()) {
          quickTitleId = qt['id'];
          break;
        }
      }

      String? vibeId;
      if (_selectedVibe != null) {
        for (var v in _vibes) {
          if (v['label'] == _selectedVibe) {
            vibeId = v['id'];
            break;
          }
        }
      }

      Map<String, dynamic> data = {
        "title": _titleController.text.trim(),
        "note": _noteController.text.trim(),
      };
      
      if (quickTitleId != null) {
        data["quickTitleId"] = quickTitleId;
      }
      if (vibeId != null) {
        data["vibeIds"] = [vibeId];
      }

      final response = await DateNowApiService.patchPlan(planId, data);
      
      if (response != null && response['success'] == true) {
        if (mounted) {
          context.read<PostPlanBloc>().add(
            UpdateStep2Event(
              title: _titleController.text.trim(),
              description: _noteController.text.trim(),
              tags: _selectedVibe != null ? [_selectedVibe!] : [],
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PostPlanBloc>().state;
      if (state.title.isNotEmpty) {
        setState(() {
          _titleController.text = state.title;
          _noteController.text = state.description;
          if (state.tags.isNotEmpty) {
            _selectedVibe = state.tags.first;
          }
        });
      }
    });
  }

  Future<void> _fetchOptions() async {
    final titles = await DateNowApiService.getOptions('QUICK_TITLE');
    final vibes = await DateNowApiService.getOptions('VIBE');
    if (mounted) {
      setState(() {
        _quickTitles = titles ?? [];
        _vibes = vibes ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isContinueActive = _titleController.text.trim().isNotEmpty;

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
                      "Make it inviting",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      "A clear title and your vibe help the right people ask you out.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Plan Title
                    const Text(
                      'Plan title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      maxLength: 42,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'e.g. Iced coffee & deep talks',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        counterText: '${_titleController.text.length}/42',
                        counterStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
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
                    const SizedBox(height: 10),

                    // Quick Titles
                    const Text(
                      'Or pick a quick title',
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
                      children: _quickTitles.map((titleObj) {
                        final title = titleObj['label'] as String;
                        bool isSelected = _titleController.text == title;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _titleController.text = title;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE43A6A).withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE43A6A)
                                    : Colors.grey.shade300,
                                width: isSelected ? 1.2 : 1.0,
                              ),
                            ),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFFE43A6A)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Short Note
                    const Text(
                      'A short note (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Anyone up for a calm evening? 🌅',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
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
                    const SizedBox(height: 20),

                    // Your Vibe
                    const Text(
                      'Your vibe',
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
                      children: _vibes.map((vibeObj) {
                        final vibe = vibeObj['label'] as String;
                        bool isSelected = _selectedVibe == vibe;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVibe = vibe;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE43A6A).withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE43A6A)
                                    : Colors.grey.shade300,
                                width: isSelected ? 1.2 : 1.0,
                              ),
                            ),
                            child: Text(
                              vibe,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFFE43A6A)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 0),
                  ],
                ),
        ),
        // Bottom Buttons for Step 2
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
                          _submitStep2();
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
}
