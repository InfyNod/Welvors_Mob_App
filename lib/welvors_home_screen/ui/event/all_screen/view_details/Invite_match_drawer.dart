import 'package:flutter/material.dart';
import 'dart:async';

void showInviteMatchDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      Set<String> invitedMatches = {};
      bool showToast = false;
      Timer? toastTimer;

      return StatefulBuilder(
        builder: (context, setState) {
          
          void handleInvite(String matchId) {
            if (!invitedMatches.contains(matchId)) {
              setState(() {
                invitedMatches.add(matchId);
                showToast = true;
              });
              
              toastTimer?.cancel();
              toastTimer = Timer(const Duration(seconds: 3), () {
                if (context.mounted) {
                  setState(() {
                    showToast = false;
                  });
                }
              });
            }
          }

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
                                    text: 'ID-verified guests, trained staff on site, and public venue. We\'ll notify you both on arrival.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // List of matches
                    _buildMatchTile(
                      'Aanya, 25', 
                      '92% Match · Chatting since Oct 2', 
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
                      invitedMatches.contains('aanya'),
                      () => handleInvite('aanya'),
                    ),
                    const SizedBox(height: 20),
                    _buildMatchTile(
                      'Elena, 23', 
                      '95% Match · Chatting since Sep 18', 
                      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=100&q=80',
                      invitedMatches.contains('elena'),
                      () => handleInvite('elena'),
                    ),
                    const SizedBox(height: 20),
                    _buildMatchTile(
                      'Chloe, 26', 
                      '88% Match · New match', 
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
                      invitedMatches.contains('chloe'),
                      () => handleInvite('chloe'),
                    ),
                    const SizedBox(height: 32),
                    
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
                        'Invite sent 💌 They\'ll see event & venue details',
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
        },
      );
    },
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
        child: Text(
          isInvited ? 'Invited ✓' : 'Invite',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
