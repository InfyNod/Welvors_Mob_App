import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admirers_bloc/admirers_bloc.dart';
import '../../admirers_bloc/admirers_event.dart';
import '../../admirers_bloc/admirers_state.dart';
import '../../service_admire/admirers_api_service.dart';

class SentLikesScreen extends StatefulWidget {
  const SentLikesScreen({super.key});

  @override
  State<SentLikesScreen> createState() => _SentLikesScreenState();
}

class _SentLikesScreenState extends State<SentLikesScreen> {
  final Set<String> _hiddenCardIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdmirersBloc, AdmirersState>(
      builder: (context, state) {
        if (state is AdmirersLoading || state is AdmirersInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
          );
        } else if (state is AdmirersLoaded) {
          final allSentCards = state.sentLikes;
          final sentCards = allSentCards.where((c) => !_hiddenCardIds.contains(c['id']?.toString() ?? '')).toList();

          if (sentCards.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFFE43A6A),
              onRefresh: () async {
                setState(() {
                  _hiddenCardIds.clear();
                });
                context.read<AdmirersBloc>().add(LoadAdmirersData());
                await Future.delayed(const Duration(milliseconds: 1500));
              },
              child: _buildEmptyState(),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFE43A6A),
            onRefresh: () async {
              setState(() {
                _hiddenCardIds.clear();
              });
              context.read<AdmirersBloc>().add(LoadAdmirersData());
              await Future.delayed(const Duration(milliseconds: 1500));
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: sentCards.length,
              itemBuilder: (context, index) {
                final card = sentCards[index];
                return AnimatedSentCardItem(
                  key: ValueKey(card['id'] ?? index),
                  card: card,
                  onAnimationComplete: () {
                    setState(() {
                      _hiddenCardIds.add(card['id']?.toString() ?? index.toString());
                    });
                  },
                  builder: (c, onSent) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildSentCard(c, onSent),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE43A6A).withOpacity(0.08),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send_rounded,
                        size: 42,
                        color: Color(0xFFE43A6A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Sent Likes Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1F1F),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profiles you like will appear here so you can keep track of them.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentCard(Map<String, dynamic> card, VoidCallback onSent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(card['statusTextColor'] ?? 0xFF9E9E9E).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(card),
          _buildBody(card),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildFooter(card, onSent),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> card) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(card['statusBgColor'] ?? 0xFFEEEEEE),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(card['statusTextColor'] ?? 0xFF9E9E9E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                card['statusText'] ?? '',
                style: TextStyle(
                  color: Color(card['statusTextColor'] ?? 0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            card['timeElapsed'] ?? '',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> card) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(card['imageUrl'] ?? ''),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${card['name'] ?? ''}, ${card['age'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8EF), // light pink
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Color(0xFFE43A6A),
                            size: 10,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'You liked her',
                            style: TextStyle(
                              color: Color(0xFFE43A6A),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${card['matchPercent'] ?? ''} · ${card['location'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFooter(Map<String, dynamic> card, VoidCallback onSent) {
    int progressState = card['progressState'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressPill(
                'SENT',
                progressState >= 0,
                const Color(0xFFFFF6E6), // bg
                const Color(0xFF8A6011), // text
              ),
              _buildProgressLine(),
              _buildProgressPill(
                'SEEN',
                progressState >= 1,
                const Color(0xFFE9F2FF), // bg
                const Color(0xFF3563C1), // text
              ),
              _buildProgressLine(),
              _buildProgressPill(
                progressState >= 2 ? 'MATCHED' : 'MATCH',
                progressState >= 2,
                const Color(0xFFE9F7F0), // bg
                const Color(0xFF1B7F53), // text
              ),
            ],
          ),
          _buildActionButton(card, onSent),
        ],
      ),
    );
  }

  Widget _buildProgressPill(
    String text,
    bool isActive,
    Color activeBgColor,
    Color activeTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeBgColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12), // Pill shape
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? activeTextColor : Colors.grey.shade500,
          fontSize: 8, // Slightly smaller text
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      width: 12,
      height: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> card, VoidCallback onSent) {
    return AnimatedRoseButton(
      text: card['actionText'] ?? 'Send a rose',
      baseColor: Color(card['actionBgColor'] ?? 0xFFE43A6A),
      textColor: Color(card['actionTextColor'] ?? 0xFFFFFFFF),
      onSent: onSent,
    );
  }
}

class AnimatedRoseButton extends StatefulWidget {
  final String text;
  final Color baseColor;
  final Color textColor;
  final VoidCallback? onSent;

  const AnimatedRoseButton({
    super.key,
    required this.text,
    required this.baseColor,
    required this.textColor,
    this.onSent,
  });

  @override
  State<AnimatedRoseButton> createState() => _AnimatedRoseButtonState();
}

class _AnimatedRoseButtonState extends State<AnimatedRoseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late bool _isSent;

  @override
  void initState() {
    super.initState();
    _isSent = !widget.text.toLowerCase().contains('send');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Only animate if it is an active "Send a rose" button
    if (!_isSent) {
      _startAnimationLoop();
    }
  }

  void _startAnimationLoop() async {
    while (mounted && !_isSent) {
      await _controller.forward();
      if (!mounted || _isSent) break;
      await _controller.reverse();
      if (!mounted || _isSent) break;
      await Future.delayed(
        const Duration(seconds: 1),
      ); // 1 second delay between pulses
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isSent) return;

    setState(() {
      _isSent = true;
    });

    _controller.stop(); // Stop the pulsing animation

    // Show custom bouncy popup message
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    if (widget.onSent != null) {
      widget.onSent!();
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 120, // Slightly above the bottom
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
                  ), // Smaller padding
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
                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min, // Make width as small as possible
                    children: [
                      Text(
                        '🌹',
                        style: TextStyle(fontSize: 14),
                      ), // Smaller emoji
                      SizedBox(width: 6),
                      Text(
                        'Rose sent', // Shorter text
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12, // Smaller font
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
    bool isActive = !_isSent;
    String displayText = _isSent ? 'Rose sent' : widget.text;
    Color bgColor = _isSent ? const Color(0xFFF5F5F5) : widget.baseColor;
    Color txtColor = _isSent ? const Color(0xFF757575) : widget.textColor;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: isActive ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), // Square-ish corners
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(colors: [bgColor, bgColor]),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFE43A6A).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌹', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                displayText,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedSentCardItem extends StatefulWidget {
  final Map<String, dynamic> card;
  final Widget Function(Map<String, dynamic> card, VoidCallback onSent) builder;
  final VoidCallback? onAnimationComplete;

  const AnimatedSentCardItem({
    super.key,
    required this.card,
    required this.builder,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedSentCardItem> createState() => _AnimatedSentCardItemState();
}

class _AnimatedSentCardItemState extends State<AnimatedSentCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    _sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleSent() async {
    // API Call
    try {
      final service = AdmirersApiService();
      final receiverId = widget.card['userId']?.toString() ?? widget.card['id'].toString();
      debugPrint('Attempting to send rose to receiverId: $receiverId');
      await service.sendRose(receiverId: receiverId);
      debugPrint('Rose sent successfully to $receiverId');
    } catch (e) {
      debugPrint('Failed to send rose: $e');
    }

    // Wait for the popup message to be seen, then slide out
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _slideController.forward().then((_) {
          if (mounted && widget.onAnimationComplete != null) {
            widget.onAnimationComplete!();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.builder(widget.card, _handleSent),
      ),
    );
  }
}
