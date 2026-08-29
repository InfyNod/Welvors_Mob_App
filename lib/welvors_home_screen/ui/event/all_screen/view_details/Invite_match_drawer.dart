import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../service_event/event_api_service.dart';

void showInviteMatchDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const InviteMatchDrawerWidget();
    },
  );
}

class InviteMatchDrawerWidget extends StatefulWidget {
  const InviteMatchDrawerWidget({super.key});

  @override
  State<InviteMatchDrawerWidget> createState() => _InviteMatchDrawerWidgetState();
}

class _InviteMatchDrawerWidgetState extends State<InviteMatchDrawerWidget> {
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              const Text(
                'Invite a match 💌',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Meet at a verified venue — the safest way to take it offline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              // Green info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A7F58).withOpacity(0.3)),
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
                          style: TextStyle(fontSize: 12, color: Color(0xFF3A7F58), height: 1.4),
                          children: [
                            TextSpan(
                              text: 'Safe first meeting — ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "ID-verified guests, trained staff on site, and public venue. We'll notify you both on arrival.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Dynamic List of matches
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
                  ),
                )
              else if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                )
              else if (conversations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No matches found yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                ...conversations.map((conv) {
                  final user = conv['user'];
                  if (user == null) return const SizedBox.shrink();
                  
                  final name = user['fullName']?.toString().split(' ').first ?? 'User';
                  final age = user['age']?.toString() ?? '';
                  final nameAge = age.isNotEmpty ? '$name, $age' : name;
                  
                  final matchPercentage = user['matchPercentage'] ?? 0;
                  final subtitle = '$matchPercentage% Match';
                  final imageUrl = user['profilePhoto']?.toString() ?? 'https://via.placeholder.com/100';
                  final userId = user['id']?.toString() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildMatchTile(
                      nameAge, 
                      subtitle, 
                      imageUrl,
                      invitedMatches.contains(userId),
                      () => handleInvite(userId),
                    ),
                  );
                }),

              const SizedBox(height: 12),
              
              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
        
        // Custom Toast
        if (showToast)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 60,
            child: AnimatedOpacity(
              opacity: showToast ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Text(
                  "Invite sent 💌 They'll see event & venue details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMatchTile(String nameAge, String subtitle, String imageUrl, bool isInvited, VoidCallback onInvite) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameAge,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: isInvited ? null : onInvite,
          style: ElevatedButton.styleFrom(
            backgroundColor: isInvited ? const Color(0xFFE8F9F0) : const Color(0xFFE43A6A),
            foregroundColor: isInvited ? const Color(0xFF2CAF6B) : Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            minimumSize: const Size(80, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            disabledBackgroundColor: const Color(0xFFE8F9F0),
            disabledForegroundColor: const Color(0xFF2CAF6B),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInvited)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.check, size: 14),
                ),
              Text(
                isInvited ? 'Sent' : 'Invite',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isInvited ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
