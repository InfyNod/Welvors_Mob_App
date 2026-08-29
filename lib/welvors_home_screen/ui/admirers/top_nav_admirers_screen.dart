import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'admirers_bloc/admirers_bloc.dart';
import 'admirers_bloc/admirers_event.dart';
import 'admirers_bloc/admirers_state.dart';
import 'all_pages_admirers/likes/received.dart';
import 'all_pages_admirers/roses/rose_received.dart';
import 'all_pages_admirers/vip+/vip_received.dart';

class TopNavAdmirersScreen extends StatefulWidget {
  const TopNavAdmirersScreen({super.key});

  @override
  State<TopNavAdmirersScreen> createState() => _TopNavAdmirersScreenState();
}

class _TopNavAdmirersScreenState extends State<TopNavAdmirersScreen> {
  late PageController _pageController;
  final List<String> _tabKeys = ['likes', 'roses', 'vip'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdmirersBloc()..add(LoadAdmirersData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: BlocConsumer<AdmirersBloc, AdmirersState>(
            listener: (context, state) {
              if (state is AdmirersLoaded) {
                final index = _tabKeys.indexOf(state.activeTab);
                if (_pageController.hasClients) {
                  final currentIndex = _pageController.page?.round() ?? 0;
                  if (currentIndex != index) {
                    if ((currentIndex - index).abs() > 1) {
                      _pageController.jumpToPage(index);
                    } else {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                }
              }
            },
            builder: (context, state) {
              if (state is AdmirersLoading || state is AdmirersInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AdmirersLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: 2),
                    _buildTabs(context, state),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    // Dynamic content based on tab via PageView
                    Expanded(
                      child: Container(
                        color: const Color(0xFFFAFAFA),
                        child: CustomRefreshIndicator(
                              offsetToArmed: 80,
                              onRefresh: () async {
                                context.read<AdmirersBloc>().add(LoadAdmirersData());
                                await Future.delayed(const Duration(milliseconds: 1500)); // Smooth loading experience
                              },
                              notificationPredicate: (ScrollNotification notification) {
                                return notification.metrics.axis == Axis.vertical;
                              },
                              builder: (BuildContext context, Widget child, IndicatorController controller) {
                                return Stack(
                                  children: [
                                    child, // Keeps the list in place (does not push it far down)

                                    Positioned(
                                      top: -50 + (controller.value * 70), // Gently drops from just under the tabs
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: AnimatedBuilder(
                                          animation: controller,
                                          builder: (context, _) {
                                            // Smooth heartbeat effect
                                            double scale = controller.isDragging || controller.isArmed
                                                ? controller.value.clamp(0.0, 1.0)
                                                : (controller.isLoading ? 1.05 : 0.0);

                                            return Transform.scale(
                                              scale: scale,
                                              child: Container(
                                                height: 46,
                                                width: 46,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFFE85A7A).withOpacity(0.2),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ],
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    if (!controller.isIdle)
                                                      SizedBox(
                                                        width: 46,
                                                        height: 46,
                                                        child: CircularProgressIndicator(
                                                          value: controller.isLoading ? null : controller.value.clamp(0.0, 1.0),
                                                          strokeWidth: 2.5,
                                                          valueColor: const AlwaysStoppedAnimation(Color(0xFFE85A7A)),
                                                        ),
                                                      ),
                                                    const Text('🌹', style: TextStyle(fontSize: 20)),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  context.read<AdmirersBloc>().add(
                                    ChangeAdmirersTab(_tabKeys[index]),
                                  );
                                },
                                children: const [
                                  ReceivedLikesScreen(),
                                  ReceivedRosesScreen(),
                                  VipReceivedScreen(),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AdmirersLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Admi',
                        style: TextStyle(color: Color(0xFF1F1F1F)),
                      ),
                      TextSpan(
                        text: 'rers',
                        style: TextStyle(color: Color(0xFFE43A6A)), // Pink
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'People who like you — revealed ✨',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, AdmirersLoaded state) {
    final tabs = [
      {
        'label': '❤️Likes',
        'count': state.likesCount.toString(),
        'key': 'likes',
      },
      {
        'label': '🌹Roses',
        'count': state.rosesCount.toString(),
        'key': 'roses',
      },
      {'label': '👑VIP+', 'count': '', 'key': 'vip'},
    ];

    final int selectedIndex = _tabKeys.indexOf(state.activeTab);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double parentWidth = constraints.maxWidth;
          final double itemWidth = parentWidth / tabs.length;

          double indicatorWidth;
          if (selectedIndex == 0) {
            indicatorWidth = 90; // "❤️Likes 36"
          } else if (selectedIndex == 1) {
            indicatorWidth = 85; // "🌹Roses 3"
          } else {
            indicatorWidth = 60; // "👑VIP+"
          }

          double indicatorCenter =
              (selectedIndex * itemWidth) + (itemWidth / 2);

          return Stack(
            children: [
              Row(
                children: List.generate(tabs.length, (index) {
                  final tab = tabs[index];
                  final isActive = selectedIndex == index;
                  final textColor = isActive
                      ? const Color(0xFFE85A7A)
                      : Colors.grey.shade600;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<AdmirersBloc>().add(
                          ChangeAdmirersTab(tab['key']!),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tab['label']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            if (tab['count']!.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text(
                                tab['count']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE85A7A),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: 0,
                left: indicatorCenter - (indicatorWidth / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 3,
                  width: indicatorWidth,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE85A7A),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
