import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admirers_bloc/admirers_bloc.dart';
import 'admirers_bloc/admirers_event.dart';
import 'admirers_bloc/admirers_state.dart';
import 'all_pages_admirers/likes/received.dart';
import 'all_pages_admirers/likes/sent.dart';

class TopNavAdmirersScreen extends StatefulWidget {
  const TopNavAdmirersScreen({super.key});

  @override
  State<TopNavAdmirersScreen> createState() => _TopNavAdmirersScreenState();
}

class _TopNavAdmirersScreenState extends State<TopNavAdmirersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabKeys = ['received', 'sent'];

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    final state = context.read<AdmirersBloc>().state;
    if (state is AdmirersLoaded) {
      initialIndex = _tabKeys.indexOf(state.activeTab);
      if (initialIndex == -1) initialIndex = 0;
    }
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<AdmirersBloc>().add(
          ChangeAdmirersTab(_tabKeys[_tabController.index]),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocConsumer<AdmirersBloc, AdmirersState>(
          listener: (context, state) {
            if (state is AdmirersLoaded) {
              final index = _tabKeys.indexOf(state.activeTab);
              if (index != -1 && _tabController.index != index) {
                _tabController.animateTo(index);
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
                  _buildTabBar(state),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  // Dynamic content based on tab via TabBarView
                  Expanded(
                    child: Container(
                      color: const Color(0xFFFAFAFA),
                      child: RefreshIndicator(
                        color: const Color(0xFFE43A6A),
                        onRefresh: () async {
                          context.read<AdmirersBloc>().add(LoadAdmirersData());
                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );
                        },
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: const [
                            ReceivedLikesScreen(),
                            SentLikesScreen(),
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
    );
  }

  Widget _buildHeader(AdmirersLoaded state) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 0),
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

  Widget _buildTabBar(AdmirersLoaded state) {
    return TabBar(
      controller: _tabController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      indicatorColor: const Color(0xFFE43A6A),
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent, // Hides default grey bottom line
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      physics: const BouncingScrollPhysics(),
      tabs: [
        _buildTab('Received', state.likesCount, 0),
        _buildTab('Sent', state.sentLikes.length, 1),
      ],
    );
  }

  Widget _buildTab(String title, int count, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isSelected = _tabController.index == index;
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE43A6A) : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE43A6A)
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
