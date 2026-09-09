import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'commitment_bloc/commitment_bloc.dart';
import 'commitment_bloc/commitment_event.dart';

class EndStatusBody extends StatelessWidget {
  final String partnerName;
  final String userName; // 'Rahul' as per design

  const EndStatusBody({
    super.key,
    required this.partnerName,
    this.userName = 'You', // Fallback name
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Icon
                Transform.translate(
                  offset: const Offset(-15, 0),
                  child: Lottie.asset(
                    'assets/Love_blind.json',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 2),
                // Title
                const Text(
                  "You're open to matches\nagain.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Your status is updated and $partnerName has been\nnotified. Take your time.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A655F),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                // What Partner Receives Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'WHAT ${partnerName.toUpperCase()} RECEIVES',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8A8680),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Notification Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8DCD0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(227, 58, 105, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$userName ended your exclusive status',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your profile is open to matches again.\nNotified just now.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A8680),
                                height: 1.4,
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
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: GestureDetector(
              onTap: () {
                context.read<CommitmentBloc>().add(BackToManagementRequested());
              },
              child: Container(
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(223, 44, 89, 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Back to management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
