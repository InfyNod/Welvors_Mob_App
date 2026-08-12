import '../../../export.dart';

class TrustScoreCardFace extends StatelessWidget {
  final int score;

  const TrustScoreCardFace({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final progress = score / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Mycolor.pink, Mycolor.pink1],
        ),
      ),
      child: Column(
        children: [
          const Text(
            "YOUR TRUST SCORE",
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          hSized3,

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$score",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "/100",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          hSized10,

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Mycolor.grey1,
              valueColor: const AlwaysStoppedAnimation(Color(0xffe11d74)),
            ),
          ),

          hSized10,

          const Text(
            "+ Updated instantly",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
