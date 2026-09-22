import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

/// Horizontal filter tabs for chat categories (All, Gifts, Compliments, Date Invites)
class ChatFilterTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final ScrollController tabScrollController;
  final Map<int, GlobalKey> tabKeys;
  final int giftsCount;
  final int complimentsCount;
  final int dateInvitesCount;

  const ChatFilterTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.tabScrollController,
    required this.tabKeys,
    required this.giftsCount,
    required this.complimentsCount,
    required this.dateInvitesCount,
  });

  String _countLabel(int count) => count > 0 ? '$count' : '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: tabScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab('💬 All', '', 0),
            const SizedBox(width: 18),
            _buildTab('🎁 Gifts', _countLabel(giftsCount), 1),
            const SizedBox(width: 18),
            _buildTab('💖 Compliments', _countLabel(complimentsCount), 2),
            const SizedBox(width: 18),
            _buildTab('📅 Date Invites', _countLabel(dateInvitesCount), 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, String count, int index) {
    final selected = selectedTab == index;
    final tabKey = tabKeys.putIfAbsent(index, GlobalKey.new);

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: KeyedSubtree(
        key: tabKey,
        child: Container(
          padding: const EdgeInsets.only(bottom: 6, top: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFE43A6A) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: AppText.h2.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFFE43A6A) : AppColors.ink60,
                ),
              ),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  count,
                  maxLines: 1,
                  style: AppText.pill.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? const Color(0xFFE43A6A) : AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
