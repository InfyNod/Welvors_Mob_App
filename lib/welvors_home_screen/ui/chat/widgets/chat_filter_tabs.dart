import 'package:flutter/material.dart';

/// Horizontal pill/chip filter tabs for chat categories (All, Gifts, Compliments, Date Invites, Events)
class ChatFilterTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final ScrollController tabScrollController;
  final Map<int, GlobalKey> tabKeys;
  final int giftsCount;
  final int complimentsCount;
  final int dateInvitesCount;
  final int eventsCount;

  const ChatFilterTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.tabScrollController,
    required this.tabKeys,
    required this.giftsCount,
    required this.complimentsCount,
    required this.dateInvitesCount,
    this.eventsCount = 0,
  });

  String _countLabel(int count) => count > 0 ? '$count' : '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEFECE6), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab('💬 All', '', 0),
            const SizedBox(width: 8),
            _buildTab('🎁 Gifts', _countLabel(giftsCount), 1),
            const SizedBox(width: 8),
            _buildTab('💝 Compliments', _countLabel(complimentsCount), 2),
            const SizedBox(width: 8),
            _buildTab('📅 Date Invites', _countLabel(dateInvitesCount), 3),
            const SizedBox(width: 8),
            _buildTab('🎟 Events', _countLabel(eventsCount), 4),
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
      behavior: HitTestBehavior.opaque,
      child: KeyedSubtree(
        key: tabKey,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE85A7A) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? const Color(0xFFE85A7A) : const Color(0xFFEFECE6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF5F5C56),
                ),
              ),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.30)
                        : const Color(0xFFF5F2EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : const Color(0xFF8A8680),
                    ),
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
