import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/config/custom_snackbar.dart';

class ChatAutomationScreen extends StatefulWidget {
  const ChatAutomationScreen({super.key});

  @override
  State<ChatAutomationScreen> createState() => _ChatAutomationScreenState();
}

class _AutoRule {
  final String key;
  final String title;
  final String description;
  final String icon;
  final Color iconBg;
  final List<String> templates;
  bool isEnabled = false;
  String text = '';

  _AutoRule({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.templates,
  });
}

class _ChatAutomationScreenState extends State<ChatAutomationScreen> {
  final Map<String, _AutoRule> _rules = {
    'acc': _AutoRule(
      key: 'acc',
      title: 'When we match',
      description: 'Your first line goes out the moment you match',
      icon: '💬',
      iconBg: const Color(0xFFE9EEFA),
      templates: [
        'We matched — and I’m genuinely glad. Tell me one thing that made you smile today?',
        'Hi! Something about your profile felt real. I’d love to know the person behind it.',
        'Okay, this feels like a good start. What does your perfect Sunday look like?',
      ],
    ),
    'rose': _AutoRule(
      key: 'rose',
      title: 'When someone sends you a rose',
      description: 'Thank them before the moment passes',
      icon: '🌹',
      iconBg: const Color(0xFFFFEEF2),
      templates: [
        'A rose? That’s the sweetest thing today — thank you. You just made me smile properly.',
        'Okay, that was lovely. Thank you for the rose — and for not playing it cool.',
        'You didn’t have to send a rose… but I’m so glad you did. Tell me more about you.',
        'That rose made my evening. Consider my curiosity officially yours.',
      ],
    ),
    'comp': _AutoRule(
      key: 'comp',
      title: 'When someone compliments you',
      description: 'Reply warmly to compliments on your profile',
      icon: '💝',
      iconBg: const Color(0xFFFFF4E0),
      templates: [
        'That’s such a kind thing to say — thank you. You noticed the one photo I love most.',
        'Okay, you’ve made me blush a little. Thank you — that was genuinely sweet.',
        'Thank you — compliments like that stay with a person. What made you pick that one?',
        'You have a way with words. Thank you — that meant more than you’d think.',
      ],
    ),
    'gift': _AutoRule(
      key: 'gift',
      title: 'When someone sends you a gift',
      description: 'Say thank you the second it lands',
      icon: '🎁',
      iconBg: const Color(0xFFEAF7F0),
      templates: [
        'A gift? You’re spoiling me — thank you, genuinely. That was so thoughtful.',
        'Okay, this made my whole day. Thank you — I’m keeping this one.',
        'You didn’t have to, and that’s exactly why it means something. Thank you ❤️',
        'Thank you — gestures like this say more than a hundred messages.',
      ],
    ),
  };

  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedRules();
  }

  Future<void> _loadSavedRules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chat_automation_settings');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final key in _rules.keys) {
          if (decoded.containsKey(key) && decoded[key] is Map) {
            final map = decoded[key] as Map;
            _rules[key]!.isEnabled = map['on'] == true;
            _rules[key]!.text = map['v']?.toString() ?? '';
          }
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  Future<void> _persistRules() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = <String, dynamic>{};
    for (final e in _rules.entries) {
      toSave[e.key] = {
        'on': e.value.isEnabled,
        'v': e.value.text,
      };
    }
    await prefs.setString('chat_automation_settings', jsonEncode(toSave));
  }

  void _toggleRule(String key) {
    final rule = _rules[key]!;
    if (rule.text.isEmpty && !rule.isEnabled) {
      _openEditSheet(key);
      return;
    }
    setState(() {
      rule.isEnabled = !rule.isEnabled;
    });
    _persistRules();
    CustomSnackBar.showSuccess(
      context,
      '${rule.title} is ${rule.isEnabled ? "on" : "off"}',
    );
  }

  void _openEditSheet(String key) {
    final rule = _rules[key]!;
    String draft = rule.text;
    final textController = TextEditingController(text: draft);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grip bar
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFECE6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      rule.title,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rule.description,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Color(0xFF5F5C56),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'PICK A TEMPLATE',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Color(0xFF8A8680),
                      ),
                    ),
                    const SizedBox(height: 9),

                    ...rule.templates.map((tpl) {
                      final isSelected = draft == tpl;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            draft = tpl;
                            textController.text = tpl;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFEEF2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE85A7A)
                                  : const Color(0xFFEFECE6),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            tpl,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13.5,
                              height: 1.45,
                              color: isSelected
                                  ? const Color(0xFFC73A5E)
                                  : const Color(0xFF1F1F1F),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    const Text(
                      'OR WRITE YOUR OWN',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Color(0xFF8A8680),
                      ),
                    ),
                    const SizedBox(height: 9),

                    TextField(
                      controller: textController,
                      maxLength: 200,
                      maxLines: 4,
                      minLines: 3,
                      onChanged: (val) {
                        setSheetState(() {
                          draft = val;
                        });
                      },
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13.5,
                        height: 1.5,
                        color: Color(0xFF1F1F1F),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your message…',
                        hintStyle: const TextStyle(
                          fontFamily: 'DM Sans',
                          color: Color(0xFF8A8680),
                        ),
                        counterText: '${draft.length}/200',
                        counterStyle: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
                          color: Color(0xFF8A8680),
                        ),
                        contentPadding: const EdgeInsets.all(13),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFEFECE6),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFEFECE6),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE85A7A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: draft.trim().isEmpty
                            ? null
                            : () {
                                setState(() {
                                  rule.text = draft.trim();
                                  rule.isEnabled = true;
                                });
                                _persistRules();
                                Navigator.of(sheetContext).pop();
                                CustomSnackBar.showSuccess(
                                  context,
                                  '${rule.title} is on',
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85A7A),
                          disabledBackgroundColor: const Color(0xFFEFECE6),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: const Color(0xFF8A8680),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Save & turn on',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF8F4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE85A7A)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEFECE6)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
          children: [
            const Text(
              '✈️',
              style: TextStyle(fontSize: 34),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chat Automation',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: Color(0xFF1F1F1F),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When someone sends you a rose, a compliment or a gift, we reply for you — warm, grateful, and in your voice. No one is left on read.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: Color(0xFF5F5C56),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AUTO-REPLIES',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF8A8680),
              ),
            ),
            const SizedBox(height: 10),

            ..._rules.values.map(_buildRuleCard),

            const SizedBox(height: 18),
            const Text(
              'Auto-replies are free and go out within seconds. You can edit or turn any of them off anytime — and once you reply yourself, automation stops for that chat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                color: Color(0xFF8A8680),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(_AutoRule rule) {
    final hasValue = rule.text.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFECE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: rule.iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  rule.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: rule.isEnabled
                            ? const Color(0xFF1F1F1F)
                            : const Color(0xFF5F5C56),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rule.description,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        color: Color(0xFF5F5C56),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: rule.isEnabled,
                onChanged: (_) => _toggleRule(rule.key),
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFE85A7A),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE0DCD2),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEFECE6), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? rule.text : 'Not set yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? const Color(0xFF1F1F1F)
                          : const Color(0xFF8A8680),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _openEditSheet(rule.key),
                  child: Text(
                    hasValue ? 'Edit →' : 'Create now →',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE85A7A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
