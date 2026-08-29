import 'package:flutter/material.dart';
import 'vip_send.dart';

class VipReceivedScreen extends StatefulWidget {
  const VipReceivedScreen({super.key});

  @override
  State<VipReceivedScreen> createState() => _VipReceivedScreenState();
}

class _VipReceivedScreenState extends State<VipReceivedScreen> {
  int _selectedTab = 0; // 0 for Received, 1 for Sent
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<Map<String, dynamic>> _vipCards = [
    {
      'id': 0,
      'name': 'Dev',
      'age': '27',
      'subtitle': '2h ago · 92% Match',
      'pillIcon': '💍',
      'pillText': 'Exclusively Dating',
      'message':
          '"I really feel a connection with you — would love to make this official and stop seeing other people."',
      'imageUrl':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=500&q=80',
    },
    {
      'id': 1,
      'name': 'Arjun',
      'age': '28',
      'subtitle': 'Yesterday · 86% Match',
      'pillIcon': '❤️',
      'pillText': 'In a Relationship',
      'message':
          '"You\'re different from everyone else here. Ready to be exclusive whenever you are."',
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
    },
    {
      'id': 2,
      'name': 'Kabir',
      'age': '30',
      'subtitle': '2 days ago · 81% Match',
      'pillIcon': '💍',
      'pillText': 'Girlfriend / Boyfriend',
      'message':
          '"Let\'s give this a real shot — you\'ve been on my mind all week."',
      'imageUrl':
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=500&q=80',
    },
  ];

  void _handleAction(int id, String popupText, {bool isAccepted = true}) {
    final index = _vipCards.indexWhere((card) => card['id'] == id);
    if (index >= 0) {
      final removedCard = _vipCards.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(removedCard, animation, isAccepted: isAccepted),
        duration: const Duration(milliseconds: 600),
      );
      setState(() {});
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                popupText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 16),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildInfoBanner(),
          const SizedBox(height: 16),
          _buildToggle(),
          const SizedBox(height: 16),
          _selectedTab == 0 ? _buildReceivedContent() : const VipSendScreen(),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 24,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (_selectedTab == 0 && _vipCards.length <= 2) ? 0.0 : 1.0,
              child: Text(
                _selectedTab == 0
                    ? '👑 You\'re seeing proposals because you\'re a VIP+ member'
                    : '👑 Proposals are a VIP+ exclusive feature',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              alignment: _selectedTab == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _selectedTab == 0
                            ? const Color(0xFFE85A7A)
                            : Colors.grey.shade600,
                        fontWeight: _selectedTab == 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 15,
                      ),
                      child: const Text('Received'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _selectedTab == 1
                            ? const Color(0xFFE85A7A)
                            : Colors.grey.shade600,
                        fontWeight: _selectedTab == 1
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 15,
                      ),
                      child: const Text('Sent'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(32, 32, 31, 1),
            Color.fromRGBO(55, 45, 26, 1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(251, 207, 99, 1),
                  Color.fromRGBO(240, 183, 77, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('👑', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          // Texts
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VIP+ Proposals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Serious relationship proposals — visible only to VIP & VIP Elite members.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: _vipCards.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(_vipCards[index], animation);
            },
          ),
          if (_vipCards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No more proposals',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> card, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildVipCard(
            id: card['id'],
            name: card['name'],
            age: card['age'],
            subtitle: card['subtitle'],
            pillIcon: card['pillIcon'],
            pillText: card['pillText'],
            message: card['message'],
            imageUrl: card['imageUrl'],
          ),
        ),
      ),
    );
  }

  Widget _buildRemovedItem(
    Map<String, dynamic> card,
    Animation<double> animation, {
    bool isAccepted = true,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1.0),
        ),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: Offset(isAccepted ? 1.5 : -1.5, 0), // slides out left if declined, right if accepted
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInBack, // snapping effect
                ),
              ),
          child: RotationTransition(
            turns: Tween<double>(
              begin: isAccepted ? 0.05 : -0.05,
              end: 0.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildVipCard(
                id: card['id'],
                name: card['name'],
                age: card['age'],
                subtitle: card['subtitle'],
                pillIcon: card['pillIcon'],
                pillText: card['pillText'],
                message: card['message'],
                imageUrl: card['imageUrl'],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVipCard({
    required int id,
    required String name,
    required String age,
    required String subtitle,
    required String pillIcon,
    required String pillText,
    required String message,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name, $age',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFF4), // Light pink bg
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(pillIcon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            pillText,
                            style: const TextStyle(
                              color: Color(0xFFE85A7A), // pink text
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              // Accept
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _handleAction(id, "Proposal Accepted! 💍", isAccepted: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85A7A),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE85A7A).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '❤️ Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Decline
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _handleAction(id, "Declined ❌", isAccepted: false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No sent proposals yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
