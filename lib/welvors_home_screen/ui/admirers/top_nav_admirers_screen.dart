import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admirers_bloc/admirers_bloc.dart';
import 'admirers_bloc/admirers_event.dart';
import 'admirers_bloc/admirers_state.dart';
import 'all_pages_admirers/likes/received.dart';
import 'all_pages_admirers/roses/rose_received.dart';

class TopNavAdmirersScreen extends StatelessWidget {
  const TopNavAdmirersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdmirersBloc()..add(LoadAdmirersData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: BlocBuilder<AdmirersBloc, AdmirersState>(
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
                    // Dynamic content based on tab
                    Expanded(
                      child: Container(
                        color: const Color(0xFFFAFAFA),
                        child: _buildTabContent(state),
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

  Widget _buildTabContent(AdmirersLoaded state) {
    switch (state.activeTab) {
      case 'likes':
        return const ReceivedLikesScreen();
      case 'roses':
        return const ReceivedRosesScreen();
      case 'vip':
        return const Center(child: Text('VIP+ Content Coming Soon'));
      default:
        return const SizedBox();
    }
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
        'label': '❤️ Likes',
        'count': state.likesCount.toString(),
        'key': 'likes',
      },
      {
        'label': '🌹 Roses',
        'count': state.rosesCount.toString(),
        'key': 'roses',
      },
      {'label': '👑 VIP+', 'count': '', 'key': 'vip'},
    ];

    final int selectedIndex = [
      'likes',
      'roses',
      'vip',
    ].indexOf(state.activeTab);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double parentWidth = constraints.maxWidth;
          final double itemWidth = parentWidth / tabs.length;

          double indicatorWidth;
          if (selectedIndex == 0) {
            indicatorWidth = 70; // "❤️ Likes 36"
          } else if (selectedIndex == 1) {
            indicatorWidth = 65; // "🌹 Roses 3"
          } else {
            indicatorWidth = 60; // "👑 VIP+"
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
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE85A7A),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85A7A),
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
