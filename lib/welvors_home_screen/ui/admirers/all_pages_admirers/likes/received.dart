import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admirers_bloc/admirers_bloc.dart';
import '../../admirers_bloc/admirers_event.dart';
import '../../admirers_bloc/admirers_state.dart';
import 'reveal_drawer.dart';
import '../profile_view/profile_view.dart';

class ReceivedLikesScreen extends StatefulWidget {
  const ReceivedLikesScreen({super.key});

  @override
  State<ReceivedLikesScreen> createState() => _ReceivedLikesScreenState();
}

class _ReceivedLikesScreenState extends State<ReceivedLikesScreen> {
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
    
    // Pass the text to custom popup
    // Usually popupText has an emoji at the end like "Rejected ❌", 
    // so we can just display it directly.
    _showCustomPopup(context, popupText);
  }

  void _showRevealedSnackbar(BuildContext context) {
    _showCustomPopup(context, 'Revealed · like them back!', '💛');
  }

  void _showCustomPopup(BuildContext context, String text, [String? emoji]) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 120, // Match the height from sent.dart
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack, // Bouncy pop animation
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                  );
                },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (emoji != null) ...[
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12, // Same text style
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFE43A6A),
      onRefresh: () async {
        context.read<AdmirersBloc>().add(LoadAdmirersData());
        await Future.delayed(const Duration(milliseconds: 1500));
      },
      child: _likeCards.isEmpty
          ? const CustomScrollView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No received likes yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildReceivedGrid(),
                  if (_likeCards.isNotEmpty) _buildPremiumBanner(),
                  const SizedBox(height: 24), // Bottom padding for scrolling
                ],
              ),
            ),
    );
  }

  Widget _buildReceivedGrid() {
    if (_likeCards.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: const Center(
          child: Text(
            'No received likes yet',
            style: TextStyle(color: Colors.grey),
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
          onTapProfile: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdmirerProfileView(
                  userCard: card,
                  onAction: _handleAction,
                ),
              ),
            );
          },
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
    VoidCallback? onTapProfile,
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
        } else {
          if (onTapProfile != null) {
            onTapProfile();
          }
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
