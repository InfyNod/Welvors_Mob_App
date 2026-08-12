import '../../../export.dart';

class ConsentHeader extends StatelessWidget {
  const ConsentHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFFAF5), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFBDEBD5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏛️', style: TextStyle(fontSize: 30)),

              const SizedBox(width: 16),

              const Text(
                '→',
                style: TextStyle(fontSize: 20, color: Color(0xFF9A9298)),
              ),

              const SizedBox(width: 16),

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE83B91), Color(0xFFC91660)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('💕', style: TextStyle(fontSize: 30)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'DigiLocker consent',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF242129),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Welvors is requesting access to your Aadhaar\n'
            'issued by UIDAI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF686169),
            ),
          ),
        ],
      ),
    );
  }
}
