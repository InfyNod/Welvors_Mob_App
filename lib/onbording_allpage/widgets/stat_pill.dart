import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class StatPill extends StatelessWidget {
  final String? emoji;
  final Widget? icon;
  final String text;
  final Color? emojiColor;
  
  const StatPill({this.emoji, this.icon, required this.text, this.emojiColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppColors.shadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(
              emoji!, 
              style: TextStyle(fontSize: 14, color: emojiColor),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 6),
          ],
          Text(text, style: AppText.pill.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}