import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admirers_bloc/admirers_bloc.dart';
import '../../admirers_bloc/admirers_state.dart';

class SentLikesScreen extends StatelessWidget {
  const SentLikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdmirersBloc, AdmirersState>(
      builder: (context, state) {
        if (state is AdmirersLoading || state is AdmirersInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
          );
        } else if (state is AdmirersLoaded) {
          final sentCards = state.sentLikes;

          if (sentCards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No sent likes yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: sentCards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final card = sentCards[index];
              return _buildSentCard(card);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSentCard(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          _buildQuote(card),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildFooter(card),
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
                          Icon(Icons.favorite, color: Color(0xFFE43A6A), size: 10),
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

  Widget _buildQuote(Map<String, dynamic> card) {
    if (card['quote'] == null || card['quote'].isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Text(
        card['quote'],
        style: const TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.black54,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFooter(Map<String, dynamic> card) {
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
          _buildActionButton(card),
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

  Widget _buildActionButton(Map<String, dynamic> card) {
    return AnimatedRoseButton(
      text: card['actionText'] ?? 'Send a rose',
      baseColor: Color(card['actionBgColor'] ?? 0xFFE43A6A),
      textColor: Color(card['actionTextColor'] ?? 0xFFFFFFFF),
    );
  }
}

class AnimatedRoseButton extends StatefulWidget {
  final String text;
  final Color baseColor;
  final Color textColor;

  const AnimatedRoseButton({
    super.key,
    required this.text,
    required this.baseColor,
    required this.textColor,
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

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 120, // Slightly above the bottom
          left: 0,
          right: 0,
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
        );
      },
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
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
                    colors: [Color(0xFFFF6B9E), Color(0xFFE43A6A)],
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
