import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import 'home_screen.dart';
import 'date_now_screen.dart';
import 'admirers_screen.dart';
import 'chat_screen.dart';
import 'events_screen.dart';

class TopAndBottomNavScreen extends StatelessWidget {
  const TopAndBottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeDataEvent()),
      child: const _TopAndBottomNavView(),
    );
  }
}

class _TopAndBottomNavView extends StatefulWidget {
  const _TopAndBottomNavView();

  @override
  State<_TopAndBottomNavView> createState() => _TopAndBottomNavViewState();
}

class _TopAndBottomNavViewState extends State<_TopAndBottomNavView> {
  int _selectedIndex = 0;
  bool _isRoseVisible = true;
  
  final ValueNotifier<Offset?> _rosePositionNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isDraggingRoseNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _rosePositionNotifier.dispose();
    _isDraggingRoseNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(bottom: false, child: _buildTopBar()),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            // Scrolling down -> Dock rose to edge
            if (_isRoseVisible) setState(() => _isRoseVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            // Scrolling up -> Undock rose
            if (!_isRoseVisible) setState(() => _isRoseVisible = true);
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            // Initialize to bottom-right corner safely, waiting for a valid height
            if (_rosePositionNotifier.value == null && maxHeight > 200) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_rosePositionNotifier.value == null) {
                  _rosePositionNotifier.value = Offset(maxWidth - 82, maxHeight - 95);
                }
              });
            }

            return Stack(
              children: [
                _getSelectedScreen(),

                // Draggable Floating Rose Button (Only on Home Screen)
                if (_selectedIndex == 0)
                  AnimatedBuilder(
                    animation: Listenable.merge([_rosePositionNotifier, _isDraggingRoseNotifier]),
                    builder: (context, child) {
                      final currentRosePos = _rosePositionNotifier.value ?? Offset(maxWidth - 82, maxHeight - 95);
                      
                      final currentPos = Offset(
                        currentRosePos.dx.clamp(0.0, maxWidth - 70),
                        currentRosePos.dy.clamp(0.0, maxHeight - 70),
                      );

                      final double dockedLeft = currentPos.dx > maxWidth / 2 ? maxWidth - 25 : -45;

                      return AnimatedPositioned(
                        duration: _isDraggingRoseNotifier.value
                            ? Duration.zero
                            : const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        left: _isRoseVisible ? currentPos.dx : dockedLeft,
                        top: currentPos.dy,
                        child: child!,
                      );
                    },
                    child: GestureDetector(
                      onPanStart: (details) {
                        if (!_isRoseVisible) return;
                        _isDraggingRoseNotifier.value = true;
                      },
                      onPanEnd: (details) {
                        _isDraggingRoseNotifier.value = false;
                      },
                      onTap: () {
                        if (!_isRoseVisible) {
                          // Tap to undock
                          setState(() => _isRoseVisible = true);
                        } else {
                          // TODO: Implement send rose logic here in the future
                        }
                      },
                      onPanUpdate: (details) {
                        if (!_isRoseVisible) return; // Prevent dragging while docked
                        
                        final currentRosePos = _rosePositionNotifier.value ?? Offset(maxWidth - 82, maxHeight - 95);
                        final currentPos = Offset(
                          currentRosePos.dx.clamp(0.0, maxWidth - 70),
                          currentRosePos.dy.clamp(0.0, maxHeight - 70),
                        );
                        
                        _rosePositionNotifier.value = Offset(
                          (currentPos.dx + details.delta.dx).clamp(0.0, maxWidth - 70),
                          (currentPos.dy + details.delta.dy).clamp(0.0, maxHeight - 70),
                        );
                      },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isRoseVisible
                            ? 1.0
                            : 0.4, // Fades out slightly when docked
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.pinkAccent.shade100,
                                const Color.fromARGB(244, 237, 231, 233),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            '🌹',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen(); // Just calls the HomeScreen which handles the cards
      case 1:
        return const DateNowScreen();
      case 2:
        return const AdmirersScreen();
      case 3:
        return const ChatScreen();
      case 4:
        return const EventsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Left side (Menu Icon)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildTopIcon(Icons.menu, color: Colors.black87),
            ),
          ),

          // Center (Daily dynamically updated)
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daily ${state.remainingSwipes}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Right side (Action Icons)
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopIcon(Icons.bolt, color: Colors.amber.shade700),
                  const SizedBox(width: 10),
                  _buildTopIcon(Icons.tune, color: Colors.black54),
                  const SizedBox(width: 10),
                  _buildNotificationIcon(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Icon(Icons.notifications_none, size: 22, color: Colors.black54),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            // Active tab gets 32% of width, rest is divided among 4 inactive tabs
            final activeWidth = screenWidth * 0.32;
            final inactiveWidth = (screenWidth - activeWidth) / 4;

            double getLeftOffset(int index) {
              double left = 0;
              for (int i = 0; i < index; i++) {
                left += (i == _selectedIndex) ? activeWidth : inactiveWidth;
              }
              return left;
            }

            final indicatorLeft = getLeftOffset(_selectedIndex) + 4;
            final indicatorWidth = activeWidth - 8;

            return SizedBox(
              height: 44, // Slightly decreased height
              child: Stack(
                children: [
                  // Snake sliding background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: indicatorLeft,
                    top: 0,
                    bottom: 0,
                    width: indicatorWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pinkAccent.shade100,
                            Colors.redAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  // Tab Icons
                  Row(
                    children: [
                      _buildNavItem(
                        Icons.home_filled,
                        'Home',
                        0,
                        0 == _selectedIndex ? activeWidth : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.play_circle_outline,
                        'Date Now',
                        1,
                        1 == _selectedIndex ? activeWidth : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.favorite_border,
                        'Admirers',
                        2,
                        2 == _selectedIndex ? activeWidth : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.chat_bubble_outline,
                        'Chat',
                        3,
                        3 == _selectedIndex ? activeWidth : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.calendar_today_outlined,
                        'Events',
                        4,
                        4 == _selectedIndex ? activeWidth : inactiveWidth,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, double width) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade400,
                  size: isActive ? 20 : 26,
                ),
                if (isActive) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
