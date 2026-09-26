import '../../../export.dart';

class ConsentCheckbox extends StatelessWidget {
  final bool accepted;
  final VoidCallback onTap;

  const ConsentCheckbox({super.key, required this.accepted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE72B7A), width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accepted ? const Color(0xFFE72B7A) : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFE72B7A), width: 2),
              ),
              child: accepted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Text(
                'I consent to DigiLocker sharing the above with Welvors.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF29242D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
