import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/sizesboxs.dart';

class YourJourneyScreen extends StatefulWidget {
  final VoidCallback? function;

  const YourJourneyScreen({super.key, this.function});

  @override
  State<YourJourneyScreen> createState() => _YourJourneyScreenState();
}

class _YourJourneyScreenState extends State<YourJourneyScreen> {
  int? expandedStep;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F1),
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------
            // TOP NAVIGATION
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    width: 40,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 17,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Your Journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ----------------------------------------------------------
            // BODY
            // ----------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    hSized12,

                    // Profile
                    _buildProfileHeader(),

                    hSized12,

                    const Text(
                      'You & Aanya',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Connected 47 days · Exclusively Dating',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),

                    const SizedBox(height: 20),

                    // Progress Card
                    _buildProgressCard(),

                    const SizedBox(height: 24),

                    // Section Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'YOUR LEVEL LADDER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Timeline
                    _buildTimeline(),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------------
            // BOTTOM BUTTON
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.function!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE5370),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Level up your relationship',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // PROFILE HEADER
  // =========================================================================

  Widget _buildProfileHeader() {
    return SizedBox(
      height: 90,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
              ),
            ),
          ),

          Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('💕', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PROGRESS CARD
  // =========================================================================

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Level 4 · Dating',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB52B44),
                ),
              ),
              Text(
                '2 / 3 dates done',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Unfilled
                Container(
                  height: 8,
                  width: double.infinity,
                  color: const Color(0xFFF5F2EC),
                ),

                // Filled
                FractionallySizedBox(
                  widthFactor: 2 / 3,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEE5370), Color(0xFFFF8A65)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 13),
              children: [
                TextSpan(
                  text: '1 more offline date to ',
                  style: TextStyle(fontSize: 12),
                ),
                TextSpan(
                  text: 'Level 5 · Exclusive',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TIMELINE
  // =========================================================================

  Widget _buildTimeline() {
    return Column(
      children: [
        // ----------------------------------------------------------
        // STEP 1
        // ----------------------------------------------------------
        _buildTimelineStep(
          stepIndex: 0,
          icon: '🌹',
          title: 'First Spark',
          subtitle: 'Break the ice',
          isDone: true,
          showLine: true,
          child: _buildStepCard(
            title: 'First Spark',
            description: 'Start your journey together.',
            tasks: [
              _buildTaskData('Say hello', true),
              _buildTaskData('Start your first conversation', true),
              _buildTaskData('Get to know each other', true),
            ],
          ),
        ),

        // ----------------------------------------------------------
        // STEP 2
        // ----------------------------------------------------------
        _buildTimelineStep(
          stepIndex: 1,
          icon: '🔥',
          title: 'Warming Up',
          subtitle: 'Find your rhythm',
          isDone: true,
          showLine: true,
          child: _buildStepCard(
            title: 'Warming Up',
            description: 'Build your connection and find your rhythm.',
            tasks: [
              _buildTaskData('Chat regularly', true),
              _buildTaskData('Share interests', true),
              _buildTaskData('Spend quality time', true),
            ],
          ),
        ),

        // ----------------------------------------------------------
        // STEP 3
        // ----------------------------------------------------------
        _buildTimelineStep(
          stepIndex: 2,
          icon: '🤝',
          title: 'First Meet',
          subtitle: 'Meet in real life',
          isDone: true,
          showLine: true,
          child: _buildStepCard(
            title: 'First Meet',
            description: 'Take your connection from online to real life.',
            tasks: [
              _buildTaskData('Plan your first date', true),
              _buildTaskData('Meet in real life', true),
              _buildTaskData('Complete your first date', true),
            ],
          ),
        ),

        // ----------------------------------------------------------
        // STEP 4 - CURRENT
        // ----------------------------------------------------------
        _buildTimelineStep(
          stepIndex: 3,
          number: '4',
          icon: '💖',
          title: 'Dating',
          subtitle: 'Make it a habit',
          isCurrent: true,
          showLine: true,
          child: _buildCurrentLevelCard(),
        ),

        // ----------------------------------------------------------
        // STEP 5
        // ----------------------------------------------------------
        _buildTimelineStep(
          stepIndex: 4,
          icon: '🏅',
          title: 'Exclusive',
          subtitle: 'Only each other',
          isLocked: true,
          showLine: true,
          child: _buildStepCard(
            title: 'Exclusive',
            description: 'Complete the Dating stage to unlock Exclusive.',
            tasks: [
              _buildTaskData('Complete 3 offline dates', false),
              _buildTaskData('Build a consistent connection', false),
              _buildTaskData('Choose each other exclusively', false),
            ],
          ),
        ),

        // ----------------------------------------------------------
        // STEP 6
        // ----------------------------------------------------------
        _buildTimelineStep(
          stepIndex: 5,
          icon: '💍',
          title: 'Serious',
          subtitle: 'Building a future',
          isLocked: true,
          showLine: false,
          child: _buildStepCard(
            title: 'Serious',
            description: 'Build a meaningful future together.',
            tasks: [
              _buildTaskData('Build long-term trust', false),
              _buildTaskData('Talk about the future', false),
              _buildTaskData('Grow together', false),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TIMELINE STEP
  // =========================================================================

  Widget _buildTimelineStep({
    required int stepIndex,
    required String icon,
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isCurrent = false,
    bool isLocked = false,
    String? number,
    bool showLine = true,
    Widget? child,
  }) {
    final bool isExpanded = expandedStep == stepIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==============================================================
        // LEFT TIMELINE
        // ==============================================================
        Column(
          children: [
            GestureDetector(
              onTap: () {
                _toggleStep(stepIndex);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF27AE60)
                      : isCurrent
                      ? const Color(0xFFEE5370)
                      : Colors.transparent,
                  border: isLocked
                      ? Border.all(color: Colors.black26, width: 1)
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : isCurrent
                      ? Text(
                          number ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(" 🔒", style: TextStyle(fontSize: 15)),
                ),
              ),
            ),

            if (showLine)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 2,
                height: isExpanded && child != null ? 205 : 36,
                color: Colors.black12,
              ),
          ],
        ),

        const SizedBox(width: 12),

        // ==============================================================
        // RIGHT CONTENT
        // ==============================================================
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _toggleStep(stepIndex);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // TITLE ROW
                // ------------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 16)),

                          const SizedBox(width: 6),

                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isLocked
                                    ? Colors.black38
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    if (isDone)
                      _buildStatus(
                        '✓ DONE',
                        color: const Color(0xFF27AE60),
                        backgroundColor: const Color(0xFFE8F8F0),
                      ),

                    if (isCurrent)
                      _buildStatus(
                        'YOU ARE HERE',
                        color: const Color(0xFFEE5370),
                        backgroundColor: const Color(0xFFFDE8ED),
                      ),

                    if (isLocked)
                      _buildStatus(
                        'LOCKED',
                        color: Colors.black38,
                        backgroundColor: Color(0x0D000000),
                      ),
                  ],
                ),

                // ------------------------------------------------------
                // SUBTITLE
                // ------------------------------------------------------
                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLocked ? Colors.black26 : Colors.black45,
                  ),
                ),

                // ------------------------------------------------------
                // OPEN CARD
                // ------------------------------------------------------
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isExpanded && child != null
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TOGGLE STEP
  // =========================================================================

  void _toggleStep(int stepIndex) {
    setState(() {
      if (expandedStep == stepIndex) {
        expandedStep = null;
      } else {
        expandedStep = stepIndex;
      }
    });
  }

  // =========================================================================
  // STATUS
  // =========================================================================

  Widget _buildStatus(
    String text, {
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // =========================================================================
  // SIMPLE STEP CARD
  // =========================================================================

  Widget _buildStepCard({
    required String title,
    required String description,
    required List<_TaskData> tasks,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),

          const SizedBox(height: 12),

          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTaskRow(
                task.icon,
                task.text,
                isCompleted: task.isCompleted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CURRENT LEVEL CARD
  // =========================================================================

  Widget _buildCurrentLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskRow(
            Icons.check,
            'Meet twice this month',
            isCompleted: true,
          ),

          const SizedBox(height: 8),

          _buildTaskRow(
            Icons.circle_outlined,
            'Chat every week',
            isCompleted: false,
          ),

          const SizedBox(height: 8),

          _buildTaskRow(
            Icons.circle_outlined,
            'Share a photo from your date',
            isCompleted: false,
          ),

          const SizedBox(height: 12),

          const Divider(height: 1, color: Colors.black12),

          const SizedBox(height: 12),

          const Text(
            'Keep meeting regularly to unlock Exclusive.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TASK ROW
  // =========================================================================

  Widget _buildTaskRow(
    IconData icon,
    String text, {
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isCompleted ? const Color(0xFF27AE60) : Colors.black26,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isCompleted ? Colors.black54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TASK DATA
  // =========================================================================

  _TaskData _buildTaskData(String text, bool completed) {
    return _TaskData(
      icon: completed ? Icons.check : Icons.circle_outlined,
      text: text,
      isCompleted: completed,
    );
  }
}

// =============================================================================
// TASK MODEL
// =============================================================================

class _TaskData {
  final IconData icon;
  final String text;
  final bool isCompleted;

  const _TaskData({
    required this.icon,
    required this.text,
    required this.isCompleted,
  });
}
