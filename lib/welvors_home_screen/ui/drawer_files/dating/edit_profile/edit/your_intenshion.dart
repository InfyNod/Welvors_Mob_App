import 'package:flutter/material.dart';

const List<Map<String, String>> intentionsOptions = [
  {
    'title': 'A long-term relationship',
    'subtitle': 'Looking to build something that lasts',
  },
  {
    'title': 'Let’s see where it goes',
    'subtitle': 'Open and unhurried, no fixed expectations',
  },
  {
    'title': 'Open to marriage, when it’s right',
    'subtitle': 'Serious, on the right timeline - not rushed',
  },
  {
    'title': 'New friends & connections',
    'subtitle': 'Meeting genuine people first',
  },
];

class YourIntentionsSection extends StatefulWidget {
  const YourIntentionsSection({super.key});

  @override
  State<YourIntentionsSection> createState() => _YourIntentionsSectionState();
}

class _YourIntentionsSectionState extends State<YourIntentionsSection> {
  String _selectedIntention = 'Open to marriage, when it’s right'; // Default

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.favorite, color: Color(0xFFE43A6A), size: 16),
            SizedBox(width: 8),
            Text(
              'YOUR INTENTIONS',
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
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => EditIntentionsScreen(currentIntention: _selectedIntention),
              ),
            );
            if (result != null && mounted) {
              setState(() {
                _selectedIntention = result;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LOOKING FOR',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedIntention,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intentionsOptions.firstWhere((element) => element['title'] == _selectedIntention, orElse: () => {'subtitle': ''})['subtitle'] ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EditIntentionsScreen extends StatefulWidget {
  final String currentIntention;
  const EditIntentionsScreen({super.key, required this.currentIntention});

  @override
  State<EditIntentionsScreen> createState() => _EditIntentionsScreenState();
}

class _EditIntentionsScreenState extends State<EditIntentionsScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentIntention;
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _selected != widget.currentIntention;
    if (!hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE43A6A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE43A6A), size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unsaved Changes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),
              const Text(
                'You have unsaved changes. Do you want to save them before leaving?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Close dialog
                    Navigator.pop(context, _selected); // Save and Pop screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true), // Pop screen
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Discard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false), // Stay
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () async {
                if (await _onWillPop()) {
                  if (context.mounted) Navigator.pop(context);
                }
              },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Your Intentions',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What are you looking for?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'All good if it changes. We just want to know what you are looking for right now.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: intentionsOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = intentionsOptions[index];
                    final String title = option['title']!;
                    final String subtitle = option['subtitle']!;
                    final isSelected = _selected == title;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selected = title;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE43A6A).withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected ? const Color(0xFFE43A6A).withOpacity(0.8) : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selected);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
