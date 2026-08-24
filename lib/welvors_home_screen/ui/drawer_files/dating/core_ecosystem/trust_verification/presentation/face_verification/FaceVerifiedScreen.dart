import '../../export.dart';
import 'widget/TrustScoreCard.dart';

class FaceVerifiedScreen extends StatelessWidget {
  const FaceVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // const Spacer(flex: 1),
              hSized60,

              /// Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xffDDF3EA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xff2FA366),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Face verified",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff252232),
                ),
              ),

              const SizedBox(height: 18),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Your selfie matched your Government ID with high confidence. This is a real, live person — verified.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xff66626F),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const TrustScoreCardFace(score: 25),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      (route) =>
                          route.settings.name == '/TrustVerificationScreen',
                    );
                  },

                  label: const Text(
                    "← Back to Trust Centre",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Mycolor.blueback,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              hSized15,
            ],
          ),
        ),
      ),
    );
  }
}
