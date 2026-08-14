import 'package:flutter/material.dart';
import 'dart:ui';
import 'reveal_drawer.dart';
import 'sent.dart';

class ReceivedLikesScreen extends StatefulWidget {
  const ReceivedLikesScreen({super.key});

  @override
  State<ReceivedLikesScreen> createState() => _ReceivedLikesScreenState();
}

class _ReceivedLikesScreenState extends State<ReceivedLikesScreen> {
  int _selectedTab = 0; // 0 for Received, 1 for Sent
  bool _isCard3Revealed = false;
  bool _isCard4Revealed = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggle(),
          const SizedBox(height: 16),
          _selectedTab == 0 ? _buildReceivedGrid() : const SentLikesScreen(),
          if (_selectedTab == 0) _buildPremiumBanner(),
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.74, // Changed from 0.72 to 0.85 to make cards shorter
      children: [
        _buildProfileCard(
          name: 'Marcus',
          age: '29',
          matchPercent: '75%',
          distance: '8 km',
          imageUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80',
          badgeText: '💬 Sent a note',
          badgeColor: Colors.white,
          badgeTextColor: Colors.black87,
          isBlurred: false,
        ),
        _buildProfileCard(
          name: 'Jordan',
          age: '27',
          matchPercent: '88%',
          distance: '5 km',
          imageUrl:
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=500&q=80',
          badgeText: '✓ VERIFIED',
          badgeColor: const Color(0xFF2CAF6B),
          badgeTextColor: Colors.white,
          isBlurred: false,
        ),
        _buildProfileCard(
          name: _isCard3Revealed ? 'Sarah' : '',
          age: _isCard3Revealed ? '25' : '',
          matchPercent: '92%',
          distance: '3 km',
          imageUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80',
          badgeText: _isCard3Revealed ? '✓ REVEALED' : null,
          badgeColor: const Color(0xFF2CAF6B),
          badgeTextColor: Colors.white,
          isBlurred: !_isCard3Revealed,
          onRevealAction: () {
            setState(() {
              _isCard3Revealed = true;
            });
            _showRevealedSnackbar(context);
          },
        ),
        _buildProfileCard(
          name: _isCard4Revealed ? 'Emily' : '',
          age: _isCard4Revealed ? '23' : '',
          matchPercent: '81%',
          distance: '6 km',
          imageUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
          badgeText: _isCard4Revealed ? '✓ REVEALED' : null,
          badgeColor: const Color(0xFF2CAF6B),
          badgeTextColor: Colors.white,
          isBlurred: !_isCard4Revealed,
          onRevealAction: () {
            setState(() {
              _isCard4Revealed = true;
            });
            _showRevealedSnackbar(context);
          },
        ),
      ],
    );
  }

  void _showRevealedSnackbar(BuildContext context) {
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

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  '34 more people like you',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reveal all instantly · free with\nPremium+',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
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
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isBlurred)
                    Row(
                      children: [
                        Text(
                          '$name, $age',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (!isBlurred) const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$matchPercent Match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        ' · ',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        distance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons (Cross & Heart)
            if (!isBlurred)
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE43A6A), // Pink
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
