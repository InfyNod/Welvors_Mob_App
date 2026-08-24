import '../../export.dart';

class FaceVerificationScreen extends StatelessWidget {
  FaceVerificationScreen({super.key});

  final GlobalKey<AnimatedDottedCircleState> imageKey =
      GlobalKey<AnimatedDottedCircleState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolor.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
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
        centerTitle: true,
        title: const Text(
          "Face Verification",
          style: TextStyle(fontWeight: FontWeight.bold, color: Mycolor.black),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: BottomButton(
          shadowColor: Mycolor.redshadow,
          colors: [Mycolor.pink, Mycolor.pink1],
          title: '📷 Capture Selfie',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FaceVerifiedScreen()),
            );
          },
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Mycolor.creamlight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "🤳 Take a quick selfie. We auto-match it against your Government ID photo — nothing is shared.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Mycolor.pink3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                hSized30,

                AnimatedDottedCircle(key: imageKey),

                const SizedBox(height: 40),

                const Text(
                  "Position your face in the circle",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xff24222D),
                  ),
                ),

                const SizedBox(height: 24),

                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    GuideChip(title: "Good lighting"),
                    GuideChip(title: "No sunglasses"),
                    GuideChip(title: "Look straight"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
