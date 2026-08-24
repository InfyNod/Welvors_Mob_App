import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _tabScrollController = ScrollController();
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'All',
    'Likes & roses',
    'Matches',
    'Gifts',
    'Dates',
    'Events',
    'Account',
    'Wallet',
  ];

  // Dummy data representing the screenshot exactly
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'rose',
      'title': 'Dev, 27',
      'action': ' sent you a Rose',
      'subtitle': '"Your trekking photos sold me — let\'s swap trail stories."',
      'time': '12 min ago',
      'buttonText': 'View profile',
      'isUnread': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.local_florist, // placeholder for rose
      'badgeColor': const Color(0xFFE43A6A),
    },
    {
      'type': 'compliment',
      'title': 'Arjun, 28',
      'action': ' complimented your About',
      'subtitle': "'Equally driven and equally curious — that line got me.'",
      'time': '3 h ago',
      'buttonText': null,
      'isUnread': false,
      'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.chat_bubble_outline,
      'badgeColor': const Color(0xFFD69E2E),
    },
    {
      'type': 'match',
      'title': "It's a match with ",
      'action': 'Aanya, 25',
      'subtitle': 'You both liked each other. Say hello before the spark fades.',
      'time': '40 min ago',
      'buttonText': 'Send a message',
      'isUnread': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.check,
      'badgeColor': const Color(0xFF10B981),
    },
    {
      'type': 'message',
      'title': 'Elena, 23',
      'action': ' sent you a message',
      'subtitle': "'Haha okay that café pick was elite. When are you free?'",
      'time': '1 h ago',
      'buttonText': null,
      'isUnread': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.chat_bubble_outline,
      'badgeColor': const Color(0xFFE43A6A),
    },
    {
      'type': 'date',
      'title': 'Kabir',
      'action': ' approved your date request',
      'subtitle': 'Coffee at Blue Tokai · Today, 7:00 PM · Koregaon Park',
      'time': '2 h ago',
      'buttonText': 'Open chat',
      'isUnread': true,
      'avatarUrl': null, // No avatar, calendar icon instead
      'badgeIcon': null,
      'badgeColor': null,
    },
    {
      'type': 'plan_join',
      'title': 'Tanya, 25',
      'action': ' wants to join your plan',
      'subtitle': '"Sunset coffee tonight" - She suggested splitting the bill (TTMM)',
      'time': '1 h ago',
      'buttonText': 'Review request',
      'isUnread': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.account_balance_wallet,
      'badgeColor': const Color(0xFFB45309), // Brownish orange
    },
    {
      'type': 'reminder',
      'title': 'Your date is ',
      'action': 'tonight',
      'subtitle': 'Reminder: Coffee with Kabir at 7:00 PM - Blue Tokai, Koregaon Park',
      'time': '5 h ago',
      'buttonText': null,
      'isUnread': false,
      'avatarUrl': null,
      'placeholderIcon': Icons.access_time_rounded,
      'badgeIcon': null,
      'badgeColor': null,
    },
    {
      'type': 'rose_gift',
      'title': 'Dev, 27',
      'action': ' sent you a Rose & a gift',
      'subtitle': 'A red Rose 🌹 with a note — opened in your chat.',
      'time': '25 min ago',
      'buttonText': 'Open chat',
      'isUnread': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.card_giftcard,
      'badgeColor': const Color(0xFF6366F1), // Indigo
    },
    {
      'type': 'event_invite',
      'title': 'Aanya',
      'action': ' accepted your event invite',
      'subtitle': "You're both going to Sunset Soirée for Singles - Sat, Oct 12",
      'time': '2 h ago',
      'buttonText': 'View event',
      'isSecondaryButton': true,
      'isUnread': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'badgeIcon': Icons.favorite,
      'badgeColor': const Color(0xFFF97316), // Orange
    },
  ];

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index, BuildContext context) {
    setState(() {
      _selectedTabIndex = index;
    });

    // Auto-center the tapped tab
    final screenWidth = MediaQuery.of(context).size.width;
    // Estimate width of tabs to calculate offset
    // Ideally we would use GlobalKeys to get exact positions, but this is a quick approximation
    // Let's assume an average width of 90 for a tab
    double estimatedTabWidth = 100.0; 
    
    double offset = (index * estimatedTabWidth) - (screenWidth / 2) + (estimatedTabWidth / 2);
    
    // Clamp the offset so we don't overscroll
    if (offset < 0) offset = 0;
    if (offset > _tabScrollController.position.maxScrollExtent) {
      offset = _tabScrollController.position.maxScrollExtent;
    }

    _tabScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9), // Off-white warm background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFDFCF9),
            surfaceTintColor: Colors.white,
            scrolledUnderElevation: 3,
            shadowColor: Colors.black.withOpacity(0.2),
            pinned: true,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '9 new updates',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: const Color(0xFFE43A6A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tabs.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTabIndex == index;
                      final isAll = index == 0;
                      return GestureDetector(
                        onTap: () => _onTabTapped(index, context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _tabs[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                              if (isAll) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.grey.shade800 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '56',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final notif = _notifications[index];
                  final isUnread = notif['isUnread'] as bool;
                  final isSecondaryButton = notif['isSecondaryButton'] == true;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnread ? const Color(0xFFF9DCE3) : Colors.grey.shade200,
                        width: isUnread ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Area
                        if (notif['avatarUrl'] != null)
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(notif['avatarUrl']),
                                ),
                                if (notif['badgeIcon'] != null)
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: notif['badgeColor'],
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Icon(
                                        notif['badgeIcon'],
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        else
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED), // Very light orange/yellow
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              notif['placeholderIcon'] ?? Icons.calendar_today_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          
                        const SizedBox(width: 14),
                        
                        // Content Area
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rich Text for Title
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                  children: [
                                    if (notif['type'] == 'match' || notif['type'] == 'reminder') ...[
                                      TextSpan(text: notif['title']),
                                      TextSpan(
                                        text: notif['action'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ] else ...[
                                      TextSpan(
                                        text: notif['title'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: notif['action']),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              
                              // Subtitle
                              Text(
                                notif['subtitle'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: notif['type'] == 'compliment' || notif['type'] == 'message'
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade500,
                                  fontStyle: notif['type'] == 'compliment' || notif['type'] == 'message' 
                                      ? FontStyle.italic 
                                      : FontStyle.normal,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Timestamp
                              Text(
                                notif['time'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              
                              // Button (if any)
                              if (notif['buttonText'] != null) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSecondaryButton ? Colors.white : const Color(0xFFE43A6A),
                                        borderRadius: BorderRadius.circular(20),
                                        border: isSecondaryButton ? Border.all(color: Colors.grey.shade300) : null,
                                      ),
                                      child: Text(
                                        notif['buttonText'],
                                        style: TextStyle(
                                          color: isSecondaryButton ? Colors.black87 : Colors.white,
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
                        
                        // Unread Dot
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
                  );
                },
                childCount: _notifications.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
