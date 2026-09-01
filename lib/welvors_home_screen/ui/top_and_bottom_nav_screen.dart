import 'dart:async';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home/filter/filter_bloc/filter_bloc.dart';
import 'home/filter/filter_bloc/filter_state.dart';
import 'package:flutter/rendering.dart';
import 'package:velvors/welvors_home_screen/ui/admirers/admirers_bloc/admirers_bloc.dart';
import 'package:velvors/welvors_home_screen/ui/admirers/admirers_bloc/admirers_event.dart';
import 'package:velvors/welvors_home_screen/ui/home/filter/filter_screen.dart';
import '../home_bloc/home_bloc.dart';
import 'home/home_screen.dart';
import 'home/send_compliment/complimenting.dart';
import 'home/notification/notification_screen.dart';
import 'date_now/date_now_screen.dart';
import 'admirers/top_nav_admirers_screen.dart';
import 'chat/chat_screen.dart';
import 'event/top_nav_events_screen.dart';
import 'drawer_files/dating/drawer_screen_dating.dart';
import 'drawer_files/dating/my_boosts/boost_bloc/boost_bloc.dart';
import 'drawer_files/dating/my_boosts/boost_bloc/boost_state.dart';
import 'drawer_files/dating/my_boosts/boost_history.dart/performance_screen.dart';
import 'drawer_files/dating/my_boosts/boost_wallet_all_screen/boost_wallet_top_nav.dart';

class TopAndBottomNavScreen extends StatefulWidget {
  final bool isPreview;
  final int initialIndex;
  const TopAndBottomNavScreen({
    super.key,
    this.isPreview = false,
    this.initialIndex = 0,
  });

  @override
  State<TopAndBottomNavScreen> createState() => _TopAndBottomNavScreenState();
}

class _TopAndBottomNavScreenState extends State<TopAndBottomNavScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isPreview) {
      return _TopAndBottomNavView(
        isPreview: widget.isPreview,
        initialIndex: widget.initialIndex,
      );
    }
    return MultiBlocProvider(
      providers: [
        // HomeBloc is now provided globally in main.dart and pre-fetched in splash_screen.dart
        BlocProvider(create: (context) => FilterBloc()),
        BlocProvider(create: (context) => AdmirersBloc()..add(LoadAdmirersData())),
      ],
      child: _TopAndBottomNavView(
        isPreview: widget.isPreview,
        initialIndex: widget.initialIndex,
      ),
    );
  }
}

class _TopAndBottomNavView extends StatefulWidget {
  final bool isPreview;
  final int initialIndex;
  const _TopAndBottomNavView({this.isPreview = false, this.initialIndex = 0});

  @override
  State<_TopAndBottomNavView> createState() => _TopAndBottomNavViewState();
}

