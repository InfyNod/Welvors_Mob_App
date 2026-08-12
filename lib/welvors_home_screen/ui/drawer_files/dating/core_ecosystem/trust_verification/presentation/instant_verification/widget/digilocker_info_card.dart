import '../../../export.dart';

class DigiLockerInfoCard extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? subtitle;

  const DigiLockerInfoCard({super.key, this.icon, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Mycolor.greenlightdigilocekr, Mycolor.greenlightdigilocker1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBDEBD5)),
      ),
      child: Column(
        children: [
          Text(icon ?? "", style: TextStyle(fontSize: 55)),
          // Lottie.asset(Apiserver.lottie, repeat: true, fit: BoxFit.contain),
          const SizedBox(height: 12),

          Text(
            // 'Connect DigiLocker',
            title ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF242129),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            subtitle ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
