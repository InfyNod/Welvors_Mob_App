import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_bloc/commitment_bloc.dart';
import 'commitment_bloc/commitment_event.dart';
import 'commitment_bloc/commitment_state.dart';

class RequestsSection extends StatefulWidget {
  const RequestsSection({super.key});

  @override
  State<RequestsSection> createState() => _RequestsSectionState();
}

class _RequestsSectionState extends State<RequestsSection> {
  bool _isExpanded = false;

  static final List<Map<String, dynamic>> _requests = [
    {
      'name': 'Ananya',
      'age': '27',
      'timeText': 'Requested to go exclusive · 2 days ago',
      'intent': 'Serious relationship',
      'intentIcon': Icons.favorite_border,
      'intentColor': const Color(0xFFF2E6EA),
      'intentTextColor': const Color(0xFF8B6B78),
      'imageUrl':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'Meera',
      'age': '29',
      'timeText': 'Requested to go exclusive · 5 days ago',
      'intent': 'Dating to marry',
      'intentIcon': Icons.diamond_outlined,
      'intentColor': const Color(0xFFFDF6E3),
      'intentTextColor': const Color(0xFF9E6B17),
      'imageUrl':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'Priya',
      'age': '26',
      'timeText': 'Requested to go exclusive · 1 week ago',
      'intent': 'Dating to marry',
      'intentIcon': Icons.diamond_outlined,
      'intentColor': const Color(0xFFFDF6E3),
      'intentTextColor': const Color(0xFF9E6B17),
      'imageUrl':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
    },
    {
      'name': 'Neha',
      'age': '28',
      'timeText': 'Requested to go exclusive · 2 weeks ago',
      'intent': 'Serious relationship',
      'intentIcon': Icons.favorite_border,
      'intentColor': const Color(0xFFF2E6EA),
      'intentTextColor': const Color(0xFF8B6B78),
      'imageUrl':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // If not expanded, show up to 3 items
    final int displayCount = _isExpanded
        ? _requests.length
        : (_requests.length > 3 ? 3 : _requests.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E5D1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'REQUESTS RECEIVED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6A655F),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFD1DC,
                  ).withOpacity(0.5), // Soft pink bg
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_requests.length} PENDING',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC73A5E), // Pink text
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < displayCount; i++) ...[
            _buildRequestItem(
              name: _requests[i]['name'],
              age: _requests[i]['age'],
              timeText: _requests[i]['timeText'],
              intent: _requests[i]['intent'],
              intentIcon: _requests[i]['intentIcon'],
              intentColor: _requests[i]['intentColor'],
              intentTextColor: _requests[i]['intentTextColor'],
              imageUrl: _requests[i]['imageUrl'],
            ),
            if (i < displayCount - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Color(0xFFF0E5D1), height: 1),
              ),
          ],
          if (!_isExpanded && _requests.length > 3) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFF0E5D1), height: 1),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1DC).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'See more requests',
                      style: TextStyle(
                        color: Color(0xFFC73A5E),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFFC73A5E),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestItem({
    required String name,
    required String age,
    required String timeText,
    required String intent,
    required IconData intentIcon,
    required Color intentColor,
    required Color intentTextColor,
    required String imageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$name, $age',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: intentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(intentIcon, size: 10, color: intentTextColor),
                            const SizedBox(width: 4),
                            Text(
                              intent,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: intentTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8680),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE8DCD0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5F5C56),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showApproveBottomSheet(
                    context,
                    name,
                    intent,
                    imageUrl,
                    intentColor,
                    intentTextColor,
                    intentIcon,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(223, 44, 89, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showApproveBottomSheet(
    BuildContext context,
    String name,
    String intent,
    String imageUrl,
    Color intentColor,
    Color intentTextColor,
    IconData intentIcon,
  ) {
    final currentState = context.read<CommitmentBloc>().state;
    final String currentPartnerName =
        currentState is CommitmentLoaded ? currentState.partnerName : 'your partner';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DCD0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Go exclusive with $name?',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                'You\'re currently exclusive with $currentPartnerName. Accepting will end that first — $currentPartnerName is notified right away. No approval needed from anyone.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A655F),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<CommitmentBloc>().add(ApproveRequestEvent(
                    partnerName: name,
                    intent: intent,
                    imageUrl: imageUrl,
                    intentColor: intentColor,
                    intentTextColor: intentTextColor,
                    intentIcon: intentIcon,
                  ));
                  setState(() {
                    _requests.removeWhere((req) => req['name'] == name);
                  });
                },
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(223, 44, 89, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Go exclusive with $name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                },
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE8DCD0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: const SizedBox(height: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
