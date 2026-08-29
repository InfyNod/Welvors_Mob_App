import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admirers_bloc/admirers_bloc.dart';
import '../../admirers_bloc/admirers_event.dart';
import '../../admirers_bloc/admirers_state.dart';
import 'reveal_drawer.dart';
import 'sent.dart';

class ReceivedLikesScreen extends StatefulWidget {
  const ReceivedLikesScreen({super.key});

  @override
  State<ReceivedLikesScreen> createState() => _ReceivedLikesScreenState();
}

class _ReceivedLikesScreenState extends State<ReceivedLikesScreen> {
  int _selectedTab = 0; // 0 for Received, 1 for Sent

  List<Map<String, dynamic>> _likeCards = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final bloc = context.read<AdmirersBloc>();
      if (bloc.state is AdmirersLoaded) {
        _likeCards = List.from((bloc.state as AdmirersLoaded).likes);
      }
      _isInitialized = true;
    }
  }

  void _handleAction(dynamic id, String popupText) {
    final index = _likeCards.indexWhere((card) => card['id'] == id);
    if (index >= 0) {
      _likeCards.removeAt(index);
      context.read<AdmirersBloc>().add(RemoveLike(id));
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

  void _showRevealedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💛', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              'Revealed · like them back!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.only(
          bottom: 16,
          left: 60,
          right: 60,
        ), // Increased horizontal margin to reduce width
        duration: const Duration(milliseconds: 2000), // Faster duration
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggle(),
          const SizedBox(height: 16),
          _selectedTab == 0 ? _buildReceivedGrid() : const SentLikesScreen(),
          if (_selectedTab == 0 && _likeCards.isNotEmpty) _buildPremiumBanner(),
          const SizedBox(height: 24), // Bottom padding for scrolling
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ), // Aligned with grid padding
      height: 50, // Increased height
      padding: const EdgeInsets.all(
        3,
      ), // Reduced padding to make inner slider taller
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12), // More square
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
                    borderRadius: BorderRadius.circular(8), // More square
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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

  Widget _buildReceivedGrid() {
    if (_likeCards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No more likes',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.74,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _likeCards.length,
      itemBuilder: (context, index) {
        final card = _likeCards[index];
        return _buildProfileCard(
          id: card['id'],
          name: card['isBlurred'] ? '' : card['name'],
          age: card['isBlurred'] ? '' : card['age'],
          matchPercent: card['matchPercent'],
          distance: card['distance'],
          imageUrl: card['imageUrl'],
          badgeText: card['badgeText'],
          badgeColor: card['badgeColor'] != null
              ? Color(card['badgeColor'])
              : null,
          badgeTextColor: card['badgeTextColor'] != null
              ? Color(card['badgeTextColor'])
              : null,
          isBlurred: card['isBlurred'],
          onRevealAction: () {
            setState(() {
              card['isBlurred'] = false;
              card['badgeText'] = '✓ REVEALED';
              card['badgeColor'] = 0xFF2CAF6B;
              card['badgeTextColor'] = 0xFFFFFFFF;
            });
            _showRevealedSnackbar(context);
          },
        );
      },
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'More people like you',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Reveal all instantly · free with Premium+',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFBB538), // Yellow premium color
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Unlock all →',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required dynamic id,
    required String name,
    required String age,
    required String matchPercent,
    required String distance,
    required String imageUrl,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    required bool isBlurred,
    VoidCallback? onRevealAction,
  }) {
    return GestureDetector(
      onTap: () {
        if (isBlurred) {
          showRevealDrawer(
            context,
            matchPercent: matchPercent,
            onReveal: () {
              if (onRevealAction != null) {
                onRevealAction();
              }
            },
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(imageUrl, fit: BoxFit.cover),

            // Blur effect if needed
            if (isBlurred)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),

            // Gradient overlay for text readability at bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Top Badge
            if (badgeText != null && !isBlurred)
              Positioned(
                top: 10,
                left: 10,
                right: 10, // Prevent overflow
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

            // Blurred state center content
            if (isBlurred)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFBB538), Color(0xFFF99E22)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🪙', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            '50 · Reveal',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Content
            Positioned(
              bottom: 12,
              left: 12,
              right: isBlurred
                  ? 12
                  : 56, // Only leave space for Heart button if not blurred
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isBlurred)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' $age',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (!isBlurred) const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$matchPercent Match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: ' · ',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                        TextSpan(
                          text: distance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Top Right Cross Button
            if (!isBlurred)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    _handleAction(id, "Rejected ❌");
                  },
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Right Heart Button
            if (!isBlurred)
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    _handleAction(id, "It's a match! 💖");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8), // Slightly larger
                    decoration: BoxDecoration(
                      color: const Color(0xFFE43A6A), // Pink
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE43A6A).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 18, // Slightly larger
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
