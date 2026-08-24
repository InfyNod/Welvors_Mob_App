import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/export.dart';

class RelationshipTagSheet extends StatefulWidget {
  final ValueChanged<String> onSend;

  const RelationshipTagSheet({required this.onSend});

  @override
  State<RelationshipTagSheet> createState() => _RelationshipTagSheetState();
}

class _RelationshipTagSheetState extends State<RelationshipTagSheet> {
  int _selected = 0;

  static const _tags = [
    ('In a Relationship', 'Committed and official'),
    ('Open Relationship', 'Exploring with transparency'),
    ('Engaged', 'Planning for a future together'),
    ('Date to Marry', 'Committed to a future marriage'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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

                // Icon
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Title
                Center(
                  child: Text(
                    "What's your status?",
                    style: AppText.h1.copyWith(fontSize: 20),
                  ),
                ),

                const SizedBox(height: 6),

                // Description
                Center(
                  child: Text(
                    'Select a tag to propose to Aanya. '
                    'It will be displayed on both profiles once accepted.',
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                ),

                const SizedBox(height: 22),

                // TAGS
                ...List.generate(_tags.length, (index) {
                  final selected = _selected == index;
                  final tag = _tags[index];

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _selected = index;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primarySoft : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.line,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tag.$1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.ink,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  tag.$2,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.sub.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Icon(
                            selected ? Icons.favorite : Icons.favorite_border,
                            color: selected
                                ? AppColors.primary
                                : AppColors.line,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // SEND BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSend(_tags[_selected].$1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Send Tag Proposal'),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Aanya will receive a notification to confirm',
                    textAlign: TextAlign.center,
                    style: AppText.sub.copyWith(color: AppColors.muted),
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
