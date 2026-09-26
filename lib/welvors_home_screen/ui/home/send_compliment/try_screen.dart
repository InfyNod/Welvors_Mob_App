import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ComplimentIdeasScreen extends StatefulWidget {
  final String? initialText;

  const ComplimentIdeasScreen({super.key, this.initialText});

  static Future<String?> show(BuildContext context, {String? initialText}) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ComplimentIdeasScreen(initialText: initialText),
      ),
    );
  }

  @override
  State<ComplimentIdeasScreen> createState() => _ComplimentIdeasScreenState();
}

class _ComplimentIdeasScreenState extends State<ComplimentIdeasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<String> categories = [
    'Sweet',
    'Playful',
    'Admiring',
    'Flirty',
    'First Move',
  ];
  final Map<String, GlobalKey> categoryKeys = {};
  String selectedCategory = 'Sweet';
  String? selectedCompliment;

  final Map<String, List<String>> complimentMap = {
    'Sweet': [
      'Your smile is absolutely contagious 😄',
      'You have the kind of warmth that makes people feel at home.',
      'There\'s something genuinely lovely about your energy.',
      'I could probably talk to you for hours and never get bored.',
      'You seem like the kind of person who makes ordinary days better.',
      'Your kindness really comes through in your profile.',
    ],
    'Playful': [
      'I bet I could beat you at Mario Kart.',
      'You look like trouble, but the fun kind.',
      'Are you always this stylish or is today a special occasion?',
      'Tell me two truths and a lie.',
      'I was going to wait to message you, but I\'m impatient.',
    ],
    'Admiring': [
      'Your sense of style is impeccable.',
      'I love how passionate you seem about your hobbies.',
      'You have such a captivating presence.',
      'Your profile really stands out from the rest.',
      'I\'m really impressed by your achievements.',
    ],
    'Flirty': [
      'I couldn\'t help but notice your profile.',
      'You\'re definitely my type.',
      'I\'d love to get to know the person behind that smile.',
      'Has anyone told you how attractive you are today?',
      'I think we\'d make a dangerously good team ☕➡️🍷.',
    ],
    'First Move': [
      'Hi! What\'s the best part of your week so far?',
      'I had to say hi before someone else did.',
      'What\'s the most spontaneous thing you\'ve done recently?',
      'If you could travel anywhere right now, where would it be?',
      'What\'s a movie you can watch over and over again?',
    ],
  };

  final Color primaryPink = const Color(0xFFE43A6A);

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 8.0, end: 35.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    for (var cat in categories) {
      categoryKeys[cat] = GlobalKey();
    }
    selectedCompliment = widget.initialText;

    // Auto-select category if initialText matches a compliment
    if (selectedCompliment != null && selectedCompliment!.isNotEmpty) {
      for (var entry in complimentMap.entries) {
        if (entry.value.contains(selectedCompliment)) {
          selectedCategory = entry.key;
          break;
        }
      }
    }
    // ensure the initially selected category is scrolled to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCategory(selectedCategory);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _scrollToCategory(String category) {
    final key = categoryKeys[category];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF05C91).withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF966EB4).withValues(alpha: 0.10),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF242424),
                size: 16,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient (top section)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF0F5), Color(0xFFF3E7FE), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Header area
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 6.0),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  224,
                                  138,
                                  168,
                                ).withValues(alpha: 0.35),
                                blurRadius: _glowAnimation.value,
                                spreadRadius: _glowAnimation.value * 0.15,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: Center(
                        child: Lottie.asset(
                          'assets/message.json',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Title and subtitle
              const Text(
                'Compliment Ideas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'pick one to make a great first impression',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Categories Horizontal List
              SizedBox(
                height: 36,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = category == selectedCategory;

                      return GestureDetector(
                        key: categoryKeys[category],
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                          _scrollToCategory(category);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryPink : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: isSelected
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Compliments Vertical List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    120,
                  ), // extra padding for bottom button
                  physics: const BouncingScrollPhysics(),
                  itemCount: complimentMap[selectedCategory]!.length,
                  itemBuilder: (context, index) {
                    final compliment = complimentMap[selectedCategory]![index];
                    final isSelected = compliment == selectedCompliment;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCompliment = compliment;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFDF3F6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? primaryPink
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                compliment,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: primaryPink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom + 16
                    : 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selectedCompliment != null ? 1.0 : 0.5,
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedCompliment != null
                        ? () => Navigator.pop(context, selectedCompliment)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Use this compliment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