class _TopAndBottomNavViewState extends State<_TopAndBottomNavView> {
  late int _selectedIndex;
  bool _isRoseVisible = true;
  bool _isDrawerOpen = false;
  bool _hasUnreadNotifications = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: (_isDrawerOpen || _selectedIndex != 0)
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(52),
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
                    _rosePositionNotifier.value = Offset(
                      maxWidth - 82,
                      maxHeight - 95,
                    );
                  }
                });
              }

              return Stack(
                children: [
                  _getSelectedScreen(),
                  // Draggable Floating Rose Button (Only on Home Screen)
                  if (_selectedIndex == 0 && !_isDrawerOpen)
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _rosePositionNotifier,
                        _isDraggingRoseNotifier,
                      ]),
                      builder: (context, child) {
                        final currentRosePos =
                            _rosePositionNotifier.value ??
                            Offset(maxWidth - 82, maxHeight - 95);

                        final currentPos = Offset(
                          currentRosePos.dx.clamp(0.0, maxWidth - 70),
                          currentRosePos.dy.clamp(0.0, maxHeight - 70),
                        );

                        final double dockedLeft = currentPos.dx > maxWidth / 2
                            ? maxWidth - 25
                            : -45;

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
                            // Implement send rose logic
                            final homeState = context.read<HomeBloc>().state;
                            if (homeState is HomeLoaded && homeState.profiles.isNotEmpty) {
                              final profile = homeState.profiles.first;
                              final name = profile.name;
                              final imageUrl = profile.images.isNotEmpty ? profile.images.first : null;
                              
                              ComplimentingBottomSheet.show(
                                context,
                                type: 'Profile',
                                profileName: name,
                                profileImageUrl: imageUrl,
                              );
                            }
                          }
                        },
                        onPanUpdate: (details) {
                          if (!_isRoseVisible) return;
                          final currentRosePos =
                              _rosePositionNotifier.value ??
                              Offset(maxWidth - 82, maxHeight - 95);
                          final currentPos = Offset(
                            currentRosePos.dx.clamp(0.0, maxWidth - 70),
                            currentRosePos.dy.clamp(0.0, maxHeight - 70),
                          );

                          _rosePositionNotifier.value = Offset(
                            (currentPos.dx + details.delta.dx).clamp(
                              0.0,
                              maxWidth - 70,
                            ),
                            (currentPos.dy + details.delta.dy).clamp(
                              0.0,
                              maxHeight - 70,
                            ),
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
      ),
    );
  }

  Widget _getSelectedScreen() {
    if (_isDrawerOpen) {
      return const DrawerScreen();
    }
    return IndexedStack(
      index: _selectedIndex,
      children: [
        HomeScreen(isPreview: widget.isPreview),
        const DateNowScreen(),
        const TopNavAdmirersScreen(),
        const ChatScreen_(),
        const EventsScreen(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 0.0,
        bottom: 4.0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSideWidth = (constraints.maxWidth - 120) / 2;
          return Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDrawerOpen = !_isDrawerOpen;
                    });
                  },
                  child: _buildTopIcon(
                    _isDrawerOpen ? Icons.close : Icons.menu,
                    color: Colors.black87,
                    iconSize: 24,
                  ),
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
              Positioned(
                right: 0,
                width: maxSideWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<BoostBloc, BoostState>(
                        builder: (context, boostState) {
                          final isActive = boostState.isAnyBoostActive;
                          return GestureDetector(
                            onTap: () {
                              if (isActive && boostState.history.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PerformanceScreen(
                                      item: boostState.history.first,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BoostWalletTopNav(),
                                  ),
                                );
                              }
                            },
                            child: _PulsingBoostIcon(
                              activeBoost:
                                  isActive && boostState.history.isNotEmpty
                                  ? boostState.history.first
                                  : null,
                              child: _buildTopIcon(
                                Icons.bolt,
                                color: isActive
                                    ? const Color(
                                        0xFFE43A6A,
                                      ) // Vibrant Pink for contrast
                                    : Colors.amber.shade700,
                                iconSize: 24,
                                bgColor: isActive
                                    ? const Color(
                                        0xFFFFF0F5,
                                      ) // Soft light premium pink
                                    : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final filterBloc = context.read<FilterBloc>();
                          final homeBloc = context.read<HomeBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: filterBloc),
                                  BlocProvider.value(value: homeBloc),
                                ],
                                child: const FilterScreen(),
                              ),
                            ),
                          );
                        },
                        child: BlocBuilder<FilterBloc, FilterState>(
                          builder: (context, filterState) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildTopIcon(
                                  Icons.tune,
                                  color: Colors.black54,
                                  iconSize: 24,
                                ),
                                if (filterState.hasActiveFilters)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildNotificationIcon(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopIcon(
    IconData icon, {
    Color? color,
    double iconSize = 22,
    double circleSize = 40,
    Color bgColor = Colors.white,
  }) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen(
              onMarkAllRead: () {
                setState(() {
                  _hasUnreadNotifications = false;
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
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
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 24, color: Colors.black54),
            if (_hasUnreadNotifications)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
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
            final inactiveWidth = _isDrawerOpen
                ? screenWidth / 5
                : (screenWidth - activeWidth) / 4;

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
                  if (!_isDrawerOpen)
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
                        (!_isDrawerOpen && 0 == _selectedIndex)
                            ? activeWidth
                            : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.play_circle_outline,
                        'Date Now',
                        1,
                        (!_isDrawerOpen && 1 == _selectedIndex)
                            ? activeWidth
                            : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.favorite_border,
                        'Admirers',
                        2,
                        (!_isDrawerOpen && 2 == _selectedIndex)
                            ? activeWidth
                            : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.chat_bubble_outline,
                        'Chat',
                        3,
                        (!_isDrawerOpen && 3 == _selectedIndex)
                            ? activeWidth
                            : inactiveWidth,
                      ),
                      _buildNavItem(
                        Icons.calendar_today_outlined,
                        'Events',
                        4,
                        (!_isDrawerOpen && 4 == _selectedIndex)
                            ? activeWidth
                            : inactiveWidth,
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
    final isActive = !_isDrawerOpen && _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _isDrawerOpen = false;
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
                  color: isActive ? Colors.white : Colors.grey.shade700,
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

class _PulsingBoostIcon extends StatefulWidget {
  final BoostHistoryItem? activeBoost;
  final Widget child;

  const _PulsingBoostIcon({required this.activeBoost, required this.child});

  @override
  State<_PulsingBoostIcon> createState() => _PulsingBoostIconState();
}

class _PulsingBoostIconState extends State<_PulsingBoostIcon> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.activeBoost != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(_PulsingBoostIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isActiveNow = widget.activeBoost != null;
    final wasActive = oldWidget.activeBoost != null;

    if (isActiveNow && !wasActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!isActiveNow && wasActive) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeBoost != null;
    double progress = 0.0;
    Color progressColor = Colors.transparent;

    if (isActive) {
      final isSuper = widget.activeBoost!.isSuperBoost;
      final totalDuration = isSuper
          ? const Duration(hours: 3)
          : const Duration(hours: 1);
      final elapsed = DateTime.now().difference(widget.activeBoost!.date);
      progress = elapsed.inMilliseconds / totalDuration.inMilliseconds;
      progress = progress.clamp(0.0, 1.0);
      progressColor = isSuper
          ? const Color(0xFFFFC107)
          : const Color(0xFFE43A6A);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isActive)
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        widget.child,
      ],
    );
  }
}
