import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admirers_bloc/admirers_bloc.dart';
import '../../admirers_bloc/admirers_event.dart';
import '../../admirers_bloc/admirers_state.dart';
import 'rose_send.dart';

class ReceivedRosesScreen extends StatefulWidget {
  const ReceivedRosesScreen({super.key});

  @override
  State<ReceivedRosesScreen> createState() => _ReceivedRosesScreenState();
}

class _ReceivedRosesScreenState extends State<ReceivedRosesScreen> {
  int _selectedTab = 0; // 0 for Received, 1 for Sent

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<Map<String, dynamic>> _roseCards = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final bloc = context.read<AdmirersBloc>();
      if (bloc.state is AdmirersLoaded) {
        _roseCards = List.from((bloc.state as AdmirersLoaded).roses);
      }
      _isInitialized = true;
    }
  }

  void _handleAction(dynamic id, String popupText, {bool isAccepted = true}) {
    final index = _roseCards.indexWhere((card) => card['id'] == id);
    if (index >= 0) {
      final removedCard = _roseCards.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(removedCard, animation, isAccepted: isAccepted),
        duration: const Duration(milliseconds: 600),
      );
      // Dispatch to BLoC to update the tab count
      context.read<AdmirersBloc>().add(RemoveRose(id));
      setState(() {});
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                popupText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 16),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggle(),
          const SizedBox(height: 16),
          _selectedTab == 0 ? _buildReceivedContent() : const RoseSendScreen(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReceivedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 16),
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: _roseCards.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(_roseCards[index], animation);
            },
          ),
          if (_roseCards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No more roses',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> card, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRoseCard(
            id: card['id'],
            name: card['name'],
            age: card['age'],
            distance: card['distance'],
            message: card['message'],
            imageUrl: card['imageUrl'],
          ),
        ),
      ),
    );
  }

  Widget _buildRemovedItem(Map<String, dynamic> card, Animation<double> animation, {bool isAccepted = true}) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1.0),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isAccepted ? 1.5 : -1.5, 0), // slides out right if accepted, left if rejected
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInBack, // snapping effect
          )),
          child: RotationTransition(
            turns: Tween<double>(begin: isAccepted ? 0.05 : -0.05, end: 0.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            )),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRoseCard(
                id: card['id'],
                name: card['name'],
                age: card['age'],
                distance: card['distance'],
                message: card['message'],
                imageUrl: card['imageUrl'],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
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
                    borderRadius: BorderRadius.circular(8),
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF4), // rgba(255, 239, 244)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌹', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFFE85A7A), // pink text
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Roses are always visible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' — these people really want to meet you. They get 3× more matches.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoseCard({
    required dynamic id,
    required String name,
    required String age,
    required String distance,
    required String message,
    required String imageUrl,
  }) {

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFFFF0F5),
          ], // white to soft pink gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF8C6D1), // rgba(248, 198, 209)
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8C6D1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image with Rose Icon
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 72,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Square with rounded corners
                    border: Border.all(
                      color: const Color(0xFFF8C6D1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFE85A7A,
                        ).withOpacity(0.4), // Pink glow
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text('🌹', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Card Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE85A7A), // Pink background
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🌹', style: TextStyle(fontSize: 8)),
                            SizedBox(width: 4),
                            Text(
                              'SENT YOU A ROSE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Name, Age, Distance
                      Text(
                        '$name, $age · $distance',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                  children: [
                    // Like Back Button
                    GestureDetector(
                      onTap: () {
                        _handleAction(id, "It's a match! 💖", isAccepted: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, // Increased horizontal padding
                          vertical: 10, // Increased height
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE85A7A), // Pink for Like back
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE85A7A,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '❤️',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Like back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Reject Button
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        _handleAction(id, "Rejected ❌", isAccepted: false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10, // Increased height
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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
