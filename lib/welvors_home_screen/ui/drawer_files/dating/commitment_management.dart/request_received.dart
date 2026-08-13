import 'package:flutter/material.dart';

class RequestsSection extends StatefulWidget {
  const RequestsSection({super.key});

  @override
  State<RequestsSection> createState() => _RequestsSectionState();
}

class _RequestsSectionState extends State<RequestsSection> {
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _requests = [
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
    }
  ];

  @override
  Widget build(BuildContext context) {
    // If not expanded, show up to 3 items
    final int displayCount =
        _isExpanded ? _requests.length : (_requests.length > 3 ? 3 : _requests.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1DC).withOpacity(0.5), // Soft pink bg
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
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'See more',
                    style: TextStyle(
                      color: Color(0xFFC73A5E),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
            CircleAvatar(radius: 22, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name, $age',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8680),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: intentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(intentIcon, size: 12, color: intentTextColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            intent,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: intentTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE8DCD0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 13,
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
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(223, 44, 89, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontSize: 13,
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
}
