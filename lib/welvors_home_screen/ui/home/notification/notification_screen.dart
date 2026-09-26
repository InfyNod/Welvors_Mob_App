import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/notification_bloc.dart';
import 'bloc/notification_event.dart';
import 'bloc/notification_state.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback? onMarkAllRead;

  const NotificationScreen({super.key, this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()..add(const LoadNotifications()),
      child: _NotificationScreenContent(onMarkAllRead: onMarkAllRead),
    );
  }
}

class _NotificationScreenContent extends StatefulWidget {
  final VoidCallback? onMarkAllRead;

  const _NotificationScreenContent({this.onMarkAllRead});

  @override
  State<_NotificationScreenContent> createState() =>
      _NotificationScreenContentState();
}

class _NotificationScreenContentState
    extends State<_NotificationScreenContent> {
  final ScrollController _tabScrollController = ScrollController();

  final ScrollController _notificationScrollController = ScrollController();

  final List<String> _tabs = [
    'All',
    'Likes & roses',
    'Matches',
    'Gifts',
    'Dates',
    'Events',
  ];

  @override
  void initState() {
    super.initState();

    _notificationScrollController.addListener(_onNotificationScroll);
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _notificationScrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  void _onNotificationScroll() {
    if (!_notificationScrollController.hasClients) {
      return;
    }

    final position = _notificationScrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<NotificationBloc>().add(const LoadMoreNotifications());
    }
  }

  // ============================================================
  // TAB
  // ============================================================

  void _onTabTapped(int index, BuildContext context) {
    context.read<NotificationBloc>().add(
      FilterNotifications(tabIndex: index, tabName: _tabs[index]),
    );

    if (!_tabScrollController.hasClients) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    const estimatedTabWidth = 100.0;

    double offset =
        (index * estimatedTabWidth) -
        (screenWidth / 2) +
        (estimatedTabWidth / 2);

    if (offset < 0) {
      offset = 0;
    }

    if (offset > _tabScrollController.position.maxScrollExtent) {
      offset = _tabScrollController.position.maxScrollExtent;
    }

    _tabScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _notificationScrollController,
            slivers: [
              // ==================================================
              // APP BAR
              // ==================================================
              SliverAppBar(
                backgroundColor: const Color(0xFFFDFCF9),
                surfaceTintColor: Colors.white,
                scrolledUnderElevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                pinned: true,

                leadingWidth: 64,

                leading: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                centerTitle: true,

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (state.status == NotificationStatus.loaded)
                      state.unreadCount > 0
                          ? Text(
                              '${state.unreadCount} new updates',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.done_all,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "You're all caught up",
                                  style: TextStyle(
                                    color: const Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                  ],
                ),

                // ==================================================
                // MARK ALL
                // ==================================================
                actions: [
                  if (state.status == NotificationStatus.loaded &&
                      state.unreadCount > 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: InkWell(
                          onTap: () {
                            context.read<NotificationBloc>().add(
                              const MarkAllAsRead(),
                            );

                            if (widget.onMarkAllRead != null) {
                              widget.onMarkAllRead!();
                            }
                          },
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Color(0xFFE43A6A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                // ==================================================
                // TABS
                // ==================================================
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: SizedBox(
                      height: 36,
                      child: ListView.separated(
                        controller: _tabScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _tabs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = state.selectedTabIndex == index;

                          final isAll = index == 0;

                          return GestureDetector(
                            onTap: () => _onTabTapped(index, context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _tabs[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),

                                  if (isAll) ...[
                                    const SizedBox(width: 6),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${state.allNotifications.length}',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                  ),
                ),
              ),

              // ==================================================
              // LOADING
              // ==================================================
              if (state.status == NotificationStatus.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                  ),
                )
              // ==================================================
              // ERROR
              // ==================================================
              else if (state.status == NotificationStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            size: 48,
                            color: Color(0xFFE43A6A),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ??
                                'Unable to load notifications',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(
                                const LoadNotifications(refresh: true),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE43A6A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // ==================================================
              // EMPTY
              // ==================================================
              else if (state.displayedNotifications.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No notifications found',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              // ==================================================
              // LIST
              // ==================================================
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 50,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final notif = state.displayedNotifications[index];

                      final isUnread = notif['isUnread'] as bool? ?? false;

                      final isSecondaryButton =
                          notif['isSecondaryButton'] == true;

                      final isItalic = notif['isItalic'] == true;

                      final avatarUrl = notif['avatarUrl'];

                      final icon = notif['icon'];

                      final badgeIcon = notif['badgeIcon'];

                      return GestureDetector(
                        onTap: () {
                          final notificationId = notif['id']?.toString() ?? '';

                          if (notificationId.isNotEmpty && isUnread) {
                            context.read<NotificationBloc>().add(
                              MarkNotificationAsRead(notificationId),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isUnread
                                  ? const Color(0xFFF9DCE3)
                                  : Colors.grey.shade200,
                              width: isUnread ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ==================================================
                              // AVATAR / ICON
                              // ==================================================
                              if (avatarUrl != null)
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey.shade100,
                                        backgroundImage: NetworkImage(
                                          avatarUrl.toString(),
                                        ),
                                      ),

                                      if (badgeIcon != null)
                                        Positioned(
                                          right: -2,
                                          bottom: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color:
                                                  notif['badgeColor'] ??
                                                  const Color(0xFFE43A6A),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              badgeIcon,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              else if (icon != null)
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        notif['iconBgColor'] ??
                                        Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: notif['iconColor']),
                                )
                              else
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                              const SizedBox(width: 14),

                              // ==================================================
                              // CONTENT
                              // ==================================================
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                notif['title']?.toString() ??
                                                '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      notif['subtitle']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isItalic
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade500,
                                        fontStyle: isItalic
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                        height: 1.3,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      notif['time']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // ==================================================
                                    // OPTIONAL BUTTON
                                    // ==================================================
                                    if (notif['buttonText'] != null) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: InkWell(
                                          onTap: () {},
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSecondaryButton
                                                  ? Colors.white
                                                  : const Color(0xFFE43A6A),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: isSecondaryButton
                                                  ? Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )
                                                  : null,
                                            ),
                                            child: Text(
                                              notif['buttonText'],
                                              style: TextStyle(
                                                color: isSecondaryButton
                                                    ? Colors.black87
                                                    : Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // ==================================================
                              // UNREAD DOT
                              // ==================================================
                              if (isUnread)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE43A6A),
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      );
                    }, childCount: state.displayedNotifications.length),
                  ),
                ),

              // ==================================================
              // PAGINATION LOADER
              // ==================================================
              if (state.status == NotificationStatus.loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE43A6A),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
