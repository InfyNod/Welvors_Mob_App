import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded && state.profiles.isNotEmpty) {
          final currentProfile = state.profiles.first;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      0.75, // Scalable height for cards
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: _CardsStack(),
                  ),
                ),
                _ProfileDetailsView(profile: currentProfile),
                const SizedBox(
                  height: 100,
                ), // Padding for bottom nav & floating rose
              ],
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _CardsStack(),
          );
        }
      },
    );
  }
}

class _ProfileDetailsView extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileDetailsView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Tags Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPillTag(profile.matchPercentage, Colors.blue),
              _buildPillTag(profile.trustPercentage, Colors.green),
              _buildPillTag(profile.replyTime, Colors.orange),
            ],
          ),
          const SizedBox(height: 16),

          // ABOUT Section
          _buildDetailCard(
            title: 'ABOUT',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.about,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'LOOKING FOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.pinkAccent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.lookingFor,
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // THE BASICS Section
          _buildDetailCard(
            title: 'THE BASICS',
            child: Column(
              children: [
                _buildBasicRow(
                  Icons.cake_outlined,
                  'Age',
                  '${profile.age} years old',
                  '19 Feb 1999',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.height_outlined,
                  'Height',
                  profile.height.split(' • ').first,
                  profile.height.split(' • ').last,
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.mosque_outlined,
                  'Religion',
                  profile.religion.split(' • ').first,
                  profile.religion.split(' • ').last,
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.location_on_outlined,
                  'Lives in',
                  profile.location.split(', ').first,
                  profile.location.split(', ').last,
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.translate,
                  'Mother tongue',
                  profile.motherTongue,
                  '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(String text, Color dotColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.pinkAccent,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pink.shade100, width: 1.5),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.pinkAccent,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicRow(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.pinkAccent.shade200, size: 24),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CardsStack extends StatelessWidget {
  const _CardsStack();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          if (state.profiles.isEmpty) {
            return const Center(
              child: Text(
                'No more profiles for today!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Stack(
            children: state.profiles
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final profile = entry.value;
                  final isFront = index == 0;

                  final widgetKey = ValueKey(profile.imageUrl);

                  return isFront
                      ? _DraggableCard(key: widgetKey, profile: profile)
                      : _StaticCard(key: widgetKey, profile: profile);
                })
                .toList()
                .reversed
                .toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _StaticCard extends StatelessWidget {
  final ProfileModel profile;
  const _StaticCard({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileCardUI(profile: profile, glowColor: Colors.transparent);
  }
}

class _DraggableCard extends StatefulWidget {
  final ProfileModel profile;
  const _DraggableCard({required this.profile, super.key});

  @override
  State<_DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<_DraggableCard>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.addListener(() {
      setState(() {
        _position = _animOffset.value;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4;

    if (_position.dx > threshold) {
      // Swiped Right
      _animateOut(Offset(screenWidth * 1.5, 0), true);
    } else if (_position.dx < -threshold) {
      // Swiped Left
      _animateOut(Offset(-screenWidth * 1.5, 0), false);
    } else {
      // Snap Back
      _animOffset = Tween<Offset>(begin: _position, end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
      );
      _animController.forward(from: 0);
    }
  }

  void _animateOut(Offset target, bool isRightSwipe) {
    _animOffset = Tween<Offset>(
      begin: _position,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0).then((_) {
      if (mounted) {
        context.read<HomeBloc>().add(
          SwipeProfileEvent(isRightSwipe: isRightSwipe),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = _position.dx / 400; // slight rotation

    // Calculate glow opacity based on drag distance
    final double dragPercent = (_position.dx / 150).clamp(-1.0, 1.0);
    Color glowColor = Colors.transparent;

    if (dragPercent > 0) {
      glowColor = Colors.green.withOpacity(
        dragPercent * 0.6,
      ); // Green for right
    } else if (dragPercent < 0) {
      glowColor = Colors.red.withOpacity(
        dragPercent.abs() * 0.6,
      ); // Red for left
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _position,
        child: Transform.rotate(
          angle: angle,
          child: _ProfileCardUI(profile: widget.profile, glowColor: glowColor),
        ),
      ),
    );
  }
}

class _ProfileCardUI extends StatelessWidget {
  final ProfileModel profile;
  final Color glowColor;

  const _ProfileCardUI({required this.profile, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(profile.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Directional Glow Overlay (Red/Green based on swipe)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: glowColor,
              ),
            ),
          ),
          // Top-left rotate icon
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, size: 20, color: Colors.black87),
            ),
          ),
          // Top-right diamond icon
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.pink.shade50.withOpacity(0.95),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/Red_Diamond.json',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Bottom gradient & details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  Row(
                    children: [
                      _buildTag(profile.matchPercentage, Colors.blue),
                      const SizedBox(width: 8),
                      _buildTag(profile.trustPercentage, Colors.green),
                      const SizedBox(width: 8),
                      _buildTag(profile.replyTime, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Name & Age
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.age.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Colors.pinkAccent,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  _buildInfoRow(Icons.location_on, profile.location),
                  const SizedBox(height: 4),
                  // Job
                  _buildInfoRow(Icons.work, profile.job),
                  const SizedBox(height: 4),
                  // Intent
                  _buildInfoRow(Icons.favorite, profile.intent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
