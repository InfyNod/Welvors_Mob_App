import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import '../service_event/event_api_service.dart';

class InviteMatchScreen extends StatefulWidget {
  const InviteMatchScreen({super.key});

  @override
  State<InviteMatchScreen> createState() => _InviteMatchScreenState();
}

class _InviteMatchScreenState extends State<InviteMatchScreen> {
  Set<String> invitedMatches = {};
  bool showToast = false;
  Timer? toastTimer;

  bool isLoading = true;
  List<dynamic> conversations = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  @override
  void dispose() {
    toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMatches() async {
    try {
      final data = await EventApiService.getChatConversations();

      if (data != null && data['success'] == true) {
        setState(() {
          conversations = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load matches';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading matches';
        isLoading = false;
      });
    }
  }

  void handleInvite(String matchId) {
    if (!invitedMatches.contains(matchId)) {
      setState(() {
        invitedMatches.add(matchId);
        showToast = true;
      });

      toastTimer?.cancel();
      toastTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showToast = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color.fromARGB(255, 250, 124, 135), Color(0xFFE43A6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Invite a match',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white, // Required for ShaderMask
              shadows: [Shadow(color: Color(0x33E43A6A), blurRadius: 8)],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Subtitle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F7), // Soft pink background
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE43A6A).withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified, color: Color(0xFFE43A6A), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(text: 'Meet at a '),
                                      TextSpan(
                                        text: 'verified venue',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFE43A6A),
                                        ),
                                      ),
                                      TextSpan(text: ' — the safest way to take it offline.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Dynamic List of matches
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE43A6A),
                              ),
                            ),
                          )
                        else if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        else if (conversations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: Text(
                                'No matches found yet.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        else
                          ...conversations.map((conv) {
                            final user = conv['user'];
                            if (user == null) return const SizedBox.shrink();

                            final name =
                                user['fullName']?.toString().split(' ').first ??
                                'User';
                            final age = user['age']?.toString() ?? '';
                            final nameAge = age.isNotEmpty
                                ? '$name, $age'
                                : name;

                            final matchPercentage =
                                user['matchPercentage'] ?? 0;
                            final subtitle = '$matchPercentage% Match';
                            final imageUrl =
                                user['profilePhoto']?.toString() ??
                                'https://via.placeholder.com/100';
                            final userId = user['id']?.toString() ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildMatchTile(
                                nameAge,
                                subtitle,
                                imageUrl,
                                invitedMatches.contains(userId),
                                () => handleInvite(userId),
                              ),
                            );
                          }),
                        const SizedBox(height: 10),
                        // Green info box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F9F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF3A7F58).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.security,
                                color: Color(0xFF3A7F58),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF3A7F58),
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Safe first meeting — ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "ID-verified guests, trained staff on site, and public venue. We'll notify you both on arrival.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Custom Toast
          if (showToast)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: showToast ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2CAF6B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Invite sent",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchTile(
    String nameAge,
    String subtitle,
    String imageUrl,
    bool isInvited,
    VoidCallback onInvite,
  ) {
    return Row(
      children: [
        CircleAvatar(radius: 26, backgroundImage: NetworkImage(imageUrl)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameAge,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: isInvited ? null : onInvite,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: isInvited
                  ? null
                  : const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 251, 141, 150),
                        Color(0xFFE43A6A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isInvited ? const Color(0xFFE8F9F0) : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isInvited
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFFE43A6A).withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
              border: isInvited
                  ? Border.all(color: const Color(0xFF2CAF6B).withOpacity(0.3))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isInvited)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Color(0xFF2CAF6B),
                    ),
                  ),
                Text(
                  isInvited ? 'Sent' : 'Invite',
                  style: TextStyle(
                    fontSize: 13,
                    color: isInvited ? const Color(0xFF2CAF6B) : Colors.white,
                    fontWeight: isInvited ? FontWeight.w800 : FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
