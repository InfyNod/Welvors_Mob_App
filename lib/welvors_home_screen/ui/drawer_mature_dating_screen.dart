import 'package:flutter/material.dart';

class MatureDatingScreen extends StatefulWidget {
  const MatureDatingScreen({Key? key}) : super(key: key);

  @override
  State<MatureDatingScreen> createState() => _MatureDatingScreenState();
}

class _MatureDatingScreenState extends State<MatureDatingScreen> {
  bool _isNotified = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with Glow
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow Effect
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF673AB7).withOpacity(0.15),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
                // Gradient Icon Background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3F51B5), // Indigo
                        Color(0xFF9C27B0), // Purple
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.workspace_premium, // Elegant icon for Mature Dating
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Coming Soon Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6), // Light purple background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD1C4E9), width: 1.5),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(
                  color: Color(0xFF673AB7), // Deep purple text
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Mature Dating',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'A refined space for 40+ singles seeking\nmeaningful companionship — with age-\nverified profiles, slower-paced matching and\nprivacy-first controls. Coming soon.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Notify me Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isNotified ? null : const Color(0xFF1E1E1E),
                gradient: _isNotified
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3F51B5), // Indigo
                          Color(0xFF9C27B0), // Purple
                        ],
                      )
                    : null,
                boxShadow: _isNotified
                    ? [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isNotified = !_isNotified;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  _isNotified ? Icons.notifications_active : Icons.notifications_none,
                  size: 24,
                ),
                label: Text(
                  _isNotified ? 'Notified!' : 'Notify me at launch',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
