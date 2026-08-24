import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<FilterNotifications>(_onFilterNotifications);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  void _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    
    // Simulating API delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Massive dummy data from screenshots
    final List<Map<String, dynamic>> mockData = [
      {'isHeader': true, 'title': 'TODAY'},
      {
        'title': 'Dev, 27', 'action': ' sent you a Rose',
        'subtitle': '"Your trekking photos sold me — let\'s swap trail stories."',
        'time': '12 min ago', 'buttonText': 'View profile', 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.local_florist, 'badgeColor': const Color(0xFFE43A6A),
      },
      {
        'title': 'Arjun, 28', 'action': ' complimented your About',
        'subtitle': "'Equally driven and equally curious — that line got me.'",
        'time': '3 h ago', 'buttonText': null, 'isUnread': false, 'isItalic': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.chat_bubble_outline, 'badgeColor': const Color(0xFFD69E2E),
      },
      {
        'title': "It's a match with ", 'action': 'Aanya, 25',
        'subtitle': 'You both liked each other. Say hello before the spark fades.',
        'time': '40 min ago', 'buttonText': 'Send a message', 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.check, 'badgeColor': const Color(0xFF10B981),
      },
      {
        'title': 'Elena, 23', 'action': ' sent you a message',
        'subtitle': "'Haha okay that café pick was elite. When are you free?'",
        'time': '1 h ago', 'buttonText': null, 'isUnread': true, 'isItalic': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.chat_bubble_outline, 'badgeColor': const Color(0xFFE43A6A),
      },
      {
        'title': 'Kabir', 'action': ' approved your date request',
        'subtitle': 'Coffee at Blue Tokai · Today, 7:00 PM · Koregaon Park',
        'time': '2 h ago', 'buttonText': 'Open chat', 'isUnread': true,
        'icon': Icons.calendar_today_rounded, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Tanya, 25', 'action': ' wants to join your plan',
        'subtitle': '"Sunset coffee tonight" · She suggested splitting the bill (TTMM)',
        'time': '1 h ago', 'buttonText': 'Review request', 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.account_balance_wallet, 'badgeColor': const Color(0xFFB45309),
      },
      {
        'title': 'Your date is ', 'action': 'tonight',
        'subtitle': 'Reminder: Coffee with Kabir at 7:00 PM · Blue Tokai, Koregaon Park',
        'time': '5 h ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Dev, 27', 'action': ' sent you a Rose & a gift',
        'subtitle': 'A red Rose 🌹 with a note — opened in your chat.',
        'time': '25 min ago', 'buttonText': 'Open chat', 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.card_giftcard, 'badgeColor': const Color(0xFF6366F1),
      },
      {
        'title': 'Aanya', 'action': ' accepted your event invite',
        'subtitle': "You're both going to Sunset Soirée for Singles · Sat, Oct 12",
        'time': '2 h ago', 'buttonText': 'View event', 'isSecondaryButton': true, 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.favorite, 'badgeColor': const Color(0xFFF97316),
      },
      {
        'title': 'Action needed — ', 'action': 'finish verification',
        'subtitle': 'Add your government ID to reach Platinum and unlock more matches.',
        'time': '4 h ago', 'buttonText': 'Continue', 'isUnread': true,
        'icon': Icons.security, 'iconColor': const Color(0xFF059669), 'iconBgColor': const Color(0xFFECFDF5),
      },
      {
        'title': '+₹500', 'action': ' · Gift received from Aanya',
        'subtitle': 'Coins added to your Welvors wallet · Today, 2:14 PM',
        'time': 'Today, 2:14 PM', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': '−₹50', 'action': ' · Rose sent to Jordan',
        'subtitle': 'Paid from wallet · Balance ₹3,240',
        'time': 'Today, 11:02 AM', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      
      {'isHeader': true, 'title': 'EARLIER THIS WEEK'},
      {
        'title': 'Shraddha, 21', 'action': ' and 4 others liked you',
        'subtitle': "See everyone who's into you in Admirers.",
        'time': 'Yesterday', 'buttonText': 'View admirers', 'isSecondaryButton': true, 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.favorite, 'badgeColor': const Color(0xFFE43A6A),
      },
      {
        'title': 'Aanya, 25', 'action': ' matched your Rose',
        'subtitle': 'Your Rose paid off — start the conversation.',
        'time': '2 days ago', 'buttonText': 'Open chat', 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.star, 'badgeColor': const Color(0xFF3B82F6),
      },
      {
        'title': 'Someone viewed your profile', 'action': '',
        'subtitle': "See who's checking you out — a VIP perk.",
        'time': '2 days ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.workspace_premium, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': Colors.black87,
      },
      {
        'title': 'Priya, 24', 'action': ' sent a voice note',
        'subtitle': '0:14 — tap to listen in chat.',
        'time': '2 days ago', 'buttonText': null, 'isUnread': false,
        'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.mic, 'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Your match with ', 'action': 'Jordan is expiring',
        'subtitle': 'You have 24 hours left to send the first message.',
        'time': '2 days ago', 'buttonText': 'Say hi now', 'isUnread': true,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFF97316), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': '3 people', 'action': ' requested to join your plan',
        'subtitle': '"Sunset coffee tonight" · Review & approve who you meet.',
        'time': '2 days ago', 'buttonText': 'Review requests', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.group, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Your request to join was approved', 'action': '',
        'subtitle': 'Meera accepted — Dinner at 45 Days, Baner · Fri 8 PM',
        'time': '2 days ago', 'buttonText': 'Open chat', 'isUnread': true,
        'icon': Icons.check_circle, 'iconColor': const Color(0xFF10B981), 'iconBgColor': const Color(0xFFECFDF5),
      },
      {
        'title': '5 new plans', 'action': ' live near you tonight',
        'subtitle': 'Coffee, dinner & rooftop plans within 4 km · matching your filters',
        'time': 'Yesterday', 'buttonText': 'Browse plans', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.location_on, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Chloe, 26', 'action': ' sent you a gift',
        'subtitle': 'A Cup of Coffee ☕ — opened in your chat.',
        'time': 'Yesterday', 'buttonText': 'View gift', 'isSecondaryButton': true, 'isUnread': false,
        'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.coffee, 'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Arjun, 28', 'action': ' sent a premium gift',
        'subtitle': 'A Promise Ring 💍 — one of the rarest gifts on Welvors.',
        'time': '2 days ago', 'buttonText': 'Open chat', 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.diamond, 'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Your gift was opened', 'action': '',
        'subtitle': 'Aanya loved the Teddy 🧸 you sent. Send another to keep it going.',
        'time': '3 days ago', 'buttonText': 'Send a gift', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.auto_awesome, 'iconColor': const Color(0xFF8B5CF6), 'iconBgColor': const Color(0xFFF3E8FF),
      },
      {
        'title': 'Filling fast', 'action': ' — Sunset Soirée for Singles',
        'subtitle': 'Only 8 of 60 spots left. Book before it sells out.',
        'time': 'Yesterday', 'buttonText': 'Book now', 'isUnread': true,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFE43A6A), 'iconBgColor': const Color(0xFFFDF2F8),
      },
      {
        'title': 'Reminder —', 'action': ' your event is tomorrow',
        'subtitle': 'Sunset Soirée · Sat, Oct 12 · 7:00 PM · The Rooftop Lounge, Bandra',
        'time': '2 days ago', 'buttonText': 'View ticket', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFE43A6A), 'iconBgColor': const Color(0xFFFDF2F8),
      },
      {
        'title': 'Rohan', 'action': ' invited you to an event',
        'subtitle': 'Speed Dating Night · Thu, Oct 17 · The Velvet Room, Lower Parel',
        'time': '3 days ago', 'buttonText': 'View invite', 'isSecondaryButton': true, 'isUnread': false,
        'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.confirmation_number, 'badgeColor': const Color(0xFFF97316),
      },
      {
        'title': 'Photo verification approved', 'action': '',
        'subtitle': 'Your Trust Score went up to 98%. You now stand out more.',
        'time': 'Yesterday', 'buttonText': 'Open Trust Centre', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.verified_user, 'iconColor': const Color(0xFF10B981), 'iconBgColor': const Color(0xFFECFDF5),
      },
      {
        'title': 'Your Boost just ended', 'action': '',
        'subtitle': '11× more profile views in the last 30 min. See the breakdown.',
        'time': '2 days ago', 'buttonText': 'View report', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.bolt, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFFBEB),
      },
      {
        'title': 'Your profile is ', 'action': '80% complete',
        'subtitle': 'Add 2 more photos and a prompt to get noticed more.',
        'time': '3 days ago', 'buttonText': 'Complete profile', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.person_outline, 'iconColor': const Color(0xFF8B5CF6), 'iconBgColor': const Color(0xFFF3E8FF),
      },
      {
        'title': 'Your AI Avatar is ready', 'action': '',
        'subtitle': 'Preview your studio avatar and add it to your profile.',
        'time': '3 days ago', 'buttonText': 'View avatar', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.auto_awesome, 'iconColor': const Color(0xFF8B5CF6), 'iconBgColor': const Color(0xFFF3E8FF),
      },
      {
        'title': '+₹2,000', 'action': ' · Money added via UPI',
        'subtitle': 'Includes ₹100 bonus on your top-up · tanishka@oksbi',
        'time': '2 days ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': '−₹270', 'action': ' · Date Plans topped up',
        'subtitle': '3 plans @ ₹90 each · used to post dates on Date Now',
        'time': '2 days ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      
      {'isHeader': true, 'title': 'EARLIER'},
      {
        'title': 'You\'re a Top Pick today', 'action': '',
        'subtitle': 'Your profile is featured to more people for 24 hours.',
        'time': '5 days ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.star, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFFBEB),
      },
      {
        'title': 'You received a VIP+ proposal', 'action': '',
        'subtitle': 'Someone wants to make it exclusive. Reveal it in Admirers.',
        'time': '1 week ago', 'buttonText': null, 'isUnread': true,
        'icon': Icons.workspace_premium, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': Colors.black87,
      },
      {
        'title': 'Aanya', 'action': ' wants to add a relationship tag',
        'subtitle': 'She tagged you as "Exclusive". Confirm to make it mutual.',
        'time': '4 days ago', 'buttonText': 'Review tag', 'isSecondaryButton': true, 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.favorite, 'badgeColor': const Color(0xFFE43A6A),
      },
      {
        'title': 'You have 3 unread messages', 'action': '',
        'subtitle': 'Don\'t leave them hanging — reply to keep matches warm.',
        'time': '5 days ago', 'buttonText': 'Open messages', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.chat_bubble_outline, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': 'Your plan expires soon', 'action': '',
        'subtitle': '"Sunday brunch" goes offline in 6 hours. Extend or repost it.',
        'time': '4 days ago', 'buttonText': 'Manage plan', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFF97316), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Only 1 Date Plan left', 'action': '',
        'subtitle': 'Top up to keep posting plans on Date Now · ₹100 per plan',
        'time': '5 days ago', 'buttonText': 'Top up plans', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.local_activity, 'iconColor': const Color(0xFFF97316), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Elena, 23', 'action': ' sent you Chocolates',
        'subtitle': 'A box of Chocolates 🍫 — sweeten the chat back.',
        'time': '5 days ago', 'buttonText': 'Reply with a gift', 'isSecondaryButton': true, 'isUnread': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        'badgeIcon': Icons.card_giftcard, 'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Gift of the week — Bouquet', 'action': '',
        'subtitle': 'Send a Bouquet 💐 today and it counts double toward your streak.',
        'time': '1 week ago', 'buttonText': 'Send now', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.local_florist, 'iconColor': const Color(0xFFE43A6A), 'iconBgColor': const Color(0xFFFDF2F8),
      },
      {
        'title': 'Booking confirmed — Singles Supper Club', 'action': '',
        'subtitle': 'Sat, Oct 12 · 7:00 PM · The Terrace, Bandra. See you there.',
        'time': '4 days ago', 'buttonText': 'View booking', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.event_available, 'iconColor': const Color(0xFF10B981), 'iconBgColor': const Color(0xFFECFDF5),
      },
      {
        'title': 'A waitlist spot just opened', 'action': '',
        'subtitle': 'Rooftop Wine & Connect has space — claim it before it\'s gone.',
        'time': '6 days ago', 'buttonText': 'Claim spot', 'isSecondaryButton': true, 'isUnread': true,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFF97316), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'New event near you — Speed Dating Night', 'action': '',
        'subtitle': 'Thu, Oct 17 · The Velvet Room, Lower Parel · 8 spots left',
        'time': '6 days ago', 'buttonText': 'View event', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.event, 'iconColor': const Color(0xFFE43A6A), 'iconBgColor': const Color(0xFFFDF2F8),
      },
      {
        'title': 'Refund initiated — ₹1,250', 'action': '',
        'subtitle': 'For your cancelled booking · credited in 5–7 business days',
        'time': '1 week ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': 'ID verification approved', 'action': '',
        'subtitle': "You're now ID-verified. A verified badge is live on your profile.",
        'time': '5 days ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.verified_user, 'iconColor': const Color(0xFF10B981), 'iconBgColor': const Color(0xFFECFDF5),
      },
      {
        'title': 'Welcome to ', 'action': 'VIP',
        'subtitle': 'Your plan is active — enjoy unlimited likes, who-liked-you & more.',
        'time': '5 days ago', 'buttonText': 'See benefits', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.workspace_premium, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': Colors.black87,
      },
      {
        'title': 'You have ', 'action': '2 Boosts', 'titleSuffix': ' left',
        'subtitle': 'Use them at peak hours (8–10 PM) for the most views.',
        'time': '6 days ago', 'buttonText': 'Use a Boost', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.bolt, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': const Color(0xFFFFFBEB),
      },
      {
        'title': 'Your VIP renews in 3 days', 'action': '',
        'subtitle': 'Renews at ₹1,499/mo on 28 Jun. Manage anytime.',
        'time': '6 days ago', 'buttonText': 'Manage plan', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.access_time_rounded, 'iconColor': const Color(0xFFF97316), 'iconBgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Forever Love — ', 'action': 'milestone reached',
        'subtitle': 'You\'ve completed 6 months together. Keep going toward your 5 Lakh trip.',
        'time': '1 week ago', 'buttonText': 'View journey', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.favorite, 'iconColor': const Color(0xFFF59E0B), 'iconBgColor': Colors.black87,
      },
      {
        'title': 'New login to your account', 'action': '',
        'subtitle': 'iPhone 15 · Mumbai · If this wasn\'t you, secure your account.',
        'time': '1 week ago', 'buttonText': 'Review activity', 'isSecondaryButton': true, 'isUnread': true,
        'icon': Icons.security, 'iconColor': const Color(0xFFE43A6A), 'iconBgColor': const Color(0xFFFDF2F8),
      },
      {
        'title': '+₹500 added to your wallet', 'action': '',
        'subtitle': 'Riya activated a plan with your invite. Keep referring to earn more.',
        'time': '6 days ago', 'buttonText': 'Open wallet', 'isSecondaryButton': true, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': '−₹80', 'action': ' · Compliment sent to Elena',
        'subtitle': 'Paid from wallet · Balance updated',
        'time': '6 days ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': '−₹1,500', 'action': ' · Withdrawal processed',
        'subtitle': '₹1,125 sent to HDFC •••• 1234 · ₹375 service charge (25%)',
        'time': '1 week ago', 'buttonText': null, 'isUnread': false,
        'icon': Icons.account_balance_wallet, 'iconColor': const Color(0xFF3B82F6), 'iconBgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': 'Low wallet balance', 'action': '',
        'subtitle': 'You\'re below ₹200. Add money to keep sending gifts & boosts.',
        'time': '1 week ago', 'buttonText': 'Add money', 'isSecondaryButton': true, 'isUnread': true,
        'icon': Icons.warning_amber_rounded, 'iconColor': const Color(0xFFF97316), 'iconBgColor': const Color(0xFFFFF7ED),
      },
    ];

    emit(state.copyWith(
      status: NotificationStatus.loaded,
      allNotifications: mockData,
      displayedNotifications: mockData,
      selectedTabIndex: 0,
    ));
  }

  void _onFilterNotifications(FilterNotifications event, Emitter<NotificationState> emit) {
    if (state.status != NotificationStatus.loaded) return;

    List<Map<String, dynamic>> filtered = [];

    if (event.tabIndex == 0) {
      filtered = List.from(state.allNotifications);
    } else {
      filtered = state.allNotifications.where((notif) {
        if (notif['isHeader'] == true) return false;
        
        final String action = (notif['action'] ?? '').toString().toLowerCase();
        final String title = (notif['title'] ?? '').toString().toLowerCase();
        final String subtitle = (notif['subtitle'] ?? '').toString().toLowerCase();
        
        if (event.tabName == 'Likes & roses') {
          return action.contains('like') || action.contains('rose') || title.contains('like');
        } else if (event.tabName == 'Matches') {
          return title.contains('match') || action.contains('match');
        } else if (event.tabName == 'Gifts') {
          return action.contains('gift') || title.contains('gift') || action.contains('chocolate') || title.contains('chocolate');
        } else if (event.tabName == 'Dates') {
          return title.contains('date') || action.contains('date') || action.contains('plan') || title.contains('plan');
        } else if (event.tabName == 'Events') {
          return action.contains('event') || title.contains('event') || title.contains('soiré');
        } else if (event.tabName == 'Wallet') {
          return action.contains('wallet') || title.contains('₹') || title.contains('wallet');
        } else if (event.tabName == 'Account') {
          return title.contains('profile') || title.contains('vip') || action.contains('vip') || title.contains('verification') || title.contains('account');
        }
        
        return true; 
      }).toList();
    }

    emit(state.copyWith(
      selectedTabIndex: event.tabIndex,
      displayedNotifications: filtered,
    ));
  }

  void _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotificationState> emit) {
    if (state.status != NotificationStatus.loaded) return;

    final updatedList = state.allNotifications.map((notif) {
      if (notif.containsKey('isUnread')) {
        final newNotif = Map<String, dynamic>.from(notif);
        newNotif['isUnread'] = false;
        return newNotif;
      }
      return notif;
    }).toList();

    final updatedDisplayed = state.displayedNotifications.map((notif) {
      if (notif.containsKey('isUnread')) {
        final newNotif = Map<String, dynamic>.from(notif);
        newNotif['isUnread'] = false;
        return newNotif;
      }
      return notif;
    }).toList();

    emit(state.copyWith(
      allNotifications: updatedList,
      displayedNotifications: updatedDisplayed,
    ));
  }
}
