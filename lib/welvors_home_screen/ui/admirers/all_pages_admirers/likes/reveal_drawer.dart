import 'package:flutter/material.dart';

void showRevealDrawer(
  BuildContext context, {
  required String matchPercent,
  required VoidCallback onReveal,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        RevealDrawer(matchPercent: matchPercent, onReveal: onReveal),
  );
}

class RevealDrawer extends StatelessWidget {
  final String matchPercent;
  final VoidCallback onReveal;

  const RevealDrawer({
    super.key,
    required this.matchPercent,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 14),

          // Eye Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3E2), // Light orange/yellow background
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFDE4C3), width: 4),
            ),
            child: const Text('👁️', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'Reveal this admirer?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Someone with a '),
                TextSpan(
                  text: '$matchPercent Match ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(text: 'likes you. Spend '),
                const TextSpan(
                  text: '50 coins ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(text: 'to see who it is — then like them back.'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cost Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('🪙', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Reveal cost',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9E6515), // Darker text for contrast
                      ),
                    ),
                  ],
                ),
                Text(
                  '50 coins',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9E6515),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Balance
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              children: const [
                TextSpan(text: 'Your balance: '),
                TextSpan(
                  text: '1,280 coins',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reveal Button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onReveal();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBB538), Color(0xFFF99E22)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ), // Made it square-ish with 16 radius

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBB538).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🪙', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Reveal for 50 coins',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Maybe later
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Maybe later',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
