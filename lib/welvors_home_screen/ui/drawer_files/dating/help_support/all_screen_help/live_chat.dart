import 'package:flutter/material.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _messages = [
    {
      'isSender': false,
      'text': "Hi! 👋 I'm Welvors Support. What can I\nhelp you with today?",
    }
  ];

  List<String> _currentChips = [
    'Account issue',
    'Payment / refund',
    'Report someone',
    'Something else'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Chat',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Support Profile Info
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE43A6A), // Pink background
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        Positioned(
                          top: 10,
                          child: Icon(
                            Icons.more_horiz,
                            color: Color(0xFFE43A6A),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welvors Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Online · typically replies in 2 min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Chat Message Bubbles
                  ..._messages.map((msg) => _buildMessageBubble(msg)).toList(),
                ],
              ),
            ),
          ),
          
          // Bottom Action Section
          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Action Chips (horizontal scroll)
                if (_currentChips.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _currentChips.map((label) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildChip(label),
                        );
                      }).toList(),
                    ),
                  ),
                if (_currentChips.isNotEmpty) const SizedBox(height: 16),
                
                // Input Field
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement send message
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE85A7A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ), // Close SafeArea
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isSender = msg['isSender'];
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSender ? null : const Color(0xFFF6F7F9),
          gradient: isSender
              ? const LinearGradient(
                  colors: [Color(0xFFE43A6A), Color(0xFFFA6A85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSender ? 16 : 4),
            bottomRight: Radius.circular(isSender ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: isSender 
                  ? const Color(0xFFE43A6A).withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg['text'],
          style: TextStyle(
            fontSize: 14,
            color: isSender ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  void _onChipTapped(String label) {
    setState(() {
      _messages.add({'isSender': true, 'text': label});
      _currentChips.clear(); // Hide current chips
    });

    // Simulate bot reply based on selection
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          if (label == 'Account issue') {
            _messages.add({
              'isSender': false,
              'text': "For account & login issues, try resetting your password or signing in with your linked number. Want me to connect you to an agent?"
            });
            _currentChips = ['Connect to agent', 'Raise a ticket', 'No, thanks'];
          } else {
            _messages.add({
              'isSender': false,
              'text': "Thanks for letting us know. Let me connect you to an agent who can help with this."
            });
            _currentChips = ['Connect to agent', 'Nevermind'];
          }
        });
      }
    });
  }

  Widget _buildChip(String label) {
    return GestureDetector(
      onTap: () => _onChipTapped(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F3), // Light pink background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE43A6A).withOpacity(0.5), width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE43A6A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
