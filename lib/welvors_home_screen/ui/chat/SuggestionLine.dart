import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';

class SuggestionLine {
  final String text;
  final String tag;
  const SuggestionLine(this.text, this.tag);
}

class SaySomethingBetterSheet extends StatefulWidget {
  final ValueChanged<String> onPick;

  const SaySomethingBetterSheet({super.key, required this.onPick});

  @override
  State<SaySomethingBetterSheet> createState() =>
      _SaySomethingBetterSheetState();
}

class _SaySomethingBetterSheetState extends State<SaySomethingBetterSheet> {
  int _mode =
      1; // 0 Openers, 1 Impression, 2 Go deeper, 3 Ask her out, 4 Revive it

  static const _tabs = [
    '🌱 Openers',
    '✨ Impression',
    '💬 Go deeper',
    '💌 Ask her out',
    '🔄 Revive it',
  ];

  static const _hints = [
    'First message. Reference her profile — generic "hey" gets ignored.',
    'Warm but not over the top. Say one real thing, not five compliments.',
    'Once the small talk is done. These move a chat forward.',
    'Be specific — day, place, and an easy way to say yes to.',
    'Chat gone quiet? Own the gap and give her something easy to reply to.',
  ];

  static const Map<int, List<SuggestionLine>> _lines = {
    0: [
      SuggestionLine(
        'Okay, the Lonavala trek photo — was that sunrise or sunset? I keep meaning to do that one.',
        'USES HER PHOTO',
      ),
      SuggestionLine(
        'Your bio says "night owl" and your gym check-in says 6 AM. I need an explanation.',
        'PLAYFUL, SPECIFIC',
      ),
      SuggestionLine(
        'Two questions: best filter coffee in Pune, and are you free this week to prove it?',
        'OPENER + PLAN',
      ),
      SuggestionLine(
        'You listed pottery and product management in the same breath. That combination is very interesting.',
        'CURIOUS',
      ),
      SuggestionLine(
        'I read the whole profile before typing this, so I refuse to open with "hey".',
        'HONEST, LIGHT',
      ),
    ],
    1: [
      SuggestionLine(
        'You have that rare thing where the photos and the words sound like the same person.',
        'SINCERE',
      ),
      SuggestionLine(
        'I like that you know exactly what you want and you said it plainly. That is attractive.',
        'VALUES HER CLARITY',
      ),
      SuggestionLine(
        'Talking to you feels easy in a way that most conversations here really are not.',
        'WARM',
      ),
      SuggestionLine(
        'You are the first person in weeks whose reply I actually looked forward to.',
        'HONEST',
      ),
      SuggestionLine(
        'You make ordinary plans sound like they would be a good evening.',
        'PLAYFUL',
      ),
    ],
    2: [
      SuggestionLine(
        'What does a really good weekend look like for you — the honest version, not the Instagram one?',
        'REAL ANSWER',
      ),
      SuggestionLine(
        'What are you building towards this year? Work, personal, anything.',
        'AMBITION',
      ),
      SuggestionLine(
        'What is something you changed your mind about in the last year?',
        'THOUGHTFUL',
      ),
      SuggestionLine(
        'What made you join Welvors — what are you hoping to find?',
        'INTENT',
      ),
      SuggestionLine(
        'Who knows you best, and what would they say about you?',
        'PERSONAL',
      ),
    ],
    3: [
      SuggestionLine(
        'Coffee this Saturday, 5 PM, Blue Tokai in Bandra? Say the word and I will book it.',
        'SPECIFIC',
      ),
      SuggestionLine(
        'I would rather talk to you in person than type. Are you free one evening this week?',
        'DIRECT',
      ),
      SuggestionLine(
        'There is a pottery place in Koregaon Park I have been meaning to try. Come make something ugly with me?',
        'ACTIVITY',
      ),
      SuggestionLine(
        'No pressure at all — but if you are free Friday, dinner is on me.',
        'LOW PRESSURE',
      ),
      SuggestionLine(
        'I am posting a Date Now plan for Sunday brunch. If it looks good, request to join.',
        'SOFT ASK',
      ),
    ],
    4: [
      SuggestionLine(
        'I disappeared into a work week. Sorry! How did yours go?',
        'OWNS THE GAP',
      ),
      SuggestionLine(
        'Still owe you an answer on the coffee question. And a coffee.',
        'CALLBACK',
      ),
      SuggestionLine(
        'This chat deserves better than my last reply. Starting again: how was your weekend?',
        'LIGHT',
      ),
      SuggestionLine(
        'Random, but I saw a cat today that looked exactly like your profile cat. Had to tell someone.',
        'EASY REPLY',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final lines = _lines[_mode] ?? const [];

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              Text('Say something better', style: AppText.h1),

              const SizedBox(height: 4),

              Text(
                'Tap a line to drop it in your message box.',
                style: AppText.body.copyWith(color: AppColors.muted),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = _mode == index;
                    return GestureDetector(
                      onTap: () => setState(() => _mode = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.darkChip : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.darkChip
                                : AppColors.line,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: AppText.pill.copyWith(
                            color: selected ? Colors.white : AppColors.ink60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _hints[_mode],
                  style: AppText.body.copyWith(color: AppColors.ink60),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: lines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return GestureDetector(
                      onTap: () => widget.onPick(line.text),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.text,
                              style: AppText.body.copyWith(
                                fontSize: 15,
                                height: 1.4,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              line.tag,
                              style: AppText.eyebrow.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
